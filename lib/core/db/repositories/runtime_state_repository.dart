import 'dart:convert';

import '../ids.dart';
import '../user/user_db.dart';
import 'payload.dart';

/// Small JSON blobs that must survive process death (the running timer, the
/// rest timer). Each payload carries its own `schemaVersion`; reading one
/// from a newer build or a corrupt one returns null, never throws.
class RuntimeStateRepository {
  RuntimeStateRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  static const String runningTimer = 'timer.running';

  Future<Map<String, dynamic>?> read(String key, {int maxVersion = 1}) async {
    final RuntimeStateRow? row = await (_db.select(
      _db.runtimeStates,
    )..where(($RuntimeStatesTable t) => t.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    try {
      final Map<String, dynamic> json =
          jsonDecode(row.payload) as Map<String, dynamic>;
      return payloadVersion(json) > maxVersion ? null : json;
    } on Object {
      return null;
    }
  }

  Future<void> write(String key, Map<String, dynamic> payload) => _db
      .into(_db.runtimeStates)
      .insertOnConflictUpdate(
        RuntimeStatesCompanion.insert(
          key: key,
          payload: jsonEncode(payload),
          updatedAt: _clock(),
        ),
      );

  Future<void> clear(String key) => (_db.delete(
    _db.runtimeStates,
  )..where(($RuntimeStatesTable t) => t.key.equals(key))).go();
}
