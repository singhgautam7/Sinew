import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/measurement.dart';
import '../ids.dart';
import '../user/user_db.dart';

/// What happened when the user removed a field.
enum FieldRemoval { deleted, archived }

/// Measurement fields and dated entries. Values are metric.
class MeasurementRepository {
  MeasurementRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  // ── Fields ────────────────────────────────────────────────────────────────

  Stream<List<MeasurementField>> watchFields({bool includeArchived = false}) =>
      _fieldsQuery(includeArchived).watch().map(
        (List<MeasurementFieldRow> rows) => rows.map(_mapField).toList(),
      );

  Future<List<MeasurementField>> fields({bool includeArchived = false}) async =>
      (await _fieldsQuery(includeArchived).get()).map(_mapField).toList();

  Future<void> saveField(MeasurementField f) => _db
      .into(_db.measurementFields)
      .insertOnConflictUpdate(_fieldRow(f.copyWith(updatedAt: _clock())));

  /// Saves several fields (a left and right pair) in one transaction, so a
  /// pair is never half created.
  Future<void> saveFields(List<MeasurementField> fields) =>
      _db.transaction(() async {
        final DateTime now = _clock();
        for (final MeasurementField f in fields) {
          await _db
              .into(_db.measurementFields)
              .insertOnConflictUpdate(_fieldRow(f.copyWith(updatedAt: now)));
        }
      });

  /// Removes several fields (both sides of a pair) in one transaction, by
  /// the same rule as [removeField] applied to the group: when any of them
  /// has data, all are archived together; otherwise all are deleted.
  Future<FieldRemoval> removeFields(List<String> fieldIds) =>
      _db.transaction(() async {
        bool anyData = false;
        for (final String id in fieldIds) {
          anyData = anyData || await fieldHasData(id);
        }
        if (anyData) {
          await (_db.update(
            _db.measurementFields,
          )..where(($MeasurementFieldsTable t) => t.id.isIn(fieldIds))).write(
            MeasurementFieldsCompanion(
              archived: const Value<bool>(true),
              enabled: const Value<bool>(false),
              updatedAt: Value<DateTime>(_clock()),
            ),
          );
          return FieldRemoval.archived;
        }
        await (_db.delete(
          _db.measurementFields,
        )..where(($MeasurementFieldsTable t) => t.id.isIn(fieldIds))).go();
        return FieldRemoval.deleted;
      });

  /// Writes positions in the given order, in one transaction.
  Future<void> reorderFields(List<String> orderedIds) =>
      _db.transaction(() async {
        final DateTime now = _clock();
        for (int i = 0; i < orderedIds.length; i++) {
          await (_db.update(_db.measurementFields)..where(
                ($MeasurementFieldsTable t) => t.id.equals(orderedIds[i]),
              ))
              .write(
                MeasurementFieldsCompanion(
                  position: Value<int>(i),
                  updatedAt: Value<DateTime>(now),
                ),
              );
        }
      });

  Future<bool> fieldHasData(String fieldId) async {
    final MeasurementValueRow? any =
        await (_db.select(_db.measurementValues)
              ..where(($MeasurementValuesTable t) => t.fieldId.equals(fieldId))
              ..limit(1))
            .getSingleOrNull();
    return any != null;
  }

  /// Deletes a field with no data; archives one that has data, so history is
  /// never destroyed. The UI asks for confirmation before calling this.
  Future<FieldRemoval> removeField(String fieldId) => _db.transaction(() async {
    if (await fieldHasData(fieldId)) {
      await (_db.update(
        _db.measurementFields,
      )..where(($MeasurementFieldsTable t) => t.id.equals(fieldId))).write(
        MeasurementFieldsCompanion(
          archived: const Value<bool>(true),
          enabled: const Value<bool>(false),
          updatedAt: Value<DateTime>(_clock()),
        ),
      );
      return FieldRemoval.archived;
    }
    await (_db.delete(
      _db.measurementFields,
    )..where(($MeasurementFieldsTable t) => t.id.equals(fieldId))).go();
    return FieldRemoval.deleted;
  });

  // ── Entries ───────────────────────────────────────────────────────────────

  /// Writes an entry and replaces its values, in one transaction.
  Future<MeasurementEntry> saveEntry(MeasurementEntry entry) {
    final MeasurementEntry e = entry.copyWith(updatedAt: _clock());
    return _db.transaction(() async {
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
      return e;
    });
  }

  Future<void> deleteEntry(String id) => (_db.delete(
    _db.measurementEntries,
  )..where(($MeasurementEntriesTable t) => t.id.equals(id))).go();

  /// Entries newest first, each with its values.
  Future<List<MeasurementEntry>> entries({DateTime? from, DateTime? to}) async {
    final SimpleSelectStatement<$MeasurementEntriesTable, MeasurementEntryRow>
    q = _db.select(_db.measurementEntries)
      ..orderBy(<OrderClauseGenerator<$MeasurementEntriesTable>>[
        ($MeasurementEntriesTable t) => OrderingTerm.desc(t.date),
      ]);
    if (from != null) {
      q.where(
        ($MeasurementEntriesTable t) => t.date.isBiggerOrEqualValue(from),
      );
    }
    if (to != null) {
      q.where(($MeasurementEntriesTable t) => t.date.isSmallerOrEqualValue(to));
    }
    final List<MeasurementEntryRow> rows = await q.get();
    if (rows.isEmpty) return const <MeasurementEntry>[];
    final Map<String, Map<String, double>> values = await _valuesFor(
      rows.map((MeasurementEntryRow r) => r.id).toList(),
    );
    return <MeasurementEntry>[
      for (final MeasurementEntryRow r in rows)
        MeasurementEntry(
          id: r.id,
          date: r.date,
          note: r.note,
          values: values[r.id] ?? const <String, double>{},
          updatedAt: r.updatedAt,
        ),
    ];
  }

