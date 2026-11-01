import 'dart:io';

import '../../models/enums.dart';
import '../../models/exercise.dart';
import '../library/library_db.dart';
import 'exercise_repository.dart';

// PURE DART.

/// Keeps history readable across a library update.
///
/// A new library version may drop an exercise the user already logged. Before
/// the installer replaces the old file, [snapshot] copies it aside; once the
/// new one is in place, [complete] finds the exercises the user's data still
/// points at that only the old library had, and stores a tombstone (name and
/// tracking type) for each, so `ExerciseResolver` never returns a blank row.
///
/// Wire it as:
/// ```dart
/// final File file = await installer.ensureInstalled(
///   beforeReplace: upgrade.snapshot,
/// );
/// await upgrade.complete(file);
/// ```
/// [complete] also runs on a normal start: it is a no-op without a snapshot,
/// and it finishes the job if the app was killed between the install and the
/// tombstones.
class LibraryUpgrade {
  LibraryUpgrade({required this.custom});

  final CustomExerciseRepository custom;

  static const String snapshotSuffix = '.previous';

  static File snapshotFor(File library) =>
      File('${library.path}$snapshotSuffix');

  /// `LibraryInstaller.ensureInstalled(beforeReplace:)` callback. An existing
  /// snapshot (a previous upgrade that never completed) is kept: it is the
  /// older library, so comparing against it finds a superset of removals.
  Future<void> snapshot(File oldLibrary, String newVersion) async {
    final File copy = snapshotFor(oldLibrary);
    if (copy.existsSync()) return;
    final File tmp = File('${copy.path}.part');
    await oldLibrary.copy(tmp.path);
    await tmp.rename(copy.path);
  }

  /// Writes the tombstones and removes the snapshot. Returns how many were
  /// written. Never throws: a failure leaves the snapshot for the next start.
  Future<int> complete(File newLibrary) async {
    final File copy = snapshotFor(newLibrary);
    if (!copy.existsSync()) return 0;
    LibraryDatabase? oldDb;
    LibraryDatabase? newDb;
    try {
      oldDb = LibraryDatabase.openReadOnly(copy);
      newDb = LibraryDatabase.openReadOnly(newLibrary);
      final LibraryRepository oldLib = LibraryRepository(oldDb);
      final LibraryRepository newLib = LibraryRepository(newDb);

      final Set<String> referenced = await custom
          .referencedLibraryExerciseIds();
      final Map<String, Exercise> before = await oldLib.byIds(referenced);
      final Map<String, Exercise> after = await newLib.byIds(before.keys);
      final String version = (await newLib.libraryVersion()) ?? 'unknown';

      final List<ExerciseTombstone> stones = <ExerciseTombstone>[
        for (final Exercise e in before.values)
          if (!after.containsKey(e.id))
            ExerciseTombstone(
              exerciseId: e.id,
              name: e.name,
              trackingType: e.trackingType == TrackingType.unknown
                  ? TrackingType.reps
                  : e.trackingType,
              removedInLibraryVersion: version,
            ),
      ];
      if (stones.isNotEmpty) await custom.addTombstones(stones);
      await oldDb.close();
      await newDb.close();
      oldDb = null;
      newDb = null;
      copy.deleteSync();
      return stones.length;
    } on Object {
      return 0;
    } finally {
      await oldDb?.close();
      await newDb?.close();
    }
  }
}
