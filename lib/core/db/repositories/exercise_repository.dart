import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/exercise.dart';
import '../ids.dart';
import '../library/library_db.dart';
import '../user/user_db.dart';

/// Read access to the bundled library. Search and filters arrive in Phase 2.
class LibraryRepository {
  LibraryRepository(this._db);

  final LibraryDatabase _db;

  Future<int> count() async {
    final Expression<int> c = _db.exercises.seq.count();
    final TypedResult row = await (_db.selectOnly(
      _db.exercises,
    )..addColumns(<Expression<Object>>[c])).getSingle();
    return row.read(c) ?? 0;
  }

  Future<String?> libraryVersion() => _db.meta('libraryVersion');

  Future<Exercise?> byId(String id) async {
    final LibraryExerciseRow? row = await (_db.select(
      _db.exercises,
    )..where(($ExercisesTable t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : mapLibraryRow(row);
  }

  /// Batched by 250 ids so SQLite's parameter limit is never reached.
  Future<Map<String, Exercise>> byIds(Iterable<String> ids) async {
    final List<String> all = ids.toSet().toList();
    final Map<String, Exercise> out = <String, Exercise>{};
    for (int i = 0; i < all.length; i += 250) {
      final List<String> chunk = all.sublist(
        i,
        i + 250 > all.length ? all.length : i + 250,
      );
      final List<LibraryExerciseRow> rows = await (_db.select(
        _db.exercises,
      )..where(($ExercisesTable t) => t.id.isIn(chunk))).get();
      for (final LibraryExerciseRow r in rows) {
        out[r.id] = mapLibraryRow(r);
      }
    }
    return out;
  }

  static Exercise mapLibraryRow(LibraryExerciseRow r) => Exercise(
    id: r.id,
    name: r.name,
    aliases: r.aliases,
    sanskritName: r.sanskritName,
    category: r.category,
    subcategory: r.subcategory,
    trackingType: enumByName(
      TrackingType.values,
      r.trackingType,
      TrackingType.unknown,
    ),
    primaryMuscles: r.primaryMuscles,
    secondaryMuscles: r.secondaryMuscles,
    equipment: r.equipment,
    difficulty: enumByNameOrNull(Difficulty.values, r.difficulty),
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
    source: r.source,
    license: r.license,
  );
}

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
