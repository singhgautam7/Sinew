import 'dart:math';

import '../../core/models/enums.dart';
import '../../core/models/timer_preset.dart';
import 'cues.dart';
import 'timer_config.dart';

// PURE DART.

/// Everything the UI shows for a run at one instant, derived from timestamps.
class TimerSnapshot {
  const TimerSnapshot({
    required this.atMs,
    required this.stepIndex,
    required this.stepCount,
    required this.step,
    required this.stepElapsedMs,
    required this.stepDurationMs,
    required this.totalElapsedMs,
    required this.totalDurationMs,
    required this.finished,
    required this.stopped,
    required this.paused,
    required this.round,
    required this.roundCount,
    required this.amrapRounds,
    required this.endedAtMs,
  });

  /// The instant this snapshot describes (epoch ms).
  final int atMs;

  /// Index of the current step (the last step once finished).
  final int stepIndex;
  final int stepCount;

  /// Null only for a run with no steps.
  final TimerStepSpec? step;
  final int stepElapsedMs;

  /// Effective duration of the current step (after skips and +10 s), or null
  /// when it is open-ended.
  final int? stepDurationMs;

  /// Active time only: time spent paused never counts.
  final int totalElapsedMs;

  /// Effective total, or null while any step is open-ended.
  final int? totalDurationMs;

  /// True once every step is done or the run was stopped.
  final bool finished;

  /// True when [finished] because of [TimerRun.stop].
  final bool stopped;
  final bool paused;

  /// 1-based count of work steps reached so far (0 during prepare).
  final int round;

  /// Number of work steps in the run.
  final int roundCount;
  final int amrapRounds;

  /// Wall-clock end of the run once finished or stopped, else null.
  final int? endedAtMs;

  TimerPhase get phase => step?.phase ?? TimerPhase.open;

  int? get stepRemainingMs {
    final int? d = stepDurationMs;
    return d == null ? null : max(0, d - stepElapsedMs);
  }

  int? get totalRemainingMs {
    final int? d = totalDurationMs;
    return d == null ? null : max(0, d - totalElapsedMs);
  }

  /// 0..1 through the current step; 0 for an open-ended step.
  double get stepProgress {
    final int? d = stepDurationMs;
    if (d == null) return 0;
    if (d == 0) return 1;
    return (stepElapsedMs / d).clamp(0.0, 1.0);
  }

  /// 0..1 through the whole run; 0 while the total is unknown.
  double get totalProgress {
    final int? d = totalDurationMs;
    if (d == null) return 0;
    if (d == 0) return 1;
    return (totalElapsedMs / d).clamp(0.0, 1.0);
  }

  List<Object?> get _props => <Object?>[
    atMs,
    stepIndex,
    stepCount,
    step?.label,
    step?.phase,
    stepElapsedMs,
    stepDurationMs,
    totalElapsedMs,
    totalDurationMs,
    finished,
    stopped,
    paused,
    round,
    roundCount,
    amrapRounds,
    endedAtMs,
  ];

  @override
  bool operator ==(Object other) {
    if (other is! TimerSnapshot) return false;
    final List<Object?> a = _props;
    final List<Object?> b = other._props;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_props);

  @override
  String toString() =>
      'TimerSnapshot(step $stepIndex/$stepCount, ${step?.label}, '
      'elapsed $stepElapsedMs, total $totalElapsedMs, finished $finished)';
}

/// An immutable timer run. All time is derived from [startedAtMs], the paused
/// total and per-step adjustments, never from counting ticks, so a run
/// survives the UI being suspended or the process being killed: persist
/// [toJson], restore with [fromJson] and call [snapshotAt].
///
/// Timeline: steps run back to back in *active* time (wall time minus time
/// spent paused). A step's effective duration is its spec duration unless a
/// skip or `addTime` overrode it.
class TimerRun {
  const TimerRun._({
    required this.mode,
    required this.steps,
    required this.startedAtMs,
    this.pausedTotalMs = 0,
    this.pausedAtMs,
    this.endedAtMs,
    this.durationOverrides = const <int, int>{},
    this.amrapRounds = 0,
    this.locked = false,
  });

