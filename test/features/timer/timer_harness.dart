import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/app.dart';
import 'package:sinew/core/db/library/library_installer.dart';
import 'package:sinew/core/db/repositories/runtime_state_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/wallpaper_seed.dart';
import 'package:sinew/engines/timer/timer_engine.dart';
import 'package:sinew/features/timer/api/timer_api.dart';
import 'package:sinew/features/timer/controller/timer_bootstrap.dart';
import 'package:sinew/features/timer/controller/timer_session.dart';
import 'package:sinew/features/timer/data/active_timer.dart';
import 'package:sinew/features/timer/services/foreground_host.dart';

import '../../helpers/test_db.dart';

/// A clock the test moves by hand (epoch ms).
class FakeClock {
  FakeClock([this.nowMs = 1700000000000]);

  int nowMs;

  int call() => nowMs;

  void advance(Duration d) => nowMs += d.inMilliseconds;
}

/// Settings the kit serves without touching preferences.
class _FixedSettings extends SettingsController {
  _FixedSettings(this._settings);

  final AppSettings _settings;

  @override
  AppSettings build() => _settings;
}

class FakeCuePlayer implements CuePlayer {
  final List<CueEvent> events = <CueEvent>[];

  @override
  Future<void> play(CueEvent event, TimerCues cues) async {
    events.add(event);
  }

  List<CueKind> get kinds => <CueKind>[for (final CueEvent e in events) e.kind];
}

class FakeHost implements BackgroundTimerHost {
  final List<({TimerRun run, String title})> shown =
      <({TimerRun run, String title})>[];
  final List<TimerCues> cuesShown = <TimerCues>[];
  int clears = 0;

  @override
  Future<void> show(
    TimerRun run,
    TimerCues cues, {
    required String title,
  }) async {
    shown.add((run: run, title: title));
    cuesShown.add(cues);
  }

  @override
  Future<void> clear() async {
    clears++;
  }
}

class FakeWake implements ScreenWake {
  final List<bool> calls = <bool>[];

  @override
  Future<void> keepOn({required bool on}) async {
    calls.add(on);
  }
}

class FakeLink implements TimerServiceLink {
  final StreamController<ActiveTimer> controller =
      StreamController<ActiveTimer>.broadcast();
  ActiveTimer? saved;

  @override
  Stream<ActiveTimer> get changes => controller.stream;

  @override
  Future<ActiveTimer?> readSaved() async => saved;
}

/// Everything a timer test needs: a fresh in-memory database, a fake clock
/// and fakes for the platform pieces.
class TimerKit {
  TimerKit({UserDatabase? db}) : db = db ?? memoryUserDb();

  final UserDatabase db;
  final FakeClock clock = FakeClock();
  final FakeCuePlayer cues = FakeCuePlayer();
  final FakeHost host = FakeHost();
  final FakeWake wake = FakeWake();
  final FakeLink link = FakeLink();

  /// What the app's settings say; set before building a container.
  AppSettings settings = const AppSettings();

  List<Override> overrides({List<Override> extra = const <Override>[]}) =>
      <Override>[
        userDatabaseProvider.overrideWithValue(db),
        timerNowMsProvider.overrideWithValue(clock.call),
        cuePlayerProvider.overrideWithValue(cues),
        backgroundTimerHostProvider.overrideWithValue(host),
        screenWakeProvider.overrideWithValue(wake),
        timerServiceLinkProvider.overrideWithValue(link),
        settingsProvider.overrideWith(() => _FixedSettings(settings)),
        ...extra,
      ];

  ProviderContainer container({List<Override> extra = const <Override>[]}) {
    final ProviderContainer c = ProviderContainer(
      retry: noRetry,
      overrides: overrides(extra: extra),
    );
    return c;
  }

  /// Pumps the whole app (real router) at [location].
  Future<void> pumpApp(
    WidgetTester tester, {
    String location = Routes.timer,
    List<Override> extra = const <Override>[],
    double textScale = 1,
    Override? library,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        overrides: <Override>[
          prefsProvider.overrideWithValue(prefs),
          seedSourceProvider.overrideWithValue(() async => null),
          library ??
              libraryRepositoryProvider.overrideWith(
                (Ref ref) async =>
                    throw const LibraryAssetMissing(LibraryInstaller.assetDb),
              ),
          ...overrides(extra: extra),
        ],
        child: TimerBootstrap(child: SinewApp(initialLocation: location)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Persists a freshly started run, as a process that was killed would have
/// left it, so the next [TimerKit.pumpApp] restores it.
Future<void> persistRun(
  TimerKit kit,
  TimerConfig config, {
  String title = 'Test timer',
}) async {
  final ActiveTimer a = ActiveTimer(
    run: TimerRun.start(compile(config), kit.clock.nowMs, mode: config.mode),
    cues: config.defaultCues,
    title: title,
    updatedAtMs: kit.clock.nowMs,
    config: config,
  );
  await RuntimeStateRepository(kit.db)
      .write(RuntimeStateRepository.runningTimer, a.toJson());
}
