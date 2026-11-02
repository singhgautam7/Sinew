import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sinew/core/db/ids.dart';
import 'package:sinew/core/db/user/user_db.dart';

/// A fresh in-memory user database with the real schema and migrations.
UserDatabase memoryUserDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return UserDatabase.forTesting(NativeDatabase.memory());
}

/// A clock that advances one second per call, so `updatedAt` ordering in
/// tests is deterministic.
Clock steppingClock([DateTime? start]) {
  DateTime t = start ?? DateTime.utc(2026, 1, 1, 9);
  return () {
    final DateTime now = t;
    t = t.add(const Duration(seconds: 1));
    return now;
  };
}
