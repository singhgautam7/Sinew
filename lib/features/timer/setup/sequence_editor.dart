import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/timer_preset.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/domain/timer_ring.dart';
import '../../../core/widgets/sinew_menu.dart';
import '../../../engines/timer/timer_engine.dart';
import 'step_editor.dart';

/// One step in an editable list: a drag handle, a phase colour bar, a name
/// and subtitle, a time pill and an overflow menu (duplicate, delete).
class SequenceRow extends StatelessWidget {
  const SequenceRow({
    super.key,
    required this.index,
    required this.phase,
    required this.title,
    required this.subtitle,
    required this.timeText,
    required this.onTap,
    required this.onDuplicate,
    required this.onDelete,
  });

  final int index;
  final TimerPhase phase;
  final String title;
  final String subtitle;
  final String timeText;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final Color bar = context.accents.phase(sinewPhaseOf(phase)).ring;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs + Space.xxs),
      child: Semantics(
        label: '$title, $subtitle, $timeText',
        child: Material(
          color: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: Radii.largeR,
            side: BorderSide(color: cs.outlineVariant, width: Strokes.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: TimerUi.stepRowHeight,
              ),
              child: Row(
                children: <Widget>[
                  ReorderableDragStartListener(
                    index: index,
                    child: Semantics(
                      label: 'Drag to reorder',
                      child: SizedBox(
                        width: IconSpec.tapTarget,
                        height: IconSpec.tapTarget,
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: TimerUi.stepBarWidth,
                    height: TimerUi.stepBarHeight,
                    decoration: BoxDecoration(
                      color: bar,
                      borderRadius: BorderRadius.circular(Radii.extraSmall),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Space.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleSmall,
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: TimerUi.stepTimeHeight,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.md,
                      vertical: Space.xs,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: Radii.mediumR,
                    ),
                    child: Text(
                      timeText,
                      maxLines: 1,
                      style: context.text.titleSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Builder(
                    builder: (BuildContext menuContext) => IconButton(
                      tooltip: 'More for $title',
                      constraints: const BoxConstraints(
                        minWidth: IconSpec.tapTarget,
                        minHeight: IconSpec.tapTarget,
                      ),
                      onPressed: () async {
                        final String? choice = await showSinewMenu<String>(
                          context: menuContext,
                          entries: const <SinewMenuEntry<String>>[
                            SinewMenuEntry<String>(
                              value: 'duplicate',
                              label: 'Duplicate',
                              icon: Icons.copy_rounded,
                            ),
                            SinewMenuEntry<String>(
                              value: 'delete',
                              label: 'Delete',
                              icon: Icons.delete_outline_rounded,
                              destructive: true,
                            ),
                          ],
                        );
                        if (choice == 'duplicate') onDuplicate();
                        if (choice == 'delete') onDelete();
                      },
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
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

/// The reorderable step list of a custom sequence.
class CustomSequenceEditor extends StatelessWidget {
  const CustomSequenceEditor({
    super.key,
    required this.steps,
    required this.onChanged,
  });

  final List<TimerStepSpec> steps;
  final ValueChanged<List<TimerStepSpec>> onChanged;

  String _time(TimerStepSpec s) => s.durationMs == null
      ? 'Open'
      : ClockText.format((s.durationMs! / 1000).round());

  Future<void> _add(BuildContext context) async {
    final TimerStepSpec? step = await showStepEditor(
      context,
      initial: const TimerStepSpec(
        label: '',
        phase: TimerPhase.work,
        durationMs: 30000,
      ),
      kind: StepEditorKind.custom,
      isNew: true,
    );
    if (step != null) onChanged(<TimerStepSpec>[...steps, step]);
  }

  Future<void> _edit(BuildContext context, int i) async {
    final TimerStepSpec? step = await showStepEditor(
      context,
      initial: steps[i],
      kind: StepEditorKind.custom,
      isNew: false,
    );
    if (step == null) return;
    onChanged(<TimerStepSpec>[...steps]..[i] = step);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: steps.length,
          onReorderItem: (int from, int to) {
            final List<TimerStepSpec> next = <TimerStepSpec>[...steps];
            next.insert(to, next.removeAt(from));
            onChanged(next);
          },
          itemBuilder: (BuildContext c, int i) {
            final TimerStepSpec s = steps[i];
            return SequenceRow(
              key: ValueKey<String>('step-$i-${s.label}-${s.durationMs}'),
              index: i,
              phase: s.phase,
              title: s.label.isEmpty ? phaseName(s.phase) : s.label,
              subtitle: phaseName(s.phase),
              timeText: _time(s),
              onTap: () => _edit(context, i),
              onDuplicate: () =>
                  onChanged(<TimerStepSpec>[...steps]..insert(i + 1, s)),
              onDelete: () => onChanged(<TimerStepSpec>[...steps]..removeAt(i)),
            );
          },
        ),
        const SizedBox(height: Space.xs),
        AppButton(
          label: 'Add step',
          icon: Icons.add_rounded,
          type: AppButtonType.dotted,
          fullWidth: true,
          onPressed: () => _add(context),
        ),
      ],
    );
  }
}

/// The reorderable pose list of a yoga flow.
class PoseEditor extends StatelessWidget {
  const PoseEditor({super.key, required this.poses, required this.onChanged});

  final List<YogaPose> poses;
  final ValueChanged<List<YogaPose>> onChanged;

  Future<void> _add(BuildContext context) async {
    final TimerStepSpec? step = await showStepEditor(
      context,
      initial: const TimerStepSpec(
        label: '',
        phase: TimerPhase.work,
        durationMs: 30000,
      ),
      kind: StepEditorKind.pose,
      isNew: true,
    );
    if (step != null) onChanged(<YogaPose>[...poses, _pose(step)]);
  }

  YogaPose _pose(TimerStepSpec s) => YogaPose(
    label: s.label,
    holdSec: ((s.durationMs ?? 30000) / 1000).round(),
    exerciseId: s.exerciseId,
  );

  Future<void> _edit(BuildContext context, int i) async {
    final YogaPose p = poses[i];
    final TimerStepSpec? step = await showStepEditor(
      context,
      initial: TimerStepSpec(
        label: p.label,
        phase: TimerPhase.work,
        durationMs: p.holdSec * 1000,
        exerciseId: p.exerciseId,
      ),
      kind: StepEditorKind.pose,
      isNew: false,
    );
    if (step == null) return;
    onChanged(<YogaPose>[...poses]..[i] = _pose(step));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: poses.length,
          onReorderItem: (int from, int to) {
            final List<YogaPose> next = <YogaPose>[...poses];
            next.insert(to, next.removeAt(from));
            onChanged(next);
          },
          itemBuilder: (BuildContext c, int i) {
            final YogaPose p = poses[i];
            return SequenceRow(
              key: ValueKey<String>('pose-$i-${p.label}-${p.holdSec}'),
              index: i,
              phase: TimerPhase.cooldown,
              title: p.label,
              subtitle: 'Pose ${i + 1}',
              timeText: ClockText.format(p.holdSec),
              onTap: () => _edit(context, i),
              onDuplicate: () =>
                  onChanged(<YogaPose>[...poses]..insert(i + 1, p)),
              onDelete: () => onChanged(<YogaPose>[...poses]..removeAt(i)),
            );
          },
        ),
        const SizedBox(height: Space.xs),
        AppButton(
          label: 'Add pose',
          icon: Icons.add_rounded,
          type: AppButtonType.dotted,
          fullWidth: true,
          onPressed: () => _add(context),
        ),
      ],
    );
  }
}

/// Total of a custom sequence for its header, e.g. `Total 14:30`.
String sequenceTotal(List<TimerStepSpec> steps) {
  final int? ms = totalDurationMs(steps);
  return ms == null ? 'Open ended' : 'Total ${ClockText.format(ms ~/ 1000)}';
}
