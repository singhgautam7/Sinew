import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/ids.dart';
import '../../../core/db/repositories/runtime_state_repository.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/timer_preset.dart';
import '../../../core/models/training.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../engines/timer/timer_engine.dart';
import '../api/timer_api.dart';
import '../data/active_timer.dart';
import '../services/cue_player_impl.dart';

/// Epoch milliseconds now. The one clock the timer feature reads, so tests
/// can replace it with a fake and move time by hand.
final Provider<int Function()> timerNowMsProvider = Provider<int Function()>(
  (Ref ref) =>
      () => DateTime.now().millisecondsSinceEpoch,
);

/// A run that finished or was stopped this long ago is dropped on restore
/// rather than offered for logging.
const int _staleFinishedMs = 2 * 60 * 60 * 1000;

/// The timer the user started, if there is one: restored on app start,
/// persisted after every control, cued by timestamps.
///
/// State is [AsyncValue] because restoring reads the database. A `null` value
/// means no timer. A value whose run is finished or stopped is the summary
/// the user can log or close.
class TimerSession extends AsyncNotifier<ActiveTimer?> {
  Timer? _ticker;
  StreamSubscription<ActiveTimer>? _remote;
  Future<void> _persistChain = Future<void>.value();
  int _lastCueMs = 0;
  bool _finishHandled = false;

  int _now() => ref.read(timerNowMsProvider)();

  ActiveTimer? get active => state.value;

  RuntimeStateRepository get _runtime =>
      ref.read(runtimeStateRepositoryProvider);

  @override
  Future<ActiveTimer?> build() async {
    ref.onDispose(() {
      _ticker?.cancel();
      _remote?.cancel();
    });
    _remote = ref.read(timerServiceLinkProvider).changes.listen(_onRemote);
    return _restore();
  }

  // ---- starting and restoring -------------------------------------------

  /// Starts [config] now, replacing any timer that was running.
  Future<void> start(
    TimerConfig config, {
    required String title,
    TimerCues? cues,
    String? presetId,
  }) async {
    final int now = _now();
    final ActiveTimer a = ActiveTimer(
      run: TimerRun.start(compile(config), now, mode: config.mode),
      cues: cues ?? config.defaultCues,
      title: title,
      updatedAtMs: now,
      config: config,
      presetId: presetId,
    );
    _finishHandled = false;
    _lastCueMs = a.run.startedAtMs;
    await _commit(a);
  }

  Future<ActiveTimer?> _restore() async {
    ActiveTimer? a;
    try {
      final Map<String, dynamic>? json = await _runtime.read(
        RuntimeStateRepository.runningTimer,
      );
      a = ActiveTimer.fromJson(json);
      if (a == null) {
        if (json != null) {
          await _runtime.clear(RuntimeStateRepository.runningTimer);
        }
        return null;
      }
      final ActiveTimer? saved = await ref
          .read(timerServiceLinkProvider)
          .readSaved();
      if (saved != null &&
          a.sameRunAs(saved.run) &&
          saved.updatedAtMs > a.updatedAtMs) {
        a = a.copyWith(
          run: saved.run,
          cues: saved.cues,
          title: saved.title,
          updatedAtMs: saved.updatedAtMs,
        );
      }
    } on Object catch (e) {
      debugPrint('Sinew timer restore failed: $e');
      return null;
    }

    final int now = _now();
    final TimerSnapshot s = a.run.snapshotAt(now);
    if (s.finished) {
      final int endedAt = s.endedAtMs ?? now;
      if (now - endedAt > _staleFinishedMs) {
        await _runtime.clear(RuntimeStateRepository.runningTimer);
        return null;
      }
      // Finished while the app was away: the summary is still worth showing.
      _finishHandled = true;
      await _runtime.clear(RuntimeStateRepository.runningTimer);
      unawaited(_quietly(ref.read(backgroundTimerHostProvider).clear()));
      return a;
    }
    _finishHandled = false;
    _lastCueMs = now;
    // The run is still going: re-establish the service and the tick.
    scheduleMicrotask(() {
      if (ref.mounted && active != null) {
        _syncHost(active!);
        _ensureTicker();
      }
    });
    return a;
  }

