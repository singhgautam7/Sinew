import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/ids.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/repositories/measurement_repository.dart';
import 'package:sinew/core/db/repositories/plate_inventory_repository.dart';
import 'package:sinew/core/db/repositories/profile_repository.dart';
import 'package:sinew/core/db/repositories/routine_repository.dart';
import 'package:sinew/core/db/repositories/runtime_state_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/repositories/timer_preset_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/plate_inventory.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/core/models/training.dart';

import '../helpers/test_db.dart';

void main() {
  late UserDatabase db;
  late Clock clock;

  setUp(() {
    db = memoryUserDb();
    clock = steppingClock();
  });
  tearDown(() => db.close());

  group('ProfileRepository', () {
    test('reads defaults before anything is saved', () async {
      final Profile p = await ProfileRepository(db).get();
      expect(p, const Profile());
      expect(p.weightUnit, WeightUnit.kg);
      expect(p.bmiCutoffs, BmiCutoffs.who);
    });

    test('round-trips every field', () async {
      final ProfileRepository repo = ProfileRepository(db, clock: clock);
      final Profile p = Profile(
        sex: Sex.female,
        birthYear: 1994,
        heightCm: 168.5,
        activityLevel: ActivityLevel.veryActive,
        weightUnit: WeightUnit.lb,
        lengthUnit: LengthUnit.inch,
        distanceUnit: DistanceUnit.mi,
        bmiCutoffs: BmiCutoffs.asian,
        updatedAt: DateTime.utc(2026, 2, 2),
      );
      await repo.save(p);
      final Profile back = await repo.get();
      expect(back.copyWith(updatedAt: back.updatedAt?.toUtc()), p);
    });
  });

  group('CustomExerciseRepository', () {
    test('assigns a custom id, archives without deleting', () async {
      final CustomExerciseRepository repo = CustomExerciseRepository(
        db,
        clock: clock,
      );
      final Exercise saved = await repo.save(
        const Exercise(
          id: '',
          name: 'Garage sled push',
          category: 'strength',
          trackingType: TrackingType.distanceTime,
          equipment: <String>['sled'],
        ),
      );
      expect(saved.id, startsWith(Exercise.customPrefix));
      expect(saved.isCustom, isTrue);

      await repo.setArchived(saved.id, archived: true);
      expect(await repo.watchAll().first, isEmpty);
      final List<Exercise> all = await repo
          .watchAll(includeArchived: true)
          .first;
      expect(all.single.archived, isTrue);
      expect(all.single.equipment, <String>['sled']);
    });
  });

  group('RoutineRepository', () {
    test('save replaces items and keeps their order', () async {
      final RoutineRepository repo = RoutineRepository(db, clock: clock);
      final DateTime now = clock();
      Routine r = Routine(
        id: newId(),
        name: 'Push A',
        createdAt: now,
        updatedAt: now,
        items: <RoutineItem>[
          RoutineItem(id: newId(), exerciseId: 'bench-press', position: 1),
          RoutineItem(
            id: newId(),
            exerciseId: 'overhead-press',
            position: 0,
            targetReps: 8,
            restSec: 90,
          ),
        ],
      );
      await repo.save(r);
      Routine back = (await repo.byId(r.id))!;
      expect(back.items.map((RoutineItem i) => i.exerciseId), <String>[
        'overhead-press',
        'bench-press',
      ]);
      expect(back.items.first.targetReps, 8);

      r = r.copyWith(items: <RoutineItem>[r.items.first]);
      await repo.save(r);
      back = (await repo.byId(r.id))!;
      expect(back.items, hasLength(1));

      await repo.delete(r.id);
      expect(await repo.byId(r.id), isNull);
      expect(await db.select(db.routineItems).get(), isEmpty);
    });
  });

  group('SessionRepository', () {
    test('one active session; sets persist one by one', () async {
      final SessionRepository repo = SessionRepository(db, clock: clock);
      final WorkoutSession s = await repo.start(name: 'Legs');
      await expectLater(repo.start(), throwsA(isA<ActiveSessionExists>()));

      final SessionExercise squat = await repo.addExercise(s.id, 'back-squat');
      final SessionExercise lunge = await repo.addExercise(s.id, 'lunge');
      expect(lunge.position, squat.position + 1);

      final SetEntry set1 = SetEntry(
        id: newId(),
        position: 0,
        weightKg: 100,
        reps: 5,
        completed: true,
      );
      await repo.upsertSet(s.id, squat.id, set1);
      await repo.upsertSet(s.id, squat.id, set1.copyWith(reps: 6));

      // What a restart after process death would read back.
      final WorkoutSession active = (await repo.active())!;
      expect(active.id, s.id);
      expect(active.exercises.first.sets.single.reps, 6);
      expect(active.updatedAt.isAfter(s.updatedAt), isTrue);

      await repo.finish(
        s.id,
        endedAt: clock(),
        durationSec: 3600,
        volumeKg: 600,
        caloriesKcal: 250,
      );
      expect(await repo.active(), isNull);
      expect(await repo.finishedCount(), 1);
      final List<WorkoutSession> history = await repo.watchHistory().first;
      expect(history.single.volumeKg, 600);
    });

    test(
      'previousSets returns the latest finished session for an exercise',
      () async {
        final SessionRepository repo = SessionRepository(db, clock: clock);
        Future<void> session(double kg) async {
          final WorkoutSession s = await repo.start();
          final SessionExercise e = await repo.addExercise(s.id, 'deadlift');
          await repo.upsertSet(
            s.id,
            e.id,
            SetEntry(id: newId(), position: 0, weightKg: kg, reps: 3),
          );
          await repo.finish(s.id, endedAt: clock());
        }

        await session(140);
        await session(150);
        final WorkoutSession current = await repo.start();
        await repo.addExercise(current.id, 'deadlift');

        final List<SetEntry> prev = await repo.previousSets('deadlift');
        expect(prev.single.weightKg, 150);
        expect(await repo.previousSets('bench-press'), isEmpty);
      },
    );

    test('saveTree and allWithTree round-trip a whole session', () async {
      final SessionRepository repo = SessionRepository(db, clock: clock);
      final DateTime t = DateTime.utc(2026, 5, 1, 7);
      final WorkoutSession s = WorkoutSession(
        id: newId(),
        startedAt: t,
        endedAt: t.add(const Duration(hours: 1)),
        source: SessionSource.import,
        updatedAt: t,
        exercises: <SessionExercise>[
          SessionExercise(
            id: newId(),
            exerciseId: 'plank',
            position: 0,
            sets: <SetEntry>[
              SetEntry(id: newId(), position: 0, holdSec: 60, isPR: true),
              SetEntry(id: newId(), position: 1, holdSec: 45, isWarmup: true),
            ],
          ),
        ],
      );
      await repo.saveTree(s);
      final WorkoutSession back = (await repo.allWithTree()).single;
      expect(back.exercises.single.sets.map((SetEntry x) => x.holdSec), <int>[
        60,
        45,
      ]);
      expect(back.exercises.single.sets.first.isPR, isTrue);
      expect(back.source, SessionSource.import);

      await repo.delete(s.id);
      expect(await db.select(db.setEntries).get(), isEmpty);
    });
  });

  group('MeasurementRepository', () {
    MeasurementField field(String id, {BodyAnchor? anchor, int pos = 0}) =>
        MeasurementField(
          id: id,
          name: id,
          unitType: MeasurementUnitType.length,
          bodyAnchor: anchor,
          position: pos,
          updatedAt: DateTime.utc(2026),
        );

    test('entries, latest values and history', () async {
      final MeasurementRepository repo = MeasurementRepository(
        db,
        clock: clock,
      );
      await repo.saveField(field('waist', anchor: BodyAnchor.waist));
      await repo.saveField(field('weight'));
      await repo.saveEntry(
        MeasurementEntry(
          id: 'e1',
          date: DateTime.utc(2026, 1, 1),
          values: <String, double>{'waist': 90, 'weight': 80},
          updatedAt: DateTime.utc(2026),
        ),
      );
      await repo.saveEntry(
        MeasurementEntry(
          id: 'e2',
          date: DateTime.utc(2026, 2, 1),
          values: <String, double>{'waist': 88},
          updatedAt: DateTime.utc(2026),
        ),
      );

      final Map<String, ({double value, DateTime date})> latest = await repo
          .latestValues();
      expect(latest['waist']!.value, 88);
      // Weight is not in the newest entry, so it comes from the older one.
      expect(latest['weight']!.value, 80);

      final List<({DateTime date, double value})> h = await repo.history(
        'waist',
      );
      expect(h.map((r) => r.value), <double>[90, 88]);

      final List<MeasurementEntry> entries = await repo.entries();
      expect(entries.first.id, 'e2');
      expect(entries.last.values, <String, double>{'waist': 90, 'weight': 80});
    });

    test(
      'removing a field with data archives it; without data deletes it',
      () async {
        final MeasurementRepository repo = MeasurementRepository(
          db,
          clock: clock,
        );
        await repo.saveField(field('neck'));
        await repo.saveField(field('wrist'));
        await repo.saveEntry(
          MeasurementEntry(
            id: 'e1',
            date: DateTime.utc(2026),
            values: <String, double>{'neck': 38},
            updatedAt: DateTime.utc(2026),
          ),
        );
        expect(await repo.removeField('neck'), FieldRemoval.archived);
        expect(await repo.removeField('wrist'), FieldRemoval.deleted);
        expect(await repo.fields(), isEmpty);
        final List<MeasurementField> all = await repo.fields(
          includeArchived: true,
        );
        expect(all.single.id, 'neck');
        expect(all.single.enabled, isFalse);
        expect((await repo.history('neck')).single.value, 38);
      },
    );

    test('reorder writes positions', () async {
      final MeasurementRepository repo = MeasurementRepository(
        db,
        clock: clock,
      );
      await repo.saveField(field('a', pos: 0));
      await repo.saveField(field('b', pos: 1));
      await repo.reorderFields(<String>['b', 'a']);
      expect((await repo.fields()).map((MeasurementField f) => f.id), <String>[
        'b',
        'a',
      ]);
    });
  });

  group('JSON payload repositories', () {
    test('timer presets round-trip; unreadable payloads are skipped', () async {
      final TimerPresetRepository repo = TimerPresetRepository(
        db,
        clock: clock,
      );
      final TimerPreset tabata = TimerPreset(
        id: 'tabata',
        name: 'Tabata',
        mode: TimerMode.tabata,
        steps: const <TimerStepSpec>[
          TimerStepSpec(
            label: 'Work',
            durationMs: 20000,
            phase: TimerPhase.work,
          ),
          TimerStepSpec(
            label: 'Rest',
            durationMs: 10000,
            phase: TimerPhase.rest,
          ),
        ],
        cues: const TimerCues(voice: true),
        updatedAt: DateTime.utc(2026),
      );
      await repo.save(tabata);
      final TimerPreset back = (await repo.byId('tabata'))!;
      expect(back.steps, tabata.steps);
      expect(back.cues.voice, isTrue);
      expect(back.schemaVersion, TimerPreset.currentSchemaVersion);

      DateTime t = DateTime.utc(2026);
      await db
          .into(db.timerPresets)
          .insert(
            TimerPresetsCompanion.insert(
              id: 'corrupt',
              name: 'x',
              mode: TimerMode.custom,
              payload: '{not json',
              updatedAt: t,
            ),
          );
      t = t.add(const Duration(seconds: 1));
      await db
          .into(db.timerPresets)
          .insert(
            TimerPresetsCompanion.insert(
              id: 'future',
              name: 'y',
              mode: TimerMode.custom,
              payload: jsonEncode(<String, Object>{
                'schemaVersion': 99,
                'id': 'future',
              }),
              updatedAt: t,
              position: const Value<int>(5),
            ),
          );
      expect((await repo.all()).map((TimerPreset p) => p.id), <String>[
        'tabata',
      ]);
    });

    test(
      'plate inventory: default, round trip, newer payload falls back',
      () async {
        final PlateInventoryRepository repo = PlateInventoryRepository(
          db,
          clock: clock,
        );
        expect(await repo.get(), PlateInventory.metricDefault);
        final PlateInventory mine = PlateInventory.metricDefault.copyWith(
          plates: const <PlateStock>[PlateStock(weightKg: 20, count: 2)],
        );
        await repo.save(mine);
        expect((await repo.get()).plates, mine.plates);

        await (db.update(db.plateInventories)).write(
          const PlateInventoriesCompanion(
            payload: Value<String>('{"schemaVersion": 7}'),
          ),
        );
        expect(await repo.get(), PlateInventory.metricDefault);
      },
    );

    test('runtime state survives, newer versions read as absent', () async {
      final RuntimeStateRepository repo = RuntimeStateRepository(
        db,
        clock: clock,
      );
      await repo.write(RuntimeStateRepository.runningTimer, <String, Object>{
        'schemaVersion': 1,
        'startedAtMs': 123,
      });
      expect(
        (await repo.read(RuntimeStateRepository.runningTimer))!['startedAtMs'],
        123,
      );
      await repo.write('other', <String, Object>{'schemaVersion': 2});
      expect(await repo.read('other'), isNull);
      await repo.clear(RuntimeStateRepository.runningTimer);
      expect(await repo.read(RuntimeStateRepository.runningTimer), isNull);
    });
  });
}
