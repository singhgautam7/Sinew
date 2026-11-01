import 'package:csv/csv.dart';

import '../../core/db/repositories/exercise_repository.dart';
import '../../core/db/repositories/measurement_repository.dart';
import '../../core/db/repositories/session_repository.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/models/measurement.dart';
import '../../core/models/training.dart';

// PURE DART (no Flutter imports).

/// A finished CSV export: the file name and its text.
class CsvFile {
  const CsvFile({required this.fileName, required this.contents});

  final String fileName;
  final String contents;
}

/// Spreadsheet exports. Values are metric, as stored: kilograms, centimetres,
/// metres, seconds. Dates are local time, `yyyy-MM-dd HH:mm`.
class CsvExportService {
  CsvExportService({
    required this._measurements,
    required this._sessions,
    required this._resolver,
  });

  final MeasurementRepository _measurements;
  final SessionRepository _sessions;
  final ExerciseResolver _resolver;

  static const String measurementsFileName = 'measurements.csv';
  static const String setsFileName = 'sets.csv';

  /// `sets.csv` header, in order.
  static const List<String> setsHeader = <String>[
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
  ];

  Future<CsvFile> measurementsCsv() async => CsvFile(
    fileName: measurementsFileName,
    contents: buildMeasurementsCsv(
      fields: await _measurements.fields(includeArchived: true),
      entries: await _measurements.entries(),
    ),
  );

  Future<CsvFile> setsCsv() async {
    final List<WorkoutSession> sessions = await _sessions.allWithTree();
    final Set<String> ids = <String>{
      for (final WorkoutSession s in sessions)
        for (final SessionExercise e in s.exercises) e.exerciseId,
    };
    final Map<String, Exercise> found = await _resolver.resolve(ids);
    return CsvFile(
      fileName: setsFileName,
      contents: buildSetsCsv(
        sessions: sessions,
        exerciseNames: <String, String>{
          for (final MapEntry<String, Exercise> e in found.entries)
            e.key: e.value.name,
        },
      ),
    );
  }

  /// `date`, one column per field named `Name (unit)`, then `note`. One row
  /// per entry, oldest first. A field appears when it is enabled and not
  /// archived, or when any entry has a value for it; empty cells are blank.
  static String buildMeasurementsCsv({
    required List<MeasurementField> fields,
    required List<MeasurementEntry> entries,
  }) {
    final Set<String> used = <String>{
      for (final MeasurementEntry e in entries) ...e.values.keys,
    };
    final List<MeasurementField> columns =
        fields
            .where(
              (MeasurementField f) =>
                  used.contains(f.id) || (f.enabled && !f.archived),
            )
            .toList()
          ..sort(
            (MeasurementField a, MeasurementField b) => a.position != b.position
                ? a.position - b.position
                : a.name.compareTo(b.name),
          );
    final List<MeasurementEntry> ordered = <MeasurementEntry>[...entries]
      ..sort(
        (MeasurementEntry a, MeasurementEntry b) => a.date.compareTo(b.date),
      );
    final List<List<Object?>> rows = <List<Object?>>[
      <Object?>[
        'date',
        for (final MeasurementField f in columns) _columnTitle(f),
        'note',
      ],
      for (final MeasurementEntry e in ordered)
        <Object?>[
          formatDateTime(e.date),
          for (final MeasurementField f in columns)
            e.values.containsKey(f.id) ? formatNumber(e.values[f.id]!) : '',
          e.note ?? '',
        ],
    ];
    return Csv().encode(rows);
  }

  /// One row per set, sessions oldest first, then exercise and set order.
  /// [exerciseNames] maps exercise id to name; an id with no name falls back
  /// to the id itself.
  static String buildSetsCsv({
    required List<WorkoutSession> sessions,
    required Map<String, String> exerciseNames,
  }) {
    final List<WorkoutSession> ordered = <WorkoutSession>[...sessions]
      ..sort(
        (WorkoutSession a, WorkoutSession b) =>
            a.startedAt.compareTo(b.startedAt),
      );
    final List<List<Object?>> rows = <List<Object?>>[
      setsHeader,
      for (final WorkoutSession s in ordered)
        for (final SessionExercise e in _byPosition(s.exercises))
          for (final SetEntry x in _setsByPosition(e.sets))
            <Object?>[
              formatDateTime(s.startedAt),
              s.id,
              exerciseNames[e.exerciseId] ?? e.exerciseId,
              e.exerciseId,
              x.position + 1,
              x.type.name,
              x.isWarmup,
              _opt(x.weightKg),
              _opt(x.reps),
              _opt(x.durationSec),
              _opt(x.distanceM),
              _opt(x.rounds),
              _opt(x.holdSec),
              x.completed,
              x.isPR,
            ],
    ];
    return Csv().encode(rows);
  }

  static List<SessionExercise> _byPosition(List<SessionExercise> l) =>
      <SessionExercise>[...l]..sort(
        (SessionExercise a, SessionExercise b) => a.position - b.position,
      );

  static List<SetEntry> _setsByPosition(List<SetEntry> l) =>
      <SetEntry>[...l]
        ..sort((SetEntry a, SetEntry b) => a.position - b.position);

  static Object _opt(num? v) => v == null ? '' : formatNumber(v);

  static String _columnTitle(MeasurementField f) {
    final String? unit = switch (f.unitType) {
      MeasurementUnitType.mass => 'kg',
      MeasurementUnitType.length => 'cm',
      MeasurementUnitType.percent => '%',
      MeasurementUnitType.count => null,
      MeasurementUnitType.custom => f.customUnit,
    };
    return unit == null || unit.isEmpty ? f.name : '${f.name} ($unit)';
  }

  /// `75` for 75.0, `75.5` for 75.5.
  static String formatNumber(num v) {
    if (v is int) return '$v';
    return v == v.roundToDouble() ? '${v.round()}' : '$v';
  }

  /// Local time, `2026-01-05 08:30`.
  static String formatDateTime(DateTime d) {
    final DateTime l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year.toString().padLeft(4, '0')}-${two(l.month)}-${two(l.day)} '
        '${two(l.hour)}:${two(l.minute)}';
  }
}
