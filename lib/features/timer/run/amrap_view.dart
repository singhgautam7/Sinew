import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/domain/timer_controls.dart';
import '../../../core/widgets/domain/timer_ring.dart';
import '../../../engines/timer/timer_engine.dart';
import '../data/active_timer.dart';

/// AMRAP: the time left on top, a big surface that counts a round wherever
/// it is tapped, and the controls under it.
class AmrapView extends StatelessWidget {
  const AmrapView({
    super.key,
    required this.timer,
    required this.snapshot,
    required this.progress,
    required this.onTogglePause,
    required this.onAddRound,
    required this.onUndoRound,
    required this.onLock,
    required this.onUnlock,
    required this.onStop,
  });

  final ActiveTimer timer;
  final TimerSnapshot snapshot;

  /// Fraction of the cap already used, every frame. Only the bar listens.
  final ValueListenable<double> progress;
  final VoidCallback onTogglePause;
  final VoidCallback onAddRound;
  final VoidCallback onUndoRound;
  final VoidCallback onLock;
  final VoidCallback onUnlock;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final PhaseColor c = context.accents.phase(SinewPhase.work);
    final TextTheme tt = context.text;
    final int? left = snapshot.stepRemainingMs;
    final int seconds = left == null
        ? snapshot.stepElapsedMs ~/ 1000
        : (left + 999) ~/ 1000;
    final bool locked = timer.run.locked;
    final bool paused = snapshot.paused;
    return ColoredBox(
      color: c.field,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: c.on),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TimerSpec.topBarPadH,
                  vertical: TimerSpec.topBarPadV,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        timer.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium!.copyWith(color: c.on),
                      ),
                    ),
                    Text(
                      paused ? 'Paused' : (left == null ? 'Time' : 'Time left'),
                      style: tt.titleMedium!.copyWith(color: c.on),
                    ),
                  ],
                ),
              ),
              Semantics(
                container: true,
                label:
                    '${ClockText.spoken(seconds)}'
                    '${left == null ? ' elapsed' : ' left'}'
                    '${paused ? ', paused' : ''}',
                child: ExcludeSemantics(
                  child: Column(
                    children: <Widget>[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          ClockText.format(seconds),
                          maxLines: 1,
                          style: context.timerNumeral.copyWith(
                            fontSize: TimerUi.amrapClock,
                            letterSpacing: TimerUi.amrapClockTracking,
                            color: c.on,
                          ),
                        ),
                      ),
                      if (left != null)
                        Padding(
                          padding: const EdgeInsets.only(top: Space.md),
                          child: SizedBox(
                            width: TimerUi.amrapBarWidth,
                            height: TimerUi.amrapBarHeight,
                            child: ClipRRect(
                              borderRadius: Radii.fullR,
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  ColoredBox(
                                    color: c.on.withValues(
                                      alpha: TimerSpec.trackOpacity,
                                    ),
                                  ),
                                  ValueListenableBuilder<double>(
                                    valueListenable: progress,
                                    builder:
                                        (
                                          BuildContext _,
                                          double left,
                                          Widget? _,
                                        ) => FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: (1 - left).clamp(
                                            0.0,
                                            1.0,
                                          ),
                                          child: ColoredBox(color: c.ring),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    Space.screen,
                    Space.xl,
                    Space.screen,
                    Space.lg,
                  ),
                  child: AmrapCounter(
                    phase: SinewPhase.work,
                    rounds: snapshot.amrapRounds,
                    onAdd: locked || paused ? () {} : onAddRound,
                    onUndo: locked || paused ? () {} : onUndoRound,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: Space.screen,
                  right: Space.screen,
                  bottom: Space.xl,
                ),
                child: TimerControls(
                  phase: SinewPhase.work,
                  paused: paused,
                  locked: locked,
                  onPlayPause: onTogglePause,
                  onLock: onLock,
                  onUnlock: onUnlock,
                  onStop: onStop,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