  static const int currentSchemaVersion = 1;

  /// Starts a run at [nowMs].
  factory TimerRun.start(
    List<TimerStepSpec> steps,
    int nowMs, {
    TimerMode mode = TimerMode.custom,
  }) => TimerRun._(
    mode: mode,
    steps: List<TimerStepSpec>.unmodifiable(steps),
    startedAtMs: nowMs,
  );

  /// A single rest step, reused by the workout rest timer.
  factory TimerRun.rest(int durationSec, int nowMs) => TimerRun.start(
    <TimerStepSpec>[
      TimerStepSpec(
        label: 'Rest',
        phase: TimerPhase.rest,
        durationMs: max(0, durationSec) * 1000,
      ),
    ],
    nowMs,
    mode: TimerMode.custom,
  );

  final TimerMode mode;
  final List<TimerStepSpec> steps;
  final int startedAtMs;

  /// Accumulated completed pauses.
  final int pausedTotalMs;

  /// Set while paused.
  final int? pausedAtMs;

  /// Set by [stop].
  final int? endedAtMs;

  /// Step index to effective duration (ms) for skipped or extended steps.
  final Map<int, int> durationOverrides;
  final int amrapRounds;
  final bool locked;

  bool get isPaused => pausedAtMs != null;

  TimerRun _copy({
    int? pausedTotalMs,
    Object? pausedAtMs = _keep,
    Object? endedAtMs = _keep,
    Map<int, int>? durationOverrides,
    int? amrapRounds,
    bool? locked,
  }) => TimerRun._(
    mode: mode,
    steps: steps,
    startedAtMs: startedAtMs,
    pausedTotalMs: pausedTotalMs ?? this.pausedTotalMs,
    pausedAtMs: identical(pausedAtMs, _keep)
        ? this.pausedAtMs
        : pausedAtMs as int?,
    endedAtMs: identical(endedAtMs, _keep) ? this.endedAtMs : endedAtMs as int?,
    durationOverrides: durationOverrides ?? this.durationOverrides,
    amrapRounds: amrapRounds ?? this.amrapRounds,
    locked: locked ?? this.locked,
  );

  /// Effective duration of step [i] in ms; null when open-ended.
  int? effectiveDurationMs(int i) =>
      durationOverrides[i] ?? steps[i].durationMs;

  /// Effective total in ms, or null while any step is open-ended.
  int? get effectiveTotalMs {
    int total = 0;
    for (int i = 0; i < steps.length; i++) {
      final int? d = effectiveDurationMs(i);
      if (d == null) return null;
      total += d;
    }
    return total;
  }

  int _activeAt(int nowMs) {
    final int ref = endedAtMs ?? pausedAtMs ?? nowMs;
    return max(0, ref - startedAtMs - pausedTotalMs);
  }

  /// Everything the UI needs at [nowMs].
  TimerSnapshot snapshotAt(int nowMs) {
    final int n = steps.length;
    final int active = _activeAt(nowMs);
    final int? total = effectiveTotalMs;
    int index = 0;
    int stepElapsed = 0;
    bool done = false;
    if (n == 0) {
      done = true;
    } else {
      int cum = 0;
      bool found = false;
      for (int i = 0; i < n; i++) {
        final int? d = effectiveDurationMs(i);
        if (d == null) {
          index = i;
          stepElapsed = active - cum;
          found = true;
          break;
        }
        if (active < cum + d) {
          index = i;
          stepElapsed = active - cum;
          found = true;
          break;
        }
        cum += d;
      }
      if (!found) {
        done = true;
        index = n - 1;
        stepElapsed = effectiveDurationMs(n - 1) ?? 0;
      }
    }
    final bool stopped = endedAtMs != null;
    final bool finished = done || stopped;
    int work = 0;
    int round = 0;
    for (int i = 0; i < n; i++) {
      if (steps[i].phase == TimerPhase.work) {
        work++;
        if (i <= index) round = work;
      }
    }
    final int totalElapsed = total == null ? active : min(active, total);
    int? ended = endedAtMs;
    if (ended == null && done) {
      ended = startedAtMs + pausedTotalMs + (total ?? 0);
    }
    return TimerSnapshot(
      atMs: nowMs,
      stepIndex: index,
      stepCount: n,
      step: n == 0 ? null : steps[index],
      stepElapsedMs: max(0, stepElapsed),
      stepDurationMs: n == 0 ? 0 : effectiveDurationMs(index),
      totalElapsedMs: totalElapsed,
      totalDurationMs: total,
      finished: finished,
      stopped: stopped,
      paused: isPaused,
      round: round,
      roundCount: work,
      amrapRounds: amrapRounds,
      endedAtMs: finished ? ended : null,
    );
  }

