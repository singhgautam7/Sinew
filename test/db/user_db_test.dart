import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/ids.dart';
import 'package:sinew/core/db/user/user_db.dart';

import '../helpers/test_db.dart';

void main() {
  test('creates every table at the current schema version', () async {
    final UserDatabase db = memoryUserDb();
    addTearDown(db.close);
    final List<QueryRow> rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final Set<String> names = rows
        .map((QueryRow r) => r.read<String>('name'))
        .toSet();
    expect(
      names,
      containsAll(<String>[
        'profiles',
        'custom_exercises',
        'exercise_tombstones',
        'routines',
        'routine_items',
        'workout_sessions',
        'session_exercises',
        'set_entries',
        'measurement_fields',
        'measurement_entries',
        'measurement_values',
        'timer_presets',
        'plate_inventories',
        'runtime_states',
      ]),
    );
    final int version = (await db
            .customSelect('PRAGMA user_version')
            .getSingle())
        .read<int>('user_version');
    expect(version, UserDatabase.currentSchemaVersion);
  });

  test('foreign keys are enforced', () async {
    final UserDatabase db = memoryUserDb();
    addTearDown(db.close);
    final int fk = (await db.customSelect('PRAGMA foreign_keys').getSingle())
        .read<int>('foreign_keys');
    expect(fk, 1);
  });

  test('the database allows at most one active session', () async {
    final UserDatabase db = memoryUserDb();
    addTearDown(db.close);
    final DateTime now = DateTime.utc(2026);
    WorkoutSessionsCompanion row() => WorkoutSessionsCompanion.insert(
      id: newId(),
      startedAt: now,
      updatedAt: now,
    );
    await db.into(db.workoutSessions).insert(row());
    expect(
      () => db.into(db.workoutSessions).insert(row()),
      throwsA(isA<SqliteException>()),
    );
    // Finished sessions are unlimited.
    await db
        .into(db.workoutSessions)
        .insert(row().copyWith(endedAt: Value<DateTime?>(now)));
    await db
        .into(db.workoutSessions)
        .insert(row().copyWith(endedAt: Value<DateTime?>(now)));
  });

  test('a database from a newer build is refused, not opened', () async {
    final UserDatabase db = UserDatabase.forTesting(
      NativeDatabase.memory(
        setup: (rawDb) => rawDb.execute('PRAGMA user_version = 99'),
      ),
    );
    addTearDown(db.close);
    await expectLater(
      db.customSelect('SELECT 1').get(),
      throwsA(isA<UnsupportedSchemaVersion>()),
    );
  });

  test('timestamps keep millisecond precision', () async {
    final UserDatabase db = memoryUserDb();
    addTearDown(db.close);
    final DateTime t = DateTime.utc(2026, 3, 4, 5, 6, 7, 891);
    await db
        .into(db.runtimeStates)
        .insert(
          RuntimeStatesCompanion.insert(key: 'k', payload: '{}', updatedAt: t),
        );
    final RuntimeStateRow row = await db.select(db.runtimeStates).getSingle();
    expect(row.updatedAt.toUtc(), t);
  });
}