  /// Merges what the background service holds, for when the app comes back
  /// to the foreground after a notification button changed the run.
  Future<void> syncFromService() async {
    final ActiveTimer? a = active;
    if (a == null) return;
    final ActiveTimer? saved = await ref
        .read(timerServiceLinkProvider)
        .readSaved();
    if (saved != null) _onRemote(saved);
    tick();
  }

  void _onRemote(ActiveTimer remote) {
    final ActiveTimer? a = active;
    if (a == null || !a.sameRunAs(remote.run)) return;
    if (remote.updatedAtMs <= a.updatedAtMs) return;
    final ActiveTimer next = a.copyWith(
      run: remote.run,
      cues: remote.cues,
      updatedAtMs: remote.updatedAtMs,
    );
    if (a.run.isPaused && !next.run.isPaused) _lastCueMs = _now();
    state = AsyncData<ActiveTimer?>(next);
    _persist(next);
    _ensureTicker();
  }

  // ---- controls ---------------------------------------------------------

  void togglePause() {
    final ActiveTimer? a = _live();
    if (a == null) return;
    final int now = _now();
    final TimerRun run = a.run.isPaused ? a.run.resume(now) : a.run.pause(now);
    if (a.run.isPaused) _lastCueMs = now;
    unawaited(_commit(a.copyWith(run: run, updatedAtMs: now)));
  }

  void skip() => _change((TimerRun r, int now) => r.skip(now));

  void addTime() => _change((TimerRun r, int now) => r.addTime(now));

  void setLocked(bool locked) =>
      _change((TimerRun r, int now) => r.setLocked(locked));

  void addRound() => _change((TimerRun r, int now) => r.incrementRound());

  void undoRound() => _change((TimerRun r, int now) => r.decrementRound());

  /// Ends the run now. The summary stays so it can be logged or closed.
  void stop() {
    final ActiveTimer? a = _live();
    if (a == null) return;
    final int now = _now();
    unawaited(_commit(a.copyWith(run: a.run.stop(now), updatedAtMs: now)));
  }

  /// Stopwatch: records a lap at the elapsed time.
  void lap() {
    final ActiveTimer? a = _live();
    if (a == null || a.run.isPaused) return;
    final int now = _now();
    final int elapsed = a.run.snapshotAt(now).totalElapsedMs;
    unawaited(
      _commit(
        a.copyWith(laps: <int>[...a.laps, elapsed], updatedAtMs: now),
        host: false,
      ),
    );
  }

  /// Stopwatch: starts over from zero, dropping the laps.
  void resetStopwatch() {
    final ActiveTimer? a = _live();
    if (a == null) return;
    final int now = _now();
    _lastCueMs = now;
    unawaited(
      _commit(
        ActiveTimer(
          run: TimerRun.start(a.run.steps, now, mode: a.run.mode),
          cues: a.cues,
          title: a.title,
          updatedAtMs: now,
          config: a.config,
          presetId: a.presetId,
        ),
      ),
    );
  }

  void _change(TimerRun Function(TimerRun run, int nowMs) f) {
    final ActiveTimer? a = _live();
    if (a == null) return;
    final int now = _now();
    final TimerRun next = f(a.run, now);
    if (identical(next, a.run)) return;
    unawaited(_commit(a.copyWith(run: next, updatedAtMs: now)));
  }

  /// The active timer if it is still running (not finished or stopped).
  ActiveTimer? _live() {
    final ActiveTimer? a = active;
    if (a == null || _finishHandled) return null;
    if (a.run.snapshotAt(_now()).finished) return null;
    return a;
  }

  // ---- finishing --------------------------------------------------------

  /// Saves the finished or stopped timer as a workout, then closes it.
  /// Returns the new session's id.
  Future<String> logAsWorkout() async {
    final ActiveTimer a = active!;
    final int now = _now();
    final TimerSnapshot end = a.run.snapshotAt(now);
    final WorkoutSession session = sessionFromRun(
      a.run,
      end,
      name: a.title,
      newId: newId,
    );
    await ref.read(sessionRepositoryProvider).saveTree(session);
    await dismiss();
    return session.id;
  }

