import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/exercise.dart';
import '../../models/measurement.dart';
import '../../models/plate_inventory.dart';
import '../../models/profile.dart';
import '../../models/timer_preset.dart';
import '../../models/training.dart';
import '../../../engines/records/records.dart';
import '../ids.dart';
import '../user/user_db.dart';
import 'backup_snapshot.dart';
import 'exercise_repository.dart';
import 'measurement_repository.dart';
import 'payload.dart';
import 'routine_repository.dart';
import 'session_repository.dart';
import 'timer_preset_repository.dart';

/// How a restore treats what is already on the device.
enum RestoreMode {
  /// Wipe the user's data, then write the backup.
  replace,

  /// Keep what is here; write an incoming record only when it is new or its
  /// `updatedAt` is newer than the local one.
  merge,
}

/// Counts per section, by the section's backup key.
class BackupWriteResult {
  const BackupWriteResult({required this.written, required this.kept});

  /// Records inserted or overwritten.
  final Map<String, int> written;

  /// Merge only: records left as they were (local is newer or equal).
  final Map<String, int> kept;
}

/// Reads and writes the whole user database for backup and restore.
///
/// Both directions are one drift transaction: a backup is a consistent
/// snapshot, and a restore is all or nothing (any error rolls everything
/// back and is rethrown).
///
/// Not part of a backup: `runtime_states` (running timer, seed markers). A
/// replace restore leaves it alone, so a built-in the user deleted before
/// backing up is not re-seeded.
class BackupRepository {
  BackupRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<BackupSnapshot> readAll() => _db.transaction(() async {
    final ProfileRow? profile = await _db
        .select(_db.profiles)
        .getSingleOrNull();
    final PlateInventoryRow? plates = await _db
        .select(_db.plateInventories)
        .getSingleOrNull();
    return BackupSnapshot(
      profile: profile == null ? null : _profile(profile),
      customExercises: await CustomExerciseRepository(_db).all(),
      tombstones: await CustomExerciseRepository(_db).tombstones(),
      routines: await RoutineRepository(_db).allWithItems(),
      sessions: await SessionRepository(_db).allWithTree(),
      measurementFields: await MeasurementRepository(_db)
          .fields(includeArchived: true),
      measurementEntries: await MeasurementRepository(_db).entries(),
      timerPresets: await TimerPresetRepository(_db).all(),
      plateInventory: plates == null ? null : _plates(plates),
    );
  });

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<BackupWriteResult> writeAll(
    BackupSnapshot s, {
    required RestoreMode mode,
  }) => _db.transaction(() async {
    final Map<String, int> written = <String, int>{};
    final Map<String, int> kept = <String, int>{};
    final bool replace = mode == RestoreMode.replace;
    if (replace) await _wipe();

    void count(String section, bool wrote) {
      final Map<String, int> into = wrote ? written : kept;
      into[section] = (into[section] ?? 0) + 1;
    }

    // Profile and plate inventory: one row each, the newer updatedAt wins.
    if (s.profile != null) {
      final ProfileRow? local = await _db
          .select(_db.profiles)
          .getSingleOrNull();
      final bool write =
          replace ||
          local == null ||
          _isNewer(s.profile!.updatedAt, local.updatedAt);
      if (write) await _putProfile(s.profile!);
      count('profile', write);
    }
    if (s.plateInventory != null) {
      final PlateInventoryRow? local = await _db
          .select(_db.plateInventories)
          .getSingleOrNull();
      final bool write =
          replace ||
          local == null ||
          _isNewer(s.plateInventory!.updatedAt, local.updatedAt);
      if (write) await _putPlates(s.plateInventory!);
      count('plateInventory', write);
    }

    final Map<String, DateTime> customStamps = replace
        ? const <String, DateTime>{}
        : await _stamps(
            _db.customExercises,
            _db.customExercises.id,
            _db.customExercises.updatedAt,
          );
    for (final Exercise e in s.customExercises) {
      final bool write = replace || _isNewer(e.updatedAt, customStamps[e.id]);
      if (write) {
        await _db
            .into(_db.customExercises)
            .insertOnConflictUpdate(CustomExerciseRepository.companion(e));
      }
      count('customExercises', write);
    }

    for (final ExerciseTombstone t in s.tombstones) {
      await _db
          .into(_db.exerciseTombstones)
          .insertOnConflictUpdate(
            ExerciseTombstonesCompanion.insert(
              exerciseId: t.exerciseId,
              name: t.name,
              trackingType: t.trackingType,
              removedInLibraryVersion: t.removedInLibraryVersion,
            ),
          );
      count('tombstones', true);
    }

    final Map<String, DateTime> routineStamps = replace
        ? const <String, DateTime>{}
        : await _stamps(_db.routines, _db.routines.id, _db.routines.updatedAt);
    for (final Routine r in s.routines) {
      final bool write = replace || _isNewer(r.updatedAt, routineStamps[r.id]);
      if (write) await _putRoutine(r);
      count('routines', write);
    }

    final Map<String, DateTime> sessionStamps = replace
        ? const <String, DateTime>{}
        : await _stamps(
            _db.workoutSessions,
            _db.workoutSessions.id,
            _db.workoutSessions.updatedAt,
          );
    final String? localActive = replace
        ? null
        : (await (_db.select(_db.workoutSessions)
                    ..where(($WorkoutSessionsTable t) => t.endedAt.isNull()))
                  .getSingleOrNull())
              ?.id;
    final SessionRepository sessions = SessionRepository(_db);
    for (final WorkoutSession w in s.sessions) {
      bool write = replace || _isNewer(w.updatedAt, sessionStamps[w.id]);
      // Only one session may be running. An unfinished session from the
      // backup never displaces the one in progress here.
      if (write &&
          w.endedAt == null &&
          localActive != null &&
          localActive != w.id) {
        write = false;
      }
      if (write) await sessions.saveTree(w);
      count('sessions', write);
    }

    final Map<String, DateTime> fieldStamps = replace
        ? const <String, DateTime>{}
        : await _stamps(
            _db.measurementFields,
            _db.measurementFields.id,
            _db.measurementFields.updatedAt,
          );
    for (final MeasurementField f in s.measurementFields) {
      final bool write = replace || _isNewer(f.updatedAt, fieldStamps[f.id]);
      if (write) await _putField(f);
      count('measurementFields', write);
    }

    final Map<String, DateTime> entryStamps = replace
        ? const <String, DateTime>{}
        : await _stamps(
            _db.measurementEntries,
            _db.measurementEntries.id,
            _db.measurementEntries.updatedAt,
          );
    for (final MeasurementEntry e in s.measurementEntries) {
      final bool write = replace || _isNewer(e.updatedAt, entryStamps[e.id]);
      if (write) await _putEntry(e);
      count('measurementEntries', write);
    }

    final Map<String, DateTime> presetStamps = replace
        ? const <String, DateTime>{}
        : await _stamps(
            _db.timerPresets,
            _db.timerPresets.id,
            _db.timerPresets.updatedAt,
          );
    for (final TimerPreset p in s.timerPresets) {
      final bool write = replace || _isNewer(p.updatedAt, presetStamps[p.id]);
      if (write) await _putPreset(p);
      count('timerPresets', write);
    }

    // Merging or replacing changes which set beat which: recompute the PR
    // flags in this same transaction so history never shows stale badges.
    if (replace || (written['sessions'] ?? 0) > 0) await _recomputePrFlags();

    return BackupWriteResult(written: written, kept: kept);
  });