  /// Freezes the run; paused time never counts. No-op when already paused or
  /// ended.
  TimerRun pause(int nowMs) {
    if (isPaused || endedAtMs != null) return this;
    if (snapshotAt(nowMs).finished) return this;
    return _copy(pausedAtMs: nowMs);
  }

  TimerRun resume(int nowMs) {
    final int? p = pausedAtMs;
    if (p == null) return this;
    return _copy(
      pausedTotalMs: pausedTotalMs + max(0, nowMs - p),
      pausedAtMs: null,
    );
  }

  /// Ends the current step now; the next one starts immediately.
  TimerRun skip(int nowMs) {
    final TimerSnapshot s = snapshotAt(nowMs);
    if (s.finished) return this;
    return _copy(
      durationOverrides: <int, int>{
        ...durationOverrides,
        s.stepIndex: s.stepElapsedMs,
      },
    );
  }

  /// Extends the current timed step by [ms] (default +10 s). No-op on an open
  /// step or a finished run.
  TimerRun addTime(int nowMs, {int ms = 10000}) {
    final TimerSnapshot s = snapshotAt(nowMs);
    final int? d = s.stepDurationMs;
    if (s.finished || d == null) return this;
    return _copy(
      durationOverrides: <int, int>{
        ...durationOverrides,
        s.stepIndex: max(s.stepElapsedMs, d + ms),
      },
    );
  }

  /// Ends the run at [nowMs]. Active time is frozen at that moment (or at the
  /// pause, when stopped while paused).
  TimerRun stop(int nowMs) {
    if (endedAtMs != null) return this;
    if (snapshotAt(nowMs).finished) return this;
    final int? p = pausedAtMs;
    return _copy(
      pausedTotalMs: p == null ? pausedTotalMs : pausedTotalMs + (nowMs - p),
      pausedAtMs: null,
      endedAtMs: nowMs,
    );
  }

  TimerRun incrementRound() => _copy(amrapRounds: amrapRounds + 1);

  TimerRun decrementRound() => _copy(amrapRounds: max(0, amrapRounds - 1));

  TimerRun setLocked(bool value) => _copy(locked: value);

  // ---- cues -------------------------------------------------------------

