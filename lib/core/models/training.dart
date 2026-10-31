import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'training.freezed.dart';
part 'training.g.dart';

/// A saved plan of exercises.
@freezed
abstract class Routine with _$Routine {
  const factory Routine({
    required String id,
    required String name,
    String? notes,
    @Default(0) int position,
    @Default(false) bool archived,
    @Default(<RoutineItem>[]) List<RoutineItem> items,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Routine;

  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);
}

@freezed
abstract class RoutineItem with _$RoutineItem {
  const factory RoutineItem({
    required String id,
    required String exerciseId,
    required int position,

    /// Items sharing a group number form a superset; null is a straight set.
    int? supersetGroup,
    @Default(3) int targetSets,
    int? targetReps,
    int? targetDurationSec,
    double? targetDistanceM,
    double? targetWeightKg,
    int? restSec,
    String? notes,
  }) = _RoutineItem;

  factory RoutineItem.fromJson(Map<String, dynamic> json) =>
      _$RoutineItemFromJson(json);
}

/// One workout. [endedAt] null means it is the active session; there is at
/// most one (enforced by a partial unique index).
@freezed
abstract class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required String id,
    String? name,
    required DateTime startedAt,
    DateTime? endedAt,
    String? routineId,
    String? notes,

    /// 1 to 10.
    int? perceivedEffort,
    @Default(SessionSource.manual) SessionSource source,

    /// Cached at finish and recomputed on edit. Estimates, not truth.
    int? durationSec,
    double? volumeKg,
    double? caloriesKcal,
    @Default(<SessionExercise>[]) List<SessionExercise> exercises,
    required DateTime updatedAt,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}

@freezed
abstract class SessionExercise with _$SessionExercise {
  const factory SessionExercise({
    required String id,
    required String exerciseId,
    required int position,
    int? supersetGroup,
    String? notes,
    @Default(<SetEntry>[]) List<SetEntry> sets,
  }) = _SessionExercise;

  factory SessionExercise.fromJson(Map<String, dynamic> json) =>
      _$SessionExerciseFromJson(json);
}

/// One set. Which fields are filled depends on the exercise's
/// [TrackingType]. All values metric: kilograms, seconds, metres.
@freezed
abstract class SetEntry with _$SetEntry {
  const factory SetEntry({
    required String id,
    required int position,
    @Default(SetType.normal) SetType type,
    double? weightKg,
    int? reps,
    int? durationSec,
    double? distanceM,
    int? rounds,
    int? holdSec,
    @Default(false) bool completed,
    @Default(false) bool isWarmup,
    @Default(false) bool isPR,
    DateTime? completedAt,
  }) = _SetEntry;

  factory SetEntry.fromJson(Map<String, dynamic> json) =>
      _$SetEntryFromJson(json);
}
