import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/plate_inventory.dart';
import '../ids.dart';
import '../user/user_db.dart';
import 'payload.dart';

/// The bars and plates the user owns. One row; absent reads as
/// [PlateInventory.metricDefault]. An unreadable or newer payload also reads
/// as the default instead of throwing.
class PlateInventoryRepository {
  PlateInventoryRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  Future<PlateInventory> get() async =>
      _decode(await _query().getSingleOrNull());

  Stream<PlateInventory> watch() => _query().watchSingleOrNull().map(_decode);

  /// Always stamps `updatedAt` with now; a restore writes through
  /// `BackupRepository`, which keeps the incoming stamp.
  ///
  /// An unreadable or newer stored payload is never overwritten (it would
  /// destroy data this build cannot read): the save is skipped then.
  Future<void> save(PlateInventory inventory) async {
    final PlateInventoryRow? existing = await _query().getSingleOrNull();
    if (existing != null && _isUnreadable(existing)) return;
    final DateTime now = _clock();
    final PlateInventory stamped = inventory.copyWith(
      schemaVersion: PlateInventory.currentSchemaVersion,
      updatedAt: now,
    );
    await _db
        .into(_db.plateInventories)
        .insertOnConflictUpdate(
          PlateInventoriesCompanion.insert(
            id: const Value<String>('default'),
            payload: jsonEncode(stamped.toJson()),
            updatedAt: now,
          ),
        );
  }

  SingleOrNullSelectable<PlateInventoryRow> _query() =>
      _db.select(_db.plateInventories)
        ..where(($PlateInventoriesTable t) => t.id.equals('default'));

  static bool _isUnreadable(PlateInventoryRow row) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(row.payload) as Map<String, dynamic>;
      return payloadVersion(json) > PlateInventory.currentSchemaVersion;
    } on Object {
      return true;
    }
  }

  static PlateInventory _decode(PlateInventoryRow? row) {
    if (row == null) return PlateInventory.metricDefault;
    try {
      final Map<String, dynamic> json =
          jsonDecode(row.payload) as Map<String, dynamic>;
      if (payloadVersion(json) > PlateInventory.currentSchemaVersion) {
        return PlateInventory.metricDefault;
      }
      return PlateInventory.fromJson(json);
    } on Object {
      return PlateInventory.metricDefault;
    }
  }
}
