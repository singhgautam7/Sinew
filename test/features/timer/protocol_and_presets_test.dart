import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/runtime_state_repository.dart';
import 'package:sinew/core/db/repositories/timer_preset_repository.dart';
import 'package:sinew/core/db/repositories/library_types.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/engines/timer/timer_engine.dart';
import 'package:sinew/features/timer/data/active_timer.dart';
import 'package:sinew/features/timer/data/timer_presets.dart';
import 'package:sinew/features/timer/services/service_protocol.dart';
import 'package:sinew/features/timer/setup/setup_model.dart';
import 'package:sinew/features/timer/setup/timer_setup_screen.dart';

import '../../helpers/test_db.dart';

ActiveTimer _active(TimerConfig c, int now, {String title = 'Tabata'}) =>
    ActiveTimer(
      run: TimerRun.start(compile(c), now, mode: c.mode),
      cues: c.defaultCues,
      title: title,
      updatedAtMs: now,
      config: c,
    );

void main() {
  group('setup model', () {
    test('Tabata total is prepare + work + rest', () {
      final SetupModel m = SetupModel.defaults(TimerMode.tabata);
      // 10 + 8 x 20 + 7 x 10
      expect(m.totalMs, 240000);
      expect(m.withValue('work', 25).totalMs, 280000);
    });

    test('Interval total follows rounds, sets and set rest', () {
      SetupModel m = SetupModel.defaults(TimerMode.interval);
      // 10 + 8 x 30 + 7 x 15
      expect(m.totalMs, 355000);
      m = m.withValue('sets', 3).withValue('setRest', 60);
      // 10 + 3 x (8 x 30 + 7 x 15) + 2 x 60
      expect(m.totalMs, 10000 + 3 * (240000 + 105000) + 120000);
    });

    test('an AMRAP without a cap has no total', () {
      final SetupModel m = SetupModel.defaults(TimerMode.amrap)
          .copyWith(noCap: true);
      expect(m.totalMs, isNull);
      expect(m.toConfig(), isA<AmrapConfig>());
      expect((m.toConfig() as AmrapConfig).capSec, isNull);
    });

    test('every mode round-trips through its config', () {
      for (final TimerMode mode in TimerMode.values) {
        final SetupModel m = SetupModel.defaults(mode);
        final SetupModel again = SetupModel.fromConfig(m.toConfig());
        expect(again.mode, mode);
        expect(again.values, m.values);
      }
    });

    test('flows and sequences need steps to start', () {
      expect(SetupModel.defaults(TimerMode.yogaFlow).canStart, isFalse);
      expect(SetupModel.defaults(TimerMode.custom).canStart, isFalse);
      expect(SetupModel.defaults(TimerMode.tabata).canStart, isTrue);
    });

    test('Boxing defaults warn ten seconds before a round ends', () {
      expect(SetupModel.defaults(TimerMode.boxing).cues.warningSec, 10);
    });
  });

  group('presets', () {
    test('built-ins seed once, even when called twice', () async {
      final db = memoryUserDb();
      addTearDown(db.close);
      final TimerPresetRepository repo = TimerPresetRepository(db);
      final RuntimeStateRepository state = RuntimeStateRepository(db);
      final DateTime now = DateTime.utc(2026, 11, 1);
      await seedBuiltInPresets(presets: repo, state: state, now: now);
      await seedBuiltInPresets(presets: repo, state: state, now: now);
      final List<TimerPreset> all = await repo.all();
      expect(
        all.map((TimerPreset p) => p.id).toSet(),
        BuiltInPresetIds.all.toSet(),
      );
      expect(all, hasLength(5));
      expect(all.every((TimerPreset p) => p.builtIn), isTrue);
    });

    test('a deleted built-in does not come back', () async {
      final db = memoryUserDb();
      addTearDown(db.close);
      final TimerPresetRepository repo = TimerPresetRepository(db);
      final RuntimeStateRepository state = RuntimeStateRepository(db);
      final DateTime now = DateTime.utc(2026, 11, 1);
      await seedBuiltInPresets(presets: repo, state: state, now: now);
      await repo.delete(BuiltInPresetIds.emom);
      await seedBuiltInPresets(presets: repo, state: state, now: now);
      expect(await repo.byId(BuiltInPresetIds.emom), isNull);
      expect(await repo.all(), hasLength(4));
    });

    test('built-ins match the brief', () {
      final Map<String, TimerPreset> by = <String, TimerPreset>{
        for (final TimerPreset p in builtInPresets(DateTime.utc(2026))) p.id: p,
      };
      expect(by[BuiltInPresetIds.tabata]!.mode, TimerMode.tabata);
      expect(totalDurationMs(by[BuiltInPresetIds.tabata]!.steps), 240000);
      expect(totalDurationMs(by[BuiltInPresetIds.emom]!.steps), 600000);
      expect(totalDurationMs(by[BuiltInPresetIds.amrap]!.steps), 720000);
      // 12 x 3:00 with 11 x 1:00 rests and a 10 s get-ready.
      expect(
        totalDurationMs(by[BuiltInPresetIds.boxing]!.steps),
        10000 + 12 * 180000 + 11 * 60000,
      );
      expect(by[BuiltInPresetIds.boxing]!.cues.warningSec, 10);
      expect(totalDurationMs(by[BuiltInPresetIds.countdown]!.steps), 300000);
    });

    test('steps map back to the config they came from', () {
      for (final TimerConfig c in <TimerConfig>[
        const TabataConfig(),
        const IntervalConfig(
          workSec: 40,
          restSec: 20,
          rounds: 4,
          sets: 2,
          restBetweenSetsSec: 60,
          prepareSec: 5,
          cooldownSec: 30,
        ),
        const EmomConfig(rounds: 7, intervalSec: 90),
        const AmrapConfig(capSec: 600),
        const AmrapConfig(),
        const BoxingConfig(rounds: 3),
        const CountdownConfig(durationSec: 90, prepareSec: 5),
        const YogaFlowConfig(
          poses: <YogaPose>[
            YogaPose(label: 'Cobra', holdSec: 30, exerciseId: 'cobra'),
            YogaPose(label: 'Child', holdSec: 45),
          ],
          transitionSec: 4,
        ),
      ]) {
        final TimerConfig back = configFromSteps(c.mode, compile(c));
        expect(compile(back), compile(c), reason: '${c.mode}');
      }
    });

    test('steps that do not fit a mode open as a custom sequence', () {
      final List<TimerStepSpec> odd = <TimerStepSpec>[
        const TimerStepSpec(
          label: 'Rest',
          phase: TimerPhase.rest,
          durationMs: 5000,
        ),
      ];
      expect(configFromSteps(TimerMode.tabata, odd), isA<CustomConfig>());
    });

    test('describePreset reads for a person', () {
      final TimerPreset tabata = builtInPresets(DateTime.utc(2026)).first;
      expect(describePreset(tabata), '20 / 10 x 8, 4:00');
    });
  });

  group('flow to yoga config', () {
    test('poses in order, flow transition, repeated for rounds', () {
      const Flow flow = Flow(
        id: 'sun',
        name: 'Sun salutation',
        category: 'yoga',
        totalDurationSec: 100,
        rounds: 2,
        steps: <FlowStep>[
          FlowStep(
            position: 0,
            exerciseId: 'mountain-pose',
            label: 'Mountain',
            holdSec: 20,
            transitionSec: 3,
          ),
          FlowStep(
            position: 1,
            exerciseId: 'downward-dog',
            holdSec: 30,
            transitionSec: 3,
          ),
        ],
      );
      final YogaFlowConfig c = flowConfig(flow);
      expect(c.poses, hasLength(4));
      expect(c.poses[0].label, 'Mountain');
      expect(c.poses[1].label, 'Downward dog');
      expect(c.poses[1].exerciseId, 'downward-dog');
      expect(c.transitionSec, 3);
      expect(
        totalDurationMs(compile(c)),
        (20 + 3 + 30 + 3 + 20 + 3 + 30) * 1000,
      );
    });
  });

  group('service protocol', () {
    const int t0 = 1700000000000;

    test('an active timer survives JSON', () {
      final ActiveTimer a = _active(
        const TabataConfig(),
        t0,
      ).copyWith(laps: <int>[1000, 2500]);
      final ActiveTimer? back = ActiveTimer.fromJson(a.toJson());
      expect(back, isNotNull);
      expect(back!.title, 'Tabata');
      expect(back.laps, <int>[1000, 2500]);
      expect(back.config, isA<TabataConfig>());
      expect(back.run.snapshotAt(t0 + 5000), a.run.snapshotAt(t0 + 5000));
    });

    test('corrupt or newer payloads read as null', () {
      expect(ActiveTimer.fromJson(null), isNull);
      expect(
        ActiveTimer.fromJson(<String, dynamic>{'schemaVersion': 99}),
        isNull,
      );
      expect(
        ActiveTimer.fromJson(<String, dynamic>{
          'schemaVersion': 1,
          'run': 'nope',
        }),
        isNull,
      );
      expect(decodeState('{not json'), isNull);
      expect(decodeState(null), isNull);
    });

    test('the notification names the phase, round, time and next step', () {
      final ActiveTimer a = _active(const TabataConfig(prepareSec: 0), t0);
      final NotificationContent c = notificationContent(a, t0 + 6000);
      expect(c.title, 'Work, round 1 of 8');
      expect(c.text, 'Tabata, 0:14 left, next: rest 0:10');
      expect(c.buttons, <(String, String)>[
        (btnToggle, 'Pause'),
        (btnSkip, 'Skip'),
        (btnAdd, '+10s'),
      ]);
    });

    test('a paused run offers Resume', () {
      final ActiveTimer a = _active(const TabataConfig(prepareSec: 0), t0);
      final ActiveTimer paused = a.copyWith(run: a.run.pause(t0 + 3000));
      final NotificationContent c = notificationContent(paused, t0 + 9000);
      expect(c.title, startsWith('Paused'));
      expect(c.buttons.first, (btnToggle, 'Resume'));
    });

    test('the stopwatch notification has no skip or +10s', () {
      final ActiveTimer a = _active(
        const StopwatchConfig(),
        t0,
        title: 'Stopwatch',
      );
      final NotificationContent c = notificationContent(a, t0 + 65000);
      expect(c.text, 'Stopwatch, 1:05');
      expect(c.buttons, <(String, String)>[(btnToggle, 'Pause')]);
    });

    test('buttons act on the run', () {
      final ActiveTimer a = _active(const TabataConfig(prepareSec: 0), t0);
      final ActiveTimer paused = applyButton(a, btnToggle, t0 + 1000)!;
      expect(paused.run.isPaused, isTrue);
      expect(paused.updatedAtMs, t0 + 1000);
      final ActiveTimer resumed = applyButton(paused, btnToggle, t0 + 4000)!;
      expect(resumed.run.isPaused, isFalse);
      final ActiveTimer skipped = applyButton(a, btnSkip, t0 + 2000)!;
      expect(skipped.run.snapshotAt(t0 + 2000).step!.label, 'Rest');
      final ActiveTimer longer = applyButton(a, btnAdd, t0 + 2000)!;
      expect(longer.run.snapshotAt(t0 + 2000).stepDurationMs, 30000);
      expect(applyButton(a, 'unknown', t0), isNull);
      expect(applyButton(a, btnSkip, t0 + 10 * 60000), isNull);
    });

    test('only the same run is merged', () {
      final ActiveTimer a = _active(const TabataConfig(), t0);
      expect(a.sameRunAs(a.run), isTrue);
      expect(a.sameRunAs(TimerRun.rest(90, t0)), isFalse);
      expect(
        a.sameRunAs(TimerRun.start(compile(const TabataConfig()), t0 + 1)),
        isFalse,
      );
    });
  });
}