  /// Absolute-time cue events with `fromMs <= atMs < toMs`, so the app can
  /// schedule them ahead (notifications, sounds) and have them fire even
  /// while the UI is suspended. A paused or stopped run yields none: the app
  /// reschedules on resume.
  ///
  /// Per timed step: a phase-start event (text is the step label), countdown
  /// ticks over the last `cues.countdownSec` seconds ("3", "2", "1"; only
  /// when the step is longer than the tick), and, for work steps, one
  /// warning `cues.warningSec` before the end (skipped when it would coincide
  /// with a countdown tick or the step is not longer). One finish event when
  /// the last step ends. Zero-length steps produce nothing.
  List<CueEvent> cuesBetween(int fromMs, int toMs, TimerCues cues) {
    if (isPaused || endedAtMs != null || toMs <= fromMs) {
      return const <CueEvent>[];
    }
    final List<CueEvent> out = <CueEvent>[];
    final int base = startedAtMs + pausedTotalMs;
    int cum = 0;
    void add(CueKind kind, int at, int step, String text) {
      if (at < fromMs || at >= toMs) return;
      out.add(
        CueEvent(
          kind: kind,
          atMs: at,
          stepIndex: step,
          text: text,
          sound: cues.sound,
          haptic: cues.haptic,
          voice: cues.voice && text.isNotEmpty,
        ),
      );
    }

    bool open = false;
    for (int i = 0; i < steps.length; i++) {
      final int? d = effectiveDurationMs(i);
      if (d == 0) continue;
      add(CueKind.phaseStart, base + cum, i, steps[i].label);
      if (d == null) {
        open = true;
        break;
      }
      for (int k = cues.countdownSec; k >= 1; k--) {
        if (d > k * 1000) {
          add(CueKind.countdown, base + cum + d - k * 1000, i, '$k');
        }
      }
      final int? w = cues.warningSec;
      if (w != null &&
          w > cues.countdownSec &&
          steps[i].phase == TimerPhase.work &&
          d > w * 1000) {
        add(CueKind.warning, base + cum + d - w * 1000, i, '$w seconds');
      }
      cum += d;
    }
    if (!open && steps.isNotEmpty && cum > 0) {
      add(CueKind.finish, base + cum, steps.length - 1, 'Done');
    }
    out.sort((CueEvent a, CueEvent b) {
      final int c = a.atMs.compareTo(b.atMs);
      return c != 0 ? c : a.stepIndex.compareTo(b.stepIndex);
    });
    return out;
  }

  // ---- persistence ------------------------------------------------------

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': currentSchemaVersion,
    'mode': mode.name,
    'startedAtMs': startedAtMs,
    'pausedTotalMs': pausedTotalMs,
    'pausedAtMs': pausedAtMs,
    'endedAtMs': endedAtMs,
    'amrapRounds': amrapRounds,
    'locked': locked,
    'overrides': <String, int>{
      for (final MapEntry<int, int> e in durationOverrides.entries)
        '${e.key}': e.value,
    },
    'steps': <Map<String, dynamic>>[
      for (final TimerStepSpec s in steps) stepToJson(s),
    ],
  };

  /// Restores a run written by [toJson]. A newer schema version or corrupt
  /// data returns null, never throws.
  static TimerRun? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final Object? v = json['schemaVersion'];
      if (v is! int || v > currentSchemaVersion || v < 1) return null;
      final Object? started = json['startedAtMs'];
      final Object? rawSteps = json['steps'];
      if (started is! num || rawSteps is! List<Object?>) return null;
      final List<TimerStepSpec> steps = <TimerStepSpec>[];
      for (final Object? s in rawSteps) {
        if (s is! Map<Object?, Object?>) return null;
        steps.add(stepFromJson(Map<String, dynamic>.from(s)));
      }
      final Map<int, int> overrides = <int, int>{};
      final Object? ov = json['overrides'];
      if (ov is Map<Object?, Object?>) {
        for (final MapEntry<Object?, Object?> e in ov.entries) {
          final int? k = int.tryParse('${e.key}');
          final Object? val = e.value;
          if (k == null || val is! num || k < 0 || k >= steps.length) {
            return null;
          }
          overrides[k] = val.toInt();
        }
      }
      int? oi(String k) {
        final Object? x = json[k];
        return x is num ? x.toInt() : null;
      }

      final Object? m = json['mode'];
      return TimerRun._(
        mode: enumByName(
          TimerMode.values,
          m is String ? m : null,
          TimerMode.custom,
        ),
        steps: List<TimerStepSpec>.unmodifiable(steps),
        startedAtMs: started.toInt(),
        pausedTotalMs: oi('pausedTotalMs') ?? 0,
        pausedAtMs: oi('pausedAtMs'),
        endedAtMs: oi('endedAtMs'),
        durationOverrides: Map<int, int>.unmodifiable(overrides),
        amrapRounds: max(0, oi('amrapRounds') ?? 0),
        locked: json['locked'] == true,
      );
    } on Object {
      return null;
    }
  }
}

const Object _keep = Object();
