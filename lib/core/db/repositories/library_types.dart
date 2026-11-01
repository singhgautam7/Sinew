import '../../models/enums.dart';

// PURE DART.

/// The light row a virtualised exercise list needs: no steps, tips or notes.
class ExerciseSummary {
  const ExerciseSummary({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.trackingType,
    this.primaryMuscles = const <String>[],
    this.equipment = const <String>[],
    this.difficulty,
    this.unilateral = false,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final TrackingType trackingType;
  final List<String> primaryMuscles;
  final List<String> equipment;
  final Difficulty? difficulty;
  final bool unilateral;

  /// True for the user's own exercises merged in by `ExerciseSearchService`.
  final bool isCustom;

  @override
  bool operator ==(Object other) =>
      other is ExerciseSummary &&
      other.id == id &&
      other.name == name &&
      other.category == category &&
      other.subcategory == subcategory &&
      other.trackingType == trackingType &&
      _listEq(other.primaryMuscles, primaryMuscles) &&
      _listEq(other.equipment, equipment) &&
      other.difficulty == difficulty &&
      other.unilateral == unilateral &&
      other.isCustom == isCustom;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    subcategory,
    trackingType,
    Object.hashAll(primaryMuscles),
    Object.hashAll(equipment),
    difficulty,
    unilateral,
    isCustom,
  );

  @override
  String toString() => 'ExerciseSummary($id, $name)';
}

/// Every filter is an optional set: empty means "no restriction". Filters of
/// different kinds combine with AND, values within a kind with OR.
class LibraryFilters {
  const LibraryFilters({
    this.categories = const <String>{},
    this.muscles = const <String>{},
    this.equipment = const <String>{},
    this.difficulties = const <Difficulty>{},
    this.trackingTypes = const <TrackingType>{},
    this.includeSecondaryMuscles = false,
  });

  final Set<String> categories;

  /// Matches an exercise's primary muscles; with [includeSecondaryMuscles]
  /// also its secondary ones.
  final Set<String> muscles;
  final Set<String> equipment;
  final Set<Difficulty> difficulties;
  final Set<TrackingType> trackingTypes;
  final bool includeSecondaryMuscles;

  bool get isEmpty =>
      categories.isEmpty &&
      muscles.isEmpty &&
      equipment.isEmpty &&
      difficulties.isEmpty &&
      trackingTypes.isEmpty;

  LibraryFilters copyWith({
    Set<String>? categories,
    Set<String>? muscles,
    Set<String>? equipment,
    Set<Difficulty>? difficulties,
    Set<TrackingType>? trackingTypes,
    bool? includeSecondaryMuscles,
  }) => LibraryFilters(
    categories: categories ?? this.categories,
    muscles: muscles ?? this.muscles,
    equipment: equipment ?? this.equipment,
    difficulties: difficulties ?? this.difficulties,
    trackingTypes: trackingTypes ?? this.trackingTypes,
    includeSecondaryMuscles:
        includeSecondaryMuscles ?? this.includeSecondaryMuscles,
  );

  @override
  bool operator ==(Object other) =>
      other is LibraryFilters &&
      _setEq(other.categories, categories) &&
      _setEq(other.muscles, muscles) &&
      _setEq(other.equipment, equipment) &&
      _setEq(other.difficulties, difficulties) &&
      _setEq(other.trackingTypes, trackingTypes) &&
      other.includeSecondaryMuscles == includeSecondaryMuscles;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(categories),
    Object.hashAllUnordered(muscles),
    Object.hashAllUnordered(equipment),
    Object.hashAllUnordered(difficulties),
    Object.hashAllUnordered(trackingTypes),
    includeSecondaryMuscles,
  );
}

/// A guided sequence (yoga or mobility flow) for the timer's flow mode.
class Flow {
  const Flow({
    required this.id,
    required this.name,
    required this.category,
    this.difficulty,
    this.description = '',
    required this.totalDurationSec,
    required this.rounds,
    this.tags = const <String>[],
    this.steps = const <FlowStep>[],
  });

  final String id;
  final String name;
  final String category;
  final Difficulty? difficulty;
  final String description;
  final int totalDurationSec;
  final int rounds;
  final List<String> tags;

  /// In order. Empty in a list; filled by `LibraryRepository.flowById`.
  final List<FlowStep> steps;
}

class FlowStep {
  const FlowStep({
    required this.position,
    required this.exerciseId,
    this.label,
    required this.holdSec,
    required this.transitionSec,
    this.cue,
  });

  final int position;

  /// The pose's library exercise id.
  final String exerciseId;

  /// The pose name captured when the library was built, if known.
  final String? label;
  final int holdSec;
  final int transitionSec;
  final String? cue;
}

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _setEq<T>(Set<T> a, Set<T> b) => a.length == b.length && a.containsAll(b);
