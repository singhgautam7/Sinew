import '../../../core/db/repositories/runtime_state_repository.dart';
import '../../../core/db/repositories/timer_preset_repository.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/timer_preset.dart';
import '../../../engines/timer/timer_engine.dart';

/// The ids of the presets that ship with the app.
abstract final class BuiltInPresetIds {
  static const String tabata = 'builtin-tabata-20-10-8';
  static const String emom = 'builtin-emom-10';
  static const String amrap = 'builtin-amrap-12';
  static const String boxing = 'builtin-boxing-12x3';
  static const String countdown = 'builtin-countdown-5';

  static const List<String> all = <String>[
    tabata,
    emom,
    amrap,
    boxing,
    countdown,
  ];
}

/// Key of the record of which built-in presets were already inserted, so a
/// preset the user deleted never comes back.
const String kPresetsSeededKey = 'timer.presetsSeeded';

TimerPreset _builtIn(
  String id,
  String name,
  TimerConfig config,
  int position,
  DateTime now,
) => TimerPreset(
  id: id,
  name: name,
  mode: config.mode,
  steps: compile(config),
  cues: config.defaultCues,
  position: position,
  builtIn: true,
  updatedAt: now,
);

/// The five presets of the brief.
List<TimerPreset> builtInPresets(DateTime now) => <TimerPreset>[
  _builtIn(BuiltInPresetIds.tabata, 'Tabata', const TabataConfig(), 0, now),
  _builtIn(
    BuiltInPresetIds.emom,
    'EMOM 10',
    const EmomConfig(rounds: 10),
    1,
    now,
  ),
  _builtIn(
    BuiltInPresetIds.amrap,
    'AMRAP 12',
    const AmrapConfig(capSec: 12 * 60),
    2,
    now,
  ),
  _builtIn(
    BuiltInPresetIds.boxing,
    'Boxing rounds',
    const BoxingConfig(),
    3,
    now,
  ),
  _builtIn(
    BuiltInPresetIds.countdown,
    '5 minute countdown',
    const CountdownConfig(durationSec: 300),
    4,
    now,
  ),
];

/// Inserts the built-in presets that were never inserted before. Safe to call
/// on every visit: it reads the record first and writes only what is missing.
Future<void> seedBuiltInPresets({
  required TimerPresetRepository presets,
  required RuntimeStateRepository state,
  required DateTime now,
}) async {
  final Map<String, dynamic>? seeded = await state.read(kPresetsSeededKey);
  final Set<String> done = <String>{
    if (seeded?['ids'] case final List<Object?> ids)
      for (final Object? id in ids)
        if (id is String) id,
  };
  final List<TimerPreset> missing = <TimerPreset>[
    for (final TimerPreset p in builtInPresets(now))
      if (!done.contains(p.id)) p,
  ];
  if (missing.isEmpty) return;
  for (final TimerPreset p in missing) {
    // A restore may already hold the preset; never overwrite it.
    if (await presets.byId(p.id) == null) await presets.save(p);
    done.add(p.id);
  }
  await state.write(kPresetsSeededKey, <String, dynamic>{
    'schemaVersion': 1,
    'ids': done.toList(),
  });
}

int _sec(TimerStepSpec s) => ((s.durationMs ?? 0) / 1000).round();

