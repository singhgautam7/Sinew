import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/repositories/measurement_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/features/backup/csv_export.dart';

import '../helpers/backup_fixtures.dart';
import '../helpers/test_db.dart';
import '../helpers/test_library.dart';

List<List<dynamic>> _parse(String csv) => Csv().decode(csv);

void main() {
  group('measurements.csv', () {
    final List<MeasurementField> fields = <MeasurementField>[
      MeasurementField(
        id: 'weight',
        name: 'Weight',
        unitType: MeasurementUnitType.mass,
        position: 0,
        updatedAt: DateTime.utc(2026),
      ),
      MeasurementField(
        id: 'waist',
        name: 'Waist',
        unitType: MeasurementUnitType.length,
        position: 1,
        updatedAt: DateTime.utc(2026),
      ),
      MeasurementField(
        id: 'fat',
        name: 'Body fat',
        unitType: MeasurementUnitType.percent,
        position: 2,
        updatedAt: DateTime.utc(2026),
      ),
      MeasurementField(
        id: 'grip',
        name: 'Grip, left',
        unitType: MeasurementUnitType.custom,
        customUnit: 'lbf',
        position: 3,
        updatedAt: DateTime.utc(2026),
      ),
      MeasurementField(
        id: 'old',
        name: 'Old (archived, unused)',
        unitType: MeasurementUnitType.length,
        archived: true,
        enabled: false,
        position: 4,
        updatedAt: DateTime.utc(2026),
      ),
      MeasurementField(
        id: 'old-used',
        name: 'Archived but used',
        unitType: MeasurementUnitType.count,
        archived: true,
        enabled: false,
        position: 5,
        updatedAt: DateTime.utc(2026),
      ),
    ];
    final List<MeasurementEntry> entries = <MeasurementEntry>[
      MeasurementEntry(
        id: 'b',
        date: DateTime(2026, 2, 3, 7, 5),
        values: const <String, double>{'weight': 71.5, 'old-used': 3},
        updatedAt: DateTime.utc(2026),
      ),
      MeasurementEntry(
        id: 'a',
        date: DateTime(2026, 1, 5, 8, 30),
        values: const <String, double>{
          'weight': 72,
          'waist': 80.25,
          'grip': 40,
        },
        note: 'After "cut", fasted',
        updatedAt: DateTime.utc(2026),
      ),
    ];

    test('header: date, one column per field with unit, note', () {
      final List<List<dynamic>> rows = _parse(
        CsvExportService.buildMeasurementsCsv(fields: fields, entries: entries),
      );
      expect(rows.first, <String>[
        'date',
        'Weight (kg)',
        'Waist (cm)',
        'Body fat (%)',
        'Grip, left (lbf)',
        'Archived but used',
        'note',
      ]);
    });

    test('rows: oldest first, blanks for missing values, notes quoted', () {
      final String csv = CsvExportService.buildMeasurementsCsv(
        fields: fields,
        entries: entries,
      );
      final List<List<dynamic>> rows = _parse(csv);
      expect(rows.length, 3);
      expect(rows[1], <dynamic>[
        '2026-01-05 08:30',
        '72',
        '80.25',
        '',
        '40',
        '',
        'After "cut", fasted',
      ]);
      expect(rows[2], <dynamic>[
        '2026-02-03 07:05',
        '71.5',
        '',
        '',
        '',
        '3',
        '',
      ]);
      expect(csv, contains('"Grip, left (lbf)"'));
      expect(csv, contains('"After ""cut"", fasted"'));
    });

    test('no entries still gives a header row', () {
      final List<List<dynamic>> rows = _parse(
        CsvExportService.buildMeasurementsCsv(
          fields: fields,
          entries: const <MeasurementEntry>[],
        ),
      );
      expect(rows.length, 1);
      expect(rows.first.first, 'date');
      expect(rows.first.last, 'note');
    });
  });

  group('sets.csv', () {
    final List<WorkoutSession> sessions = <WorkoutSession>[
      WorkoutSession(
        id: 'late',
        startedAt: DateTime(2026, 1, 9, 18),
        updatedAt: DateTime.utc(2026),
        exercises: <SessionExercise>[
          const SessionExercise(
            id: 'x',
            exerciseId: 'plank',
            position: 0,
            sets: <SetEntry>[
              SetEntry(id: 's1', position: 0, holdSec: 45, completed: true),
            ],
          ),
        ],
      ),
      WorkoutSession(
        id: 'early',
        startedAt: DateTime(2026, 1, 2, 7, 15),
        updatedAt: DateTime.utc(2026),
        exercises: <SessionExercise>[
          const SessionExercise(
            id: 'e2',
            exerciseId: 'gone-move',
            position: 1,
            sets: <SetEntry>[SetEntry(id: 'z', position: 0)],
          ),
          const SessionExercise(
            id: 'e1',
            exerciseId: 'bench-press',
            position: 0,
            sets: <SetEntry>[
              SetEntry(
                id: 'b2',
                position: 1,
                type: SetType.drop,
                weightKg: 57.5,
                reps: 6,
                completed: true,
                isPR: true,
              ),
              SetEntry(
                id: 'b1',
                position: 0,
                weightKg: 60,
                reps: 8,
                durationSec: 40,
                distanceM: 1.5,
                rounds: 2,
                completed: true,
                isWarmup: true,
              ),
            ],
          ),
        ],
      ),
    ];

    test('header is fixed', () {
      expect(CsvExportService.setsHeader, <String>[
        'date',
        'session_id',
        'exercise',
        'exercise_id',
        'set',
        'type',
        'warmup',
        'weight_kg',
        'reps',
        'duration_s',
        'distance_m',
        'rounds',
        'hold_s',
        'completed',
        'pr',
      ]);
    });

    test('one row per set, in session, exercise and set order', () {
      final List<List<dynamic>> rows = _parse(
        CsvExportService.buildSetsCsv(
          sessions: sessions,
          exerciseNames: const <String, String>{
            'bench-press': 'Bench Press',
            'plank': 'Plank',
          },
        ),
      );
      expect(rows.first, CsvExportService.setsHeader);
      expect(rows.length, 1 + 4);
      expect(rows[1], <dynamic>[
        '2026-01-02 07:15', 'early', 'Bench Press', 'bench-press', '1',
        'normal', 'true', '60', '8', '40', '1.5', '2', '', 'true', 'false', //
      ]);
      expect(rows[2], <dynamic>[
        '2026-01-02 07:15', 'early', 'Bench Press', 'bench-press', '2',
        'drop', 'false', '57.5', '6', '', '', '', '', 'true', 'true', //
      ]);
      // A name that no longer resolves falls back to its id.
      expect(rows[3][2], 'gone-move');
      expect(rows[3][3], 'gone-move');
      expect(rows[3][13], 'false');
      expect(rows[4], <dynamic>[
        '2026-01-09 18:00', 'late', 'Plank', 'plank', '1',
        'normal', 'false', '', '', '', '', '', '45', 'true', 'false', //
      ]);
    });

    test('the service resolves names through the resolver', () async {
      final UserDatabase db = memoryUserDb();
      addTearDown(db.close);
      await populate(db, sessions: 1);
      final CustomExerciseRepository custom = CustomExerciseRepository(db);
      await custom.addTombstones(const <ExerciseTombstone>[
        ExerciseTombstone(
          exerciseId: 'plank',
          name: 'Plank (retired)',
          trackingType: TrackingType.hold,
          removedInLibraryVersion: '2.0.0',
        ),
      ]);
      final Directory dir = await Directory.systemTemp.createTemp('sinew_csv');
      addTearDown(() => dir.delete(recursive: true));
      final LibraryDatabase lib = openLibrary(
        await buildTestLibrary(
          dir,
          exercises: <Map<String, Object?>>[
            exerciseJson('bench-press', 'Bench Press'),
          ],
        ),
      );
      addTearDown(lib.close);

      final CsvExportService svc = CsvExportService(
        measurements: MeasurementRepository(db),
        sessions: SessionRepository(db),
        resolver: ExerciseResolver(
          custom: custom,
          library: LibraryRepository(lib),
        ),
      );
      final CsvFile sets = await svc.setsCsv();
      expect(sets.fileName, 'sets.csv');
      final List<List<dynamic>> rows = _parse(sets.contents);
      expect(rows.length, 1 + 4);
      expect(rows.skip(1).map((List<dynamic> r) => r[2]).toSet(), <String>{
        'Bench Press',
        'Plank (retired)',
      });

      final CsvFile m = await svc.measurementsCsv();
      expect(m.fileName, 'measurements.csv');
      final List<List<dynamic>> mrows = _parse(m.contents);
      expect(mrows.first.first, 'date');
      expect(mrows.first, contains('Weight (kg)'));
      expect(mrows.length, 3);
    });
  });
}
