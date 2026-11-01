import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/measurement.dart';
import '../ids.dart';
import '../user/user_db.dart';
import 'payload.dart';

/// Inserts built-in rows once. A marker per seed (in `runtime_states`) records
/// the ids already seeded, so a built-in the user deleted stays deleted and a
/// built-in added by a later app version is still inserted.
class SeedRepository {
  SeedRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  static const int markerSchemaVersion = 1;

  /// Inserts the [fields] that are neither present nor recorded as seeded
  /// before. Never touches an existing row (renames, order, enabled and
  /// archived state are the user's). Returns how many were inserted. One
  /// transaction.
  Future<int> insertMissingMeasurementFields(
    List<MeasurementField> fields, {
    String markerKey = 'seed.measurementFields',
  }) async {
    // Every cold start comes through here: one read, and no transaction at
    // all once the marker already lists every built-in.
    final RuntimeStateRow? current =
        await (_db.select(_db.runtimeStates)
              ..where(($RuntimeStatesTable t) => t.key.equals(markerKey)))
            .getSingleOrNull();
    final Set<String> known = _readMarker(current);
    if (fields.every((MeasurementField f) => known.contains(f.id))) return 0;
    return _insertMissing(fields, markerKey);
  }

  Future<int> _insertMissing(List<MeasurementField> fields, String markerKey) =>
      _db.transaction(() async {
        final RuntimeStateRow? marker =
            await (_db.select(_db.runtimeStates)
                  ..where(($RuntimeStatesTable t) => t.key.equals(markerKey)))
                .getSingleOrNull();
        final Set<String> seeded = _readMarker(marker);
        final Set<String> existing = <String>{
          for (final MeasurementFieldRow r
              in await _db.select(_db.measurementFields).get())
            r.id,
        };
        int inserted = 0;
        for (final MeasurementField f in fields) {
          if (seeded.contains(f.id) || existing.contains(f.id)) continue;
          await _db
              .into(_db.measurementFields)
              .insert(
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
                  updatedAt: _clock(),
                ),
              );
          inserted++;
        }
        final Set<String> all = <String>{...seeded, ...fields.map((f) => f.id)};
        if (inserted > 0 || all.length != seeded.length) {
          await _db
              .into(_db.runtimeStates)
              .insertOnConflictUpdate(
                RuntimeStatesCompanion.insert(
                  key: markerKey,
                  payload: jsonEncode(<String, Object?>{
                    'schemaVersion': markerSchemaVersion,
                    'ids': (all.toList()..sort()),
                  }),
                  updatedAt: _clock(),
                ),
              );
        }
        return inserted;
      });

  static Set<String> _readMarker(RuntimeStateRow? row) {
    if (row == null) return <String>{};
    try {
      final Map<String, dynamic> json =
          jsonDecode(row.payload) as Map<String, dynamic>;
      if (payloadVersion(json) > markerSchemaVersion) return <String>{};
      return (json['ids'] as List<dynamic>).cast<String>().toSet();
    } on Object {
      return <String>{};
    }
  }
}