/// Rebuilds the config a preset's steps came from, so its setup screen can
/// show the same fields. A preset that does not fit its mode opens as a
/// custom sequence instead of failing.
TimerConfig configFromSteps(TimerMode mode, List<TimerStepSpec> steps) {
  TimerConfig custom() => CustomConfig(steps);
  if (mode == TimerMode.custom) return custom();
  if (mode == TimerMode.stopwatch) return const StopwatchConfig();

  int prepare = 0;
  int start = 0;
  if (steps.isNotEmpty && steps.first.phase == TimerPhase.prepare) {
    prepare = _sec(steps.first);
    start = 1;
  }
  final List<TimerStepSpec> body = steps.sublist(start);
  final List<TimerStepSpec> works = <TimerStepSpec>[
    for (final TimerStepSpec s in body)
      if (s.phase == TimerPhase.work) s,
  ];
  if (works.isEmpty) return custom();

  switch (mode) {
    case TimerMode.countdown:
      if (body.length != 1 || works.first.durationMs == null) return custom();
      return CountdownConfig(
        durationSec: _sec(works.first),
        prepareSec: prepare,
      );
    case TimerMode.interval:
    case TimerMode.tabata:
      final int setBreaks = body
          .where((TimerStepSpec s) => s.phase == TimerPhase.roundRest)
          .length;
      final int sets = setBreaks + 1;
      if (works.length % sets != 0) return custom();
      final int rounds = works.length ~/ sets;
      final TimerStepSpec? rest = body
          .where((TimerStepSpec s) => s.phase == TimerPhase.rest)
          .firstOrNull;
      final TimerStepSpec? setRest = body
          .where((TimerStepSpec s) => s.phase == TimerPhase.roundRest)
          .firstOrNull;
      final TimerStepSpec? cool = body
          .where((TimerStepSpec s) => s.phase == TimerPhase.cooldown)
          .firstOrNull;
      if (mode == TimerMode.tabata && (sets > 1 || cool != null)) {
        return IntervalConfig(
          workSec: _sec(works.first),
          restSec: rest == null ? 0 : _sec(rest),
          rounds: rounds,
          sets: sets,
          restBetweenSetsSec: setRest == null ? 0 : _sec(setRest),
          prepareSec: prepare,
          cooldownSec: cool == null ? 0 : _sec(cool),
        );
      }
      if (mode == TimerMode.tabata) {
        return TabataConfig(
          workSec: _sec(works.first),
          restSec: rest == null ? 0 : _sec(rest),
          rounds: rounds,
          prepareSec: prepare,
        );
      }
      return IntervalConfig(
        workSec: _sec(works.first),
        restSec: rest == null ? 0 : _sec(rest),
        rounds: rounds,
        sets: sets,
        restBetweenSetsSec: setRest == null ? 0 : _sec(setRest),
        prepareSec: prepare,
        cooldownSec: cool == null ? 0 : _sec(cool),
      );
    case TimerMode.emom:
      if (works.length != body.length || works.first.durationMs == null) {
        return custom();
      }
      return EmomConfig(
        intervalSec: _sec(works.first),
        rounds: works.length,
        prepareSec: prepare,
      );
    case TimerMode.amrap:
      if (body.length != 1) return custom();
      return AmrapConfig(
        capSec: works.first.durationMs == null ? null : _sec(works.first),
        prepareSec: prepare,
      );
    case TimerMode.boxing:
      final TimerStepSpec? rest = body
          .where((TimerStepSpec s) => s.phase == TimerPhase.rest)
          .firstOrNull;
      return BoxingConfig(
        rounds: works.length,
        roundSec: _sec(works.first),
        restSec: rest == null ? 0 : _sec(rest),
        prepareSec: prepare,
      );
    case TimerMode.yogaFlow:
      final TimerStepSpec? gap = body
          .where((TimerStepSpec s) => s.phase == TimerPhase.rest)
          .firstOrNull;
      return YogaFlowConfig(
        poses: <YogaPose>[
          for (final TimerStepSpec s in works)
            YogaPose(
              label: s.label,
              holdSec: _sec(s),
              exerciseId: s.exerciseId,
            ),
        ],
        transitionSec: gap == null ? 0 : _sec(gap),
      );
    case TimerMode.stopwatch:
    case TimerMode.custom:
      return custom();
  }
}

/// One line under a preset's name, for example `20 / 10 x 8, 4:30`.
String describePreset(TimerPreset p) {
  final TimerConfig config = configFromSteps(p.mode, p.steps);
  final int? total = totalDurationMs(p.steps);
  final String time = total == null ? 'Open ended' : _clock(total ~/ 1000);
  final String? detail = switch (config) {
    TabataConfig() =>
      '${config.workSec} / ${config.restSec} x ${config.rounds}',
    IntervalConfig() =>
      '${config.rounds} x ${config.workSec} / ${config.restSec}'
          '${config.sets > 1 ? ', ${config.sets} sets' : ''}',
    EmomConfig() => '${config.rounds} rounds',
    BoxingConfig() =>
      '${config.rounds} x ${_clock(config.roundSec)}, '
          'rest ${_clock(config.restSec)}',
    YogaFlowConfig() => '${config.poses.length} poses',
    CustomConfig() => '${config.steps.length} steps',
    _ => null,
  };
  return detail == null ? time : '$detail, $time';
}

String _clock(int seconds) {
  final int s = seconds < 0 ? 0 : seconds;
  final int h = s ~/ 3600;
  final int m = (s % 3600) ~/ 60;
  final String ss = (s % 60).toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
  return '$m:$ss';
}
