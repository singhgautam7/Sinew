import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/db/ids.dart';
import '../../core/db/repositories/backup_repository.dart';
import '../../core/db/repositories/backup_snapshot.dart';
import 'backup_codec.dart';
import 'backup_types.dart';

export '../../core/db/repositories/backup_repository.dart'
    show BackupWriteResult, RestoreMode;
export 'backup_types.dart';

/// What a restore did, per section key (`sessions`, `routines`, ...).
class RestoreSummary {
  const RestoreSummary({
    required this.mode,
    required this.written,
    required this.kept,
    required this.settingsApplied,
  });

  final RestoreMode mode;

  /// Records inserted or overwritten.
  final Map<String, int> written;

  /// Merge only: records left alone because the local one was newer or equal.
  final Map<String, int> kept;

  /// Number of settings written back to the device.
  final int settingsApplied;
}

/// Export and restore of the whole user dataset as one JSON file.
///
/// Services only, no UI: a screen asks for a [BackupFile] and saves or shares
/// it, or reads a file's text into [parse] and then calls [restore].
class BackupService {
  BackupService({
    required this._repository,
    required this._prefs,
    this._clock = systemClock,
    this._codec = const BackupCodec(),
    this.onBackedUp,
    this.onSettingsRestored,
  });

  final BackupRepository _repository;
  final SharedPreferences _prefs;
  final Clock _clock;
  final BackupCodec _codec;

  /// Called after `backup.lastAt` changes (providers refresh from it).
  final void Function()? onBackedUp;

  /// Called after restored settings were written (providers re-read them).
  final void Function()? onSettingsRestored;

  /// SharedPreferences key holding the time of the last export (ISO-8601).
  static const String lastBackupKey = 'backup.lastAt';

  /// The library version key written by `LibraryInstaller`.
  static const String libraryVersionKey = 'library.version';

  /// Preference keys that belong in a backup.
  static const List<String> settingsPrefixes = <String>[
    'theme.',
    'text.',
    'app.',
    'units.',
  ];

  // ── Export ────────────────────────────────────────────────────────────────

  /// `sinew-backup-YYYYMMDD-HHmm.json`, in local time.
  static String fileNameFor(DateTime at) {
    final DateTime l = at.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'sinew-backup-${l.year.toString().padLeft(4, '0')}${two(l.month)}'
        '${two(l.day)}-${two(l.hour)}${two(l.minute)}.json';
  }

  /// Reads everything in one transaction and returns the backup file. Records
  /// the time in `backup.lastAt` (pass `markBackedUp: false` to record it
  /// only once the file is really saved, with [markBackedUp]).
  Future<BackupFile> export({bool markBackedUp = true}) async {
    final BackupSnapshot snapshot = await _repository.readAll();
    final DateTime now = _clock();
    final String json = _codec.encode(
      BackupDocument(
        schemaVersion: _codec.currentVersion,
        exportedAt: now,
        libraryVersion: _prefs.getString(libraryVersionKey),
        snapshot: snapshot,
        settings: _readSettings(),
      ),
    );
    final BackupFile file = BackupFile(
      fileName: fileNameFor(now),
      contents: json,
      exportedAt: now,
    );
    if (markBackedUp) await this.markBackedUp(now);
    return file;
  }

  /// Writes [file] into [directory] (for sharing from a temp folder).
  Future<File> writeTo(Directory directory, BackupFile file) async {
    await directory.create(recursive: true);
    final File out = File(p.join(directory.path, file.fileName));
    await out.writeAsString(file.contents, flush: true);
    return out;
  }

  Future<void> markBackedUp([DateTime? at]) async {
    await _prefs.setString(
      lastBackupKey,
      (at ?? _clock()).toUtc().toIso8601String(),
    );
    onBackedUp?.call();
  }

  /// When the last export was made, or null if never.
  DateTime? get lastBackupAt => readLastBackupAt(_prefs);

  static DateTime? readLastBackupAt(SharedPreferences prefs) {
    final String? v = prefs.getString(lastBackupKey);
    return v == null ? null : DateTime.tryParse(v);
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  /// Validates [json] completely (JSON, app, format version, every record)
  /// before anything is written. Never throws.
  BackupParseResult parse(String json) => _codec.decode(json);

  /// Writes the backup to the database in one transaction, then applies its
  /// settings. Any failure leaves the database as it was and throws
  /// [RestoreFailed].
  ///
  /// Settings follow the same rule as the data: [RestoreMode.replace] writes
  /// every setting in the backup; [RestoreMode.merge] only fills settings
  /// this device has not set (preferences carry no timestamp to compare).
  Future<RestoreSummary> restore(
    BackupPreview preview, {
    required RestoreMode mode,
  }) async {
    final BackupWriteResult result;
    try {
      result = await _repository.writeAll(
        preview.document.snapshot,
        mode: mode,
      );
    } on Object catch (e) {
      throw RestoreFailed(e);
    }
    final int applied = await _applySettings(preview.document.settings, mode);
    if (applied > 0) onSettingsRestored?.call();
    return RestoreSummary(
      mode: mode,
      written: result.written,
      kept: result.kept,
      settingsApplied: applied,
    );
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Map<String, Object> _readSettings() {
    final List<String> keys =
        _prefs
            .getKeys()
            .where(
              (String k) =>
                  settingsPrefixes.any((String pre) => k.startsWith(pre)),
            )
            .toList()
          ..sort();
    final Map<String, Object> out = <String, Object>{};
    for (final String k in keys) {
      final Object? v = _prefs.get(k);
      if (v is bool || v is int || v is double || v is String) {
        out[k] = v!;
      } else if (v is List<String>) {
        out[k] = v;
      }
    }
    return out;
  }

  Future<int> _applySettings(
    Map<String, Object> settings,
    RestoreMode mode,
  ) async {
    int applied = 0;
    for (final MapEntry<String, Object> e in settings.entries) {
      if (!settingsPrefixes.any((String pre) => e.key.startsWith(pre))) {
        continue;
      }
      if (mode == RestoreMode.merge && _prefs.containsKey(e.key)) continue;
      final Object v = e.value;
      final bool ok = switch (v) {
        bool() => await _prefs.setBool(e.key, v),
        int() => await _prefs.setInt(e.key, v),
        double() => await _prefs.setDouble(e.key, v),
        String() => await _prefs.setString(e.key, v),
        List<String>() => await _prefs.setStringList(e.key, v),
        _ => false,
      };
      if (ok) applied++;
    }
    return applied;
  }
}
