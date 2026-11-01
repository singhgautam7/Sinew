import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/backup_snapshot.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/repositories/measurement_repository.dart';
import 'package:sinew/core/db/repositories/plate_inventory_repository.dart';
import 'package:sinew/core/db/repositories/profile_repository.dart';
import 'package:sinew/core/db/repositories/routine_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/repositories/timer_preset_repository.dart';
import 'package:sinew/core/db/seeds/measurement_seed.dart';
import 'package:sinew/core/db/repositories/seed_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/plate_inventory.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/core/models/training.dart';

import 'test_db.dart';

/// Fills [db] with a little of everything, through the real repositories.
/// [sessions] finished workouts of two exercises each; with [withActive] one
/// session is left running.
Future<void> populate(
  UserDatabase db, {
  int sessions = 3,
  bool withActive = false,
}) async {
  final DateTime start = DateTime.utc(2026, 1, 1, 9);
  final SessionRepository sessionRepo = SessionRepository(
    db,
    clock: steppingClock(start),
  );

  await ProfileRepository(db, clock: steppingClock(start)).save(
    const Profile(
      sex: Sex.female,
      birthYear: 1994,
      heightCm: 171.5,
      activityLevel: ActivityLevel.light,
      weightUnit: WeightUnit.lb,
      lengthUnit: LengthUnit.inch,
      bmiCutoffs: BmiCutoffs.asian,
    ),
  );

  final CustomExerciseRepository custom = CustomExerciseRepository(
    db,
    clock: steppingClock(start),
  );
  final Exercise mine = await custom.save(
    const Exercise(
      id: '',
      name: 'Garage press',
      category: 'strength',
      trackingType: TrackingType.weightReps,
      aliases: <String>['Floor press'],
      primaryMuscles: <String>['chest'],
      equipment: <String>['barbell'],
      difficulty: Difficulty.advanced,
      steps: <String>['Lie down', 'Press'],
      metValue: 5.5,
    ),
  );
  final Exercise old = await custom.save(
    const Exercise(
      id: '',
      name: 'Old idea',
      category: 'yoga',
      trackingType: TrackingType.hold,
    ),
  );
  await custom.setArchived(old.id, archived: true);
  await custom.addTombstones(const <ExerciseTombstone>[
    ExerciseTombstone(
      exerciseId: 'removed-lift',
      name: 'Removed lift',
      trackingType: TrackingType.reps,
      removedInLibraryVersion: '1.1.0',
    ),
  ]);

  await RoutineRepository(db, clock: steppingClock(start)).save(
    Routine(
      id: 'routine-push',
      name: 'Push day',
      notes: 'Heavy',
      position: 1,
      createdAt: start,
      updatedAt: start,
      items: <RoutineItem>[
        const RoutineItem(
          id: 'ri-1',
          exerciseId: 'bench-press',
          position: 0,
          targetSets: 4,
          targetReps: 6,
          targetWeightKg: 80,
          restSec: 150,
          supersetGroup: 1,
        ),
        RoutineItem(
          id: 'ri-2',
          exerciseId: mine.id,
          position: 1,
          notes: 'Slow',
        ),
      ],
    ),
  );

  for (int i = 0; i < sessions; i++) {
    final DateTime at = start.add(Duration(days: i * 2));
    final WorkoutSession s = await sessionRepo.start(
      name: 'Session $i',
      startedAt: at,
      source: i.isEven ? SessionSource.manual : SessionSource.routine,
      routineId: i.isEven ? null : 'routine-push',
    );
    final SessionExercise bench = await sessionRepo.addExercise(
      s.id,
      'bench-press',
    );
    final SessionExercise plank = await sessionRepo.addExercise(s.id, 'plank');
    for (int k = 0; k < 3; k++) {
      await sessionRepo.upsertSet(
        s.id,
        bench.id,
        SetEntry(
          id: 'set-$i-b$k',
          position: k,
          type: k == 0 ? SetType.normal : SetType.drop,
          weightKg: 60 + k * 2.5,
          reps: 8 - k,
          completed: true,
          isWarmup: k == 0,
          isPR: k == 2,
          completedAt: at.add(Duration(minutes: k)),
        ),
      );
    }
    await sessionRepo.upsertSet(
      s.id,
      plank.id,
      SetEntry(
        id: 'set-$i-p',
        position: 0,
        type: SetType.failure,
        holdSec: 45 + i,
        durationSec: 60,
        distanceM: 12.5,
        rounds: 2,
        completed: i != 1,
      ),
    );
    await sessionRepo.finish(
      s.id,
      endedAt: at.add(const Duration(hours: 1)),
      durationSec: 3600,
      volumeKg: 1234.5,
      caloriesKcal: 410,
      perceivedEffort: 7,
      notes: 'Felt good',
    );
  }
  if (withActive) {
    final WorkoutSession s = await sessionRepo.start(name: 'Running');
    await sessionRepo.addExercise(s.id, 'squat');
  }

  await MeasurementSeed.seed(SeedRepository(db, clock: steppingClock(start)));
  final MeasurementRepository measurements = MeasurementRepository(
    db,
    clock: steppingClock(start),
  );
  await measurements.saveEntry(
    MeasurementEntry(
      id: 'entry-1',
      date: DateTime.utc(2026, 1, 3, 7, 30),
      values: const <String, double>{
        'weight': 72.4,
        'waist': 80,
        'body-fat': 18.5,
      },
      note: 'Morning',
      updatedAt: start,
    ),
  );
  await measurements.saveEntry(
    MeasurementEntry(
      id: 'entry-2',
      date: DateTime.utc(2026, 2, 3, 7, 30),
      values: const <String, double>{'weight': 71.9, 'bicep-left': 33.25},
      updatedAt: start,
    ),
  );
  await measurements.saveField(
    MeasurementField(
      id: 'field-grip',
      name: 'Grip strength',
      unitType: MeasurementUnitType.custom,
      customUnit: 'kg',
      position: 99,
      updatedAt: start,
    ),
  );

  await TimerPresetRepository(db, clock: steppingClock(start)).save(
    TimerPreset(
      id: 'preset-tabata',
      name: 'Tabata',
      mode: TimerMode.tabata,
      steps: const <TimerStepSpec>[
        TimerStepSpec(label: 'Work', durationMs: 20000, phase: TimerPhase.work),
        TimerStepSpec(label: 'Rest', durationMs: 10000, phase: TimerPhase.rest),
        TimerStepSpec(
          label: 'Open',
          phase: TimerPhase.open,
          exerciseId: 'plank',
        ),
      ],
      cues: const TimerCues(voice: true, countdownSec: 5, warningSec: 3),
      position: 2,
      builtIn: true,
      updatedAt: start,
    ),
  );

  await PlateInventoryRepository(db, clock: steppingClock(start)).save(
    PlateInventory.metricDefault.copyWith(
      unit: WeightUnit.lb,
      machineStepKg: 4.5,
    ),
  );
}

