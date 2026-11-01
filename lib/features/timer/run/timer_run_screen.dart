import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/routing/nav_visibility.dart';
import '../../../core/routing/router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/domain/timer_controls.dart';
import '../../../core/widgets/domain/timer_ring.dart';
import '../../../core/widgets/sinew_dialogs.dart';
import '../../../core/widgets/sinew_snackbar.dart';
import '../../../core/widgets/sinew_states.dart';
import '../../../engines/timer/timer_engine.dart';
import '../api/timer_api.dart';
import '../controller/timer_session.dart';
import '../data/active_timer.dart';
import 'amrap_view.dart';
import 'finished_view.dart';
import 'run_labels.dart';
import 'stopwatch_view.dart';

/// The running timer, full screen above the shell (no nav). Repaints from a
/// ticker but always reads the run at the clock's current instant, so it is
/// right after any pause in frames.
class TimerRunScreen extends ConsumerStatefulWidget {
  const TimerRunScreen({super.key});

  @override
  ConsumerState<TimerRunScreen> createState() => _TimerRunScreenState();
}

class _TimerRunScreenState extends ConsumerState<TimerRunScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final NavHideReasons _nav;
  late final ScreenWake _wake;
  int _shown = -1;
  int? _lastStep;
  int _lastAnnounceMs = 0;
  bool _busy = false;
  bool _leaving = false;

  TimerSession get _session => ref.read(timerSessionProvider.notifier);
  int _clock() => ref.read(timerNowMsProvider)();

  @override
  void initState() {
    super.initState();
    _nav = ref.read(navHideReasonsProvider.notifier);
    _wake = ref.read(screenWakeProvider);
    _ticker = createTicker(_onFrame)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _nav.hide(NavHideReason.runningTimer);
      _wake.keepOn(on: true);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    // Providers may not change while the tree is being torn down.
    Future<void>.microtask(() {
      try {
        _nav.show(NavHideReason.runningTimer);
      } on Object {
        // The whole app is going away; nothing left to show the nav on.
      }
      _wake.keepOn(on: false);
    });
    super.dispose();
  }

  void _onFrame(Duration _) {
    final int now = _clock();
    if (now == _shown) return;
    _shown = now;
    final ActiveTimer? a = ref.read(timerSessionProvider).value;
    if (a == null) return;
    final TimerSnapshot s = a.run.snapshotAt(now);
    _announce(a, s, now);
    // A paused or finished face does not change between frames: stop asking
    // for them (build starts the ticker again when the run moves).
    if (s.paused || s.finished) {
      _ticker.stop();
      setState(() {});
    } else {
      setState(() {});
    }
  }

  /// Tells a screen reader about a new step, and about the time left every
  /// so often. Never every second.
  void _announce(ActiveTimer a, TimerSnapshot s, int now) {
    if (!MediaQuery.accessibleNavigationOf(context)) return;
    String? text;
    if (s.finished) {
      if (_lastStep != -1) text = 'Timer finished';
      _lastStep = -1;
    } else if (_lastStep != s.stepIndex) {
      if (_lastStep != null) text = stepAnnouncement(a, s);
      _lastStep = s.stepIndex;
      _lastAnnounceMs = now;
    } else if (!s.paused &&
        now - _lastAnnounceMs >= TimerTiming.announceEvery.inMilliseconds) {
      final int? left = s.stepRemainingMs;
      if (left != null &&
          left > TimerTiming.announceEvery.inMilliseconds ~/ 2) {
        text = '${ClockText.spoken((left + 999) ~/ 1000)} left';
      }
      _lastAnnounceMs = now;
    }
    if (text == null || text.isEmpty) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      text,
      Directionality.of(context),
    );
  }

  void _leave() {
    if (_leaving || !mounted) return;
    _leaving = true;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.timer);
    }
  }

  Future<void> _confirmStop() async {
    final bool ok = await showSinewConfirmDialog(
      context: context,
      title: 'Stop the timer?',
      message: 'The timer ends now. You can still log what you did.',
      confirmLabel: 'Stop',
      destructive: true,
    );
    if (ok) _session.stop();
  }

  Future<void> _log() async {
    setState(() => _busy = true);
    final GoRouter router = GoRouter.of(context);
    try {
      final String id = await _session.logAsWorkout();
      if (!mounted) return;
      _leave();
      showSinewSnackBar(
        rootNavigatorKey.currentContext ?? context,
        'Workout logged.',
        actionLabel: 'View',
        onAction: () => router.go(Routes.session(id)),
      );
    } on Object {
      if (!mounted) return;
      setState(() => _busy = false);
      showSinewSnackBar(
        context,
        'Could not save the workout. Try again.',
        isError: true,
      );
    }
  }

  Future<void> _close() async {
    await _session.dismiss();
    _leave();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ActiveTimer?> async = ref.watch(timerSessionProvider);
    final ActiveTimer? a = async.value;
    if (a == null) {
      if (!async.isLoading) {
        // Nothing is running (it was closed elsewhere): go back.
        WidgetsBinding.instance.addPostFrameCallback((_) => _leave());
        return const Scaffold(body: SinewLoader());
      }
      return const Scaffold(body: Delayed(child: SinewLoader()));
    }
    final TimerSnapshot snap = a.run.snapshotAt(_clock());
    final bool locked = a.run.locked && !snap.finished;
    final bool moving = !snap.paused && !snap.finished;
    if (moving && !_ticker.isActive) _ticker.start();

    final Widget body;
    if (snap.finished) {
      body = FinishedView(
        timer: a,
        snapshot: snap,
        busy: _busy,
        onLog: _log,
        onClose: _close,
      );
    } else if (a.run.mode == TimerMode.stopwatch) {
      body = StopwatchView(
        timer: a,
        snapshot: snap,
        onLap: _session.lap,
        onToggle: _session.togglePause,
        onReset: _session.resetStopwatch,
        onClose: _confirmStop,
      );
    } else if (a.run.mode == TimerMode.amrap && snap.phase == TimerPhase.work) {
      body = AmrapView(
        timer: a,
        snapshot: snap,
        onTogglePause: _session.togglePause,
        onAddRound: _session.addRound,
        onUndoRound: _session.undoRound,
        onLock: () => _session.setLocked(true),
        onUnlock: () => _session.setLocked(false),
        onStop: _confirmStop,
      );
    } else {
      body = _phaseField(a, snap);
    }
    return PopScope(
      canPop: !locked,
      child: Scaffold(body: body),
    );
  }

  Widget _phaseField(ActiveTimer a, TimerSnapshot snap) {
    final bool locked = a.run.locked;
    final bool yoga = a.run.mode == TimerMode.yogaFlow;
    final bool timed = snap.stepDurationMs != null;
    final SinewPhase phase = sinewPhaseOf(snap.phase);
    final bool yogaPose = yoga && snap.phase == TimerPhase.work;
    return PhaseField(
      snapshot: snap,
      title: a.title,
      trailing: trailingLabel(a, snap),
      heading: yogaPose ? snap.step?.label : null,
      label: yogaPose && snap.stepDurationMs != null
          ? 'hold of ${ClockText.format(snap.stepDurationMs! ~/ 1000)}'
          : null,
      nextLabel: locked ? null : nextLabel(a, snap),
      warningSec: a.cues.warningSec,
      controls: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TimerControls(
            phase: phase,
            paused: snap.paused,
            locked: locked,
            onPlayPause: _session.togglePause,
            onLock: () => _session.setLocked(true),
            onUnlock: () => _session.setLocked(false),
            onAddTime: timed ? _session.addTime : null,
            onSkip: _session.skip,
          ),
          const SizedBox(height: Space.md),
          if (locked)
            Text(
              'Controls are locked. Hold the lock for 1 second to unlock.',
              textAlign: TextAlign.center,
              style: context.text.bodyLarge,
            )
          else
            Center(
              child: _StopPill(phase: phase, onTap: _confirmStop),
            ),
        ],
      ),
    );
  }
}

/// A quiet "Stop" under the controls, in the phase colours.
class _StopPill extends StatelessWidget {
  const _StopPill({required this.phase, required this.onTap});

  final SinewPhase phase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PhaseColor c = context.accents.phase(phase);
    return Semantics(
      button: true,
      label: 'Stop the timer',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: c.on.withValues(alpha: TimerSpec.secondaryFillOpacity),
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: IconSpec.tapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.xl),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.stop_rounded, size: IconSpec.size, color: c.on),
                  const SizedBox(width: Space.sm),
                  Text(
                    'Stop',
                    style: context.text.titleMedium!.copyWith(color: c.on),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
