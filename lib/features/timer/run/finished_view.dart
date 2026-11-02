import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/timer_preset.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/domain/timer_ring.dart';
import '../../../core/widgets/sinew_list.dart';
import '../../../engines/timer/timer_engine.dart';
import '../data/active_timer.dart';

/// What a finished or stopped timer shows: a check, three numbers, the
/// timeline of its steps and the two ways out.
class FinishedView extends StatelessWidget {
  const FinishedView({
    super.key,
    required this.timer,
    required this.snapshot,
    required this.busy,
    required this.onLog,
    required this.onClose,
  });

  final ActiveTimer timer;
  final TimerSnapshot snapshot;
  final bool busy;
  final VoidCallback onLog;
  final VoidCallback onClose;

  /// Work steps the run got through.
  int get _workDone {
    int n = 0;
    final int upTo = snapshot.stopped
        ? snapshot.stepIndex
        : timer.run.steps.length;
    for (int i = 0; i < upTo && i < timer.run.steps.length; i++) {
      if (timer.run.steps[i].phase == TimerPhase.work) n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final bool stopped = snapshot.stopped;
    final bool amrap = timer.run.mode == TimerMode.amrap;
    final bool stopwatch = timer.run.mode == TimerMode.stopwatch;
    final List<(String, String)> stats = <(String, String)>[
      (ClockText.format(snapshot.totalElapsedMs ~/ 1000), 'Total'),
      if (amrap)
        ('${snapshot.amrapRounds}', 'Rounds')
      else if (stopwatch)
        ('${timer.laps.length}', 'Laps')
      else
        ('$_workDone', 'Work rounds'),
      (
        snapshot.totalDurationMs == null
            ? 'Open'
            : ClockText.format(snapshot.totalDurationMs! ~/ 1000),
        'Planned',
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.xxxl,
                  Space.screen,
                  Space.lg,
                ),
                children: <Widget>[
                  Semantics(
                    container: true,
                    label:
                        '${stopped ? 'Stopped' : 'Done'}, ${timer.title}, '
                        '${stats.first.$1} total',
                    child: ExcludeSemantics(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: TimerSpec.finishedDisc,
                            height: TimerSpec.finishedDisc,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: TimerSpec.finishedGlyph,
                              color: cs.onPrimary,
                            ),
                          ),
                          const SizedBox(height: Space.md),
                          Text(
                            stopped ? 'Stopped' : 'Done. Nice work.',
                            style: tt.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Space.xs),
                          Text(
                            timer.title,
                            style: tt.bodyMedium!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (int i = 0; i < stats.length; i++) ...<Widget>[
                          if (i > 0) const SizedBox(width: TimerUi.tileGap),
                          Expanded(
                            child: _StatTile(
                              value: stats[i].$1,
                              label: stats[i].$2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!stopwatch) ...<Widget>[
                    const SizedBox(height: Space.md),
                    _Timeline(timer: timer),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                0,
                Space.screen,
                Space.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppButton(
                    label: 'Log as workout',
                    icon: Icons.edit_note_rounded,
                    type: AppButtonType.primary,
                    fullWidth: true,
                    isLoading: busy,
                    onPressed: onLog,
                  ),
                  const SizedBox(height: Space.row),
                  AppButton(
                    label: 'Close',
                    type: AppButtonType.outline,
                    fullWidth: true,
                    onPressed: busy ? null : onClose,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: SinewCard(
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: context.text.titleLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              label,
              style: context.text.bodySmall!.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.timer});

  final ActiveTimer timer;

  @override
  Widget build(BuildContext context) {
    final List<TimerStepSpec> steps = timer.run.steps;
    if (steps.isEmpty) return const SizedBox.shrink();
    return SinewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Timeline', style: context.text.titleSmall),
          const SizedBox(height: Space.sm),
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: Radii.chipR,
              child: SizedBox(
                height: TimerUi.timelineHeight,
                child: Row(
                  children: <Widget>[
                    for (int i = 0; i < steps.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: TimerUi.timelineGap),
                      Expanded(
                        flex: _flex(timer.run.effectiveDurationMs(i)),
                        child: ColoredBox(
                          color: context.accents
                              .phase(sinewPhaseOf(steps[i].phase))
                              .ring,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Width of a step, in whole seconds, at least one so it stays visible.
  int _flex(int? ms) {
    if (ms == null) return 1;
    final int s = (ms / 1000).round();
    return s < 1 ? 1 : s;
  }
}
