import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/runtime_state_repository.dart';
import 'package:sinew/core/db/repositories/timer_preset_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/core/platform/platform_channel.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/engines/timer/timer_engine.dart';
import 'package:sinew/features/timer/controller/timer_presets_provider.dart';
import 'package:sinew/features/timer/controller/timer_session.dart';
import 'package:sinew/features/timer/data/active_timer.dart';
import 'package:sinew/features/timer/data/timer_presets.dart';
import 'package:sinew/features/timer/services/cue_player_impl.dart';
import 'package:sinew/features/timer/services/service_protocol.dart';
import 'package:sinew/features/timer/services/timer_task_handler.dart';
import 'package:sinew/core/theme/tokens.dart';

import 'timer_harness.dart';

/// Fakes the native cue channel and records every call.
class _CueChannel {
  _CueChannel(this.ringer);

  String ringer;
  final List<String> calls = <String>[];

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SinewCues.channel, (MethodCall call) async {
          final Object? args = call.arguments;
          switch (call.method) {
            case 'ringerMode':
              return ringer;
            case 'load':
              calls.add('load');
              return true;
            case 'play':
              calls.add('play:${(args as Map<Object?, Object?>)['name']}');
              return true;
            case 'speak':
              calls.add('speak:${(args as Map<Object?, Object?>)['text']}');
              return true;
            case 'vibrate':
              calls.add('vibrate');
              return null;
          }
          return null;
        });
  }

  void remove() => TestDefaultBinaryMessengerBinding
      .instance
      .defaultBinaryMessenger
      .setMockMethodCallHandler(SinewCues.channel, null);
}

CueEvent _event(CueKind kind, int atMs) => CueEvent(
  kind: kind,
  atMs: atMs,
  stepIndex: 0,
  text: 'Go',
  sound: true,
  haptic: true,
  voice: true,
);

class _Ops implements TimerServiceOps {
  final List<String> log = <String>[];

  @override
  Future<void> wakeLock({required bool on}) async => log.add('wake:$on');

  @override
  Future<void> updateNotification(
    NotificationContent c, {
    Duration? tick,
  }) async => log.add('notify:${tick?.inMilliseconds}');

  @override
  Future<void> saveState(String json) async => log.add('save');

  @override
  Future<void> sendStateToApp(String json) async => log.add('toApp');

  @override
  void sendFinishedToApp() => log.add('finished');

  @override
  Future<void> stop({required bool keepState}) async =>
      log.add('stop:keep=$keepState');
}

