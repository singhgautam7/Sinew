import '../../../core/models/enums.dart';
import '../../../core/models/timer_preset.dart';
import '../../../core/widgets/domain/timer_ring.dart' show ClockText;
import '../../../engines/timer/timer_engine.dart';
import '../data/active_timer.dart';

// Wording on the run screen, as pure functions of the run.

String phaseWord(TimerPhase p) => switch (p) {
  TimerPhase.work => 'Work',
  TimerPhase.rest || TimerPhase.roundRest => 'Rest',
  TimerPhase.prepare => 'Get ready',
  TimerPhase.cooldown => 'Cool down',
  TimerPhase.open => 'Running',
};

/// The chip under the ring: "Next: Rest 0:10", or null on the last step.
String? nextLabel(ActiveTimer a, TimerSnapshot s) {
  final int next = s.stepIndex + 1;
  if (next >= a.run.steps.length) return null;
  // A step skipped to zero length is not worth announcing.
  final TimerStepSpec spec = a.run.steps[next];
  final int? d = a.run.effectiveDurationMs(next);
  final String name = _nextName(spec);
  if (d == null) return 'Next: $name';
  return 'Next: $name ${ClockText.format((d / 1000).round())}';
}

String _nextName(TimerStepSpec s) {
  final String word = phaseWord(s.phase);
  // "Work" for a step literally called Work, the label otherwise.
  return s.label.toLowerCase() == word.toLowerCase() ? word : s.label;
}

/// The right-hand text of the top bar while running.
String? trailingLabel(ActiveTimer a, TimerSnapshot s) {
  final int? left = s.totalRemainingMs;
  if (left == null) return null;
  return '${ClockText.format((left + 999) ~/ 1000)} left';
}

/// Laps, then the lap number in the order the frame shows: newest first.
String lapText(int ms) {
  final int total = ms ~/ 10;
  final int cs = total % 100;
  final int sec = (total ~/ 100);
  return '${ClockText.format(sec)}.${cs.toString().padLeft(2, '0')}';
}

/// What the screen reader hears when the step changes.
String stepAnnouncement(ActiveTimer a, TimerSnapshot s) {
  final TimerStepSpec? step = s.step;
  if (step == null) return '';
  final String word = phaseWord(step.phase);
  final String label = step.label.toLowerCase() == word.toLowerCase()
      ? word
      : '$word, ${step.label}';
  final int? left = s.stepRemainingMs;
  return left == null
      ? label
      : '$label, ${ClockText.spoken((left + 999) ~/ 1000)}';
}
