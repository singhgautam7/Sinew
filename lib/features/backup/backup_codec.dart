import 'dart:convert';

import '../../core/db/repositories/backup_snapshot.dart';
import '../../core/models/exercise.dart';
import '../../core/models/measurement.dart';
import '../../core/models/plate_inventory.dart';
import '../../core/models/profile.dart';
import '../../core/models/timer_preset.dart';
import '../../core/models/training.dart';
import 'backup_types.dart';

// PURE DART.

/// One migration step: takes a document at version N and returns it at N + 1.
typedef BackupMigration = Map<String, Object?> Function(Map<String, Object?>);

/// Turns a [BackupDocument] into backup JSON and back, validating everything
/// before anything is written.
///
/// The file is one JSON object:
/// `app` ("sinew"), `schemaVersion`, `exportedAt`, `libraryVersion`,
/// `profile`, `customExercises`, `exerciseTombstones`, `routines`,
/// `sessions`, `measurementFields`, `measurementEntries`, `timerPresets`,
/// `plateInventory`, `settings`. Records use the models' own `toJson`.
class BackupCodec {
  const BackupCodec({
    this.currentVersion = currentSchemaVersion,
    this.migrations = const <int, BackupMigration>{},
  });

  /// The backup format this build writes and reads natively.
  static const int currentSchemaVersion = 1;
  static const String appId = 'sinew';

  /// This build's format (overridable in tests to exercise the chain).
  final int currentVersion;

  /// `migrations[n]` upgrades a version n document to n + 1. Only version 1
  /// exists today, so the chain is empty; add a step here with every format
  /// bump and an older file keeps restoring.
  final Map<int, BackupMigration> migrations;

  String encode(BackupDocument doc) {
    final BackupSnapshot s = doc.snapshot;
    return jsonEncode(<String, Object?>{
      'app': appId,
      'schemaVersion': currentVersion,
      'exportedAt': doc.exportedAt.toUtc().toIso8601String(),
      'libraryVersion': doc.libraryVersion,
      'profile': s.profile?.toJson(),
      'customExercises': s.customExercises,
      'exerciseTombstones': s.tombstones,
      'routines': s.routines,
      'sessions': s.sessions,
      'measurementFields': s.measurementFields,
      'measurementEntries': s.measurementEntries,
      'timerPresets': s.timerPresets,
      'plateInventory': s.plateInventory?.toJson(),
      'settings': doc.settings,
    });
  }

  BackupParseResult decode(String text) {
    try {
      return ParsedBackup(_decode(text));
    } on BackupFailure catch (e) {
      return RejectedBackup(e);
    } on Object catch (e) {
      // Nothing above should escape, but a backup file must never crash the
      // app: anything unforeseen is a damaged file.
      return RejectedBackup(
        CorruptBackup('This backup could not be read ($e).'),
      );
    }
  }