/// Sorts every list by id so two snapshots compare regardless of read order.
BackupSnapshot normalized(BackupSnapshot s) => BackupSnapshot(
  profile: s.profile,
  customExercises: <Exercise>[...s.customExercises]
    ..sort((Exercise a, Exercise b) => a.id.compareTo(b.id)),
  tombstones: <ExerciseTombstone>[...s.tombstones]
    ..sort(
      (ExerciseTombstone a, ExerciseTombstone b) =>
          a.exerciseId.compareTo(b.exerciseId),
    ),
  routines: <Routine>[...s.routines]
    ..sort((Routine a, Routine b) => a.id.compareTo(b.id)),
  sessions: <WorkoutSession>[...s.sessions]
    ..sort((WorkoutSession a, WorkoutSession b) => a.id.compareTo(b.id)),
  measurementFields: <MeasurementField>[...s.measurementFields]
    ..sort((MeasurementField a, MeasurementField b) => a.id.compareTo(b.id)),
  measurementEntries: <MeasurementEntry>[...s.measurementEntries]
    ..sort((MeasurementEntry a, MeasurementEntry b) => a.id.compareTo(b.id)),
  timerPresets: <TimerPreset>[...s.timerPresets]
    ..sort((TimerPreset a, TimerPreset b) => a.id.compareTo(b.id)),
  plateInventory: s.plateInventory,
);

/// Asserts two snapshots hold the same models (deep equality, by section so a
/// failure names the section).
void expectSameSnapshot(BackupSnapshot actual, BackupSnapshot expected) {
  final BackupSnapshot a = normalized(actual);
  final BackupSnapshot e = normalized(expected);
  expect(a.profile, e.profile, reason: 'profile');
  expect(a.customExercises, e.customExercises, reason: 'customExercises');
  expect(a.tombstones, e.tombstones, reason: 'tombstones');
  expect(a.routines, e.routines, reason: 'routines');
  expect(a.sessions, e.sessions, reason: 'sessions');
  expect(a.measurementFields, e.measurementFields, reason: 'measurementFields');
  expect(
    a.measurementEntries,
    e.measurementEntries,
    reason: 'measurementEntries',
  );
  expect(a.timerPresets, e.timerPresets, reason: 'timerPresets');
  expect(a.plateInventory, e.plateInventory, reason: 'plateInventory');
}
