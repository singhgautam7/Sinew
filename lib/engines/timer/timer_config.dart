import '../../core/models/enums.dart';
import '../../core/models/timer_preset.dart';

// PURE DART.

/// What the user configures on a timer setup screen. Every config compiles to
/// one flat `List<TimerStepSpec>` (see `compile`); the run engine only ever
/// sees steps.
///
/// Durations are whole seconds here (the UI works in seconds) and become
/// milliseconds in the compiled steps.
sealed class TimerConfig {
  const TimerConfig();

  static const int currentSchemaVersion = 1;

  TimerMode get mode;

  /// Cue settings the mode wants by default (boxing warns 10 s before a round
  /// ends). The user can still override them.
  TimerCues get defaultCues => const TimerCues();

  Map<String, dynamic> toJson();

  /// Reads a config written by [toJson]. Unknown types, newer schema versions
  /// and malformed data return null, never throw.
  static TimerConfig? fromJson(Object? raw) {
    if (raw is! Map) return null;
    try {
      final Map<String, dynamic> j = Map<String, dynamic>.from(raw);
      final Object? v = j['schemaVersion'];
      if (v is! int || v > TimerConfig.currentSchemaVersion) return null;
      int i(String k, int d) {
        final Object? x = j[k];
        return x is num ? x.toInt() : d;
      }

      int? oi(String k) {
        final Object? x = j[k];
        return x is num ? x.toInt() : null;
      }

      switch (j['type']) {
        case 'stopwatch':
          return const StopwatchConfig();
        case 'countdown':
          return CountdownConfig(
            durationSec: i('durationSec', 60),
            prepareSec: i('prepareSec', 0),
          );
        case 'interval':
          return IntervalConfig(
            workSec: i('workSec', 30),
            restSec: i('restSec', 15),
            rounds: i('rounds', 8),
            sets: i('sets', 1),
            restBetweenSetsSec: i('restBetweenSetsSec', 0),
            prepareSec: i('prepareSec', 10),
            cooldownSec: i('cooldownSec', 0),
          );
        case 'tabata':
          return TabataConfig(
            workSec: i('workSec', 20),
            restSec: i('restSec', 10),
            rounds: i('rounds', 8),
            prepareSec: i('prepareSec', 10),
          );
        case 'emom':
          return EmomConfig(
            intervalSec: i('intervalSec', 60),
            rounds: i('rounds', 10),
            prepareSec: i('prepareSec', 0),
          );
        case 'amrap':
          return AmrapConfig(
            capSec: oi('capSec'),
            prepareSec: i('prepareSec', 0),
          );
        case 'boxing':
          return BoxingConfig(
            rounds: i('rounds', 12),
            roundSec: i('roundSec', 180),
            restSec: i('restSec', 60),
            prepareSec: i('prepareSec', 10),
          );
        case 'yogaFlow':
          final Object? ps = j['poses'];
          if (ps is! List<Object?>) return null;
          final List<YogaPose> poses = <YogaPose>[];
          for (final Object? p in ps) {
            if (p is! Map<Object?, Object?>) return null;
            final Object? label = p['label'];
            final Object? hold = p['holdSec'];
            final Object? ex = p['exerciseId'];
            if (label is! String || hold is! num) return null;
            poses.add(
              YogaPose(
                label: label,
                holdSec: hold.toInt(),
                exerciseId: ex is String ? ex : null,
              ),
            );
          }
          return YogaFlowConfig(
            poses: poses,
            transitionSec: i('transitionSec', 5),
          );
        case 'custom':
          final Object? ss = j['steps'];
          if (ss is! List<Object?>) return null;
          final List<TimerStepSpec> steps = <TimerStepSpec>[];
          for (final Object? s in ss) {
            if (s is! Map<Object?, Object?>) return null;
            steps.add(stepFromJson(Map<String, dynamic>.from(s)));
          }
          return CustomConfig(steps);
      }
    } on Object {
      return null;
    }
    return null;
  }
}

/// Hand-written step deserialisation, tolerant of unknown phases. Throws a
/// [FormatException] on a malformed step; callers catch it.
TimerStepSpec stepFromJson(Map<String, dynamic> j) {
  final Object? label = j['label'];
  final Object? dur = j['durationMs'];
  final Object? ex = j['exerciseId'];
  final Object? phase = j['phase'];
  if (label is! String) throw const FormatException('step label');
  return TimerStepSpec(
    label: label,
    durationMs: dur is num ? dur.toInt() : null,
    phase: enumByName(
      TimerPhase.values,
      phase is String ? phase : null,
      TimerPhase.work,
    ),
    exerciseId: ex is String ? ex : null,
  );
}

Map<String, dynamic> stepToJson(TimerStepSpec s) => <String, dynamic>{
  'label': s.label,
  'durationMs': s.durationMs,
  'phase': s.phase.name,
  'exerciseId': s.exerciseId,
};

Map<String, dynamic> _base(String type) => <String, dynamic>{
  'schemaVersion': TimerConfig.currentSchemaVersion,
  'type': type,
};

