import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/core/db/repositories/backup_repository.dart';
import 'package:sinew/core/db/repositories/backup_snapshot.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/plate_inventory.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/features/backup/backup_codec.dart';
import 'package:sinew/features/backup/backup_service.dart';

import '../helpers/backup_fixtures.dart';
import '../helpers/test_db.dart';

DateTime _t(int minutes) =>
    DateTime.utc(2026, 3, 1, 12).add(Duration(minutes: minutes));

WorkoutSession _session(
  String id,
  DateTime updatedAt, {
  int sets = 2,
  DateTime? endedAt,
  bool finished = true,
}) => WorkoutSession(
  id: id,
  name: id,
  startedAt: _t(0),
  endedAt: finished ? (endedAt ?? _t(60)) : null,
  updatedAt: updatedAt,
  exercises: <SessionExercise>[
    SessionExercise(
      id: '$id-e',
      exerciseId: 'bench-press',
      position: 0,
      sets: <SetEntry>[
        for (int i = 0; i < sets; i++)
          SetEntry(id: '$id-s$i', position: i, reps: 5, weightKg: 50),
      ],
    ),
  ],
);

void main() {
  late UserDatabase db;
  late BackupRepository repo;
  late SharedPreferences prefs;
  late BackupService service;

  setUp(() async {
    db = memoryUserDb();
    repo = BackupRepository(db);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    service = BackupService(
      repository: repo,
      prefs: prefs,
      clock: () => DateTime.utc(2026, 5, 6, 7, 8),
    );
  });
  tearDown(() => db.close());

  group('export', () {
    test('file name is sinew-backup-YYYYMMDD-HHmm.json in local time', () {
      expect(
        BackupService.fileNameFor(DateTime(2026, 1, 2, 3, 4)),
        'sinew-backup-20260102-0304.json',
      );
      expect(
        BackupService.fileNameFor(DateTime(2026, 11, 12, 13, 14)),
        'sinew-backup-20261112-1314.json',
      );
    });

    test('one JSON document with the documented keys and versions', () async {
      await populate(db);
      await prefs.setString('library.version', '1.0.0');
      await prefs.setString('theme.mode', 'dark');
      await prefs.setBool('theme.amoled', true);
      await prefs.setDouble('text.scale', 1.15);
      await prefs.setBool('app.onboarded', true);
      await prefs.setString('units.extra', 'x');
      await prefs.setString('library.other', 'not exported');
      await prefs.setInt('theme.wallpaperSeed', 0xff336699);

      final BackupFile file = await service.export();
      final Map<String, dynamic> json =
          jsonDecode(file.contents) as Map<String, dynamic>;
      expect(json.keys.toSet(), <String>{
        'app',
        'schemaVersion',
        'exportedAt',
        'libraryVersion',
        'profile',
        'customExercises',
        'exerciseTombstones',
        'routines',
        'sessions',
        'measurementFields',
        'measurementEntries',
        'timerPresets',
        'plateInventory',
        'settings',
      });
      expect(json['app'], 'sinew');
      expect(json['schemaVersion'], 1);
      expect(json['libraryVersion'], '1.0.0');
      expect(json['exportedAt'], '2026-05-06T07:08:00.000Z');
      expect((json['sessions'] as List<dynamic>).length, 3);
      expect(json['settings'], <String, Object>{
        'app.onboarded': true,
        'text.scale': 1.15,
        'theme.amoled': true,
        'theme.mode': 'dark',
        'theme.wallpaperSeed': 0xff336699,
        'units.extra': 'x',
      });
      expect(
        file.fileName,
        matches(RegExp(r'^sinew-backup-\d{8}-\d{4}\.json$')),
      );
    });

    test('records backup.lastAt, unless told to wait', () async {
      expect(service.lastBackupAt, isNull);
      await service.export(markBackedUp: false);
      expect(service.lastBackupAt, isNull);
      await service.export();
      expect(service.lastBackupAt, DateTime.utc(2026, 5, 6, 7, 8));
      expect(prefs.getString('backup.lastAt'), '2026-05-06T07:08:00.000Z');
    });

    test('an empty database exports and parses', () async {
      final BackupFile file = await service.export();
      final BackupParseResult r = service.parse(file.contents);
      final BackupPreview p = (r as ParsedBackup).preview;
      expect(p.sessions, 0);
      expect(p.firstSessionAt, isNull);
      expect(p.hasProfile, isFalse);
      expect(p.hasPlateInventory, isFalse);
    });
  });

  group('restore (replace)', () {
    test('export then restore into a fresh database is lossless', () async {
      await populate(db, withActive: true);
      await prefs.setString('theme.mode', 'light');
      await prefs.setDouble('text.scale', 1.2);
      final BackupSnapshot before = await repo.readAll();
      expect(before.sessions.length, 4);
      final BackupFile file = await service.export();

      final UserDatabase fresh = memoryUserDb();
      addTearDown(fresh.close);
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences freshPrefs =
          await SharedPreferences.getInstance();
      final BackupService target = BackupService(
        repository: BackupRepository(fresh),
        prefs: freshPrefs,
      );
      final BackupParseResult parsed = target.parse(file.contents);
      final BackupPreview preview = (parsed as ParsedBackup).preview;
      expect(preview.sessions, 4);
      expect(preview.customExercises, 2);
      expect(preview.routines, 1);
      expect(preview.measurementEntries, 2);
      expect(preview.timerPresets, 1);
      expect(preview.hasProfile, isTrue);
      expect(preview.hasPlateInventory, isTrue);
      expect(preview.schemaVersion, 1);
      expect(preview.exportedAt, DateTime.utc(2026, 5, 6, 7, 8));
      expect(preview.firstSessionAt, DateTime.utc(2026, 1, 1, 9));
      expect(preview.lastSessionAt, isNotNull);
      expect(preview.settings, 2);

      final RestoreSummary summary = await target.restore(
        preview,
        mode: RestoreMode.replace,
      );
      expect(summary.written['sessions'], 4);
      expect(summary.settingsApplied, 2);

      expectSameSnapshot(await BackupRepository(fresh).readAll(), before);
      expect(freshPrefs.getString('theme.mode'), 'light');
      expect(freshPrefs.getDouble('text.scale'), 1.2);

      // Specific values survive the trip.
      final BackupSnapshot after = await BackupRepository(fresh).readAll();
      expect(after.profile!.heightCm, 171.5);
      expect(after.profile!.weightUnit, WeightUnit.lb);
      expect(after.plateInventory!.machineStepKg, 4.5);
      expect(
        after.sessions.firstWhere((WorkoutSession s) => s.endedAt == null).name,
        'Running',
      );
      expect(after.tombstones.single.exerciseId, 'removed-lift');
    });

    test('replace wipes what was there', () async {
      await populate(db);
      final BackupFile file = await service.export();

      final UserDatabase other = memoryUserDb();
      addTearDown(other.close);
      await populate(other, sessions: 5);
      final BackupRepository otherRepo = BackupRepository(other);
      await otherRepo.writeAll(
        (service.parse(
          file.contents,
        ) as ParsedBackup).preview.document.snapshot,
        mode: RestoreMode.replace,
      );
      final BackupSnapshot got = await otherRepo.readAll();
      expect(got.sessions.length, 3);
      expectSameSnapshot(got, await repo.readAll());
    });
  });

  group('restore (merge)', () {
    test('newer wins in both directions, untouched ids are kept', () async {
      // Local device.
      await repo.writeAll(
        BackupSnapshot(
          profile: Profile(heightCm: 170, updatedAt: _t(10)),
          plateInventory: PlateInventory(machineStepKg: 2, updatedAt: _t(50)),
          customExercises: <Exercise>[
            Exercise(
              id: 'custom-a',
              name: 'A local newer',
              category: 'strength',
              trackingType: TrackingType.reps,
              createdAt: _t(0),
              updatedAt: _t(30),
            ),
            Exercise(
              id: 'custom-b',
              name: 'B local older',
              category: 'strength',
              trackingType: TrackingType.reps,
              createdAt: _t(0),
              updatedAt: _t(10),
            ),
            Exercise(
              id: 'custom-local-only',
              name: 'Local only',
              category: 'strength',
              trackingType: TrackingType.reps,
              createdAt: _t(0),
              updatedAt: _t(5),
            ),
          ],
          routines: <Routine>[
            Routine(
              id: 'r-new-local',
              name: 'Local newer',
              createdAt: _t(0),
              updatedAt: _t(40),
              items: const <RoutineItem>[
                RoutineItem(id: 'ri-l1', exerciseId: 'x', position: 0),
              ],
            ),
            Routine(
              id: 'r-old-local',
              name: 'Local older',
              createdAt: _t(0),
              updatedAt: _t(10),
              items: const <RoutineItem>[
                RoutineItem(id: 'ri-l2', exerciseId: 'x', position: 0),
                RoutineItem(id: 'ri-l3', exerciseId: 'y', position: 1),
              ],
            ),
          ],
          sessions: <WorkoutSession>[
            _session('s-new-local', _t(100), sets: 3),
            _session('s-old-local', _t(10), sets: 3),
            _session('s-local-only', _t(10)),
          ],
          measurementFields: <MeasurementField>[
            MeasurementField(
              id: 'f1',
              name: 'Local newer',
              unitType: MeasurementUnitType.length,
              updatedAt: _t(60),
            ),
            MeasurementField(
              id: 'f2',
              name: 'Local older',
              unitType: MeasurementUnitType.length,
              updatedAt: _t(10),
            ),
          ],
          measurementEntries: <MeasurementEntry>[
            MeasurementEntry(
              id: 'e-new-local',
              date: _t(0),
              values: const <String, double>{'f1': 1},
              updatedAt: _t(70),
            ),
            MeasurementEntry(
              id: 'e-old-local',
              date: _t(0),
              values: const <String, double>{'f1': 2, 'f2': 3},
              updatedAt: _t(10),
            ),
          ],
          timerPresets: <TimerPreset>[
            TimerPreset(
              id: 'p-new-local',
              name: 'Local newer',
              mode: TimerMode.emom,
              updatedAt: _t(80),
            ),
            TimerPreset(
              id: 'p-old-local',
              name: 'Local older',
              mode: TimerMode.emom,
              updatedAt: _t(10),
            ),
          ],
        ),
        mode: RestoreMode.replace,
      );

      // Incoming backup.
      final BackupSnapshot incoming = BackupSnapshot(
        profile: Profile(heightCm: 180, updatedAt: _t(20)),
        plateInventory: PlateInventory(machineStepKg: 9, updatedAt: _t(20)),
        customExercises: <Exercise>[
          Exercise(
            id: 'custom-a',
            name: 'A incoming older',
            category: 'strength',
            trackingType: TrackingType.reps,
            createdAt: _t(0),
            updatedAt: _t(20),
          ),
          Exercise(
            id: 'custom-b',
            name: 'B incoming newer',
            category: 'strength',
            trackingType: TrackingType.reps,
            createdAt: _t(0),
            updatedAt: _t(20),
          ),
          Exercise(
            id: 'custom-new',
            name: 'Only incoming',
            category: 'strength',
            trackingType: TrackingType.reps,
            createdAt: _t(0),
            updatedAt: _t(1),
          ),
        ],
        routines: <Routine>[
          Routine(
            id: 'r-new-local',
            name: 'Incoming older',
            createdAt: _t(0),
            updatedAt: _t(20),
            items: const <RoutineItem>[
              RoutineItem(id: 'ri-i1', exerciseId: 'z', position: 0),
            ],
          ),
          Routine(
            id: 'r-old-local',
            name: 'Incoming newer',
            createdAt: _t(0),
            updatedAt: _t(20),
            items: const <RoutineItem>[
              RoutineItem(id: 'ri-i2', exerciseId: 'z', position: 0),
            ],
          ),
        ],
        sessions: <WorkoutSession>[
          _session('s-new-local', _t(20), sets: 1),
          _session('s-old-local', _t(20), sets: 1),
          _session('s-incoming-only', _t(5)),
        ],
        measurementFields: <MeasurementField>[
          MeasurementField(
            id: 'f1',
            name: 'Incoming older',
            unitType: MeasurementUnitType.length,
            updatedAt: _t(20),
          ),
          MeasurementField(
            id: 'f2',
            name: 'Incoming newer',
            unitType: MeasurementUnitType.length,
            updatedAt: _t(20),
          ),
        ],
        measurementEntries: <MeasurementEntry>[
          MeasurementEntry(
            id: 'e-new-local',
            date: _t(0),
            values: const <String, double>{'f1': 99},
            updatedAt: _t(20),
          ),
          MeasurementEntry(
            id: 'e-old-local',
            date: _t(0),
            values: const <String, double>{'f2': 99},
            updatedAt: _t(20),
          ),
        ],
        timerPresets: <TimerPreset>[
          TimerPreset(
            id: 'p-new-local',
            name: 'Incoming older',
            mode: TimerMode.tabata,
            updatedAt: _t(20),
          ),
          TimerPreset(
            id: 'p-old-local',
            name: 'Incoming newer',
            mode: TimerMode.tabata,
            updatedAt: _t(20),
          ),
        ],
      );

      final BackupWriteResult result = await repo.writeAll(
        incoming,
        mode: RestoreMode.merge,
      );
      final BackupSnapshot got = normalized(await repo.readAll());

      // Profile and plate inventory: newer updatedAt wins.
      expect(got.profile!.heightCm, 180, reason: 'incoming profile is newer');
      expect(
        got.plateInventory!.machineStepKg,
        2,
        reason: 'local plates are newer',
      );

      Map<String, T> by<T>(List<T> l, String Function(T) id) => <String, T>{
        for (final T x in l) id(x): x,
      };
      final Map<String, Exercise> ex = by(
        got.customExercises,
        (Exercise e) => e.id,
      );
      expect(ex['custom-a']!.name, 'A local newer');
      expect(ex['custom-b']!.name, 'B incoming newer');
      expect(ex['custom-local-only']!.name, 'Local only');
      expect(ex['custom-new']!.name, 'Only incoming');

      final Map<String, Routine> rt = by(got.routines, (Routine r) => r.id);
      expect(rt['r-new-local']!.name, 'Local newer');
      expect(rt['r-new-local']!.items.map((RoutineItem i) => i.id), <String>[
        'ri-l1',
      ]);
      expect(rt['r-old-local']!.name, 'Incoming newer');
      expect(rt['r-old-local']!.items.map((RoutineItem i) => i.id), <String>[
        'ri-i2',
      ]);

      final Map<String, WorkoutSession> se = by(
        got.sessions,
        (WorkoutSession s) => s.id,
      );
      expect(se.keys.toSet(), <String>{
        's-new-local',
        's-old-local',
        's-local-only',
        's-incoming-only',
      });
      expect(
        se['s-new-local']!.exercises.single.sets.length,
        3,
        reason: 'local newer kept whole',
      );
      expect(
        se['s-old-local']!.exercises.single.sets.length,
        1,
        reason: 'incoming newer replaces the whole tree',
      );
      expect(se['s-old-local']!.updatedAt, _t(20));
      expect(se['s-local-only']!.exercises.single.sets.length, 2);

      final Map<String, MeasurementField> fl = by(
        got.measurementFields,
        (MeasurementField f) => f.id,
      );
      expect(fl['f1']!.name, 'Local newer');
      expect(fl['f2']!.name, 'Incoming newer');

      final Map<String, MeasurementEntry> en = by(
        got.measurementEntries,
        (MeasurementEntry e) => e.id,
      );
      expect(en['e-new-local']!.values, <String, double>{'f1': 1});
      expect(en['e-old-local']!.values, <String, double>{'f2': 99});

      final Map<String, TimerPreset> pr = by(
        got.timerPresets,
        (TimerPreset p) => p.id,
      );
      expect(pr['p-new-local']!.name, 'Local newer');
      expect(pr['p-old-local']!.name, 'Incoming newer');
      expect(pr['p-old-local']!.mode, TimerMode.tabata);

      expect(result.written['sessions'], 2);
      expect(result.kept['sessions'], 1);
      expect(result.written['profile'], 1);
      expect(result.kept['plateInventory'], 1);
    });

    test(
      'merging a backup into the device it came from changes nothing',
      () async {
        await populate(db, withActive: true);
        final BackupSnapshot before = await repo.readAll();
        final BackupFile file = await service.export();
        final BackupPreview preview =
            (service.parse(file.contents) as ParsedBackup).preview;
        final RestoreSummary summary = await service.restore(
          preview,
          mode: RestoreMode.merge,
        );
        expectSameSnapshot(await repo.readAll(), before);
        expect(
          summary.written.values.fold<int>(0, (int a, int b) => a + b),
          1,
          reason: 'only the tombstone upsert, which has no timestamp',
        );
      },
    );

    test('an unfinished workout never displaces the one in progress', () async {
      await repo.writeAll(
        BackupSnapshot(
          sessions: <WorkoutSession>[
            _session('running-here', _t(5), finished: false),
          ],
        ),
        mode: RestoreMode.replace,
      );
      final BackupResultCheck check = await _merge(
        repo,
        BackupSnapshot(
          sessions: <WorkoutSession>[
            _session('running-there', _t(50), finished: false),
            _session('done-there', _t(50)),
          ],
        ),
      );
      expect(check.ids, <String>['done-there', 'running-here']);
    });

    test('settings: merge fills gaps, replace overwrites', () async {
      await prefs.setString('theme.mode', 'dark');
      final BackupDocument doc = BackupDocument(
        schemaVersion: 1,
        exportedAt: _t(0),
        snapshot: const BackupSnapshot(),
        settings: const <String, Object>{
          'theme.mode': 'light',
          'text.scale': 1.1,
          'app.tags': <String>['a', 'b'],
          'evil.key': 'ignored',
        },
      );
      final BackupPreview preview = (service.parse(
        const BackupCodec().encode(doc),
      ) as ParsedBackup).preview;
      await service.restore(preview, mode: RestoreMode.merge);
      expect(prefs.getString('theme.mode'), 'dark');
      expect(prefs.getDouble('text.scale'), 1.1);
      expect(prefs.getStringList('app.tags'), <String>['a', 'b']);
      expect(prefs.containsKey('evil.key'), isFalse);
      await service.restore(preview, mode: RestoreMode.replace);
      expect(prefs.getString('theme.mode'), 'light');
    });
  });

  group('bad files fail safely and write nothing', () {
    late String good;
    setUp(() async {
      await populate(db);
      good = (await service.export()).contents;
    });

    Future<void> expectUntouched() async {
      final BackupSnapshot before = await repo.readAll();
      expect(before.sessions.length, 3);
      expect(
        prefs.getKeys().where((String k) => k.startsWith('theme.')),
        isEmpty,
      );
    }

    test('truncated or garbage text is CorruptBackup', () async {
      for (final String text in <String>[
        good.substring(0, good.length ~/ 2),
        '',
        'not json at all',
        '{"app":"sinew",',
      ]) {
        final BackupParseResult r = service.parse(text);
        expect(
          r,
          isA<RejectedBackup>(),
          reason: text.length > 30 ? 'truncated' : text,
        );
        expect((r as RejectedBackup).error, isA<CorruptBackup>());
        expect(r.error.message, isNotEmpty);
      }
      await expectUntouched();
    });

    test('a missing section or a damaged record is CorruptBackup', () async {
      final Map<String, dynamic> json =
          jsonDecode(good) as Map<String, dynamic>;
      final Map<String, dynamic> noSessions = <String, dynamic>{...json}
        ..remove('sessions');
      final BackupParseResult a = service.parse(jsonEncode(noSessions));
      expect((a as RejectedBackup).error, isA<CorruptBackup>());
      expect(a.error.message, contains('sessions'));

      final Map<String, dynamic> damaged =
          jsonDecode(good) as Map<String, dynamic>;
      ((damaged['sessions'] as List<dynamic>)[1]
              as Map<String, dynamic>)['startedAt'] =
          'yesterday-ish';
      final BackupParseResult b = service.parse(jsonEncode(damaged));
      expect((b as RejectedBackup).error, isA<CorruptBackup>());
      expect(b.error.message, contains('Item 2 of "sessions"'));

      final Map<String, dynamic> dup = jsonDecode(good) as Map<String, dynamic>;
      final List<dynamic> ss = dup['sessions'] as List<dynamic>;
      ss[1] = ss[0];
      final BackupParseResult c = service.parse(jsonEncode(dup));
      expect((c as RejectedBackup).error, isA<CorruptBackup>());

      final Map<String, dynamic> noVersion = <String, dynamic>{...json}
        ..['schemaVersion'] = 'one';
      expect(
        (service.parse(jsonEncode(noVersion)) as RejectedBackup).error,
        isA<CorruptBackup>(),
      );
      await expectUntouched();
    });

    test('a file from another app is NotASinewBackup', () async {
      for (final String text in <String>[
        jsonEncode(<String, Object>{'version': 3, 'transactions': <Object>[]}),
        jsonEncode(<String, Object>{'app': 'kuber', 'schemaVersion': 1}),
        jsonEncode(<Object>[1, 2, 3]),
        '42',
        '"sinew"',
      ]) {
        final BackupParseResult r = service.parse(text);
        expect(
          (r as RejectedBackup).error,
          isA<NotASinewBackup>(),
          reason: text,
        );
        expect(r.error.message, contains('not a Sinew backup'));
      }
      await expectUntouched();
    });

    test(
      'a newer format is BackupFromNewerVersion with both numbers',
      () async {
        final Map<String, dynamic> json =
            jsonDecode(good) as Map<String, dynamic>;
        json['schemaVersion'] = 7;
        final BackupParseResult r = service.parse(jsonEncode(json));
        final BackupFailure e = (r as RejectedBackup).error;
        expect(e, isA<BackupFromNewerVersion>());
        expect((e as BackupFromNewerVersion).found, 7);
        expect(e.supported, 1);
        expect(e.message, contains('7'));
        expect(e.message, contains('newer'));
        await expectUntouched();
      },
    );

    test('a mid-restore failure rolls everything back', () async {
      final BackupSnapshot before = await repo.readAll();

      // Two sessions share a set id: the second insert violates the primary
      // key after the wipe and several inserts have already happened.
      final BackupSnapshot poisoned = BackupSnapshot(
        profile: const Profile(heightCm: 1),
        customExercises: <Exercise>[
          Exercise(
            id: 'custom-z',
            name: 'Z',
            category: 'strength',
            trackingType: TrackingType.reps,
            createdAt: _t(0),
            updatedAt: _t(0),
          ),
        ],
        sessions: <WorkoutSession>[
          _session('p1', _t(1)),
          _session('p2', _t(1)).copyWith(
            exercises: <SessionExercise>[
              const SessionExercise(
                id: 'p2-e',
                exerciseId: 'x',
                position: 0,
                sets: <SetEntry>[SetEntry(id: 'p1-s0', position: 0)],
              ),
            ],
          ),
        ],
      );
      await expectLater(
        repo.writeAll(poisoned, mode: RestoreMode.replace),
        throwsA(anything),
      );
      expectSameSnapshot(await repo.readAll(), before);

      // Through the service: a typed failure, and settings untouched too.
      final BackupPreview preview = BackupPreview(
        document: BackupDocument(
          schemaVersion: 1,
          exportedAt: _t(0),
          snapshot: poisoned,
          settings: const <String, Object>{'theme.mode': 'light'},
        ),
        schemaVersion: 1,
        exportedAt: _t(0),
        libraryVersion: null,
        customExercises: 1,
        routines: 0,
        sessions: 2,
        measurementFields: 0,
        measurementEntries: 0,
        timerPresets: 0,
        hasProfile: true,
        hasPlateInventory: false,
        settings: 1,
        firstSessionAt: _t(0),
        lastSessionAt: _t(0),
      );
      await expectLater(
        service.restore(preview, mode: RestoreMode.replace),
        throwsA(isA<RestoreFailed>()),
      );
      expectSameSnapshot(await repo.readAll(), before);
      expect(prefs.containsKey('theme.mode'), isFalse);
    });
  });

  group('format migration hook', () {
    test('an older file is migrated step by step before it is read', () async {
      await populate(db, sessions: 1);
      final String v1 = (await service.export()).contents;

      final BackupCodec v3 = BackupCodec(
        currentVersion: 3,
        migrations: <int, BackupMigration>{
          1: (Map<String, Object?> d) => <String, Object?>{
            ...d,
            'schemaVersion': 2,
            'step1': true,
          },
          2: (Map<String, Object?> d) {
            expect(d['step1'], isTrue, reason: 'steps run in order');
            return <String, Object?>{...d, 'schemaVersion': 3};
          },
        },
      );
      final BackupParseResult r = v3.decode(v1);
      final BackupPreview p = (r as ParsedBackup).preview;
      expect(p.schemaVersion, 1, reason: 'preview reports the file as written');
      expect(p.document.schemaVersion, 3);
      expect(p.sessions, 1);

      final BackupCodec gap = BackupCodec(
        currentVersion: 3,
        migrations: <int, BackupMigration>{2: (Map<String, Object?> d) => d},
      );
      expect((gap.decode(v1) as RejectedBackup).error, isA<CorruptBackup>());
    });
  });

  group('providers', () {
    test('lastBackupAt and the reminder', () async {
      await populate(db, sessions: 10);
      final ProviderContainer container = ProviderContainer(
        retry: noRetry,
        overrides: <Override>[
          userDatabaseProvider.overrideWithValue(db),
          prefsProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(lastBackupAtProvider), isNull);
      expect(await container.read(shouldRemindBackupProvider.future), isTrue);

      await container.read(backupServiceProvider).export();
      expect(container.read(lastBackupAtProvider), isNotNull);
      expect(await container.read(shouldRemindBackupProvider.future), isFalse);
    });

    test('no reminder below ten finished workouts', () async {
      await populate(db, sessions: 9, withActive: true);
      final ProviderContainer container = ProviderContainer(
        retry: noRetry,
        overrides: <Override>[
          userDatabaseProvider.overrideWithValue(db),
          prefsProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);
      expect(await container.read(shouldRemindBackupProvider.future), isFalse);
    });

    test('restoring settings refreshes the settings provider', () async {
      final ProviderContainer container = ProviderContainer(
        retry: noRetry,
        overrides: <Override>[
          userDatabaseProvider.overrideWithValue(db),
          prefsProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(settingsProvider).amoled, isFalse);
      final BackupService svc = container.read(backupServiceProvider);
      final BackupPreview preview = (svc.parse(
        const BackupCodec().encode(
          BackupDocument(
            schemaVersion: 1,
            exportedAt: _t(0),
            snapshot: const BackupSnapshot(),
            settings: const <String, Object>{'theme.amoled': true},
          ),
        ),
      ) as ParsedBackup).preview;
      await svc.restore(preview, mode: RestoreMode.replace);
      expect(container.read(settingsProvider).amoled, isTrue);
    });
  });
}

class BackupResultCheck {
  const BackupResultCheck(this.ids);

  final List<String> ids;
}

Future<BackupResultCheck> _merge(
  BackupRepository repo,
  BackupSnapshot incoming,
) async {
  await repo.writeAll(incoming, mode: RestoreMode.merge);
  final List<String> ids =
      (await repo.readAll()).sessions.map((WorkoutSession s) => s.id).toList()
        ..sort();
  return BackupResultCheck(ids);
}
