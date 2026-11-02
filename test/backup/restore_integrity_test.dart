import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/core/background.dart';
import 'package:sinew/core/db/repositories/backup_repository.dart';
import 'package:sinew/core/db/repositories/backup_snapshot.dart';
import 'package:sinew/core/db/repositories/measurement_repository.dart';
import 'package:sinew/core/db/repositories/plate_inventory_repository.dart';
import 'package:sinew/core/db/repositories/profile_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/plate_inventory.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/features/backup/backup_codec.dart';
import 'package:sinew/features/backup/backup_service.dart';

import '../helpers/test_db.dart';

WorkoutSession _session(
  String id, {
  required DateTime start,
  required List<(String, double, int)> sets,
  DateTime? updatedAt,
}) => WorkoutSession(
  id: id,
  startedAt: start,
  endedAt: start.add(const Duration(hours: 1)),
  updatedAt: updatedAt ?? start,
  exercises: <SessionExercise>[
    SessionExercise(
      id: '$id-e',
      exerciseId: 'bench-press',
      position: 0,
      sets: <SetEntry>[
        for (int i = 0; i < sets.length; i++)
          SetEntry(
            id: sets[i].$1,
            position: i,
            weightKg: sets[i].$2,
            reps: sets[i].$3,
            completed: true,
          ),
      ],
    ),
  ],
);

BackupPreview _preview(BackupSnapshot s, {Map<String, Object>? settings}) {
  const BackupCodec codec = BackupCodec();
  final String text = codec.encode(
    BackupDocument(
      schemaVersion: 1,
      exportedAt: DateTime.utc(2026, 3),
      snapshot: s,
      settings: settings ?? const <String, Object>{},
    ),
  );
  return (codec.decode(text) as ParsedBackup).preview;
}

