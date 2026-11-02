// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  aliases:
      (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  sanskritName: json['sanskritName'] as String?,
  category: json['category'] as String,
  subcategory: json['subcategory'] as String?,
  trackingType: $enumDecode(
    _$TrackingTypeEnumMap,
    json['trackingType'],
    unknownValue: TrackingType.unknown,
  ),
  primaryMuscles:
      (json['primaryMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  secondaryMuscles:
      (json['secondaryMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  equipment:
      (json['equipment'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  difficulty: $enumDecodeNullable(_$DifficultyEnumMap, json['difficulty']),
  unilateral: json['unilateral'] as bool? ?? false,
  mechanic: json['mechanic'] as String?,
  force: json['force'] as String?,
  steps:
      (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tips:
      (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  commonMistakes:
      (json['commonMistakes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  safetyNotes:
      (json['safetyNotes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  contraindications:
      (json['contraindications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  metValue: (json['metValue'] as num?)?.toDouble(),
  defaultRestSec: (json['defaultRestSec'] as num?)?.toInt(),
  defaultHoldSec: (json['defaultHoldSec'] as num?)?.toInt(),
  variationOf: json['variationOf'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  source: json['source'] as String?,
  license: json['license'] as String?,
  isCustom: json['isCustom'] as bool? ?? false,
  archived: json['archived'] as bool? ?? false,
  createdAt: const NullableUtcDateTimeConverter().fromJson(
    json['createdAt'] as String?,
  ),
  updatedAt: const NullableUtcDateTimeConverter().fromJson(
    json['updatedAt'] as String?,
  ),
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'aliases': instance.aliases,
  'sanskritName': instance.sanskritName,
  'category': instance.category,
  'subcategory': instance.subcategory,
  'trackingType': _$TrackingTypeEnumMap[instance.trackingType]!,
  'primaryMuscles': instance.primaryMuscles,
  'secondaryMuscles': instance.secondaryMuscles,
  'equipment': instance.equipment,
  'difficulty': _$DifficultyEnumMap[instance.difficulty],
  'unilateral': instance.unilateral,
  'mechanic': instance.mechanic,
  'force': instance.force,
  'steps': instance.steps,
  'tips': instance.tips,
  'commonMistakes': instance.commonMistakes,
  'safetyNotes': instance.safetyNotes,
  'contraindications': instance.contraindications,
  'metValue': instance.metValue,
  'defaultRestSec': instance.defaultRestSec,
  'defaultHoldSec': instance.defaultHoldSec,
  'variationOf': instance.variationOf,
  'tags': instance.tags,
  'source': instance.source,
  'license': instance.license,
  'isCustom': instance.isCustom,
  'archived': instance.archived,
  'createdAt': const NullableUtcDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const NullableUtcDateTimeConverter().toJson(instance.updatedAt),
};

const _$TrackingTypeEnumMap = {
  TrackingType.weightReps: 'weightReps',
  TrackingType.reps: 'reps',
  TrackingType.time: 'time',
  TrackingType.distanceTime: 'distanceTime',
  TrackingType.rounds: 'rounds',
  TrackingType.hold: 'hold',
  TrackingType.flow: 'flow',
  TrackingType.unknown: 'unknown',
};

const _$DifficultyEnumMap = {
  Difficulty.beginner: 'beginner',
  Difficulty.intermediate: 'intermediate',
  Difficulty.advanced: 'advanced',
};

_ExerciseTombstone _$ExerciseTombstoneFromJson(Map<String, dynamic> json) =>
    _ExerciseTombstone(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      trackingType: $enumDecode(
        _$TrackingTypeEnumMap,
        json['trackingType'],
        unknownValue: TrackingType.unknown,
      ),
      removedInLibraryVersion: json['removedInLibraryVersion'] as String,
    );

Map<String, dynamic> _$ExerciseTombstoneToJson(_ExerciseTombstone instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'name': instance.name,
      'trackingType': _$TrackingTypeEnumMap[instance.trackingType]!,
      'removedInLibraryVersion': instance.removedInLibraryVersion,
    };