void main() {
  group('native cue channel', () {
    late _CueChannel channel;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      channel = _CueChannel('normal')..install();
    });
    tearDown(() => channel.remove());

    test('normal ringer: sound, vibration and voice', () async {
      final PlatformCuePlayer p = PlatformCuePlayer();
      await p.play(_event(CueKind.phaseStart, 0), const TimerCues(voice: true));
      expect(
        channel.calls,
        containsAll(<String>['vibrate', 'play:go', 'speak:Go']),
      );
    });

    test('silent ringer: haptic only', () async {
      channel.ringer = 'silent';
      final PlatformCuePlayer p = PlatformCuePlayer();
      await p.play(_event(CueKind.phaseStart, 0), const TimerCues(voice: true));
      expect(channel.calls, <String>['vibrate']);
    });

    test('vibrate ringer: haptic only', () async {
      channel.ringer = 'vibrate';
      final PlatformCuePlayer p = PlatformCuePlayer();
      await p.play(_event(CueKind.finish, 0), const TimerCues(voice: true));
      expect(channel.calls, <String>['vibrate']);
    });

    test('the global haptics switch silences the vibration', () async {
      final PlatformCuePlayer p = PlatformCuePlayer(
        hapticsEnabled: () => false,
      );
      await p.play(_event(CueKind.phaseStart, 0), const TimerCues());
      expect(channel.calls, isNot(contains('vibrate')));
      expect(channel.calls, contains('play:go'));
    });
  });

  group('stale cues', () {
    test('phase starts and the finish survive 3 s, ticks only 1 s', () {
      expect(staleLimitMs(CueKind.countdown), TimerTiming.staleCueMs);
      expect(staleLimitMs(CueKind.warning), TimerTiming.staleCueMs);
      expect(staleLimitMs(CueKind.phaseStart), TimerTiming.staleLongCueMs);
      expect(staleLimitMs(CueKind.finish), TimerTiming.staleLongCueMs);
      final TimerRun run = TimerRun.start(
        compile(const CountdownConfig(durationSec: 10, prepareSec: 0)),
        0,
        mode: TimerMode.countdown,
      );
      // The finish is due at 10 s; looked at 2.5 s late it is still played.
      final List<CueEvent> late = dueCues(
        run,
        const TimerCues(),
        lastCueMs: 0,
        nowMs: 12500,
      );
      expect(late.map((CueEvent e) => e.kind), contains(CueKind.finish));
      // The 3 s tick (at 7 s) is long gone and dropped.
      expect(
        late.map((CueEvent e) => e.kind),
        isNot(contains(CueKind.countdown)),
      );
    });
  });

  group('session', () {
    late TimerKit kit;
    ProviderContainer? c;

    setUp(() {
      kit = TimerKit();
    });

    tearDown(() async {
      c?.dispose();
      await kit.db.close();
    });

    test('a paused run cancels the ticker, resume starts it', () async {
      c = kit.container();
      await c!.read(timerSessionProvider.future);
      final TimerSession s = c!.read(timerSessionProvider.notifier);
      await s.start(const TabataConfig(), title: 'T');
      expect(s.tickerActive, isTrue);
      s.togglePause();
      await s.flush();
      expect(s.tickerActive, isFalse);
      kit.clock.advance(const Duration(seconds: 5));
      s.togglePause();
      await s.flush();
      expect(s.tickerActive, isTrue);
    });

    test('new timers take their cues from Settings', () async {
      kit.settings = const AppSettings(
        timerSound: false,
        timerHaptic: false,
        timerVoice: true,
      );
      c = kit.container();
      await c!.read(timerSessionProvider.future);
      final TimerSession s = c!.read(timerSessionProvider.notifier);
      await s.start(const BoxingConfig(), title: 'B');
      final TimerCues cues = s.active!.cues;
      expect(cues.sound, isFalse);
      expect(cues.haptic, isFalse);
      expect(cues.voice, isTrue);
      expect(cues.warningSec, 10, reason: 'the mode keeps its own warning');
    });

    test('the service gets the haptics switch inside the cues', () async {
      kit.settings = const AppSettings(haptics: false);
      c = kit.container();
      await c!.read(timerSessionProvider.future);
      await c!
          .read(timerSessionProvider.notifier)
          .start(const TabataConfig(), title: 'T');
      expect(kit.host.cuesShown.single.haptic, isFalse);
    });

    test('built-in presets are seeded with the Settings cues', () async {
      kit.settings = const AppSettings(timerSound: false);
      c = kit.container();
      await c!.read(timerPresetSeedProvider.future);
      final List<TimerPreset> all = await c!
          .read(timerPresetRepositoryProvider)
          .all();
      expect(all, hasLength(5));
      expect(all.every((TimerPreset p) => !p.cues.sound), isTrue);
    });

    test('the seed leaves an unreadable newer preset alone', () async {
      const String payload = '{"schemaVersion":99,"future":true}';
      await kit.db
          .into(kit.db.timerPresets)
          .insert(
            TimerPresetsCompanion.insert(
              id: BuiltInPresetIds.tabata,
              name: 'Tabata from the future',
              mode: TimerMode.tabata,
              payload: payload,
              updatedAt: DateTime.utc(2030),
            ),
          );
      final TimerPresetRepository repo = TimerPresetRepository(kit.db);
      expect(await repo.byId(BuiltInPresetIds.tabata), isNull);
      expect(await repo.exists(BuiltInPresetIds.tabata), isTrue);
      await seedBuiltInPresets(
        presets: repo,
        state: RuntimeStateRepository(kit.db),
        now: DateTime.utc(2026),
      );
      final TimerPresetRow row = await (kit.db.select(
        kit.db.timerPresets,
      )..where((t) => t.id.equals(BuiltInPresetIds.tabata))).getSingle();
      expect(row.payload, payload);
      expect((await repo.all()), hasLength(4));
      c = kit.container();
    });
  });

  group('service handler', () {
    final TimerRun running = TimerRun.start(
      compile(const TabataConfig(prepareSec: 0)),
      1000,
      mode: TimerMode.tabata,
    );

    ActiveTimer timer(TimerRun r) => ActiveTimer(
      run: r,
      cues: const TimerCues(),
      title: 'T',
      updatedAtMs: 1000,
    );

    Future<TimerTaskHandler> handler(_Ops ops, int Function() now) async {
      final TimerTaskHandler h = TimerTaskHandler(ops: ops, nowMs: now);
      return h;
    }

    test('running holds the wake lock and the fast repeat', () async {
      final _Ops ops = _Ops();
      final TimerTaskHandler h = await handler(ops, () => 2000);
      h.onReceiveData(stateMessage(encodeState(timer(running))));
      await Future<void>.delayed(Duration.zero);
      expect(h.counting, isTrue);
      expect(ops.log, containsAllInOrder(<String>['wake:true', 'notify:250']));
    });

    test('pausing drops the wake lock and slows the repeat', () async {
      final _Ops ops = _Ops();
      final TimerTaskHandler h = await handler(ops, () => 2000);
      h.onReceiveData(stateMessage(encodeState(timer(running))));
      await Future<void>.delayed(Duration.zero);
      ops.log.clear();
      h.onReceiveData(stateMessage(encodeState(timer(running.pause(3000)))));
      await Future<void>.delayed(Duration.zero);
      expect(h.counting, isFalse);
      expect(ops.log, contains('wake:false'));
      expect(ops.log, contains('notify:5000'));
    });

    test('20 minutes paused stops the service but keeps the run', () async {
      final _Ops ops = _Ops();
      int now = 3000;
      final TimerTaskHandler h = await handler(ops, () => now);
      h.onReceiveData(stateMessage(encodeState(timer(running.pause(3000)))));
      await Future<void>.delayed(Duration.zero);
      now = 3000 + const Duration(minutes: 19).inMilliseconds;
      h.tick();
      expect(ops.log.where((String e) => e.startsWith('stop')), isEmpty);
      now = 3000 + const Duration(minutes: 20).inMilliseconds;
      h.tick();
      await Future<void>.delayed(Duration.zero);
      expect(ops.log, contains('stop:keep=true'));
    });
  });
}