  BackupPreview _decode(String text) {
    final Object? raw;
    try {
      raw = jsonDecode(text);
    } on FormatException {
      throw const CorruptBackup(
        'This file is damaged or incomplete and could not be read as a '
        'backup.',
      );
    }
    if (raw is! Map<String, Object?>) throw const NotASinewBackup();
    if (raw['app'] != appId) throw const NotASinewBackup();

    final Object? versionRaw = raw['schemaVersion'];
    if (versionRaw is! int || versionRaw < 1) {
      throw const CorruptBackup(
        'This backup has no valid format version and cannot be restored.',
      );
    }
    if (versionRaw > currentVersion) {
      throw BackupFromNewerVersion(
        found: versionRaw,
        supported: currentVersion,
      );
    }
    Map<String, Object?> doc = raw;
    for (int v = versionRaw; v < currentVersion; v++) {
      final BackupMigration? step = migrations[v];
      if (step == null) {
        throw CorruptBackup(
          'This backup (format $versionRaw) is too old to be restored by '
          'this version of Sinew.',
        );
      }
      doc = step(doc);
    }

    final DateTime exportedAt = _date(doc['exportedAt'], 'exportedAt');
    final List<Exercise> custom = _list(
      doc,
      'customExercises',
      Exercise.fromJson,
    );
    final List<ExerciseTombstone> tombstones = _list(
      doc,
      'exerciseTombstones',
      ExerciseTombstone.fromJson,
      required: false,
    );
    final List<Routine> routines = _list(doc, 'routines', Routine.fromJson);
    final List<WorkoutSession> sessions = _list(
      doc,
      'sessions',
      WorkoutSession.fromJson,
    );
    final List<MeasurementField> fields = _list(
      doc,
      'measurementFields',
      MeasurementField.fromJson,
    );
    final List<MeasurementEntry> entries = _list(
      doc,
      'measurementEntries',
      MeasurementEntry.fromJson,
    );
    final List<TimerPreset> presets = _list(
      doc,
      'timerPresets',
      TimerPreset.fromJson,
    );
    final Profile? profile = _one(doc, 'profile', Profile.fromJson);
    final PlateInventory? plates = _one(
      doc,
      'plateInventory',
      PlateInventory.fromJson,
    );
    final Map<String, Object> settings = _settings(doc['settings']);

    _unique('customExercises', custom.map((Exercise e) => e.id));
    _unique('routines', routines.map((Routine r) => r.id));
    _unique(
      'routine items',
      routines.expand((Routine r) => r.items.map((RoutineItem i) => i.id)),
    );
    _unique('sessions', sessions.map((WorkoutSession s) => s.id));
    _unique(
      'session exercises',
      sessions.expand(
        (WorkoutSession s) => s.exercises.map((SessionExercise e) => e.id),
      ),
    );
    _unique(
      'sets',
      sessions.expand(
        (WorkoutSession s) => s.exercises.expand(
          (SessionExercise e) => e.sets.map((SetEntry x) => x.id),
        ),
      ),
    );
    _unique('measurementFields', fields.map((MeasurementField f) => f.id));
    _unique('measurementEntries', entries.map((MeasurementEntry e) => e.id));
    _unique('timerPresets', presets.map((TimerPreset p) => p.id));
    if (sessions.where((WorkoutSession s) => s.endedAt == null).length > 1) {
      throw const CorruptBackup(
        'This backup holds more than one unfinished workout, which Sinew '
        'cannot restore.',
      );
    }

    final Iterable<DateTime> starts = sessions.map(
      (WorkoutSession s) => s.startedAt,
    );
    DateTime? first;
    DateTime? last;
    for (final DateTime d in starts) {
      if (first == null || d.isBefore(first)) first = d;
      if (last == null || d.isAfter(last)) last = d;
    }

    final BackupDocument document = BackupDocument(
      schemaVersion: currentVersion,
      exportedAt: exportedAt,
      libraryVersion: doc['libraryVersion'] as String?,
      snapshot: BackupSnapshot(
        profile: profile,
        customExercises: custom,
        tombstones: tombstones,
        routines: routines,
        sessions: sessions,
        measurementFields: fields,
        measurementEntries: entries,
        timerPresets: presets,
        plateInventory: plates,
      ),
      settings: settings,
    );
    return BackupPreview(
      document: document,
      schemaVersion: versionRaw,
      exportedAt: exportedAt,
      libraryVersion: document.libraryVersion,
      customExercises: custom.length,
      routines: routines.length,
      sessions: sessions.length,
      measurementFields: fields.length,
      measurementEntries: entries.length,
      timerPresets: presets.length,
      hasProfile: profile != null,
      hasPlateInventory: plates != null,
      settings: settings.length,
      firstSessionAt: first,
      lastSessionAt: last,
    );
  }

  static DateTime _date(Object? v, String key) {
    if (v is String) {
      final DateTime? d = DateTime.tryParse(v);
      if (d != null) return d;
    }
    throw CorruptBackup('The "$key" date in this backup is not readable.');
  }

  static List<T> _list<T>(
    Map<String, Object?> doc,
    String key,
    T Function(Map<String, dynamic>) from, {
    bool required = true,
  }) {
    final Object? v = doc[key];
    if (v == null && !required) return <T>[];
    if (v is! List<Object?>) {
      throw CorruptBackup(
        'This backup is missing its "$key" section and cannot be restored.',
      );
    }
    final List<T> out = <T>[];
    for (int i = 0; i < v.length; i++) {
      try {
        out.add(
          from(Map<String, dynamic>.from(v[i]! as Map<dynamic, dynamic>)),
        );
      } on Object {
        throw CorruptBackup(
          'Item ${i + 1} of "$key" in this backup is damaged and cannot be '
          'read.',
        );
      }
    }
    return out;
  }

  static T? _one<T>(
    Map<String, Object?> doc,
    String key,
    T Function(Map<String, dynamic>) from,
  ) {
    final Object? v = doc[key];
    if (v == null) return null;
    try {
      return from(Map<String, dynamic>.from(v as Map<dynamic, dynamic>));
    } on Object {
      throw CorruptBackup('The "$key" in this backup is damaged.');
    }
  }

  static Map<String, Object> _settings(Object? v) {
    if (v == null) return <String, Object>{};
    if (v is! Map<String, Object?>) {
      throw const CorruptBackup('The settings in this backup are damaged.');
    }
    final Map<String, Object> out = <String, Object>{};
    for (final MapEntry<String, Object?> e in v.entries) {
      final Object? x = e.value;
      if (x is bool || x is int || x is double || x is String) {
        out[e.key] = x!;
      } else if (x is List<Object?> && x.every((Object? i) => i is String)) {
        out[e.key] = x.cast<String>();
      } else {
        throw CorruptBackup(
          'The setting "${e.key}" in this backup is damaged.',
        );
      }
    }
    return out;
  }

  static void _unique(String what, Iterable<String> ids) {
    final Set<String> seen = <String>{};
    for (final String id in ids) {
      if (!seen.add(id)) {
        throw CorruptBackup(
          'This backup lists the same id twice in "$what" and cannot be '
          'restored.',
        );
      }
    }
  }
}