  /// Latest value of every field, each from the newest entry that has it
  /// (body stats read these). One grouped query: only the winning row per
  /// field leaves the database. Ties on the same date go to the entry saved
  /// last, then to the greater id, so the answer never depends on row order.
  Future<Map<String, ({double value, DateTime date})>> latestValues() async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT v.field_id AS field_id, v.value AS value, e.date AS date '
          'FROM measurement_values v '
          'JOIN measurement_entries e ON e.id = v.entry_id '
          'WHERE NOT EXISTS ('
          'SELECT 1 FROM measurement_values v2 '
          'JOIN measurement_entries e2 ON e2.id = v2.entry_id '
          'WHERE v2.field_id = v.field_id AND ('
          'e2.date > e.date OR (e2.date = e.date AND ('
          'e2.updated_at > e.updated_at OR (e2.updated_at = e.updated_at '
          'AND e2.id > e.id)))))',
          readsFrom: <ResultSetImplementation<HasResultSet, dynamic>>{
            _db.measurementValues,
            _db.measurementEntries,
          },
        )
        .get();
    return <String, ({double value, DateTime date})>{
      for (final QueryRow r in rows)
        r.read<String>('field_id'): (
          value: r.read<double>('value'),
          date: r.read<DateTime>('date'),
        ),
    };
  }

  /// One field's history, oldest first: what a progress chart draws.
  Future<List<({DateTime date, double value})>> history(String fieldId) async {
    final List<TypedResult> rows =
        await (_db.select(_db.measurementValues).join(
                <Join<HasResultSet, dynamic>>[
                  innerJoin(
                    _db.measurementEntries,
                    _db.measurementEntries.id.equalsExp(
                      _db.measurementValues.entryId,
                    ),
                  ),
                ],
              )
              ..where(_db.measurementValues.fieldId.equals(fieldId))
              ..orderBy(<OrderingTerm>[
                OrderingTerm.asc(_db.measurementEntries.date),
              ]))
            .get();
    return <({DateTime date, double value})>[
      for (final TypedResult r in rows)
        (
          date: r.readTable(_db.measurementEntries).date,
          value: r.readTable(_db.measurementValues).value,
        ),
    ];
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  SimpleSelectStatement<$MeasurementFieldsTable, MeasurementFieldRow>
  _fieldsQuery(bool includeArchived) {
    final SimpleSelectStatement<$MeasurementFieldsTable, MeasurementFieldRow>
    q = _db.select(_db.measurementFields)
      ..orderBy(<OrderClauseGenerator<$MeasurementFieldsTable>>[
        ($MeasurementFieldsTable t) => OrderingTerm.asc(t.position),
      ]);
    if (!includeArchived) {
      q.where(($MeasurementFieldsTable t) => t.archived.equals(false));
    }
    return q;
  }

  Future<Map<String, Map<String, double>>> _valuesFor(List<String> ids) async {
    final Map<String, Map<String, double>> out =
        <String, Map<String, double>>{};
    for (int i = 0; i < ids.length; i += 250) {
      final List<String> chunk = ids.sublist(
        i,
        i + 250 > ids.length ? ids.length : i + 250,
      );
      final List<MeasurementValueRow> rows = await (_db.select(
        _db.measurementValues,
      )..where(($MeasurementValuesTable t) => t.entryId.isIn(chunk))).get();
      for (final MeasurementValueRow v in rows) {
        (out[v.entryId] ??= <String, double>{})[v.fieldId] = v.value;
      }
    }
    return out;
  }

  static MeasurementFieldsCompanion _fieldRow(MeasurementField f) =>
      MeasurementFieldsCompanion.insert(
        id: f.id,
        name: f.name,
        unitType: f.unitType,
        customUnit: Value<String?>(f.customUnit),
        side: Value<BodySide>(f.side),
        pairId: Value<String?>(f.pairId),
        bodyAnchor: Value<BodyAnchor?>(f.bodyAnchor),
        enabled: Value<bool>(f.enabled),
        position: Value<int>(f.position),
        builtIn: Value<bool>(f.builtIn),
        archived: Value<bool>(f.archived),
        updatedAt: f.updatedAt,
      );

  static MeasurementField _mapField(MeasurementFieldRow r) => MeasurementField(
    id: r.id,
    name: r.name,
    unitType: r.unitType,
    customUnit: r.customUnit,
    side: r.side,
    pairId: r.pairId,
    bodyAnchor: r.bodyAnchor,
    enabled: r.enabled,
    position: r.position,
    builtIn: r.builtIn,
    archived: r.archived,
    updatedAt: r.updatedAt,
  );
}
