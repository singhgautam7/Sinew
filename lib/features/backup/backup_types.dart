import '../../core/db/repositories/backup_snapshot.dart';

// PURE DART.

/// Why a backup could not be read or restored. The [message] is written for
/// the person using the app and is safe to show as is.
sealed class BackupFailure implements Exception {
  const BackupFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The file is damaged: not valid JSON, truncated, or a section is missing or
/// unreadable.
final class CorruptBackup extends BackupFailure {
  const CorruptBackup(super.message);
}

/// The file is readable but was not made by Sinew.
final class NotASinewBackup extends BackupFailure {
  const NotASinewBackup()
    : super(
        'This file is not a Sinew backup. Choose a file exported from Sinew.',
      );
}

/// The backup was made by a newer Sinew than this one.
final class BackupFromNewerVersion extends BackupFailure {
  BackupFromNewerVersion({required this.found, required this.supported})
    : super(
        'This backup was made by a newer version of Sinew (backup format '
        '$found, this version reads up to $supported). Update Sinew and try '
        'again.',
      );

  final int found;
  final int supported;
}

/// The restore itself failed. Nothing was changed.
final class RestoreFailed extends BackupFailure {
  RestoreFailed(this.cause)
    : super('The restore failed and nothing was changed. ($cause)');

  final Object cause;
}

/// Everything in a backup file, read and validated.
class BackupDocument {
  const BackupDocument({
    required this.schemaVersion,
    required this.exportedAt,
    this.libraryVersion,
    required this.snapshot,
    this.settings = const <String, Object>{},
  });

  final int schemaVersion;
  final DateTime exportedAt;

  /// The exercise library the backup was made with, for information.
  final String? libraryVersion;
  final BackupSnapshot snapshot;

  /// SharedPreferences values under the keys Sinew backs up (`theme.`,
  /// `text.`, `app.`, `units.`). Values are bool, int, double, String or
  /// `List<String>`.
  final Map<String, Object> settings;
}

/// What a valid backup file holds, to show before the person chooses how to
/// restore. Carries the parsed [document] so restoring does not parse twice.
class BackupPreview {
  const BackupPreview({
    required this.document,
    required this.schemaVersion,
    required this.exportedAt,
    required this.libraryVersion,
    required this.customExercises,
    required this.routines,
    required this.sessions,
    required this.measurementFields,
    required this.measurementEntries,
    required this.timerPresets,
    required this.hasProfile,
    required this.hasPlateInventory,
    required this.settings,
    required this.firstSessionAt,
    required this.lastSessionAt,
  });

  /// The parsed contents (opaque to the UI; hand the preview to `restore`).
  final BackupDocument document;

  /// The format of the file as written (before any migration).
  final int schemaVersion;
  final DateTime exportedAt;
  final String? libraryVersion;
  final int customExercises;
  final int routines;
  final int sessions;
  final int measurementFields;
  final int measurementEntries;
  final int timerPresets;
  final bool hasProfile;
  final bool hasPlateInventory;
  final int settings;

  /// Earliest and latest session start; null when there are no sessions.
  final DateTime? firstSessionAt;
  final DateTime? lastSessionAt;
}

/// The result of reading a backup file: either a [ParsedBackup] or a
/// [RejectedBackup] with a typed [BackupFailure]. Never throws.
sealed class BackupParseResult {
  const BackupParseResult();
}

final class ParsedBackup extends BackupParseResult {
  const ParsedBackup(this.preview);

  final BackupPreview preview;
}

final class RejectedBackup extends BackupParseResult {
  const RejectedBackup(this.error);

  final BackupFailure error;
}

/// A finished export: the file name and its text. Saving or sharing it is the
/// screen's job.
class BackupFile {
  const BackupFile({
    required this.fileName,
    required this.contents,
    required this.exportedAt,
  });

  final String fileName;
  final String contents;
  final DateTime exportedAt;
}
