import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';

/// How a timer mode is named and drawn on the home grid.
class TimerModeInfo {
  const TimerModeInfo(this.mode, this.label, this.caption, this.icon);

  final TimerMode mode;
  final String label;
  final String caption;
  final IconData icon;
}

/// The nine modes, in the order of the Timer home frame.
const List<TimerModeInfo> kTimerModes = <TimerModeInfo>[
  TimerModeInfo(TimerMode.stopwatch, 'Stopwatch', 'Laps', Icons.timer_rounded),
  TimerModeInfo(
    TimerMode.countdown,
    'Countdown',
    'One time',
    Icons.hourglass_bottom_rounded,
  ),
  TimerModeInfo(
    TimerMode.interval,
    'Interval',
    'Work / rest',
    Icons.repeat_rounded,
  ),
  TimerModeInfo(TimerMode.tabata, 'Tabata', '20 / 10 x 8', Icons.bolt_rounded),
  TimerModeInfo(TimerMode.emom, 'EMOM', 'Every minute', Icons.update_rounded),
  TimerModeInfo(
    TimerMode.amrap,
    'AMRAP',
    'Count rounds',
    Icons.all_inclusive_rounded,
  ),
  TimerModeInfo(TimerMode.boxing, 'Boxing', 'Rounds', Icons.sports_mma_rounded),
  TimerModeInfo(
    TimerMode.yogaFlow,
    'Yoga flow',
    'Pose holds',
    Icons.self_improvement_rounded,
  ),
  TimerModeInfo(
    TimerMode.custom,
    'Custom',
    'Any steps',
    Icons.format_list_numbered_rounded,
  ),
];

TimerModeInfo timerModeInfo(TimerMode mode) =>
    kTimerModes.firstWhere((TimerModeInfo m) => m.mode == mode);

/// `TimerMode.name` to the mode, for the setup route. Unknown names read as
/// null so a bad link opens the home instead of crashing.
TimerMode? timerModeFromName(String? name) {
  for (final TimerMode m in TimerMode.values) {
    if (m.name == name) return m;
  }
  return null;
}
