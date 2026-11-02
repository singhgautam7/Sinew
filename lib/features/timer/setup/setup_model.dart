import '../../../core/models/enums.dart';
import '../../../core/models/timer_preset.dart';
import '../../../core/theme/app_theme.dart';
import '../../../engines/timer/timer_engine.dart';

/// How a setup field is shown.
enum FieldKind { seconds, count }

/// One number the user sets on a setup screen.
class SetupFieldDef {
  const SetupFieldDef({
    required this.id,
    required this.label,
    required this.kind,
    required this.step,
    required this.min,
    this.max,
    this.dot,
  });

  final String id;
  final String label;
  final FieldKind kind;
  final int step;
  final int min;
  final int? max;

  /// The phase colour of the dot beside the label, if the field is a phase.
  final SinewPhase? dot;
}

const double _hour = 3600;

SetupFieldDef _secs(
  String id,
  String label,
  int step,
  int min, {
  SinewPhase? dot,
}) => SetupFieldDef(
  id: id,
  label: label,
  kind: FieldKind.seconds,
  step: step,
  min: min,
  max: _hour.toInt(),
  dot: dot,
);

SetupFieldDef _count(String id, String label, int min, int max) =>
    SetupFieldDef(
      id: id,
      label: label,
      kind: FieldKind.count,
      step: 1,
      min: min,
      max: max,
    );

/// The fields each mode shows, top to bottom.
List<SetupFieldDef> fieldsFor(TimerMode mode) => switch (mode) {
  TimerMode.countdown => <SetupFieldDef>[
    _secs('duration', 'Duration', 15, 5, dot: SinewPhase.work),
    _secs('prepare', 'Get ready', 5, 0, dot: SinewPhase.warmup),
  ],
  TimerMode.interval => <SetupFieldDef>[
    _secs('prepare', 'Get ready', 5, 0, dot: SinewPhase.warmup),
    _secs('work', 'Work', 5, 1, dot: SinewPhase.work),
    _secs('rest', 'Rest', 5, 0, dot: SinewPhase.rest),
    _count('rounds', 'Rounds', 1, 99),
    _count('sets', 'Sets', 1, 99),
    _secs('setRest', 'Rest between sets', 15, 0, dot: SinewPhase.rest),
    _secs('cooldown', 'Cool-down', 30, 0, dot: SinewPhase.cooldown),
  ],
  TimerMode.tabata => <SetupFieldDef>[
    _secs('prepare', 'Get ready', 5, 0, dot: SinewPhase.warmup),
    _secs('work', 'Work', 5, 1, dot: SinewPhase.work),
    _secs('rest', 'Rest', 5, 0, dot: SinewPhase.rest),
    _count('rounds', 'Rounds', 1, 99),
  ],
  TimerMode.emom => <SetupFieldDef>[
    _secs('prepare', 'Get ready', 5, 0, dot: SinewPhase.warmup),
    _secs('every', 'Every', 15, 5, dot: SinewPhase.work),
    _count('rounds', 'Rounds', 1, 99),
  ],
  TimerMode.amrap => <SetupFieldDef>[
    _secs('prepare', 'Get ready', 5, 0, dot: SinewPhase.warmup),
    _secs('cap', 'Time cap', 60, 60, dot: SinewPhase.work),
  ],
  TimerMode.boxing => <SetupFieldDef>[
    _secs('prepare', 'Get ready', 5, 0, dot: SinewPhase.warmup),
    _count('rounds', 'Rounds', 1, 99),
    _secs('roundSec', 'Round length', 15, 15, dot: SinewPhase.work),
    _secs('rest', 'Rest', 15, 0, dot: SinewPhase.rest),
  ],
  TimerMode.yogaFlow => <SetupFieldDef>[
    _secs('transition', 'Between poses', 5, 0, dot: SinewPhase.rest),
  ],
  TimerMode.stopwatch || TimerMode.custom => const <SetupFieldDef>[],
};

/// Everything the setup screen edits, as plain values. [toConfig] turns it
/// into the engine config; [SetupModel.fromConfig] goes the other way.
class SetupModel {
  const SetupModel({
    required this.mode,
    required this.values,
    required this.cues,
    this.noCap = false,
    this.steps = const <TimerStepSpec>[],
    this.poses = const <YogaPose>[],
  });

  /// A fresh model with the mode's own defaults.
  factory SetupModel.defaults(TimerMode mode) {
    final TimerConfig c = switch (mode) {
      TimerMode.stopwatch => const StopwatchConfig(),
      TimerMode.countdown => const CountdownConfig(durationSec: 300),
      TimerMode.interval => const IntervalConfig(
        workSec: 30,
        restSec: 15,
        rounds: 8,
      ),
      TimerMode.tabata => const TabataConfig(),
      TimerMode.emom => const EmomConfig(rounds: 10),
      TimerMode.amrap => const AmrapConfig(capSec: 12 * 60),
      TimerMode.boxing => const BoxingConfig(),
      TimerMode.yogaFlow => const YogaFlowConfig(poses: <YogaPose>[]),
      TimerMode.custom => const CustomConfig(<TimerStepSpec>[]),
    };
    return SetupModel.fromConfig(c);
  }