  /// Closes the timer without logging it.
  Future<void> dismiss() async {
    _ticker?.cancel();
    _ticker = null;
    _finishHandled = true;
    state = const AsyncData<ActiveTimer?>(null);
    final RuntimeStateRepository repo = _runtime;
    final BackgroundTimerHost host = ref.read(backgroundTimerHostProvider);
    await _persistChain;
    await _quietly(repo.clear(RuntimeStateRepository.runningTimer));
    await _quietly(host.clear());
  }

  // ---- the cue tick -----------------------------------------------------

  /// Plays every cue due since the last look and notices when the run ends.
  /// Runs on a 100 ms timer while a run is live; tests call it directly.
  /// Cues come from timestamps, so a late call never plays a stale burst: a
  /// cue older than [TimerTiming.staleCueMs] is dropped (the background
  /// service played it).
  void tick([int? nowMs]) {
    final ActiveTimer? a = active;
    if (a == null) return;
    final int now = nowMs ?? _now();
    final TimerRun run = a.run;
    if (run.endedAtMs == null && !run.isPaused) {
      final int from = math.max(_lastCueMs, now - TimerTiming.staleCueMs);
      for (final CueEvent e in run.cuesBetween(from, now + 1, a.cues)) {
        _play(e, run, a.cues);
      }
    }
    _lastCueMs = now + 1;
    if (!_finishHandled && run.snapshotAt(now).finished) _onFinished();
  }

  void _play(CueEvent e, TimerRun run, TimerCues cues) {
    final CuePlayer player = ref.read(cuePlayerProvider);
    final TimerPhase phase = e.stepIndex < run.steps.length
        ? run.steps[e.stepIndex].phase
        : TimerPhase.work;
    final Future<void> f = player is PhaseCuePlayer
        ? player.playForPhase(e, cues, phase)
        : player.play(e, cues);
    unawaited(_quietly(f));
  }

  void _onFinished() {
    _finishHandled = true;
    _ticker?.cancel();
    _ticker = null;
    unawaited(_quietly(_runtime.clear(RuntimeStateRepository.runningTimer)));
    unawaited(_quietly(ref.read(backgroundTimerHostProvider).clear()));
    // Rebuild listeners: the run is over.
    final ActiveTimer? a = active;
    if (a != null) state = AsyncData<ActiveTimer?>(a);
  }

  void _ensureTicker() {
    if (_ticker != null || _finishHandled) return;
    _ticker = Timer.periodic(TimerTiming.cueTick, (Timer _) => tick());
  }

  // ---- plumbing ---------------------------------------------------------

  Future<void> _commit(ActiveTimer a, {bool host = true}) async {
    state = AsyncData<ActiveTimer?>(a);
    final bool over = a.run.snapshotAt(_now()).finished;
    if (over) {
      // Stopped by hand (or finished on this very call).
      tick();
      if (!_finishHandled) _onFinished();
      return;
    }
    _persist(a);
    if (host) _syncHost(a);
    _ensureTicker();
  }

  void _persist(ActiveTimer a) {
    // Capture now: the provider may be gone by the time the write runs.
    final RuntimeStateRepository repo = _runtime;
    final Map<String, dynamic> json = a.toJson();
    _persistChain = _persistChain.then(
      (_) => _quietly(repo.write(RuntimeStateRepository.runningTimer, json)),
    );
  }

  void _syncHost(ActiveTimer a) {
    unawaited(
      _quietly(
        ref
            .read(backgroundTimerHostProvider)
            .show(a.run, a.cues, title: a.title),
      ),
    );
  }

  /// Waits for the last write to the database. For tests and shutdown.
  Future<void> flush() => _persistChain;

  Future<void> _quietly(Future<void> f) async {
    try {
      await f;
    } on Object catch (e) {
      debugPrint('Sinew timer: $e');
    }
  }
}

final AsyncNotifierProvider<TimerSession, ActiveTimer?> timerSessionProvider =
    AsyncNotifierProvider<TimerSession, ActiveTimer?>(TimerSession.new);

/// True while a timer is running or paused (not finished, not stopped), for
/// the "Running" banner on the Timer home.
final Provider<bool> timerRunningProvider = Provider<bool>((Ref ref) {
  final ActiveTimer? a = ref.watch(timerSessionProvider).value;
  if (a == null) return false;
  final int now = ref.read(timerNowMsProvider)();
  return !a.run.snapshotAt(now).finished;
});
