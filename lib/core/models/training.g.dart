// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Routine _$RoutineFromJson(Map<String, dynamic> json) => _Routine(
  id: json['id'] as String,
  name: json['name'] as String,
  notes: json['notes'] as String?,
  position: (json['position'] as num?)?.toInt() ?? 0,
  archived: json['archived'] as bool? ?? false,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => RoutineItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoutineItem>[],
  createdAt: const UtcDateTimeConverter().fromJson(json['createdAt'] as String),
  updatedAt: const UtcDateTimeConverter().fromJson(json['updatedAt'] as String),
);

Map<String, dynamic> _$RoutineToJson(_Routine instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'notes': instance.notes,
  'position': instance.position,
  'archived': instance.archived,
  'items': instance.items,
  'createdAt': const UtcDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const UtcDateTimeConverter().toJson(instance.updatedAt),
};

_RoutineItem _$RoutineItemFromJson(Map<String, dynamic> json) => _RoutineItem(
  id: json['id'] as String,
  exerciseId: json['exerciseId'] as String,
  position: (json['position'] as num).toInt(),
  supersetGroup: (json['supersetGroup'] as num?)?.toInt(),
  targetSets: (json['targetSets'] as num?)?.toInt() ?? 3,
  targetReps: (json['targetReps'] as num?)?.toInt(),
  targetDurationSec: (json['targetDurationSec'] as num?)?.toInt(),
  targetDistanceM: (json['targetDistanceM'] as num?)?.toDouble(),
  targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
  restSec: (json['restSec'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$RoutineItemToJson(_RoutineItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'position': instance.position,
      'supersetGroup': instance.supersetGroup,
      'targetSets': instance.targetSets,
      'targetReps': instance.targetReps,
      'targetDurationSec': instance.targetDurationSec,
      'targetDistanceM': instance.targetDistanceM,
      'targetWeightKg': instance.targetWeightKg,
      'restSec': instance.restSec,
      'notes': instance.notes,
    };

_WorkoutSession _$WorkoutSessionFromJson(
  Map<String, dynamic> json,
) => _WorkoutSession(
  id: json['id'] as String,
  name: json['name'] as String?,
  startedAt: const UtcDateTimeConverter().fromJson(json['startedAt'] as String),
  endedAt: const NullableUtcDateTimeConverter().fromJson(
    json['endedAt'] as String?,
  ),
  routineId: json['routineId'] as String?,
  notes: json['notes'] as String?,
  perceivedEffort: (json['perceivedEffort'] as num?)?.toInt(),
  source:
      $enumDecodeNullable(_$SessionSourceEnumMap, json['source']) ??
      SessionSource.manual,
  durationSec: (json['durationSec'] as num?)?.toInt(),
  volumeKg: (json['volumeKg'] as num?)?.toDouble(),
  caloriesKcal: (json['caloriesKcal'] as num?)?.toDouble(),
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => SessionExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SessionExercise>[],
  updatedAt: const UtcDateTimeConverter().fromJson(json['updatedAt'] as String),
);

Map<String, dynamic> _$WorkoutSessionToJson(_WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startedAt': const UtcDateTimeConverter().toJson(instance.startedAt),
      'endedAt': const NullableUtcDateTimeConverter().toJson(instance.endedAt),
      'routineId': instance.routineId,
      'notes': instance.notes,
      'perceivedEffort': instance.perceivedEffort,
      'source': _$SessionSourceEnumMap[instance.source]!,
      'durationSec': instance.durationSec,
      'volumeKg': instance.volumeKg,
      'caloriesKcal': instance.caloriesKcal,
      'exercises': instance.exercises,
      'updatedAt': const UtcDateTimeConverter().toJson(instance.updatedAt),
    };

const _$SessionSourceEnumMap = {
  SessionSource.manual: 'manual',
  SessionSource.routine: 'routine',
  SessionSource.timer: 'timer',
  SessionSource.import: 'import',
};

_SessionExercise _$SessionExerciseFromJson(Map<String, dynamic> json) =>
    _SessionExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      position: (json['position'] as num).toInt(),
      supersetGroup: (json['supersetGroup'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => SetEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SetEntry>[],
    );

Map<String, dynamic> _$SessionExerciseToJson(_SessionExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'position': instance.position,
      'supersetGroup': instance.supersetGroup,
      'notes': instance.notes,
      'sets': instance.sets,
    };

_SetEntry _$SetEntryFromJson(Map<String, dynamic> json) => _SetEntry(
  id: json['id'] as String,
  position: (json['position'] as num).toInt(),
  type: $enumDecodeNullable(_$SetTypeEnumMap, json['type']) ?? SetType.normal,
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  reps: (json['reps'] as num?)?.toInt(),
  durationSec: (json['durationSec'] as num?)?.toInt(),
  distanceM: (json['distanceM'] as num?)?.toDouble(),
  rounds: (json['rounds'] as num?)?.toInt(),
  holdSec: (json['holdSec'] as num?)?.toInt(),
  completed: json['completed'] as bool? ?? false,
  isWarmup: json['isWarmup'] as bool? ?? false,
  isPR: json['isPR'] as bool? ?? false,
  completedAt: const NullableUtcDateTimeConverter().fromJson(
    json['completedAt'] as String?,
  ),
);

Map<String, dynamic> _$SetEntryToJson(_SetEntry instance) => <String, dynamic>{
  'id': instance.id,
  'position': instance.position,
  'type': _$SetTypeEnumMap[instance.type]!,
  'weightKg': instance.weightKg,
  'reps': instance.reps,
  'durationSec': instance.durationSec,
  'distanceM': instance.distanceM,
  'rounds': instance.rounds,
  'holdSec': instance.holdSec,
  'completed': instance.completed,
  'isWarmup': instance.isWarmup,
  'isPR': instance.isPR,
  'completedAt': const NullableUtcDateTimeConverter().toJson(
    instance.completedAt,
  ),
};

const _$SetTypeEnumMap = {
  SetType.normal: 'normal',
  SetType.drop: 'drop',
  SetType.failure: 'failure',
  SetType.amrap: 'amrap',
};