  /// Recomputes `is_pr` over every finished session ([Records.prSetIds]) and
  /// writes only the sets whose flag changed, as one batch. A running
  /// session is left alone.
  Future<void> _recomputePrFlags() async {
    final List<WorkoutSession> finished = <WorkoutSession>[
      for (final WorkoutSession s in await SessionRepository(_db).allWithTree())
        if (s.endedAt != null) s,
    ];
    final Set<String> pr = Records.prSetIds(finished);
    final List<String> setPr = <String>[];
    final List<String> setNotPr = <String>[];
    for (final WorkoutSession s in finished) {
      for (final SessionExercise e in s.exercises) {
        for (final SetEntry set in e.sets) {
          final bool should = set.completed && pr.contains(set.id);
          if (should == set.isPR) continue;
          (should ? setPr : setNotPr).add(set.id);
        }
      }
    }
    if (setPr.isEmpty && setNotPr.isEmpty) return;
    await _db.batch((Batch b) {
      for (final (List<String> ids, bool flag) in <(List<String>, bool)>[
        (setPr, true),
        (setNotPr, false),
      ]) {
        for (int i = 0; i < ids.length; i += 500) {
          final List<String> chunk = ids.sublist(
            i,
            i + 500 > ids.length ? ids.length : i + 500,
          );
          b.update(
            _db.setEntries,
            SetEntriesCompanion(isPr: Value<bool>(flag)),
            where: ($SetEntriesTable t) => t.id.isIn(chunk),
          );
        }
      }
    });
  }

  /// Deletes the user's data, children before parents. (Foreign keys cascade
  /// too; being explicit keeps this independent of the pragma.)
  Future<void> _wipe() async {
    await _db.delete(_db.setEntries).go();
    await _db.delete(_db.sessionExercises).go();
    await _db.delete(_db.workoutSessions).go();
    await _db.delete(_db.routineItems).go();
    await _db.delete(_db.routines).go();
    await _db.delete(_db.measurementValues).go();
    await _db.delete(_db.measurementEntries).go();
    await _db.delete(_db.measurementFields).go();
    await _db.delete(_db.customExercises).go();
    await _db.delete(_db.exerciseTombstones).go();
    await _db.delete(_db.timerPresets).go();
    await _db.delete(_db.plateInventories).go();
    await _db.delete(_db.profiles).go();
  }

  /// A missing incoming stamp counts as oldest; a missing local record is
  /// always replaced.
  static bool _isNewer(DateTime? incoming, DateTime? local) {
    if (local == null) return true;
    if (incoming == null) return false;
    return incoming.isAfter(local);
  }

