import 'package:flutter/material.dart';

import '../../core/models/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/domain/exercise_tile.dart';

/// Vocabulary lists the filter sheet and the custom exercise form offer.
/// Mirrors `specs/data/schema/vocab.json`.
const List<String> kCategories = <String>[
  'strength',
  'calisthenics',
  'yoga',
  'mobility',
  'hiit',
  'boxing',
  'cardio',
  'pilates',
];

/// The muscles a person can pick (no `fullBody`: that is a tag, not a muscle).
const List<String> kMuscles = <String>[
  'chest',
  'shoulders',
  'rearDeltoids',
  'biceps',
  'triceps',
  'forearms',
  'trapezius',
  'lats',
  'rhomboids',
  'lowerBack',
  'core',
  'obliques',
  'hipFlexors',
  'glutes',
  'quadriceps',
  'hamstrings',
  'adductors',
  'abductors',
  'calves',
  'tibialis',
  'neck',
];

/// Common equipment first, then the rest of the vocabulary.
const List<String> kEquipment = <String>[
  'bodyweight',
  'barbell',
  'dumbbell',
  'kettlebell',
  'cable',
  'machine',
  'resistanceBand',
  'bench',
  'pullupBar',
  'yogaMat',
  'foamRoller',
  'jumpRope',
  'smithMachine',
  'ezBar',
  'trapBar',
  'squatRack',
  'inclineBench',
  'declineBench',
  'dipStation',
  'parallelBars',
  'gymnasticRings',
  'miniBand',
  'suspensionTrainer',
  'weightPlate',
  'medicineBall',
  'slamBall',
  'stabilityBall',
  'lacrosseBall',
  'massageStick',
  'yogaBlock',
  'yogaStrap',
  'yogaBolster',
  'yogaBlanket',
  'heavyBag',
  'speedBag',
  'doubleEndBag',
  'focusMitts',
  'boxingGloves',
  'handWraps',
  'treadmill',
  'stationaryBike',
  'airBike',
  'rower',
  'skiErg',
  'elliptical',
  'stairClimber',
  'pool',
  'pilatesReformer',
  'pilatesCadillac',
  'pilatesWundaChair',
  'pilatesMagicCircle',
  'pilatesSpineCorrector',
  'pilatesLadderBarrel',
  'plyoBox',
  'agilityLadder',
  'landmine',
  'weightVest',
  'abWheel',
  'slantBoard',
];

/// The tracking types a person can pick for a custom exercise.
const List<TrackingType> kTrackingTypes = <TrackingType>[
  TrackingType.weightReps,
  TrackingType.reps,
  TrackingType.time,
  TrackingType.distanceTime,
  TrackingType.rounds,
  TrackingType.hold,
  TrackingType.flow,
];

String categoryLabel(String id) => prettyVocab(id);

String muscleLabel(String id) => switch (id) {
  'quadriceps' => 'Quads',
  'trapezius' => 'Traps',
  'rearDeltoids' => 'Rear delts',
  'hipFlexors' => 'Hip flexors',
  _ => prettyVocab(id),
};

String equipmentLabel(String id) => prettyVocab(id);

String difficultyLabel(Difficulty d) => prettyVocab(d.name);

/// "Weight x reps" style labels for the tracking type picker.
String trackingLabel(TrackingType t) => switch (t) {
  TrackingType.weightReps => 'Weight × reps',
  TrackingType.reps || TrackingType.unknown => 'Reps',
  TrackingType.time => 'Time',
  TrackingType.distanceTime => 'Distance',
  TrackingType.rounds => 'Rounds',
  TrackingType.hold => 'Hold',
  TrackingType.flow => 'Flow',
};

IconData categoryIcon(String id) => switch (id) {
  'strength' => Icons.fitness_center_rounded,
  'calisthenics' => Icons.accessibility_new_rounded,
  'yoga' => Icons.self_improvement_rounded,
  'mobility' => Icons.swap_horiz_rounded,
  'hiit' => Icons.bolt_rounded,
  'boxing' => Icons.sports_mma_rounded,
  'cardio' => Icons.directions_run_rounded,
  'pilates' => Icons.spa_rounded,
  _ => Icons.category_rounded,
};

/// A sensible starting MET for a new custom exercise in [category].
double defaultMetFor(String category) => switch (category) {
  'strength' => LibrarySpec.metStrength,
  'calisthenics' => LibrarySpec.metCalisthenics,
  'yoga' => LibrarySpec.metYoga,
  'mobility' => LibrarySpec.metMobility,
  'hiit' => LibrarySpec.metHiit,
  'boxing' => LibrarySpec.metBoxing,
  'cardio' => LibrarySpec.metCardio,
  'pilates' => LibrarySpec.metPilates,
  _ => LibrarySpec.metFallback,
};

/// "1 h 5 min", "12 min", "45 s".
String durationLabel(int seconds) {
  if (seconds < 60) return '$seconds s';
  final int minutes = (seconds + 30) ~/ 60;
  final int h = minutes ~/ 60;
  final int m = minutes % 60;
  if (h == 0) return '$m min';
  return m == 0 ? '$h h' : '$h h $m min';
}
