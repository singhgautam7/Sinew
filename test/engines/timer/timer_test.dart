import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/engines/timer/timer_engine.dart';

/// A fake clock: tests move [now] explicitly.
class FakeClock {
  FakeClock([this.now = 1700000000000]);
  int now;
  void advance(Duration d) => now += d.inMilliseconds;
}

List<String> _labels(List<TimerStepSpec> s) =>
    s.map((TimerStepSpec e) => e.label).toList();

void main() {
  group('compile', () {
    test('stopwatch is one open step', () {
      final List<TimerStepSpec> s = compile(const StopwatchConfig());
      expect(s, hasLength(1));
      expect(s.single.durationMs, isNull);
      expect(s.single.phase, TimerPhase.open);
      expect(totalDurationMs(s), isNull);
    });

    test('countdown with and without prepare', () {
      expect(compile(const CountdownConfig(durationSec: 90)), hasLength(1));
      final List<TimerStepSpec> s = compile(
        const CountdownConfig(durationSec: 90, prepareSec: 5),
      );
      expect(s.first.phase, TimerPhase.prepare);
      expect(totalDurationMs(s), 95000);
    });

    test('interval has no rest after the last work step', () {
      final List<TimerStepSpec> s = compile(
        const IntervalConfig(workSec: 30, restSec: 15, rounds: 3),
      );
      // prepare, W R W R W
      expect(s, hasLength(6));
      expect(s.last.phase, TimerPhase.work);
      expect(_labels(s), <String>[
        'Get ready',
        'Work',
        'Rest',
        'Work',
        'Rest',
        'Work',
      ]);
      expect(totalDurationMs(s), 10000 + 3 * 30000 + 2 * 15000);
    });

    test('interval sets, rest between sets and cooldown', () {
      final List<TimerStepSpec> s = compile(
        const IntervalConfig(
          workSec: 20,
          restSec: 10,
          rounds: 2,
          sets: 2,
          restBetweenSetsSec: 60,
          prepareSec: 0,
          cooldownSec: 30,
        ),
      );
      expect(_labels(s), <String>[
        'Work',
        'Rest',
        'Work',
        'Rest between sets',
        'Work',
        'Rest',
        'Work',
        'Cooldown',
      ]);
      expect(s[3].phase, TimerPhase.roundRest);
      expect(s.last.phase, TimerPhase.cooldown);
    });

    test('tabata is 20/10 x 8 with a 10 s prepare', () {
      final List<TimerStepSpec> s = compile(const TabataConfig());
      expect(s, hasLength(1 + 8 + 7));
      expect(s.first.durationMs, 10000);
      expect(s[1].durationMs, 20000);
      expect(s[2].durationMs, 10000);
      expect(totalDurationMs(s), 10000 + 8 * 20000 + 7 * 10000);
    });

    test('emom has one work step per minute', () {
      final List<TimerStepSpec> s = compile(const EmomConfig(rounds: 10));
      expect(s, hasLength(10));
      expect(s[2].label, 'Minute 3 of 10');
      expect(s.every((TimerStepSpec e) => e.durationMs == 60000), isTrue);
    });

    test('amrap capped and uncapped', () {
      final List<TimerStepSpec> capped = compile(
        const AmrapConfig(capSec: 600),
      );
      expect(capped.single.durationMs, 600000);
      final List<TimerStepSpec> open = compile(const AmrapConfig());
      expect(open.single.durationMs, isNull);
      expect(totalDurationMs(open), isNull);
    });

    test('boxing defaults and warning cue', () {
      const BoxingConfig c = BoxingConfig();
      final List<TimerStepSpec> s = compile(c);
      // prepare + 12 rounds + 11 rests
      expect(s, hasLength(1 + 12 + 11));
      expect(s[1].label, 'Round 1 of 12');
      expect(s[1].durationMs, 180000);
      expect(s[2].label, 'Rest');
      expect(s.last.label, 'Round 12 of 12');
      expect(c.defaultCues.warningSec, 10);
    });

    test('yoga flow with transitions and exercise ids', () {
      final List<TimerStepSpec> s = compile(
        const YogaFlowConfig(
          poses: <YogaPose>[
            YogaPose(label: 'Mountain', exerciseId: 'mountain', holdSec: 30),
            YogaPose(label: 'Downward Dog', exerciseId: 'dog', holdSec: 45),
            YogaPose(label: 'Child', holdSec: 60),
          ],
        ),
      );
      expect(_labels(s), <String>[
        'Mountain',
        'Transition',
        'Downward Dog',
        'Transition',
        'Child',
      ]);
      expect(s[1].durationMs, 5000);
      expect(s.first.exerciseId, 'mountain');
      expect(s.last.phase, TimerPhase.work);
    });

    test('custom passes steps through', () {
      const List<TimerStepSpec> steps = <TimerStepSpec>[
        TimerStepSpec(label: 'A', phase: TimerPhase.work, durationMs: 1000),
      ];
      expect(compile(const CustomConfig(steps)), steps);
    });

    test('configs round trip through JSON', () {
      const List<TimerConfig> configs = <TimerConfig>[
        StopwatchConfig(),
        CountdownConfig(durationSec: 60, prepareSec: 3),
        IntervalConfig(workSec: 40, restSec: 20, rounds: 5, sets: 2),
        TabataConfig(),
        EmomConfig(rounds: 12),
        AmrapConfig(capSec: 300),
        AmrapConfig(),
        BoxingConfig(),
        YogaFlowConfig(poses: <YogaPose>[YogaPose(label: 'Tree', holdSec: 20)]),
        CustomConfig(<TimerStepSpec>[
          TimerStepSpec(label: 'X', phase: TimerPhase.rest, durationMs: 500),
        ]),
      ];
      for (final TimerConfig c in configs) {
        final Map<String, dynamic> j =
            jsonDecode(jsonEncode(c.toJson())) as Map<String, dynamic>;
        final TimerConfig? back = TimerConfig.fromJson(j);
        expect(back, isNotNull);
        expect(back.runtimeType, c.runtimeType);
        expect(compile(back!).map(stepToJson), compile(c).map(stepToJson));
      }
      expect(TimerConfig.fromJson(<String, dynamic>{'type': 'x'}), isNull);
      expect(TimerConfig.fromJson('junk'), isNull);
    });
  });

  group('run maths', () {
    late FakeClock clock;
    setUp(() => clock = FakeClock());

    TimerRun interval() => TimerRun.start(
      compile(
        const IntervalConfig(
          workSec: 30,
          restSec: 10,
          rounds: 3,
          prepareSec: 5,
        ),
      ),
      clock.now,
      mode: TimerMode.interval,
    );

    test('snapshot at start', () {
      final TimerRun r = interval();
      final TimerSnapshot s = r.snapshotAt(clock.now);
      expect(s.stepIndex, 0);
      expect(s.phase, TimerPhase.prepare);
      expect(s.stepElapsedMs, 0);
      expect(s.stepRemainingMs, 5000);
      expect(s.round, 0);
      expect(s.roundCount, 3);
      expect(s.finished, isFalse);
      expect(s.totalDurationMs, 5000 + 90000 + 20000);
    });

    test('advances through steps and finishes', () {
      final TimerRun r = interval();
      TimerSnapshot s = r.snapshotAt(clock.now + 5000);
      expect(s.stepIndex, 1);
      expect(s.phase, TimerPhase.work);
      expect(s.round, 1);
      s = r.snapshotAt(clock.now + 5000 + 30000 + 5000);
      expect(s.stepIndex, 2);
      expect(s.phase, TimerPhase.rest);
      expect(s.stepElapsedMs, 5000);
      expect(s.round, 1);
      expect(s.stepProgress, closeTo(0.5, 1e-9));
      s = r.snapshotAt(clock.now + 115000);
      expect(s.finished, isTrue);
      expect(s.stopped, isFalse);
      expect(s.totalElapsedMs, 115000);
      expect(s.totalProgress, 1);
      expect(s.endedAtMs, clock.now + 115000);
      s = r.snapshotAt(clock.now + 999999);
      expect(s.totalElapsedMs, 115000);
      expect(s.stepIndex, r.steps.length - 1);
      expect(s.round, 3);
    });

    test('pause freezes the snapshot and paused time never counts', () {
      TimerRun r = interval();
      clock.advance(const Duration(seconds: 12));
      r = r.pause(clock.now);
      final TimerSnapshot frozen = r.snapshotAt(clock.now);
      expect(frozen.paused, isTrue);
      expect(frozen.totalElapsedMs, 12000);
      clock.advance(const Duration(minutes: 5));
      final TimerSnapshot still = r.snapshotAt(clock.now);
      expect(still.totalElapsedMs, 12000);
      expect(still.stepIndex, frozen.stepIndex);
      expect(still.stepElapsedMs, frozen.stepElapsedMs);
      r = r.resume(clock.now);
      expect(r.snapshotAt(clock.now).totalElapsedMs, 12000);
      expect(r.snapshotAt(clock.now + 3000).totalElapsedMs, 15000);
      // Pausing twice and resuming twice are no-ops.
      expect(r.resume(clock.now), same(r));
      expect(r.pause(clock.now).pause(clock.now + 1).pausedAtMs, clock.now);
    });

    test('skip ends the current step now', () {
      TimerRun r = interval();
      clock.advance(const Duration(seconds: 2));
      r = r.skip(clock.now);
      TimerSnapshot s = r.snapshotAt(clock.now);
      expect(s.stepIndex, 1);
      expect(s.stepElapsedMs, 0);
      expect(s.totalElapsedMs, 2000);
      // The rest of the timeline shifts earlier by the 3 s skipped.
      expect(s.totalDurationMs, 5000 + 90000 + 20000 - 3000);
      clock.advance(const Duration(seconds: 10));
      r = r.skip(clock.now);
      s = r.snapshotAt(clock.now);
      expect(s.stepIndex, 2);
      expect(s.phase, TimerPhase.rest);
    });

    test('skipping the last step finishes the run', () {
      TimerRun r = TimerRun.rest(30, clock.now);
      clock.advance(const Duration(seconds: 4));
      r = r.skip(clock.now);
      final TimerSnapshot s = r.snapshotAt(clock.now);
      expect(s.finished, isTrue);
      expect(s.totalElapsedMs, 4000);
    });

    test('+10 s extends the current step', () {
      TimerRun r = TimerRun.rest(30, clock.now);
      clock.advance(const Duration(seconds: 25));
      r = r.addTime(clock.now);
      final TimerSnapshot s = r.snapshotAt(clock.now);
      expect(s.stepDurationMs, 40000);
      expect(s.stepRemainingMs, 15000);
      expect(s.finished, isFalse);
      expect(r.snapshotAt(clock.now + 15000).finished, isTrue);
      // Open-ended steps ignore it.
      final TimerRun sw = TimerRun.start(
        compile(const StopwatchConfig()),
        clock.now,
      );
      expect(sw.addTime(clock.now), same(sw));
    });

    test('stopwatch is open ended', () {
      final TimerRun r = TimerRun.start(
        compile(const StopwatchConfig()),
        clock.now,
        mode: TimerMode.stopwatch,
      );
      final TimerSnapshot s = r.snapshotAt(clock.now + 3600000);
      expect(s.finished, isFalse);
      expect(s.stepElapsedMs, 3600000);
      expect(s.stepRemainingMs, isNull);
      expect(s.totalDurationMs, isNull);
      expect(s.stepProgress, 0);
    });

    test('amrap counter', () {
      TimerRun r = TimerRun.start(
        compile(const AmrapConfig(capSec: 600)),
        clock.now,
        mode: TimerMode.amrap,
      );
      r = r.incrementRound().incrementRound().incrementRound();
      expect(r.snapshotAt(clock.now).amrapRounds, 3);
      expect(r.decrementRound().amrapRounds, 2);
      expect(
        TimerRun.start(const <TimerStepSpec>[], 0).decrementRound().amrapRounds,
        0,
      );
    });

    test('stop freezes elapsed time', () {
      TimerRun r = interval();
      clock.advance(const Duration(seconds: 20));
      r = r.stop(clock.now);
      clock.advance(const Duration(minutes: 10));
      final TimerSnapshot s = r.snapshotAt(clock.now);
      expect(s.finished, isTrue);
      expect(s.stopped, isTrue);
      expect(s.totalElapsedMs, 20000);
      expect(s.endedAtMs, 1700000000000 + 20000);
    });

    test('stop while paused keeps the pause time out', () {
      TimerRun r = interval();
      clock.advance(const Duration(seconds: 8));
      r = r.pause(clock.now);
      clock.advance(const Duration(minutes: 2));
      r = r.stop(clock.now);
      expect(r.snapshotAt(clock.now).totalElapsedMs, 8000);
    });

    test('locked flag', () {
      final TimerRun r = interval().setLocked(true);
      expect(r.locked, isTrue);
      expect(r.setLocked(false).locked, isFalse);
    });

    test('background elapsed: clock jumps 7 minutes', () {
      final TimerRun r = TimerRun.start(
        compile(const TabataConfig()),
        clock.now,
        mode: TimerMode.tabata,
      );
      // 10 prepare + (20+10) * k ... 7 minutes = 420 s -> 410 s into the
      // work/rest cycle = 13 full cycles of 30 s capped at 8 rounds.
      clock.advance(const Duration(minutes: 7));
      final TimerSnapshot s = r.snapshotAt(clock.now);
      // Total is 10 + 8*20 + 7*10 = 240 s, so it finished long ago.
      expect(s.finished, isTrue);
      expect(s.totalElapsedMs, 240000);

      final TimerRun b = TimerRun.start(
        compile(const BoxingConfig()),
        1000,
        mode: TimerMode.boxing,
      );
      // 7 min = 420 s: prepare 10, R1 180 (to 190), rest 60 (250),
      // R2 180 (to 430) -> in R2 at 170 s.
      final TimerSnapshot t = b.snapshotAt(1000 + 420000);
      expect(t.stepIndex, 3);
      expect(t.step!.label, 'Round 2 of 12');
      expect(t.stepElapsedMs, 170000);
      expect(t.round, 2);
      expect(t.stepRemainingMs, 10000);
    });
  });

  group('cues', () {
    const TimerCues cues = TimerCues(voice: true);

    test('countdown ticks and phase starts across a boundary', () {
      final TimerRun r = TimerRun.start(
        compile(
          const IntervalConfig(
            workSec: 10,
            restSec: 5,
            rounds: 2,
            prepareSec: 0,
          ),
        ),
        0,
      );
      final List<CueEvent> ev = r.cuesBetween(0, 16000, cues);
      expect(
        ev.map((CueEvent e) => '${e.kind.name}:${e.atMs}:${e.text}').toList(),
        <String>[
          'phaseStart:0:Work',
          'countdown:7000:3',
          'countdown:8000:2',
          'countdown:9000:1',
          'phaseStart:10000:Rest',
          'countdown:12000:3',
          'countdown:13000:2',
          'countdown:14000:1',
          'phaseStart:15000:Work',
        ],
      );
      expect(ev.every((CueEvent e) => e.voice && e.sound && e.haptic), isTrue);
    });

    test('window is half open and clipped', () {
      final TimerRun r = TimerRun.start(
        compile(const CountdownConfig(durationSec: 10)),
        0,
      );
      final List<CueEvent> ev = r.cuesBetween(8000, 10000, cues);
      expect(ev.map((CueEvent e) => e.atMs), <int>[8000, 9000]);
      final List<CueEvent> fin = r.cuesBetween(10000, 10001, cues);
      expect(fin.single.kind, CueKind.finish);
    });

    test('short steps skip ticks that would precede their start', () {
      final TimerRun r = TimerRun.start(const <TimerStepSpec>[
        TimerStepSpec(label: 'Quick', phase: TimerPhase.work, durationMs: 2000),
      ], 0);
      final List<CueEvent> ev = r.cuesBetween(0, 5000, cues);
      expect(
        ev
            .where((CueEvent e) => e.kind == CueKind.countdown)
            .map((CueEvent e) => e.text),
        <String>['1'], // a tick at the step start is dropped
      );
    });

    test('boxing warning 10 s before each round ends', () {
      const BoxingConfig c = BoxingConfig(rounds: 2);
      final TimerRun r = TimerRun.start(compile(c), 0, mode: TimerMode.boxing);
      final List<CueEvent> w = r
          .cuesBetween(0, 1000000, c.defaultCues)
          .where((CueEvent e) => e.kind == CueKind.warning)
          .toList();
      // Prepare 10 + round 1 ends at 190 s, warning at 180 s.
      expect(w.map((CueEvent e) => e.atMs), <int>[180000, 430000 - 10000]);
      expect(w.first.text, '10 seconds');
      // Not in the rest step.
      expect(w.every((CueEvent e) => e.stepIndex != 2), isTrue);
    });

    test('voice flag requires voice cue on', () {
      final TimerRun r = TimerRun.start(
        compile(const CountdownConfig(durationSec: 10)),
        0,
      );
      final List<CueEvent> ev = r.cuesBetween(0, 20000, const TimerCues());
      expect(ev.every((CueEvent e) => !e.voice), isTrue);
    });

    test('paused or stopped runs produce no cues', () {
      final TimerRun r = TimerRun.start(
        compile(const CountdownConfig(durationSec: 10)),
        0,
      );
      expect(r.pause(2000).cuesBetween(0, 20000, cues), isEmpty);
      expect(r.stop(2000).cuesBetween(0, 20000, cues), isEmpty);
    });

    test('cues are absolute and follow pauses, skips and +10 s', () {
      TimerRun r = TimerRun.start(
        compile(const CountdownConfig(durationSec: 30)),
        0,
      );
      r = r.pause(5000).resume(65000); // 60 s lost
      r = r.addTime(70000); // step now 40 s; ends at wall 100 s
      final List<CueEvent> ev = r.cuesBetween(0, 200000, cues);
      expect(ev.last.kind, CueKind.finish);
      expect(ev.last.atMs, 100000);
      expect(
        ev.where((CueEvent e) => e.kind == CueKind.countdown).first.atMs,
        97000,
      );
    });

    test('open ended steps only have a start cue', () {
      final TimerRun r = TimerRun.start(compile(const StopwatchConfig()), 0);
      final List<CueEvent> ev = r.cuesBetween(0, 1000000, cues);
      expect(ev, hasLength(1));
      expect(ev.single.kind, CueKind.phaseStart);
    });
  });

  group('persistence', () {
    test('round trip and restore after a simulated kill is exact', () {
      final FakeClock clock = FakeClock();
      TimerRun r = TimerRun.start(
        compile(const BoxingConfig(rounds: 3)),
        clock.now,
        mode: TimerMode.boxing,
      );
      clock.advance(const Duration(seconds: 40));
      r = r.pause(clock.now);
      clock.advance(const Duration(seconds: 90));
      r = r.resume(clock.now);
      clock.advance(const Duration(seconds: 100));
      r = r.skip(clock.now).addTime(clock.now + 1000).incrementRound();
      r = r.setLocked(true);
      clock.advance(const Duration(seconds: 17));

      final String stored = jsonEncode(r.toJson());
      final TimerSnapshot before = r.snapshotAt(clock.now);
      clock.advance(const Duration(minutes: 3)); // process dead for a while
      // ignore: unused_local_variable
      r = TimerRun.start(const <TimerStepSpec>[], 0); // discard
      final TimerRun? restored = TimerRun.fromJson(
        jsonDecode(stored) as Map<String, dynamic>,
      );
      expect(restored, isNotNull);
      expect(restored!.mode, TimerMode.boxing);
      expect(restored.locked, isTrue);
      expect(restored.toJson(), jsonDecode(stored));
      expect(
        restored.snapshotAt(
          clock.now - const Duration(minutes: 3).inMilliseconds,
        ),
        before,
      );
      // And at the later time it equals what the original would say.
      final TimerRun original = TimerRun.fromJson(
        jsonDecode(stored) as Map<String, dynamic>,
      )!;
      expect(restored.snapshotAt(clock.now), original.snapshotAt(clock.now));
    });

    test('paused run restores paused', () {
      final TimerRun r = TimerRun.rest(60, 0).pause(10000);
      final TimerRun back = TimerRun.fromJson(r.toJson())!;
      expect(back.isPaused, isTrue);
      expect(back.snapshotAt(500000).stepElapsedMs, 10000);
    });

    test('newer schema version returns null', () {
      final Map<String, dynamic> j = TimerRun.rest(30, 0).toJson();
      j['schemaVersion'] = 2;
      expect(TimerRun.fromJson(j), isNull);
    });

    test('corrupt json returns null', () {
      expect(TimerRun.fromJson(null), isNull);
      expect(TimerRun.fromJson(<String, dynamic>{}), isNull);
      expect(
        TimerRun.fromJson(<String, dynamic>{
          'schemaVersion': 1,
          'startedAtMs': 'x',
          'steps': 3,
        }),
        isNull,
      );
      final Map<String, dynamic> bad = TimerRun.rest(30, 0).toJson();
      bad['steps'] = <Object?>[42];
      expect(TimerRun.fromJson(bad), isNull);
      final Map<String, dynamic> badOv = TimerRun.rest(30, 0).toJson();
      badOv['overrides'] = <String, Object?>{'9': 1};
      expect(TimerRun.fromJson(badOv), isNull);
    });

    test('unknown phase falls back to work', () {
      final Map<String, dynamic> j = TimerRun.rest(30, 0).toJson();
      ((j['steps'] as List<Object?>).first as Map<String, dynamic>)['phase'] =
          'nope';
      expect(TimerRun.fromJson(j)!.steps.first.phase, TimerPhase.work);
    });
  });

  group('sessionFromRun', () {
    int n = 0;
    String id() => 'id${n++}';
    setUp(() => n = 0);

    test('yoga poses become hold sets grouped by exercise', () {
      TimerRun r = TimerRun.start(
        compile(
          const YogaFlowConfig(
            poses: <YogaPose>[
              YogaPose(label: 'Dog', exerciseId: 'dog', holdSec: 30),
              YogaPose(label: 'Tree', exerciseId: 'tree', holdSec: 20),
              YogaPose(label: 'Dog', exerciseId: 'dog', holdSec: 40),
            ],
          ),
        ),
        0,
        mode: TimerMode.yogaFlow,
      );
      // 30 + 5 + 20 + 5 + 40 = 100 s.
      r = r.pause(50000).resume(80000); // 30 s pause
      final TimerSnapshot end = r.snapshotAt(500000);
      expect(end.finished, isTrue);
      final WorkoutSession s = sessionFromRun(r, end, name: 'Flow', newId: id);
      expect(s.source, SessionSource.timer);
      expect(s.name, 'Flow');
      expect(s.durationSec, 100);
      expect(s.startedAt, DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
      expect(
        s.endedAt,
        DateTime.fromMillisecondsSinceEpoch(130000, isUtc: true),
      );
      expect(s.exercises.map((SessionExercise e) => e.exerciseId), <String>[
        'dog',
        'tree',
      ]);
      expect(s.exercises.first.sets.map((SetEntry e) => e.holdSec), <int?>[
        30,
        40,
      ]);
      expect(s.exercises.first.sets.first.durationSec, isNull);
      expect(s.exercises.first.sets.every((SetEntry e) => e.completed), isTrue);
    });

    test('a stopped run only logs completed steps', () {
      TimerRun r = TimerRun.start(
        compile(
          const YogaFlowConfig(
            poses: <YogaPose>[
              YogaPose(label: 'A', exerciseId: 'a', holdSec: 30),
              YogaPose(label: 'B', exerciseId: 'b', holdSec: 30),
            ],
          ),
        ),
        0,
        mode: TimerMode.yogaFlow,
      );
      r = r.stop(50000); // inside B
      final WorkoutSession s = sessionFromRun(
        r,
        r.snapshotAt(60000),
        newId: id,
      );
      expect(s.exercises.map((SessionExercise e) => e.exerciseId), <String>[
        'a',
      ]);
      expect(s.durationSec, 50);
      expect(s.name, isNull);
    });

    test('no exercise ids gives one generic entry with rounds', () {
      final TimerRun r = TimerRun.start(
        compile(const TabataConfig()),
        0,
        mode: TimerMode.tabata,
      );
      final WorkoutSession s = sessionFromRun(
        r,
        r.snapshotAt(10000000),
        newId: id,
      );
      expect(s.exercises, hasLength(1));
      expect(s.exercises.single.exerciseId, 'timer-tabata');
      final SetEntry set = s.exercises.single.sets.single;
      expect(set.rounds, 8);
      expect(set.durationSec, 240);
    });

    test('amrap logs the user counted rounds', () {
      TimerRun r = TimerRun.start(
        compile(const AmrapConfig(capSec: 600)),
        0,
        mode: TimerMode.amrap,
      );
      r = r.incrementRound().incrementRound().incrementRound().incrementRound();
      r = r.stop(300000);
      final WorkoutSession s = sessionFromRun(
        r,
        r.snapshotAt(300000),
        newId: id,
      );
      expect(s.exercises.single.exerciseId, 'timer-amrap');
      expect(s.exercises.single.sets.single.rounds, 4);
      expect(s.exercises.single.sets.single.durationSec, 300);
    });

    test('stopwatch has no rounds', () {
      TimerRun r = TimerRun.start(
        compile(const StopwatchConfig()),
        0,
        mode: TimerMode.stopwatch,
      );
      r = r.stop(90000);
      final WorkoutSession s = sessionFromRun(
        r,
        r.snapshotAt(90000),
        newId: id,
      );
      expect(s.exercises.single.exerciseId, 'timer-stopwatch');
      expect(s.exercises.single.sets.single.rounds, isNull);
      expect(s.exercises.single.sets.single.durationSec, 90);
    });
  });
}
