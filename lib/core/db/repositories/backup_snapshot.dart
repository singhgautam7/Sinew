import '../../models/exercise.dart';
import '../../models/measurement.dart';
import '../../models/plate_inventory.dart';
import '../../models/profile.dart';
import '../../models/timer_preset.dart';
import '../../models/training.dart';

// PURE DART.

/// Everything the user made, as models: what a backup holds and what
/// `BackupRepository` reads and writes. Settings (SharedPreferences) and the
/// library version belong to the backup document, not to the database.
class BackupSnapshot {
  const BackupSnapshot({
    this.profile,
    this.customExercises = const <Exercise>[],
    this.tombstones = const <ExerciseTombstone>[],
    this.routines = const <Routine>[],
    this.sessions = const <WorkoutSession>[],
    this.measurementFields = const <MeasurementField>[],
    this.measurementEntries = const <MeasurementEntry>[],
    this.timerPresets = const <TimerPreset>[],
    this.plateInventory,
  });

  /// Null when the user never saved one (reads as defaults).
  final Profile? profile;
  final List<Exercise> customExercises;

  /// Library exercises removed by a library update that history still uses.
  final List<ExerciseTombstone> tombstones;
  final List<Routine> routines;
  final List<WorkoutSession> sessions;
  final List<MeasurementField> measurementFields;
  final List<MeasurementEntry> measurementEntries;
  final List<TimerPreset> timerPresets;

  /// Null when the user never saved one (reads as the metric default).
  final PlateInventory? plateInventory;
}
