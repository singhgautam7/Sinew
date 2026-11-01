import 'dart:math';

import '../../core/models/enums.dart';
import '../../core/models/timer_preset.dart';
import 'timer_config.dart';

// PURE DART.

int _ms(int sec) => max(0, sec) * 1000;

TimerStepSpec _step(String label, TimerPhase phase, int sec, {String? ex}) =>
    TimerStepSpec(
      label: label,
      phase: phase,
      durationMs: _ms(sec),
      exerciseId: ex,
    );

void _prepare(List<TimerStepSpec> out, int sec) {
  if (sec > 0) out.add(_step('Get ready', TimerPhase.prepare, sec));
}

/// Compiles a config to the flat step list every mode shares.
///
/// Rules: an optional leading prepare step; no rest after the very last work
/// step; zero-length prepare, rest and cooldown steps are omitted; open-ended
/// steps (stopwatch, uncapped AMRAP) have a null duration.
List<TimerStepSpec> compile(TimerConfig c) {
  switch (c) {
    case StopwatchConfig():
      return const <TimerStepSpec>[
        TimerStepSpec(label: 'Stopwatch', phase: TimerPhase.open),
      ];
    case CountdownConfig():
      final List<TimerStepSpec> out = <TimerStepSpec>[];
      _prepare(out, c.prepareSec);
      out.add(_step('Countdown', TimerPhase.work, max(1, c.durationSec)));
      return out;
    case IntervalConfig():
      return _interval(
        workSec: c.workSec,
        restSec: c.restSec,
        rounds: c.rounds,
        sets: c.sets,
        restBetweenSetsSec: c.restBetweenSetsSec,
        prepareSec: c.prepareSec,
        cooldownSec: c.cooldownSec,
      );
    case TabataConfig():
      return _interval(
        workSec: c.workSec,
        restSec: c.restSec,
        rounds: c.rounds,
        sets: 1,
        restBetweenSetsSec: 0,
        prepareSec: c.prepareSec,
        cooldownSec: 0,
      );
    case EmomConfig():
      final int n = max(1, c.rounds);
      final List<TimerStepSpec> out = <TimerStepSpec>[];
      _prepare(out, c.prepareSec);
      for (int r = 1; r <= n; r++) {
        out.add(
          _step('Minute $r of $n', TimerPhase.work, max(1, c.intervalSec)),
        );
      }
      return out;
    case AmrapConfig():
      final List<TimerStepSpec> out = <TimerStepSpec>[];
      _prepare(out, c.prepareSec);
      final int? cap = c.capSec;
      out.add(
        cap == null
            ? const TimerStepSpec(label: 'AMRAP', phase: TimerPhase.work)
            : _step('AMRAP', TimerPhase.work, max(1, cap)),
      );
      return out;
    case BoxingConfig():
      final int n = max(1, c.rounds);
      final List<TimerStepSpec> out = <TimerStepSpec>[];
      _prepare(out, c.prepareSec);
      for (int r = 1; r <= n; r++) {
        out.add(_step('Round $r of $n', TimerPhase.work, max(1, c.roundSec)));
        if (r < n && c.restSec > 0) {
          out.add(_step('Rest', TimerPhase.rest, c.restSec));
        }
      }
      return out;
    case YogaFlowConfig():
      final List<TimerStepSpec> out = <TimerStepSpec>[];
      for (int i = 0; i < c.poses.length; i++) {
        final YogaPose p = c.poses[i];
        out.add(
          _step(p.label, TimerPhase.work, max(1, p.holdSec), ex: p.exerciseId),
        );
        if (i < c.poses.length - 1 && c.transitionSec > 0) {
          out.add(_step('Transition', TimerPhase.rest, c.transitionSec));
        }
      }
      return out;
    case CustomConfig():
      return List<TimerStepSpec>.of(c.steps);
  }
}

List<TimerStepSpec> _interval({
  required int workSec,
  required int restSec,
  required int rounds,
  required int sets,
  required int restBetweenSetsSec,
  required int prepareSec,
  required int cooldownSec,
}) {
  final int nRounds = max(1, rounds);
  final int nSets = max(1, sets);
  final List<TimerStepSpec> out = <TimerStepSpec>[];
  _prepare(out, prepareSec);
  for (int s = 1; s <= nSets; s++) {
    for (int r = 1; r <= nRounds; r++) {
      out.add(_step('Work', TimerPhase.work, max(1, workSec)));
      final bool lastRound = r == nRounds;
      final bool lastSet = s == nSets;
      if (!lastRound) {
        if (restSec > 0) out.add(_step('Rest', TimerPhase.rest, restSec));
      } else if (!lastSet && restBetweenSetsSec > 0) {
        out.add(
          _step('Rest between sets', TimerPhase.roundRest, restBetweenSetsSec),
        );
      }
    }
  }
  if (cooldownSec > 0) {
    out.add(_step('Cooldown', TimerPhase.cooldown, cooldownSec));
  }
  return out;
}

/// Sum of all step durations, or null when any step is open-ended (the
/// "live total" on setup screens).
int? totalDurationMs(List<TimerStepSpec> steps) {
  int total = 0;
  for (final TimerStepSpec s in steps) {
    final int? d = s.durationMs;
    if (d == null) return null;
    total += d;
  }
  return total;
}
