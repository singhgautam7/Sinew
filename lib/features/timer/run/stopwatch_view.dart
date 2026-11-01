import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../core/widgets/domain/timer_ring.dart';
import '../../../core/widgets/sinew_list.dart';
import '../../../engines/timer/timer_engine.dart';
import '../data/active_timer.dart';
import 'run_labels.dart';

/// The stopwatch: a big numeral with hundredths, a list of laps, and Lap,
/// Pause and Reset under it. Drawn on the plain surface, not a phase field.
class StopwatchView extends StatelessWidget {
  const StopwatchView({
    super.key,
    required this.timer,
    required this.snapshot,
    required this.onLap,
    required this.onToggle,
    required this.onReset,
    required this.onClose,
  });

  final ActiveTimer timer;
  final TimerSnapshot snapshot;
  final VoidCallback onLap;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final int ms = snapshot.totalElapsedMs;
    final String main = ClockText.format(ms ~/ 1000);
    final String centis = (ms ~/ 10 % 100).toString().padLeft(2, '0');
    final List<({int number, int splitMs, int cumulativeMs})> laps = timer
        .lapRows
        .reversed
        .toList();
    final bool paused = snapshot.paused;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md,
                vertical: Space.sm,
              ),
              child: Row(
                children: <Widget>[
                  AppIconButton(
                    icon: Icons.close_rounded,
                    semanticLabel: 'Stop and close',
                    kind: AppIconButtonKind.tonal,
                    onPressed: onClose,
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      timer.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: TimerUi.stopwatchTop,
                bottom: Space.xl,
              ),
              child: Semantics(
                label:
                    '${ClockText.spoken(ms ~/ 1000)}'
                    '${paused ? ', paused' : ''}',
                child: ExcludeSemantics(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      children: <Widget>[
                        Text(
                          main,
                          maxLines: 1,
                          style: context.timerNumeral.copyWith(
                            fontSize: TimerUi.stopwatchNumeral,
                            letterSpacing: TimerUi.stopwatchTracking,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          '.$centis',
                          style: context.text.headlineMedium!.copyWith(
                            fontSize: TimerUi.stopwatchCentis,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: laps.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.screen,
                      ),
                      child: SinewGroup(
                        children: <Widget>[
                          for (final lap in laps)
                            _LapRow(
                              number: lap.number,
                              split: lapText(lap.splitMs),
                              total: ClockText.format(lap.cumulativeMs ~/ 1000),
                            ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.md,
                Space.screen,
                Space.xl,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _TextCircle(label: 'Lap', onTap: paused ? null : onLap),
                  const SizedBox(width: Space.md),
                  _PrimaryButton(paused: paused, onTap: onToggle),
                  const SizedBox(width: Space.md),
                  _TextCircle(label: 'Reset', onTap: onReset),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LapRow extends StatelessWidget {
  const _LapRow({
    required this.number,
    required this.split,
    required this.total,
  });

  final int number;
  final String split;
  final String total;

  @override
  Widget build(BuildContext context) {
    final TextStyle muted = context.text.bodyMedium!.copyWith(
      color: context.cs.onSurfaceVariant,
    );
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.md,
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: Space.xxxl + Space.xl,
              child: Text('Lap $number', style: muted),
            ),
            Expanded(
              child: Text(
                split,
                style: context.text.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(total, style: muted),
          ],
        ),
      ),
    );
  }
}

class _TextCircle extends StatelessWidget {
  const _TextCircle({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final bool live = onTap != null;
    return Semantics(
      button: true,
      enabled: live,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Opacity(
        opacity: live ? 1 : Opacities.disabled,
        child: Material(
          color: cs.secondaryContainer,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: TimerUi.lapButton,
              height: TimerUi.lapButton,
              child: Center(
                child: Text(
                  label,
                  style: context.text.titleMedium!.copyWith(
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.paused, required this.onTap});

  final bool paused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Semantics(
      button: true,
      label: paused ? 'Resume' : 'Pause',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: cs.primary,
        borderRadius: BorderRadius.circular(
          paused ? SinewSpace.timerControl / 2 : SinewShape.timerPrimary,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: SizedBox(
            width: SinewSpace.timerControl,
            height: SinewSpace.timerControl,
            child: Icon(
              paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: TimerSpec.primaryIcon,
              color: cs.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