void main() {
  group('dates are UTC instants', () {
    test('models write Z and read back UTC, whatever the input offset', () {
      final DateTime local = DateTime(2026, 3, 1, 12, 30);
      final WorkoutSession s = _session(
        's',
        start: local,
        sets: <(String, double, int)>[('a', 50, 5)],
      );
      final Map<String, dynamic> json =
          jsonDecode(jsonEncode(s)) as Map<String, dynamic>;
      expect(json['startedAt'], endsWith('Z'));
      expect(json['updatedAt'], endsWith('Z'));
      final WorkoutSession back = WorkoutSession.fromJson(json);
      expect(back.startedAt.isUtc, isTrue);
      expect(back.startedAt.isAtSameMomentAs(local), isTrue);
      expect(back.endedAt!.isUtc, isTrue);
    });

    test('a date with an explicit offset keeps its instant', () {
      final MeasurementEntry e = MeasurementEntry.fromJson(<String, dynamic>{
        'id': 'e',
        'date': '2026-03-01T13:00:00+02:00',
        'values': <String, double>{'weight': 70},
        'updatedAt': '2026-03-01T13:00:00+02:00',
      });
      expect(e.date, DateTime.utc(2026, 3, 1, 11));
      expect(e.date.isUtc, isTrue);
    });

    test('export on one offset, restore, every instant is equal', () async {
      final UserDatabase a = memoryUserDb();
      final UserDatabase b = memoryUserDb();
      addTearDown(a.close);
      addTearDown(b.close);
      final DateTime t = DateTime(2026, 3, 1, 8, 15);
      await SessionRepository(a).saveTree(
        _session('s1', start: t, sets: <(String, double, int)>[('x', 60, 5)]),
      );
      final BackupSnapshot snap = await BackupRepository(a).readAll();
      final BackupPreview p = _preview(snap);
      await BackupRepository(b)
          .writeAll(p.document.snapshot, mode: RestoreMode.replace);
      final List<WorkoutSession> restored = await SessionRepository(b)
          .allWithTree();
      expect(restored.single.startedAt.isAtSameMomentAs(t), isTrue);
      expect(restored.single.updatedAt.isAtSameMomentAs(t), isTrue);
    });

    test('newer wins compares instants, not wall clocks', () async {
      final UserDatabase db = memoryUserDb();
      addTearDown(db.close);
      // Local copy updated at 11:30Z.
      await MeasurementRepository(
        db,
        clock: () => DateTime.utc(2026, 3, 1, 11, 30),
      ).saveEntry(
        MeasurementEntry(
          id: 'e',
          date: DateTime.utc(2026, 3),
          values: const <String, double>{'weight': 70},
          updatedAt: DateTime.utc(2026),
        ),
      );
      MeasurementEntry incoming(String stamp, double w) =>
          MeasurementEntry.fromJson(<String, dynamic>{
            'id': 'e',
            'date': '2026-03-01T00:00:00Z',
            'values': <String, double>{'weight': w},
            'updatedAt': stamp,
          });
      final BackupRepository repo = BackupRepository(db);
      // 13:00+02:00 is 11:00Z: older, kept.
      var r = await repo.writeAll(
        BackupSnapshot(
          measurementEntries: <MeasurementEntry>[
            incoming('2026-03-01T13:00:00+02:00', 99),
          ],
        ),
        mode: RestoreMode.merge,
      );
      expect(r.kept['measurementEntries'], 1);
      // 13:00+01:00 is 12:00Z: newer, written.
      r = await repo.writeAll(
        BackupSnapshot(
          measurementEntries: <MeasurementEntry>[
            incoming('2026-03-01T13:00:00+01:00', 80),
          ],
        ),
        mode: RestoreMode.merge,
      );
      expect(r.written['measurementEntries'], 1);
      expect(
        (await MeasurementRepository(db).entries()).single.values['weight'],
        80,
      );
    });
  });

  group('restore recomputes PR flags', () {
    test(
      'a merge that adds an earlier heavier set clears the later PR',
      () async {
        final UserDatabase db = memoryUserDb();
        addTearDown(db.close);
        final SessionRepository sessions = SessionRepository(db);
        // Local: a first set and a PR in the second session.
        await sessions.saveTree(
          _session(
            'old',
            start: DateTime.utc(2026, 1, 1),
            sets: <(String, double, int)>[('o1', 50, 5)],
          ),
        );
        final WorkoutSession later = _session(
          'new',
          start: DateTime.utc(2026, 2, 1),
          sets: <(String, double, int)>[('n1', 60, 5)],
        );
        await sessions.saveTree(
          later.copyWith(
            exercises: <SessionExercise>[
              later.exercises.single.copyWith(
                sets: <SetEntry>[
                  later.exercises.single.sets.single.copyWith(isPR: true),
                ],
              ),
            ],
          ),
        );
        // The backup brings an even earlier, heavier session.
        await BackupRepository(db).writeAll(
          BackupSnapshot(
            sessions: <WorkoutSession>[
              _session(
                'earliest',
                start: DateTime.utc(2025, 12, 1),
                sets: <(String, double, int)>[('e1', 100, 5)],
              ),
            ],
          ),
          mode: RestoreMode.merge,
        );
        final Map<String, bool> pr = <String, bool>{
          for (final WorkoutSession s in await sessions.allWithTree())
            for (final SessionExercise e in s.exercises)
              for (final SetEntry x in e.sets) x.id: x.isPR,
        };
        expect(pr['e1'], isFalse, reason: 'the first ever set is not a PR');
        expect(pr['o1'], isFalse);
        expect(pr['n1'], isFalse, reason: '60 no longer beats 100');
      },
    );
  });

  group('BackupService restore', () {
    late UserDatabase db;
    late SharedPreferences prefs;

    setUp(() async {
      db = memoryUserDb();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
    });
    tearDown(() => db.close());

    test('routine style prefs travel in a backup', () async {
      await prefs.setString('routine.style.abc', 'dumbbell:3');
      final BackupService svc = BackupService(
        repository: BackupRepository(db),
        prefs: prefs,
      );
      final BackupFile f = await svc.export();
      expect(
        (jsonDecode(f.contents) as Map<String, dynamic>)['settings'],
        containsPair('routine.style.abc', 'dumbbell:3'),
      );
    });

    test('onDataRestored fires once the data is in', () async {
      int fired = 0;
      final BackupService svc = BackupService(
        repository: BackupRepository(db),
        prefs: prefs,
        onDataRestored: () => fired++,
      );
      await svc.restore(
        _preview(const BackupSnapshot()),
        mode: RestoreMode.replace,
      );
      expect(fired, 1);
    });

    test('a settings failure is reported, the data stays restored', () async {
      int fired = 0;
      final _ThrowingPrefs bad = _ThrowingPrefs();
      final BackupService svc = BackupService(
        repository: BackupRepository(db),
        prefs: bad,
        onDataRestored: () => fired++,
      );
      final RestoreSummary s = await svc.restore(
        _preview(
          const BackupSnapshot(profile: Profile(heightCm: 180)),
          settings: const <String, Object>{'theme.mode': 'amoled'},
        ),
        mode: RestoreMode.replace,
      );
      expect(s.settingsFailed, isTrue);
      expect(s.settingsApplied, 0);
      expect(fired, 1);
      expect((await ProfileRepository(db).get()).heightCm, 180);
    });

    test('onDataRestored invalidates the providers that cache data', () async {
      final ProviderContainer c = ProviderContainer(
        retry: noRetry,
        overrides: <Override>[
          userDatabaseProvider.overrideWithValue(db),
          prefsProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(c.dispose);
      expect(await c.read(shouldRemindBackupProvider.future), isFalse);
      // A backup with ten finished workouts arrives.
      final BackupPreview p = _preview(
        BackupSnapshot(
          sessions: <WorkoutSession>[
            for (int i = 0; i < backupReminderSessions; i++)
              _session(
                's$i',
                start: DateTime.utc(2026, 1, 1 + i),
                sets: <(String, double, int)>[('set$i', 50, 5)],
              ),
          ],
        ),
      );
      await c.read(backupServiceProvider).restore(p, mode: RestoreMode.replace);
      expect(await c.read(shouldRemindBackupProvider.future), isTrue);
    });

    test('the reminder refreshes when a workout finishes', () async {
      final ProviderContainer c = ProviderContainer(
        retry: noRetry,
        overrides: <Override>[
          userDatabaseProvider.overrideWithValue(db),
          prefsProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(c.dispose);
      final ProviderSubscription<AsyncValue<bool>> sub = c.listen(
        shouldRemindBackupProvider,
        (AsyncValue<bool>? _, AsyncValue<bool> _) {},
      );
      addTearDown(sub.close);
      expect(await c.read(shouldRemindBackupProvider.future), isFalse);
      final SessionRepository repo = SessionRepository(db);
      for (int i = 0; i < backupReminderSessions; i++) {
        await repo.saveTree(
          _session(
            's$i',
            start: DateTime.utc(2026, 1, 1 + i),
            sets: <(String, double, int)>[('set$i', 50, 5)],
          ),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(await c.read(shouldRemindBackupProvider.future), isTrue);
    });

    test(
      'parseAsync and export give the same result on a real isolate',
      () async {
        Background.forceIsolate = true;
        addTearDown(() => Background.forceIsolate = false);
        await SessionRepository(db).saveTree(
          _session(
            's',
            start: DateTime.utc(2026, 1, 1),
            sets: <(String, double, int)>[('a', 50, 5)],
          ),
        );
        final BackupService svc = BackupService(
          repository: BackupRepository(db),
          prefs: prefs,
        );
        final BackupFile f = await svc.export();
        final BackupParseResult r = await svc.parseAsync(f.contents);
        expect(r, isA<ParsedBackup>());
        expect((r as ParsedBackup).preview.sessions, 1);
        final BackupParseResult bad = await svc.parseAsync('not json');
        expect(bad, isA<RejectedBackup>());
      },
    );
  });

  group('repository stamps', () {
    test('profile and plate saves always stamp now', () async {
      final UserDatabase db = memoryUserDb();
      addTearDown(db.close);
      final DateTime now = DateTime.utc(2026, 5, 5, 5);
      final ProfileRepository profiles = ProfileRepository(
        db,
        clock: () => now,
      );
      await profiles.save(
        Profile(heightCm: 170, updatedAt: DateTime.utc(2020)),
      );
      expect((await profiles.get()).updatedAt, now);

      final PlateInventoryRepository plates = PlateInventoryRepository(
        db,
        clock: () => now,
      );
      await plates.save(
        PlateInventory.metricDefault.copyWith(updatedAt: DateTime.utc(2020)),
      );
      expect((await plates.get()).updatedAt, now);
    });

    test('a plate payload from a newer build is not overwritten', () async {
      final UserDatabase db = memoryUserDb();
      addTearDown(db.close);
      await db
          .into(db.plateInventories)
          .insert(
            PlateInventoriesCompanion.insert(
              payload: jsonEncode(<String, Object>{'schemaVersion': 99}),
              updatedAt: DateTime.utc(2026),
            ),
          );
      await PlateInventoryRepository(db).save(PlateInventory.metricDefault);
      final PlateInventoryRow row = await db
          .select(db.plateInventories)
          .getSingle();
      expect(jsonDecode(row.payload), containsPair('schemaVersion', 99));
    });
  });

  group('measurement queries', () {
    test(
      'latestValues picks the newest per field, ties are deterministic',
      () async {
        final UserDatabase db = memoryUserDb();
        addTearDown(db.close);
        DateTime stamp = DateTime.utc(2026, 1, 1);
        final MeasurementRepository repo = MeasurementRepository(
          db,
          clock: () => stamp = stamp.add(const Duration(seconds: 1)),
        );
        final DateTime day = DateTime.utc(2026, 2, 1);
        await repo.saveEntry(
          MeasurementEntry(
            id: 'a',
            date: day,
            values: const <String, double>{'weight': 70, 'waist': 80},
            updatedAt: day,
          ),
        );
        await repo.saveEntry(
          MeasurementEntry(
            id: 'b',
            date: day,
            values: const <String, double>{'weight': 71},
            updatedAt: day,
          ),
        );
        await repo.saveEntry(
          MeasurementEntry(
            id: 'c',
            date: DateTime.utc(2026, 1, 15),
            values: const <String, double>{'weight': 65, 'neck': 38},
            updatedAt: day,
          ),
        );
        final latest = await repo.latestValues();
        // Same date: the entry saved last wins.
        expect(latest['weight']!.value, 71);
        expect(latest['waist']!.value, 80);
        expect(latest['neck']!.value, 38);
        expect(
          latest['neck']!.date.isAtSameMomentAs(DateTime.utc(2026, 1, 15)),
          isTrue,
        );
        expect(latest.length, 3);
      },
    );

    test('saveFields writes a pair atomically', () async {
      final UserDatabase db = memoryUserDb();
      addTearDown(db.close);
      final MeasurementRepository repo = MeasurementRepository(db);
      MeasurementField f(String id, {String? name}) => MeasurementField(
        id: id,
        name: name ?? id,
        unitType: MeasurementUnitType.length,
        pairId: 'p',
        updatedAt: DateTime.utc(2026),
      );
      await repo.saveFields(<MeasurementField>[f('l'), f('r')]);
      expect(
        (await repo.fields()).map((x) => x.id),
        containsAll(<String>['l', 'r']),
      );
      // A name over the 60 character limit fails the second row: neither stays.
      await expectLater(
        repo.saveFields(<MeasurementField>[f('l2'), f('r2', name: 'x' * 100)]),
        throwsA(anything),
      );
      expect((await repo.fields()).map((x) => x.id), isNot(contains('l2')));
    });

    test(
      'removeFields removes both sides, archiving when either has data',
      () async {
        final UserDatabase db = memoryUserDb();
        addTearDown(db.close);
        final MeasurementRepository repo = MeasurementRepository(db);
        MeasurementField f(String id) => MeasurementField(
          id: id,
          name: id,
          unitType: MeasurementUnitType.length,
          pairId: 'p',
          updatedAt: DateTime.utc(2026),
        );
        await repo.saveFields(<MeasurementField>[f('l'), f('r')]);
        await repo.saveEntry(
          MeasurementEntry(
            id: 'e',
            date: DateTime.utc(2026, 2),
            values: const <String, double>{'l': 30},
            updatedAt: DateTime.utc(2026),
          ),
        );
        expect(
          await repo.removeFields(<String>['l', 'r']),
          FieldRemoval.archived,
        );
        expect(await repo.fields(), isEmpty);
        expect((await repo.fields(includeArchived: true)).length, 2);
      },
    );
  });
}

/// Preferences whose writes fail.
class _ThrowingPrefs extends Fake implements SharedPreferences {
  @override
  Future<bool> setString(String key, String value) =>
      Future<bool>.error(StateError('disk full'));
}
