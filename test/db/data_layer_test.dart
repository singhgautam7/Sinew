import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/repositories/seed_repository.dart';
import 'package:sinew/core/db/repositories/timer_preset_repository.dart';
import 'package:sinew/core/db/seeds/measurement_seed.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/format/date_text.dart';
import 'package:sinew/core/format/number_text.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/features/body/body_model.dart';

import '../helpers/test_db.dart';

void main() {
  test('an unreadable timer preset is never overwritten by a save', () async {
    final UserDatabase db = memoryUserDb();
    addTearDown(db.close);
    await db
        .into(db.timerPresets)
        .insert(
          TimerPresetsCompanion.insert(
            id: 'p1',
            name: 'Future',
            mode: TimerMode.tabata,
            payload: jsonEncode(<String, Object>{'schemaVersion': 99}),
            updatedAt: DateTime.utc(2026),
          ),
        );
    final TimerPresetRepository repo = TimerPresetRepository(db);
    // Not listed, since this build cannot read it.
    expect(await repo.all(), isEmpty);
    // A readable preset sharing the id (a seed) must not replace it.
    await repo.save(
      TimerPreset(
        id: 'p1',
        name: 'Seeded',
        mode: TimerMode.tabata,
        updatedAt: DateTime.utc(2026, 2),
      ),
    );
    final TimerPresetRow after = await db.select(db.timerPresets).getSingle();
    expect(after.name, 'Future');
    expect(jsonDecode(after.payload), containsPair('schemaVersion', 99));
  });

  test(
    'library upgrade protects exercises used inside preset payloads',
    () async {
      final UserDatabase db = memoryUserDb();
      addTearDown(db.close);
      await db
          .into(db.timerPresets)
          .insert(
            TimerPresetsCompanion.insert(
              id: 'flow',
              name: 'Flow',
              mode: TimerMode.yogaFlow,
              payload: jsonEncode(<String, Object>{
                'schemaVersion': 1,
                'steps': <Object>[
                  <String, Object>{'exerciseId': 'downward-dog'},
                  <String, Object>{'exerciseId': 'custom-mine'},
                ],
              }),
              updatedAt: DateTime.utc(2026),
            ),
          );
      await db
          .into(db.timerPresets)
          .insert(
            TimerPresetsCompanion.insert(
              id: 'broken',
              name: 'Broken',
              mode: TimerMode.tabata,
              payload: 'not json',
              updatedAt: DateTime.utc(2026),
            ),
          );
      final Set<String> ids = await CustomExerciseRepository(db)
          .referencedLibraryExerciseIds();
      expect(ids, <String>{'downward-dog'});
    },
  );

  test('the measurement seed is a single read once it has run', () async {
    final UserDatabase db = memoryUserDb();
    addTearDown(db.close);
    final SeedRepository seeds = SeedRepository(db);
    final int first = await MeasurementSeed.seed(seeds);
    expect(first, MeasurementSeed.builtIns.length);
    expect(await MeasurementSeed.seed(seeds), 0);
    // A deleted built-in stays deleted.
    await (db.delete(
      db.measurementFields,
    )..where(($MeasurementFieldsTable t) => t.id.equals('weight'))).go();
    expect(await MeasurementSeed.seed(seeds), 0);
  });

  test('height resolves the same way for Today and Body', () {
    final DateTime profileAt = DateTime.utc(2026, 1, 1);
    final Profile profile = Profile(heightCm: 170, updatedAt: profileAt);
    // A height logged after the profile was saved wins.
    final input = bodyStatsInputFor(
      <String, DatedValue>{
        'height': (value: 175, date: DateTime.utc(2026, 2, 1)),
      },
      profile,
      DateTime.utc(2026, 3, 1),
    );
    expect(input.heightCm, 175);
    final older = bodyStatsInputFor(
      <String, DatedValue>{
        'height': (value: 175, date: DateTime.utc(2025, 2, 1)),
      },
      profile,
      DateTime.utc(2026, 3, 1),
    );
    expect(older.heightCm, 170);
  });

  group('format module', () {
    test('dates', () {
      final DateTime now = DateTime(2026, 10, 31, 9);
      expect(DateText.dayMonthSmart(DateTime(2026, 10, 3), now), '3 Oct');
      expect(DateText.dayMonthSmart(DateTime(2025, 10, 3), now), '3 Oct 2025');
      expect(DateText.dayMonthLong(now, now), 'Today, 31 Oct');
      expect(DateText.count(1, 'workout'), '1 workout');
      expect(DateText.durationText(3900), '1 h 05 min');
      expect(DateText.clock(90), '1:30');
    });

    test('numbers and the missing-value mark', () {
      expect(NumberText.thousands(12345.4), '12,345');
      expect(NumberText.thousands(999), '999');
      expect(kNoValue, '–');
    });
  });
}
