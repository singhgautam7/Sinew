import 'package:drift/drift.dart';

import '../../models/training.dart';
import '../ids.dart';
import '../user/user_db.dart';

class RoutineRepository {
  RoutineRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  /// Routines without their items, for lists.
  Stream<List<Routine>> watchAll({bool includeArchived = false}) {
    final SimpleSelectStatement<$RoutinesTable, RoutineRow> q =
        _db.select(_db.routines)
          ..orderBy(<OrderClauseGenerator<$RoutinesTable>>[
            ($RoutinesTable t) => OrderingTerm.asc(t.position),
            ($RoutinesTable t) => OrderingTerm.asc(t.name),
          ]);
    if (!includeArchived) {
      q.where(($RoutinesTable t) => t.archived.equals(false));
    }
    return q.watch().map(
      (List<RoutineRow> rows) =>
          rows.map((RoutineRow r) => _map(r, const <RoutineItem>[])).toList(),
    );
  }

  /// One routine with its items in order.
  Future<Routine?> byId(String id) async {
    final RoutineRow? row = await (_db.select(
      _db.routines,
    )..where(($RoutinesTable t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final List<RoutineItemRow> items =
        await (_db.select(_db.routineItems)
              ..where(($RoutineItemsTable t) => t.routineId.equals(id))
              ..orderBy(<OrderClauseGenerator<$RoutineItemsTable>>[
                ($RoutineItemsTable t) => OrderingTerm.asc(t.position),
              ]))
            .get();
    return _map(row, items.map(_mapItem).toList());
  }

  /// Every routine with items, for backup.
  Future<List<Routine>> allWithItems() async {
    final List<RoutineRow> rows = await _db.select(_db.routines).get();
    final List<RoutineItemRow> items = await _db.select(_db.routineItems).get();
    final Map<String, List<RoutineItem>> byRoutine =
        <String, List<RoutineItem>>{};
    for (final RoutineItemRow i in items) {
      (byRoutine[i.routineId] ??= <RoutineItem>[]).add(_mapItem(i));
    }
    return <Routine>[
      for (final RoutineRow r in rows)
        _map(
          r,
          (byRoutine[r.id] ?? <RoutineItem>[])
            ..sort((RoutineItem a, RoutineItem b) => a.position - b.position),
        ),
    ];
  }

  /// Writes the routine and replaces its items, in one transaction.
  Future<Routine> save(Routine routine) {
    final Routine r = routine.copyWith(updatedAt: _clock());
    return _db.transaction(() async {
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
          for (final RoutineItem i in r.items) itemRow(r.id, i),
        ]);
      });
      return r;
    });
  }

  Future<void> delete(String id) => (_db.delete(
    _db.routines,
  )..where(($RoutinesTable t) => t.id.equals(id))).go();

  static RoutineItemsCompanion itemRow(String routineId, RoutineItem i) =>
      RoutineItemsCompanion.insert(
        id: i.id,
        routineId: routineId,
        exerciseId: i.exerciseId,
        position: i.position,
        supersetGroup: Value<int?>(i.supersetGroup),
        targetSets: Value<int>(i.targetSets),
        targetReps: Value<int?>(i.targetReps),
        targetDurationSec: Value<int?>(i.targetDurationSec),
        targetDistanceM: Value<double?>(i.targetDistanceM),
        targetWeightKg: Value<double?>(i.targetWeightKg),
        restSec: Value<int?>(i.restSec),
        notes: Value<String?>(i.notes),
      );

  static Routine _map(RoutineRow r, List<RoutineItem> items) => Routine(
    id: r.id,
    name: r.name,
    notes: r.notes,
    position: r.position,
    archived: r.archived,
    items: items,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );

  static RoutineItem _mapItem(RoutineItemRow i) => RoutineItem(
    id: i.id,
    exerciseId: i.exerciseId,
    position: i.position,
    supersetGroup: i.supersetGroup,
    targetSets: i.targetSets,
    targetReps: i.targetReps,
    targetDurationSec: i.targetDurationSec,
    targetDistanceM: i.targetDistanceM,
    targetWeightKg: i.targetWeightKg,
    restSec: i.restSec,
    notes: i.notes,
  );
}
