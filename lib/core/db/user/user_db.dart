import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../models/enums.dart';
import '../converters.dart';

part 'user_db.g.dart';

/// Everything the user makes. One SQLite file, separate from the exercise
/// library: a library replacement cannot touch this, and a migration here
/// cannot touch the library.
///
/// Rules:
/// - Every value is metric (kg, cm, metres, seconds).
/// - Exercises are referenced by their stable string id, never a row id.
/// - Ids are random text ids (`newId()`), so a backup merges by id across
///   devices; `updatedAt` decides a merge conflict.
/// - JSON columns carry their own `schemaVersion` inside the payload.

/// Singleton row, id `me`.
@DataClassName('ProfileRow')
class Profiles extends Table {
  TextColumn get id => text().withDefault(const Constant('me'))();
  TextColumn get sex => textEnum<Sex>().nullable()();
  IntColumn get birthYear => integer().nullable()();
  RealColumn get heightCm => real().nullable()();
  TextColumn get activityLevel => textEnum<ActivityLevel>().withDefault(
    Constant(ActivityLevel.moderate.name),
  )();
  TextColumn get weightUnit =>
      textEnum<WeightUnit>().withDefault(Constant(WeightUnit.kg.name))();
  TextColumn get lengthUnit =>
      textEnum<LengthUnit>().withDefault(Constant(LengthUnit.cm.name))();
  TextColumn get distanceUnit =>
      textEnum<DistanceUnit>().withDefault(Constant(DistanceUnit.km.name))();
  TextColumn get bmiCutoffs =>
      textEnum<BmiCutoffs>().withDefault(Constant(BmiCutoffs.who.name))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Same shape as a library exercise, `isCustom = true` implied.
@DataClassName('CustomExerciseRow')
class CustomExercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get aliases => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get sanskritName => text().nullable()();
  TextColumn get category => text()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get trackingType => textEnum<TrackingType>()();
  TextColumn get primaryMuscles => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get secondaryMuscles => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get equipment => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get difficulty => textEnum<Difficulty>().nullable()();
  BoolColumn get unilateral => boolean().withDefault(const Constant(false))();
  TextColumn get mechanic => text().nullable()();
  TextColumn get force => text().nullable()();
  TextColumn get steps => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get tips => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get commonMistakes => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get safetyNotes => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get contraindications => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  RealColumn get metValue => real().nullable()();
  IntColumn get defaultRestSec => integer().nullable()();
  IntColumn get defaultHoldSec => integer().nullable()();
  TextColumn get variationOf => text().nullable()();
  TextColumn get tags => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Library exercises removed by a library update but still referenced by the
/// user's data: enough to keep old sessions readable.
@DataClassName('ExerciseTombstoneRow')
class ExerciseTombstones extends Table {
  TextColumn get exerciseId => text()();
  TextColumn get name => text()();
  TextColumn get trackingType => textEnum<TrackingType>()();
  TextColumn get removedInLibraryVersion => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{exerciseId};
}

@DataClassName('RoutineRow')
class Routines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get notes => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('RoutineItemRow')
@TableIndex(name: 'routine_items_routine', columns: <Symbol>{#routineId})
class RoutineItems extends Table {
  TextColumn get id => text()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()();
  IntColumn get position => integer()();
  IntColumn get supersetGroup => integer().nullable()();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  IntColumn get targetReps => integer().nullable()();
  IntColumn get targetDurationSec => integer().nullable()();
  RealColumn get targetDistanceM => real().nullable()();
  RealColumn get targetWeightKg => real().nullable()();
  IntColumn get restSec => integer().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// `ended_at IS NULL` is the active session. A partial unique index created in
/// the migration allows at most one.
@DataClassName('WorkoutSessionRow')
@TableIndex(name: 'workout_sessions_started', columns: <Symbol>{#startedAt})
class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get routineId => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get perceivedEffort => integer().nullable()();
  TextColumn get source => textEnum<SessionSource>().withDefault(
    Constant(SessionSource.manual.name),
  )();
  IntColumn get durationSec => integer().nullable()();
  RealColumn get volumeKg => real().nullable()();
  RealColumn get caloriesKcal => real().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('SessionExerciseRow')
@TableIndex(name: 'session_exercises_session', columns: <Symbol>{#sessionId})
@TableIndex(name: 'session_exercises_exercise', columns: <Symbol>{#exerciseId})
class SessionExercises extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()();
  IntColumn get position => integer()();
  IntColumn get supersetGroup => integer().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('SetEntryRow')
@TableIndex(
  name: 'set_entries_session_exercise',
  columns: <Symbol>{#sessionExerciseId},
)
class SetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get sessionExerciseId =>
      text().references(SessionExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get type =>
      textEnum<SetType>().withDefault(Constant(SetType.normal.name))();
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSec => integer().nullable()();
  RealColumn get distanceM => real().nullable()();
  IntColumn get rounds => integer().nullable()();
  IntColumn get holdSec => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();
  BoolColumn get isPr => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('MeasurementFieldRow')
class MeasurementFields extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get unitType => textEnum<MeasurementUnitType>()();
  TextColumn get customUnit => text().nullable()();
  TextColumn get side =>
      textEnum<BodySide>().withDefault(Constant(BodySide.none.name))();
  TextColumn get pairId => text().nullable()();
  TextColumn get bodyAnchor => textEnum<BodyAnchor>().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  BoolColumn get builtIn => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('MeasurementEntryRow')
@TableIndex(name: 'measurement_entries_date', columns: <Symbol>{#date})
class MeasurementEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// One value of one entry. Normalised (not a JSON map) so a chart reads one
/// field's history with an indexed query.
@DataClassName('MeasurementValueRow')
@TableIndex(name: 'measurement_values_field', columns: <Symbol>{#fieldId})
class MeasurementValues extends Table {
  TextColumn get entryId =>
      text().references(MeasurementEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get fieldId => text()();
  RealColumn get value => real()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{entryId, fieldId};
}

/// The sequence and cues are a JSON `TimerPreset` payload with its own
/// `schemaVersion`; the columns here are only what lists sort and filter by.
@DataClassName('TimerPresetRow')
class TimerPresets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get mode => textEnum<TimerMode>()();
  TextColumn get payload => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  BoolColumn get builtIn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Singleton row, id `default`. A JSON `PlateInventory` payload.
@DataClassName('PlateInventoryRow')
class PlateInventories extends Table {
  TextColumn get id => text().withDefault(const Constant('default'))();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Persisted state of a running timer or anything else that must survive
/// process death, by key. Values are JSON with their own `schemaVersion`.
@DataClassName('RuntimeStateRow')
class RuntimeStates extends Table {
  TextColumn get key => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

@DriftDatabase(
  tables: <Type>[
    Profiles,
    CustomExercises,
    ExerciseTombstones,
    Routines,
    RoutineItems,
    WorkoutSessions,
    SessionExercises,
    SetEntries,
    MeasurementFields,
    MeasurementEntries,
    MeasurementValues,
    TimerPresets,
    PlateInventories,
    RuntimeStates,
  ],
)
class UserDatabase extends _$UserDatabase {
  /// One drift server isolate for the process, found by name, so the timer's
  /// foreground-service isolate and the UI share one writer (Mull's pattern).
  UserDatabase()
    : super(
        driftDatabase(
          name: 'sinew_user',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  /// Test constructor: an in-memory database with the same schema.
  UserDatabase.forTesting(super.executor);

  /// Bump on every schema change and add a step to [migration]. Never edit a
  /// shipped step; add a new one. Changing the schema after Phase 2 needs
  /// sign-off (see CLAUDE.md).
  static const int currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createActiveSessionIndex();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from > to) throw UnsupportedSchemaVersion(from, to);
      // Steps go here, one `if (from < n)` block per version, in order.
      // A database newer than this build (a downgrade) is refused in
      // [beforeOpen] rather than guessed at.
    },
    beforeOpen: (OpeningDetails details) async {
      final int? before = details.versionBefore;
      if (before != null && before > currentSchemaVersion) {
        throw UnsupportedSchemaVersion(before, currentSchemaVersion);
      }
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createActiveSessionIndex() => customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS workout_sessions_one_active '
    'ON workout_sessions ((1)) WHERE ended_at IS NULL',
  );
}

/// The database on disk was written by a newer build of Sinew.
class UnsupportedSchemaVersion implements Exception {
  const UnsupportedSchemaVersion(this.found, this.supported);

  final int found;
  final int supported;

  @override
  String toString() =>
      'UnsupportedSchemaVersion: found $found, this build supports $supported';
}
