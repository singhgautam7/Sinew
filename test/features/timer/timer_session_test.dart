import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/runtime_state_repository.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/engines/timer/timer_engine.dart';
import 'package:sinew/features/timer/controller/timer_session.dart';
import 'package:sinew/features/timer/data/active_timer.dart';

import 'timer_harness.dart';

Future<TimerSession> _open(ProviderContainer c) async {
  await c.read(timerSessionProvider.future);
  return c.read(timerSessionProvider.notifier);
}

TimerSnapshot _snap(ProviderContainer c, TimerKit k) =>
    c.read(timerSessionProvider).value!.run.snapshotAt(k.clock.nowMs);

void main() {
  late TimerKit kit;
  late ProviderContainer c;

  setUp(() {
    kit = TimerKit();
    c = kit.container();
  });

  tearDown(() async {
    try {
      await c.read(timerSessionProvider.notifier).flush();
    } on Object {
      // The container was already disposed by the test.
    }
    c.dispose();
    await kit.db.close();
  });

  const TabataConfig tabata = TabataConfig(prepareSec: 3, rounds: 2);

  test('start shows the first step and tells the host', () async {
    final TimerSession s = await _open(c);
    await s.start(tabata, title: 'Tabata');
    final TimerSnapshot snap = _snap(c, kit);
    expect(snap.step!.label, 'Get ready');
    expect(snap.phase, TimerPhase.prepare);
    expect(snap.stepRemainingMs, 3000);
    expect(kit.host.shown.single.title, 'Tabata');
    await s.flush();
    final Map<String, dynamic>? stored = await c
        .read(runtimeStateRepositoryProvider)
        .read(RuntimeStateRepository.runningTimer);
    expect(ActiveTimer.fromJson(stored)!.title, 'Tabata');
  });

  test('pause stops time and resume continues it', () async {
    final TimerSession s = await _open(c);
    await s.start(tabata, title: 'Tabata');
    kit.clock.advance(const Duration(seconds: 1));
    s.togglePause();
    final int frozen = _snap(c, kit).stepElapsedMs;
    kit.clock.advance(const Duration(minutes: 10));
    expect(_snap(c, kit).stepElapsedMs, frozen);
    expect(_snap(c, kit).paused, isTrue);
    s.togglePause();
    kit.clock.advance(const Duration(seconds: 1));
    expect(_snap(c, kit).stepElapsedMs, frozen + 1000);
  });

  test('skip moves on and +10s extends the step', () async {
    final TimerSession s = await _open(c);
    await s.start(tabata, title: 'Tabata');
    s.skip();
    expect(_snap(c, kit).step!.label, 'Work');
    final int before = _snap(c, kit).stepDurationMs!;
    s.addTime();
    expect(_snap(c, kit).stepDurationMs, before + 10000);
  });

  test('five minutes in the background lands on the right step', () async {
    final TimerSession s = await _open(c);
    // 3 s prepare, then 8 x 20 s work with 10 s rests.
    await s.start(
      const TabataConfig(prepareSec: 3, rounds: 8),
      title: 'Tabata',
    );
    kit.clock.advance(const Duration(minutes: 3));
    final TimerSnapshot snap = _snap(c, kit);
    // 3 + k * 30 <= 180 -> the 6th round (index 5) starts at 153 s, rest at 173.
    expect(snap.round, 6);
    expect(snap.phase, TimerPhase.rest);
    expect(snap.stepElapsedMs, 7000);
  });

  test('a stale burst of cues is not replayed after a long gap', () async {
    final TimerSession s = await _open(c);
    await s.start(tabata, title: 'Tabata');
    s.tick();
    kit.cues.events.clear();
    // The app was suspended for 40 s: the cues in between are dropped (the
    // background service played them), and nothing is due right now.
    kit.clock.advance(const Duration(seconds: 40));
    s.tick();
    expect(kit.cues.events, isEmpty);
    // Cues after the gap play normally.
    for (int i = 0; i < 150; i++) {
      kit.clock.advance(const Duration(milliseconds: 100));
      s.tick();
    }
    expect(kit.cues.kinds.last, CueKind.finish);
  });

  test('cues fire once each, in order', () async {
    final TimerSession s = await _open(c);
    // 2 s work, 2 s rest, 2 s work: tick 3,2,1 beeps need countdown 1.
    await s.start(
      const IntervalConfig(workSec: 4, restSec: 4, rounds: 2, prepareSec: 0),
      title: 'Interval',
      cues: const TimerCues(countdownSec: 2),
    );
    for (int i = 0; i < 160; i++) {
      s.tick();
      kit.clock.advance(const Duration(milliseconds: 100));
    }
    final List<String> seen = <String>[
      for (final CueEvent e in kit.cues.events) '${e.kind.name}:${e.text}',
    ];
    expect(seen, <String>[
      'phaseStart:Work',
      'countdown:2',
      'countdown:1',
      'phaseStart:Rest',
      'countdown:2',
      'countdown:1',
      'phaseStart:Work',
      'countdown:2',
      'countdown:1',
      'finish:Done',
    ]);
    // Ticking again changes nothing.
    final int count = kit.cues.events.length;
    s.tick();
    expect(kit.cues.events, hasLength(count));
  });

  test('no cues while paused', () async {
    final TimerSession s = await _open(c);
    await s.start(
      const IntervalConfig(workSec: 4, restSec: 4, rounds: 2, prepareSec: 0),
      title: 'Interval',
    );
    s.tick();
    final int started = kit.cues.events.length;
    s.togglePause();
    for (int i = 0; i < 80; i++) {
      kit.clock.advance(const Duration(milliseconds: 100));
      s.tick();
    }
    expect(kit.cues.events, hasLength(started));
  });

  test('boxing warns ten seconds before the round ends', () async {
    final TimerSession s = await _open(c);
    const BoxingConfig box = BoxingConfig(
      rounds: 2,
      roundSec: 30,
      restSec: 10,
      prepareSec: 0,
    );
    expect(box.defaultCues.warningSec, 10);
    await s.start(box, title: 'Bag work');
    for (int i = 0; i < 300; i++) {
      s.tick();
      kit.clock.advance(const Duration(milliseconds: 100));
    }
    final List<CueEvent> warnings = <CueEvent>[
      for (final CueEvent e in kit.cues.events)
        if (e.kind == CueKind.warning) e,
    ];
    expect(warnings, hasLength(1));
    expect(warnings.single.text, '10 seconds');
    // Round 1 is 30 s long, so the warning sits 20 s in.
    expect(warnings.single.stepIndex, 0);
    expect(
      warnings.single.atMs,
      c.read(timerSessionProvider).value!.run.startedAtMs + 20000,
    );
  });

  test('AMRAP counts and undoes rounds', () async {
    final TimerSession s = await _open(c);
    await s.start(const AmrapConfig(capSec: 60), title: 'AMRAP 1');
    s.addRound();
    s.addRound();
    s.addRound();
    s.undoRound();
    expect(_snap(c, kit).amrapRounds, 2);
    for (int i = 0; i < 5; i++) {
      s.undoRound();
    }
    expect(_snap(c, kit).amrapRounds, 0);
  });

  test('stopwatch laps record elapsed time and reset clears them', () async {
    final TimerSession s = await _open(c);
    await s.start(const StopwatchConfig(), title: 'Stopwatch');
    kit.clock.advance(const Duration(seconds: 5));
    s.lap();
    kit.clock.advance(const Duration(seconds: 7));
    s.lap();
    final ActiveTimer a = c.read(timerSessionProvider).value!;
    expect(a.laps, <int>[5000, 12000]);
    expect(a.lapRows.last.splitMs, 7000);
    s.resetStopwatch();
    expect(c.read(timerSessionProvider).value!.laps, isEmpty);
    expect(_snap(c, kit).totalElapsedMs, 0);
  });

  test('restore after a simulated kill returns the same snapshot', () async {
    final TimerSession s = await _open(c);
    await s.start(tabata, title: 'Tabata', presetId: 'p1');
    kit.clock.advance(const Duration(seconds: 5));
    s.skip();
    s.setLocked(true);
    await s.flush();
    final TimerSnapshot before = _snap(c, kit);
    c.dispose();

    // A new process: new container, same database and clock.
    kit.clock.advance(const Duration(seconds: 2));
    final ProviderContainer c2 = kit.container();
    addTearDown(c2.dispose);
    final ActiveTimer? restored = await c2.read(timerSessionProvider.future);
    expect(restored, isNotNull);
    expect(restored!.title, 'Tabata');
    expect(restored.presetId, 'p1');
    expect(restored.run.locked, isTrue);
    final TimerSnapshot after = restored.run.snapshotAt(kit.clock.nowMs);
    expect(after.stepIndex, before.stepIndex);
    expect(after.stepElapsedMs, before.stepElapsedMs + 2000);
    // The restored run goes back into the background service.
    await Future<void>.delayed(Duration.zero);
    expect(kit.host.shown.length, greaterThan(1));
  });

  test('a run that finished while away is offered for logging', () async {
    final TimerSession s = await _open(c);
    await s.start(const CountdownConfig(durationSec: 30), title: 'Rest');
    await s.flush();
    c.dispose();
    kit.clock.advance(const Duration(minutes: 5));
    final ProviderContainer c2 = kit.container();
    addTearDown(c2.dispose);
    final ActiveTimer? a = await c2.read(timerSessionProvider.future);
    expect(a, isNotNull);
    expect(a!.run.snapshotAt(kit.clock.nowMs).finished, isTrue);
    expect(c2.read(timerRunningProvider), isFalse);
  });

  test('a newer copy from the background service wins on restore', () async {
    final TimerSession s = await _open(c);
    await s.start(tabata, title: 'Tabata');
    await s.flush();
    final ActiveTimer a = c.read(timerSessionProvider).value!;
    c.dispose();

    kit.clock.advance(const Duration(seconds: 1));
    // The notification's Pause button was pressed while the app was gone.
    kit.link.saved = a.copyWith(
      run: a.run.pause(kit.clock.nowMs),
      updatedAtMs: kit.clock.nowMs,
    );
    final ProviderContainer c2 = kit.container();
    addTearDown(c2.dispose);
    final ActiveTimer? restored = await c2.read(timerSessionProvider.future);
    expect(restored!.run.isPaused, isTrue);
  });

  test('stop ends the run and keeps the summary until closed', () async {
    final TimerSession s = await _open(c);
    await s.start(tabata, title: 'Tabata');
    kit.clock.advance(const Duration(seconds: 5));
    s.stop();
    final TimerSnapshot snap = _snap(c, kit);
    expect(snap.finished, isTrue);
    expect(snap.stopped, isTrue);
    expect(c.read(timerRunningProvider), isFalse);
    expect(kit.host.clears, greaterThan(0));
    await s.flush();
    expect(
      await c
          .read(runtimeStateRepositoryProvider)
          .read(RuntimeStateRepository.runningTimer),
      isNull,
    );
    expect(c.read(timerSessionProvider).value, isNotNull);
    await s.dismiss();
    expect(c.read(timerSessionProvider).value, isNull);
  });

  test('finishing clears the stored run and the service', () async {
    final TimerSession s = await _open(c);
    await s.start(const CountdownConfig(durationSec: 5), title: 'Countdown');
    await s.flush();
    kit.clock.advance(const Duration(seconds: 6));
    s.tick();
    expect(kit.cues.kinds, contains(CueKind.finish));
    expect(kit.host.clears, greaterThan(0));
    await Future<void>.delayed(Duration.zero);
    expect(
      await c
          .read(runtimeStateRepositoryProvider)
          .read(RuntimeStateRepository.runningTimer),
      isNull,
    );
  });

  test('Log as workout saves a session and closes the timer', () async {
    final TimerSession s = await _open(c);
    await s.start(const AmrapConfig(capSec: 60), title: 'AMRAP 1');
    s.addRound();
    s.addRound();
    kit.clock.advance(const Duration(seconds: 61));
    s.tick();
    final String id = await s.logAsWorkout();
    final WorkoutSession? saved = await c
        .read(sessionRepositoryProvider)
        .byId(id);
    expect(saved, isNotNull);
    expect(saved!.source, SessionSource.timer);
    expect(saved.name, 'AMRAP 1');
    expect(saved.exercises.single.exerciseId, 'timer-amrap');
    expect(saved.exercises.single.sets.single.rounds, 2);
    expect(c.read(timerSessionProvider).value, isNull);
  });

  test('a remote change from the service is adopted when newer', () async {
    final TimerSession s = await _open(c);
    await s.start(tabata, title: 'Tabata');
    final ActiveTimer a = c.read(timerSessionProvider).value!;
    kit.clock.advance(const Duration(seconds: 1));
    kit.link.controller.add(
      a.copyWith(
        run: a.run.skip(kit.clock.nowMs),
        updatedAtMs: kit.clock.nowMs,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(_snap(c, kit).step!.label, 'Work');
    // An older copy is ignored.
    kit.link.controller.add(a);
    await Future<void>.delayed(Duration.zero);
    expect(_snap(c, kit).step!.label, 'Work');
  });
}