class StopwatchConfig extends TimerConfig {
  const StopwatchConfig();

  @override
  TimerMode get mode => TimerMode.stopwatch;

  @override
  Map<String, dynamic> toJson() => _base('stopwatch');
}

class CountdownConfig extends TimerConfig {
  const CountdownConfig({required this.durationSec, this.prepareSec = 0});

  final int durationSec;
  final int prepareSec;

  @override
  TimerMode get mode => TimerMode.countdown;

  @override
  Map<String, dynamic> toJson() => _base('countdown')
    ..['durationSec'] = durationSec
    ..['prepareSec'] = prepareSec;
}

class IntervalConfig extends TimerConfig {
  const IntervalConfig({
    required this.workSec,
    required this.restSec,
    required this.rounds,
    this.sets = 1,
    this.restBetweenSetsSec = 0,
    this.prepareSec = 10,
    this.cooldownSec = 0,
  });

  final int workSec;
  final int restSec;
  final int rounds;
  final int sets;
  final int restBetweenSetsSec;
  final int prepareSec;
  final int cooldownSec;

  @override
  TimerMode get mode => TimerMode.interval;

  @override
  Map<String, dynamic> toJson() => _base('interval')
    ..['workSec'] = workSec
    ..['restSec'] = restSec
    ..['rounds'] = rounds
    ..['sets'] = sets
    ..['restBetweenSetsSec'] = restBetweenSetsSec
    ..['prepareSec'] = prepareSec
    ..['cooldownSec'] = cooldownSec;
}

/// Tabata: 20 s work, 10 s rest, 8 rounds, 10 s prepare, by default.
class TabataConfig extends TimerConfig {
  const TabataConfig({
    this.workSec = 20,
    this.restSec = 10,
    this.rounds = 8,
    this.prepareSec = 10,
  });

  final int workSec;
  final int restSec;
  final int rounds;
  final int prepareSec;

  @override
  TimerMode get mode => TimerMode.tabata;

  @override
  Map<String, dynamic> toJson() => _base('tabata')
    ..['workSec'] = workSec
    ..['restSec'] = restSec
    ..['rounds'] = rounds
    ..['prepareSec'] = prepareSec;
}

class EmomConfig extends TimerConfig {
  const EmomConfig({
    this.intervalSec = 60,
    required this.rounds,
    this.prepareSec = 0,
  });

  final int intervalSec;
  final int rounds;
  final int prepareSec;

  @override
  TimerMode get mode => TimerMode.emom;

  @override
  Map<String, dynamic> toJson() => _base('emom')
    ..['intervalSec'] = intervalSec
    ..['rounds'] = rounds
    ..['prepareSec'] = prepareSec;
}

/// As many rounds as possible. A null [capSec] is open-ended; the user counts
/// rounds with `TimerRun.incrementRound`.
class AmrapConfig extends TimerConfig {
  const AmrapConfig({this.capSec, this.prepareSec = 0});

  final int? capSec;
  final int prepareSec;

  @override
  TimerMode get mode => TimerMode.amrap;

  @override
  Map<String, dynamic> toJson() => _base('amrap')
    ..['capSec'] = capSec
    ..['prepareSec'] = prepareSec;
}

class BoxingConfig extends TimerConfig {
  const BoxingConfig({
    this.rounds = 12,
    this.roundSec = 180,
    this.restSec = 60,
    this.prepareSec = 10,
  });

  final int rounds;
  final int roundSec;
  final int restSec;
  final int prepareSec;

  @override
  TimerMode get mode => TimerMode.boxing;

  @override
  TimerCues get defaultCues => const TimerCues(warningSec: 10);

  @override
  Map<String, dynamic> toJson() => _base('boxing')
    ..['rounds'] = rounds
    ..['roundSec'] = roundSec
    ..['restSec'] = restSec
    ..['prepareSec'] = prepareSec;
}

class YogaPose {
  const YogaPose({required this.label, required this.holdSec, this.exerciseId});

  final String label;
  final String? exerciseId;
  final int holdSec;
}

class YogaFlowConfig extends TimerConfig {
  const YogaFlowConfig({required this.poses, this.transitionSec = 5});

  final List<YogaPose> poses;
  final int transitionSec;

  @override
  TimerMode get mode => TimerMode.yogaFlow;

  @override
  Map<String, dynamic> toJson() => _base('yogaFlow')
    ..['transitionSec'] = transitionSec
    ..['poses'] = <Map<String, dynamic>>[
      for (final YogaPose p in poses)
        <String, dynamic>{
          'label': p.label,
          'exerciseId': p.exerciseId,
          'holdSec': p.holdSec,
        },
    ];
}

class CustomConfig extends TimerConfig {
  const CustomConfig(this.steps);

  final List<TimerStepSpec> steps;

  @override
  TimerMode get mode => TimerMode.custom;

  @override
  Map<String, dynamic> toJson() => _base('custom')
    ..['steps'] = <Map<String, dynamic>>[
      for (final TimerStepSpec s in steps) stepToJson(s),
    ];
}
