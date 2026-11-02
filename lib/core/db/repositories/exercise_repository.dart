import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/exercise.dart';
import '../ids.dart';
import '../user/user_db.dart';
import 'library_repository.dart';

export 'library_repository.dart';
export 'library_types.dart';

/// The user's own exercises, and the tombstones of library exercises a
/// library update removed.
class CustomExerciseRepository {
  CustomExerciseRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  Stream<List<Exercise>> watchAll({bool includeArchived = false}) {
    final SimpleSelectStatement<$CustomExercisesTable, CustomExerciseRow> q =
        _db.select(_db.customExercises)
          ..orderBy(<OrderClauseGenerator<$CustomExercisesTable>>[
            ($CustomExercisesTable t) => OrderingTerm.asc(t.name),
          ]);
    if (!includeArchived) {
      q.where(($CustomExercisesTable t) => t.archived.equals(false));
    }
    return q.watch().map(
      (List<CustomExerciseRow> rows) => rows.map(_map).toList(),
    );
  }

  Future<Exercise?> byId(String id) async {
    final CustomExerciseRow? row = await (_db.select(
      _db.customExercises,
    )..where(($CustomExercisesTable t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _map(row);
  }

  Future<List<Exercise>> byIds(Iterable<String> ids) async {
    final List<String> wanted = ids
        .where((String id) => id.startsWith(Exercise.customPrefix))
        .toSet()
        .toList();
    if (wanted.isEmpty) return const <Exercise>[];
    final List<CustomExerciseRow> rows = await (_db.select(
      _db.customExercises,
    )..where(($CustomExercisesTable t) => t.id.isIn(wanted))).get();
    return rows.map(_map).toList();
  }

  /// Creates or updates. A new exercise without a custom id gets one.
  Future<Exercise> save(Exercise e) async {
    final DateTime now = _clock();
    final Exercise saved = e.copyWith(
      id: e.id.startsWith(Exercise.customPrefix)
          ? e.id
          : '${Exercise.customPrefix}${newId()}',
      isCustom: true,
      createdAt: e.createdAt ?? now,
      updatedAt: now,
    );
    await _db.into(_db.customExercises).insertOnConflictUpdate(_row(saved));
    return saved;
  }

  /// Hidden from pickers, kept for history.
  Future<void> setArchived(String id, {required bool archived}) =>
      (_db.update(
        _db.customExercises,
      )..where(($CustomExercisesTable t) => t.id.equals(id))).write(
        CustomExercisesCompanion(
          archived: Value<bool>(archived),
          updatedAt: Value<DateTime>(_clock()),
        ),
      );

  /// Every non-archived custom exercise, for merging into library search.
  Future<List<Exercise>> allActive() async =>
      (await (_db.select(_db.customExercises)
                ..where(($CustomExercisesTable t) => t.archived.equals(false)))
              .get())
          .map(_map)
          .toList();

  /// The library exercise ids the user's data points at: session exercises
  /// routine items and timer preset steps. Custom ids are left out. Used by the library upgrade
  /// to decide which removed exercises need a tombstone.
  Future<Set<String>> referencedLibraryExerciseIds() async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT exercise_id FROM session_exercises '
          'UNION SELECT exercise_id FROM routine_items',
          readsFrom: <TableInfo<Table, dynamic>>{
            _db.sessionExercises,
            _db.routineItems,
            _db.timerPresets,
          },
        )
        .get();
    final Set<String> ids = <String>{
      for (final QueryRow r in rows)
        if (!r.read<String>('exercise_id').startsWith(Exercise.customPrefix))
          r.read<String>('exercise_id'),
    };
    // Timer presets (yoga flows, tagged steps) point at exercises inside their
    // JSON payload; a payload this build cannot read is skipped.
    final List<TimerPresetRow> presets = await _db
        .select(_db.timerPresets)
        .get();
    for (final TimerPresetRow p in presets) {
      try {
        _collectExerciseIds(jsonDecode(p.payload), ids);
      } on Object {
        continue;
      }
    }
    return ids;
  }

  static void _collectExerciseIds(Object? node, Set<String> into) {
    if (node is Map<dynamic, dynamic>) {
      for (final MapEntry<dynamic, dynamic> e in node.entries) {
        final Object? v = e.value;
        if (e.key == 'exerciseId' &&
            v is String &&
            !v.startsWith(Exercise.customPrefix)) {
          into.add(v);
        } else {
          _collectExerciseIds(v, into);
        }
      }
    } else if (node is List<dynamic>) {
      for (final Object? x in node) {
        _collectExerciseIds(x, into);
      }
    }
  }

  Future<List<ExerciseTombstone>> tombstones() async =>
      (await _db.select(_db.exerciseTombstones).get())
          .map(
            (ExerciseTombstoneRow r) => ExerciseTombstone(
              exerciseId: r.exerciseId,
              name: r.name,
              trackingType: r.trackingType,
              removedInLibraryVersion: r.removedInLibraryVersion,
            ),
          )
          .toList();

  Future<void> addTombstones(Iterable<ExerciseTombstone> stones) =>
      _db.batch((Batch b) {
        b.insertAllOnConflictUpdate(
          _db.exerciseTombstones,
          <ExerciseTombstonesCompanion>[
            for (final ExerciseTombstone s in stones)
              ExerciseTombstonesCompanion.insert(
                exerciseId: s.exerciseId,
                name: s.name,
                trackingType: s.trackingType,
                removedInLibraryVersion: s.removedInLibraryVersion,
              ),
          ],
        );
      });

  /// Every custom exercise including archived ones, for backup.
  Future<List<Exercise>> all() async =>
      (await _db.select(_db.customExercises).get()).map(_map).toList();

  /// The row for [e] exactly as given (no `updatedAt` stamping), for restore.
  static CustomExercisesCompanion companion(Exercise e) => _row(e);

  static CustomExercisesCompanion _row(Exercise e) =>
      CustomExercisesCompanion.insert(
        id: e.id,
        name: e.name,
        aliases: Value<List<String>>(e.aliases),
        sanskritName: Value<String?>(e.sanskritName),
        category: e.category,
        subcategory: Value<String?>(e.subcategory),
        trackingType: e.trackingType,
        primaryMuscles: Value<List<String>>(e.primaryMuscles),
        secondaryMuscles: Value<List<String>>(e.secondaryMuscles),
        equipment: Value<List<String>>(e.equipment),
        difficulty: Value<Difficulty?>(e.difficulty),
        unilateral: Value<bool>(e.unilateral),
        mechanic: Value<String?>(e.mechanic),
        force: Value<String?>(e.force),
        steps: Value<List<String>>(e.steps),
        tips: Value<List<String>>(e.tips),
        commonMistakes: Value<List<String>>(e.commonMistakes),
        safetyNotes: Value<List<String>>(e.safetyNotes),
        contraindications: Value<List<String>>(e.contraindications),
        metValue: Value<double?>(e.metValue),
        defaultRestSec: Value<int?>(e.defaultRestSec),
        defaultHoldSec: Value<int?>(e.defaultHoldSec),
        variationOf: Value<String?>(e.variationOf),
        tags: Value<List<String>>(e.tags),
        archived: Value<bool>(e.archived),
        createdAt: e.createdAt!,
        updatedAt: e.updatedAt!,
      );

  static Exercise _map(CustomExerciseRow r) => Exercise(
    id: r.id,
    name: r.name,
    aliases: r.aliases,
    sanskritName: r.sanskritName,
    category: r.category,
    subcategory: r.subcategory,
    trackingType: r.trackingType,
    primaryMuscles: r.primaryMuscles,
    secondaryMuscles: r.secondaryMuscles,
    equipment: r.equipment,
    difficulty: r.difficulty,
    unilateral: r.unilateral,
    mechanic: r.mechanic,
    force: r.force,
    steps: r.steps,
    tips: r.tips,
    commonMistakes: r.commonMistakes,
    safetyNotes: r.safetyNotes,
    contraindications: r.contraindications,
    metValue: r.metValue,
    defaultRestSec: r.defaultRestSec,
    defaultHoldSec: r.defaultHoldSec,
    variationOf: r.variationOf,
    tags: r.tags,
    isCustom: true,
    archived: r.archived,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );
}

/// Resolves any exercise id the user's data holds: custom first, then the
/// library, then a tombstone (an exercise a library update removed). History
/// never shows a blank row.
class ExerciseResolver {
  ExerciseResolver({required this._custom, required this._library});

  final CustomExerciseRepository _custom;
  final LibraryRepository _library;

  Future<Map<String, Exercise>> resolve(Iterable<String> ids) async {
    final Set<String> wanted = ids.toSet();
    final Map<String, Exercise> out = <String, Exercise>{
      for (final Exercise e in await _custom.byIds(wanted)) e.id: e,
    };
    out.addAll(
      await _library.byIds(wanted.where((String id) => !out.containsKey(id))),
    );
    final Iterable<String> missing = wanted.where(
      (String id) => !out.containsKey(id),
    );
    if (missing.isNotEmpty) {
      final Set<String> m = missing.toSet();
      for (final ExerciseTombstone t in await _custom.tombstones()) {
        if (m.contains(t.exerciseId)) {
          out[t.exerciseId] = Exercise(
            id: t.exerciseId,
            name: t.name,
            category: 'removed',
            trackingType: t.trackingType,
          );
        }
      }
    }
    return out;
  }
}