  factory SetupModel.fromConfig(TimerConfig c, {TimerCues? cues}) {
    final TimerCues useCues = cues ?? c.defaultCues;
    switch (c) {
      case StopwatchConfig():
        return SetupModel(
          mode: c.mode,
          values: const <String, int>{},
          cues: useCues,
        );
      case CountdownConfig():
        return SetupModel(
          mode: c.mode,
          values: <String, int>{
            'duration': c.durationSec,
            'prepare': c.prepareSec,
          },
          cues: useCues,
        );
      case IntervalConfig():
        return SetupModel(
          mode: c.mode,
          values: <String, int>{
            'prepare': c.prepareSec,
            'work': c.workSec,
            'rest': c.restSec,
            'rounds': c.rounds,
            'sets': c.sets,
            'setRest': c.restBetweenSetsSec,
            'cooldown': c.cooldownSec,
          },
          cues: useCues,
        );
      case TabataConfig():
        return SetupModel(
          mode: c.mode,
          values: <String, int>{
            'prepare': c.prepareSec,
            'work': c.workSec,
            'rest': c.restSec,
            'rounds': c.rounds,
          },
          cues: useCues,
        );
      case EmomConfig():
        return SetupModel(
          mode: c.mode,
          values: <String, int>{
            'prepare': c.prepareSec,
            'every': c.intervalSec,
            'rounds': c.rounds,
          },
          cues: useCues,
        );
      case AmrapConfig():
        return SetupModel(
          mode: c.mode,
          values: <String, int>{
            'prepare': c.prepareSec,
            'cap': c.capSec ?? 12 * 60,
          },
          noCap: c.capSec == null,
          cues: useCues,
        );
      case BoxingConfig():
        return SetupModel(
          mode: c.mode,
          values: <String, int>{
            'prepare': c.prepareSec,
            'rounds': c.rounds,
            'roundSec': c.roundSec,
            'rest': c.restSec,
          },
          cues: useCues,
        );
      case YogaFlowConfig():
        return SetupModel(
          mode: c.mode,
          values: <String, int>{'transition': c.transitionSec},
          poses: c.poses,
          cues: useCues,
        );
      case CustomConfig():
        return SetupModel(
          mode: c.mode,
          values: const <String, int>{},
          steps: c.steps,
          cues: useCues,
        );
    }
  }

  final TimerMode mode;
  final Map<String, int> values;
  final TimerCues cues;

  /// AMRAP without a time cap.
  final bool noCap;

  /// Custom sequence.
  final List<TimerStepSpec> steps;

  /// Yoga flow.
  final List<YogaPose> poses;

  int value(String id) => values[id] ?? 0;

  SetupModel copyWith({
    Map<String, int>? values,
    TimerCues? cues,
    bool? noCap,
    List<TimerStepSpec>? steps,
    List<YogaPose>? poses,
  }) => SetupModel(
    mode: mode,
    values: values ?? this.values,
    cues: cues ?? this.cues,
    noCap: noCap ?? this.noCap,
    steps: steps ?? this.steps,
    poses: poses ?? this.poses,
  );

  SetupModel withValue(String id, int v) =>
      copyWith(values: <String, int>{...values, id: v});

  TimerConfig toConfig() {
    int v(String id) => value(id);
    switch (mode) {
      case TimerMode.stopwatch:
        return const StopwatchConfig();
      case TimerMode.countdown:
        return CountdownConfig(
          durationSec: v('duration'),
          prepareSec: v('prepare'),
        );
      case TimerMode.interval:
        return IntervalConfig(
          workSec: v('work'),
          restSec: v('rest'),
          rounds: v('rounds'),
          sets: v('sets'),
          restBetweenSetsSec: v('setRest'),
          prepareSec: v('prepare'),
          cooldownSec: v('cooldown'),
        );
      case TimerMode.tabata:
        return TabataConfig(
          workSec: v('work'),
          restSec: v('rest'),
          rounds: v('rounds'),
          prepareSec: v('prepare'),
        );
      case TimerMode.emom:
        return EmomConfig(
          intervalSec: v('every'),
          rounds: v('rounds'),
          prepareSec: v('prepare'),
        );
      case TimerMode.amrap:
        return AmrapConfig(
          capSec: noCap ? null : v('cap'),
          prepareSec: v('prepare'),
        );
      case TimerMode.boxing:
        return BoxingConfig(
          rounds: v('rounds'),
          roundSec: v('roundSec'),
          restSec: v('rest'),
          prepareSec: v('prepare'),
        );
      case TimerMode.yogaFlow:
        return YogaFlowConfig(poses: poses, transitionSec: v('transition'));
      case TimerMode.custom:
        return CustomConfig(steps);
    }
  }

  /// Total time in ms, or null while the sequence is open ended.
  int? get totalMs => totalDurationMs(compile(toConfig()));

  /// True when there is something to run (a flow or a sequence needs steps).
  bool get canStart => switch (mode) {
    TimerMode.yogaFlow => poses.isNotEmpty,
    TimerMode.custom => steps.isNotEmpty,
    _ => true,
  };
}
