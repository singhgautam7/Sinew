import 'dart:convert';

import '../../../core/models/enums.dart';
import '../../../core/models/timer_preset.dart';
import '../../../core/widgets/domain/timer_ring.dart' show ClockText;
import '../../../engines/timer/timer_engine.dart';
import '../data/active_timer.dart';

// What the app and the background service say to each other. Kept free of
// plugin calls so the content and the messages can be unit tested.

/// Where the service keeps its copy of the run (the plugin's own storage, so
/// it survives the app's isolate being gone).
const String kServiceStateKey = 'sinew.timer.state';

/// Set once the notification permission was asked for, so the prompt appears
/// at the first timer start and not on every start after.
const String kNotificationAskedKey = 'sinew.timer.notificationAsked';

/// The manifest meta-data name of the monochrome notification icon.
const String kNotificationIconMeta = 'com.grs.sinew.service.TIMER_ICON';

/// The id of the foreground service notification.
const int kServiceId = 4601;

/// Message kinds. App to service: [msgState], [msgHeartbeat]. Service to
/// app: [msgState] (a notification button changed the run), [msgFinished].
const String msgState = 'state';
const String msgHeartbeat = 'hb';
const String msgFinished = 'finished';

/// Notification button ids.
const String btnToggle = 'toggle';
const String btnSkip = 'skip';
const String btnAdd = 'add';

Map<String, Object?> stateMessage(String json) => <String, Object?>{
  't': msgState,
  'json': json,
};

const Map<String, Object?> heartbeatMessage = <String, Object?>{
  't': msgHeartbeat,
};

String encodeState(ActiveTimer a) => jsonEncode(a.toJson());

ActiveTimer? decodeState(Object? raw) {
  if (raw is! String) return null;
  try {
    final Object? j = jsonDecode(raw);
    return j is Map<String, dynamic> ? ActiveTimer.fromJson(j) : null;
  } on Object {
    return null;
  }
}

/// What the ongoing notification shows.
class NotificationContent {
  const NotificationContent({
    required this.title,
    required this.text,
    required this.buttons,
  });

  final String title;
  final String text;

  /// `(id, label)` pairs, at most three.
  final List<(String, String)> buttons;

  @override
  bool operator ==(Object other) =>
      other is NotificationContent &&
      other.title == title &&
      other.text == text &&
      other.buttons.length == buttons.length &&
      Iterable<int>.generate(buttons.length)
          .every((int i) => buttons[i] == other.buttons[i]);

  @override
  int get hashCode => Object.hash(title, text, buttons.length);
}

String _phaseWord(TimerPhase p) => switch (p) {
  TimerPhase.work => 'Work',
  TimerPhase.rest || TimerPhase.roundRest => 'Rest',
  TimerPhase.prepare => 'Get ready',
  TimerPhase.cooldown => 'Cool down',
  TimerPhase.open => 'Running',
};

String _stepLine(TimerStepSpec s, int? durationMs) {
  final String word = _phaseWord(s.phase);
  final String label = s.label.toLowerCase() == word.toLowerCase()
      ? word
      : s.label;
  return durationMs == null
      ? label
      : '$label ${ClockText.format((durationMs / 1000).round())}';
}

/// The notification for [a] at [nowMs]: phase and round on the first line,
/// the time left, the run's title and what is next on the second.
NotificationContent notificationContent(ActiveTimer a, int nowMs) {
  final TimerRun run = a.run;
  final TimerSnapshot s = run.snapshotAt(nowMs);
  if (s.finished) {
    return NotificationContent(
      title: 'Done',
      text: a.title,
      buttons: const <(String, String)>[],
    );
  }
  final String word = switch (s.phase) {
    TimerPhase.open => s.step?.label ?? a.title,
    _ =>
      s.step != null && s.phase == TimerPhase.work && s.roundCount > 1
          ? '${_phaseWord(s.phase)}, round ${s.round} of ${s.roundCount}'
          : _phaseWord(s.phase),
  };
  final int? left = s.stepRemainingMs;
  final String clock = left == null
      ? ClockText.format(s.stepElapsedMs ~/ 1000)
      : ClockText.format((left + 999) ~/ 1000);
  final bool hasNext = s.stepIndex + 1 < run.steps.length;
  final String next = hasNext
      ? ', next: ${_stepLine(run.steps[s.stepIndex + 1], run.effectiveDurationMs(s.stepIndex + 1)).toLowerCase()}'
      : '';
  final bool timed = left != null;
  return NotificationContent(
    title: s.paused ? 'Paused, $word' : word,
    text: '${a.title}, $clock${timed ? ' left' : ''}$next',
    buttons: <(String, String)>[
      (btnToggle, s.paused ? 'Resume' : 'Pause'),
      if (run.steps.length > 1 || timed) (btnSkip, 'Skip'),
      if (timed) (btnAdd, '+10s'),
    ],
  );
}

/// Applies a notification button to [a] at [nowMs]. Returns null when the
/// button does nothing (the run is over).
ActiveTimer? applyButton(ActiveTimer a, String id, int nowMs) {
  final TimerRun run = a.run;
  if (run.snapshotAt(nowMs).finished) return null;
  final TimerRun next = switch (id) {
    btnToggle => run.isPaused ? run.resume(nowMs) : run.pause(nowMs),
    btnSkip => run.skip(nowMs),
    btnAdd => run.addTime(nowMs),
    _ => run,
  };
  if (identical(next, run)) return null;
  return a.copyWith(run: next, updatedAtMs: nowMs);
}
