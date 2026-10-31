// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimerPreset _$TimerPresetFromJson(Map<String, dynamic> json) => _TimerPreset(
  schemaVersion:
      (json['schemaVersion'] as num?)?.toInt() ??
      TimerPreset.currentSchemaVersion,
  id: json['id'] as String,
  name: json['name'] as String,
  mode: $enumDecode(_$TimerModeEnumMap, json['mode']),
  steps:
      (json['steps'] as List<dynamic>?)
          ?.map((e) => TimerStepSpec.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TimerStepSpec>[],
  cues: json['cues'] == null
      ? const TimerCues()
      : TimerCues.fromJson(json['cues'] as Map<String, dynamic>),
  position: (json['position'] as num?)?.toInt() ?? 0,
  builtIn: json['builtIn'] as bool? ?? false,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TimerPresetToJson(_TimerPreset instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'id': instance.id,
      'name': instance.name,
      'mode': _$TimerModeEnumMap[instance.mode]!,
      'steps': instance.steps,
      'cues': instance.cues,
      'position': instance.position,
      'builtIn': instance.builtIn,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TimerModeEnumMap = {
  TimerMode.stopwatch: 'stopwatch',
  TimerMode.countdown: 'countdown',
  TimerMode.interval: 'interval',
  TimerMode.tabata: 'tabata',
  TimerMode.emom: 'emom',
  TimerMode.amrap: 'amrap',
  TimerMode.boxing: 'boxing',
  TimerMode.yogaFlow: 'yogaFlow',
  TimerMode.custom: 'custom',
};

_TimerStepSpec _$TimerStepSpecFromJson(Map<String, dynamic> json) =>
    _TimerStepSpec(
      label: json['label'] as String,
      durationMs: (json['durationMs'] as num?)?.toInt(),
      phase: $enumDecode(
        _$TimerPhaseEnumMap,
        json['phase'],
        unknownValue: TimerPhase.work,
      ),
      exerciseId: json['exerciseId'] as String?,
    );

Map<String, dynamic> _$TimerStepSpecToJson(_TimerStepSpec instance) =>
    <String, dynamic>{
      'label': instance.label,
      'durationMs': instance.durationMs,
      'phase': _$TimerPhaseEnumMap[instance.phase]!,
      'exerciseId': instance.exerciseId,
    };

const _$TimerPhaseEnumMap = {
  TimerPhase.prepare: 'prepare',
  TimerPhase.work: 'work',
  TimerPhase.rest: 'rest',
  TimerPhase.roundRest: 'roundRest',
  TimerPhase.cooldown: 'cooldown',
  TimerPhase.open: 'open',
};

_TimerCues _$TimerCuesFromJson(Map<String, dynamic> json) => _TimerCues(
  sound: json['sound'] as bool? ?? true,
  haptic: json['haptic'] as bool? ?? true,
  voice: json['voice'] as bool? ?? false,
  countdownSec: (json['countdownSec'] as num?)?.toInt() ?? 3,
  warningSec: (json['warningSec'] as num?)?.toInt(),
);

Map<String, dynamic> _$TimerCuesToJson(_TimerCues instance) =>
    <String, dynamic>{
      'sound': instance.sound,
      'haptic': instance.haptic,
      'voice': instance.voice,
      'countdownSec': instance.countdownSec,
      'warningSec': instance.warningSec,
    };