  Future<Map<String, DateTime>> _stamps(
    TableInfo<Table, dynamic> table,
    GeneratedColumn<String> id,
    GeneratedColumn<DateTime> updatedAt,
  ) async {
    final List<TypedResult> rows = await (_db.selectOnly(
      table,
    )..addColumns(<Expression<Object>>[id, updatedAt])).get();
    return <String, DateTime>{
      for (final TypedResult r in rows) r.read(id)!: r.read(updatedAt)!,
    };
  }

  // ── Row writers (keep updatedAt exactly as the backup has it) ─────────────

  Future<void> _putProfile(Profile p) => _db
      .into(_db.profiles)
      .insertOnConflictUpdate(
        ProfilesCompanion.insert(
          id: const Value<String>('me'),
          sex: Value(p.sex),
          birthYear: Value(p.birthYear),
          heightCm: Value(p.heightCm),
          activityLevel: Value(p.activityLevel),
          weightUnit: Value(p.weightUnit),
          lengthUnit: Value(p.lengthUnit),
          distanceUnit: Value(p.distanceUnit),
          bmiCutoffs: Value(p.bmiCutoffs),
          updatedAt: p.updatedAt ?? _clock(),
        ),
      );

  Future<void> _putPlates(PlateInventory p) => _db
      .into(_db.plateInventories)
      .insertOnConflictUpdate(
        PlateInventoriesCompanion.insert(
          id: const Value<String>('default'),
          payload: jsonEncode(p.toJson()),
          updatedAt: p.updatedAt ?? _clock(),
        ),
      );

  Future<void> _putRoutine(Routine r) async {
    await _db
        .into(_db.routines)
        .insertOnConflictUpdate(
          RoutinesCompanion.insert(
            id: r.id,
            name: r.name,
            notes: Value<String?>(r.notes),
            position: Value<int>(r.position),
            archived: Value<bool>(r.archived),
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        );
    await (_db.delete(
      _db.routineItems,
    )..where(($RoutineItemsTable t) => t.routineId.equals(r.id))).go();
    await _db.batch((Batch b) {
      b.insertAll(_db.routineItems, <RoutineItemsCompanion>[
        for (final RoutineItem i in r.items) RoutineRepository.itemRow(r.id, i),
      ]);
    });
  }

  Future<void> _putField(MeasurementField f) => _db
      .into(_db.measurementFields)
      .insertOnConflictUpdate(
        MeasurementFieldsCompanion.insert(
          id: f.id,
          name: f.name,
          unitType: f.unitType,
          customUnit: Value<String?>(f.customUnit),
          side: Value(f.side),
          pairId: Value<String?>(f.pairId),
          bodyAnchor: Value(f.bodyAnchor),
          enabled: Value<bool>(f.enabled),
          position: Value<int>(f.position),
          builtIn: Value<bool>(f.builtIn),
          archived: Value<bool>(f.archived),
          updatedAt: f.updatedAt,
        ),
      );

  Future<void> _putEntry(MeasurementEntry e) async {
    await _db
        .into(_db.measurementEntries)
        .insertOnConflictUpdate(
          MeasurementEntriesCompanion.insert(
            id: e.id,
            date: e.date,
            note: Value<String?>(e.note),
            updatedAt: e.updatedAt,
          ),
        );
    await (_db.delete(
      _db.measurementValues,
    )..where(($MeasurementValuesTable t) => t.entryId.equals(e.id))).go();
    await _db.batch((Batch b) {
      b.insertAll(_db.measurementValues, <MeasurementValuesCompanion>[
        for (final MapEntry<String, double> v in e.values.entries)
          MeasurementValuesCompanion.insert(
            entryId: e.id,
            fieldId: v.key,
            value: v.value,
          ),
      ]);
    });
  }

  Future<void> _putPreset(TimerPreset p) => _db
      .into(_db.timerPresets)
      .insertOnConflictUpdate(
        TimerPresetsCompanion.insert(
          id: p.id,
          name: p.name,
          mode: p.mode,
          payload: jsonEncode(p.toJson()),
          position: Value<int>(p.position),
          builtIn: Value<bool>(p.builtIn),
          updatedAt: p.updatedAt,
        ),
      );

  // ── Row readers ───────────────────────────────────────────────────────────

  static Profile _profile(ProfileRow r) => Profile(
    sex: r.sex,
    birthYear: r.birthYear,
    heightCm: r.heightCm,
    activityLevel: r.activityLevel,
    weightUnit: r.weightUnit,
    lengthUnit: r.lengthUnit,
    distanceUnit: r.distanceUnit,
    bmiCutoffs: r.bmiCutoffs,
    updatedAt: r.updatedAt,
  );

  /// An unreadable or newer payload is left out of the backup rather than
  /// failing it (the same rule the repository applies on read).
  static PlateInventory? _plates(PlateInventoryRow r) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(r.payload) as Map<String, dynamic>;
      if (payloadVersion(json) > PlateInventory.currentSchemaVersion) {
        return null;
      }
      return PlateInventory.fromJson(json).copyWith(updatedAt: r.updatedAt);
    } on Object {
      return null;
    }
  }
}
