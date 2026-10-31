import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'timer_preset.freezed.dart';
part 'timer_preset.g.dart';

/// A saved timer. [steps] is the flat sequence every mode compiles to
/// (see `engines/timer`). Stored as JSON inside the user database, so it
/// carries its own [schemaVersion].
@freezed
abstract class TimerPreset with _$TimerPreset {
  const factory TimerPreset({
    @Default(TimerPreset.currentSchemaVersion) int schemaVersion,
    required String id,
    required String name,
    required TimerMode mode,
    @Default(<TimerStepSpec>[]) List<TimerStepSpec> steps,
    @Default(TimerCues()) TimerCues cues,
    @Default(0) int position,
    @Default(false) bool builtIn,
    required DateTime updatedAt,
  }) = _TimerPreset;

  factory TimerPreset.fromJson(Map<String, dynamic> json) =>
      _$TimerPresetFromJson(json);

  static const int currentSchemaVersion = 1;
}

/// One step. A null [durationMs] is open-ended (stopwatch, AMRAP).
@freezed
abstract class TimerStepSpec with _$TimerStepSpec {
  const factory TimerStepSpec({
    required String label,
    int? durationMs,
    @JsonKey(unknownEnumValue: TimerPhase.work) required TimerPhase phase,
    String? exerciseId,
  }) = _TimerStepSpec;

  factory TimerStepSpec.fromJson(Map<String, dynamic> json) =>
      _$TimerStepSpecFromJson(json);
}

@freezed
abstract class TimerCues with _$TimerCues {
  const factory TimerCues({
    @Default(true) bool sound,
    @Default(true) bool haptic,
    @Default(false) bool voice,

    /// Spoken/beeped countdown over the last N seconds of a step.
    @Default(3) int countdownSec,

    /// A warning this many seconds before a step ends (boxing: 10).
    int? warningSec,
  }) = _TimerCues;

  factory TimerCues.fromJson(Map<String, dynamic> json) =>
      _$TimerCuesFromJson(json);
}
