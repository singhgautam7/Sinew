import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'utc_date_time.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

/// One exercise, from the bundled library or made by the user.
///
/// User data references an exercise by [id] only, never by a row number, so a
/// new library version never breaks history. Library ids are kebab-case;
/// custom ids start with [customPrefix].
@freezed
abstract class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    @Default(<String>[]) List<String> aliases,
    String? sanskritName,
    required String category,
    String? subcategory,
    @JsonKey(unknownEnumValue: TrackingType.unknown)
    required TrackingType trackingType,
    @Default(<String>[]) List<String> primaryMuscles,
    @Default(<String>[]) List<String> secondaryMuscles,
    @Default(<String>[]) List<String> equipment,
    Difficulty? difficulty,
    @Default(false) bool unilateral,
    String? mechanic,
    String? force,
    @Default(<String>[]) List<String> steps,
    @Default(<String>[]) List<String> tips,
    @Default(<String>[]) List<String> commonMistakes,
    @Default(<String>[]) List<String> safetyNotes,
    @Default(<String>[]) List<String> contraindications,
    double? metValue,
    int? defaultRestSec,
    int? defaultHoldSec,
    String? variationOf,
    @Default(<String>[]) List<String> tags,
    String? source,
    String? license,
    @Default(false) bool isCustom,

    /// Custom exercises only: hidden from pickers but kept for history.
    @Default(false) bool archived,
    @NullableUtcDateTimeConverter() DateTime? createdAt,
    @NullableUtcDateTimeConverter() DateTime? updatedAt,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  static const String customPrefix = 'custom-';
}

/// What remains of a library exercise after a library update removed it:
/// enough to keep old sessions readable.
@freezed
abstract class ExerciseTombstone with _$ExerciseTombstone {
  const factory ExerciseTombstone({
    required String exerciseId,
    required String name,
    @JsonKey(unknownEnumValue: TrackingType.unknown)
    required TrackingType trackingType,
    required String removedInLibraryVersion,
  }) = _ExerciseTombstone;

  factory ExerciseTombstone.fromJson(Map<String, dynamic> json) =>
      _$ExerciseTombstoneFromJson(json);
}
