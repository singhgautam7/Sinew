import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/repositories/exercise_repository.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/timer_preset.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/domain/numeric_stepper.dart';
import '../../../core/widgets/domain/timer_ring.dart';
import '../../../core/widgets/sinew_bottom_sheet.dart';
import '../../../core/widgets/sinew_chips.dart';
import '../../../core/widgets/sinew_form.dart';
import '../../../core/widgets/sinew_settings.dart';
import '../../library/exercise_picker.dart';

/// What the step sheet is editing and which parts of a step it may change.
enum StepEditorKind {
  /// A custom sequence step: any phase, may be open ended.
  custom,

  /// A yoga pose: always a timed hold, no phase choice.
  pose,
}

/// The label a phase goes by in the sequence editor.
String phaseName(TimerPhase p) => switch (p) {
  TimerPhase.prepare => 'Warm-up',
  TimerPhase.work => 'Work',
  TimerPhase.rest => 'Rest',
  TimerPhase.roundRest => 'Round rest',
  TimerPhase.cooldown => 'Cool-down',
  TimerPhase.open => 'Open',
};

/// Opens the step sheet and returns the edited step, or null if cancelled.
Future<TimerStepSpec?> showStepEditor(
  BuildContext context, {
  required TimerStepSpec initial,
  required StepEditorKind kind,
  required bool isNew,
}) {
  return showSinewBottomSheet<TimerStepSpec>(
    context: context,
    builder: (BuildContext c) =>
        _StepSheet(initial: initial, kind: kind, isNew: isNew),
  );
}

class _StepSheet extends ConsumerStatefulWidget {
  const _StepSheet({
    required this.initial,
    required this.kind,
    required this.isNew,
  });

  final TimerStepSpec initial;
  final StepEditorKind kind;
  final bool isNew;

  @override
  ConsumerState<_StepSheet> createState() => _StepSheetState();
}

class _StepSheetState extends ConsumerState<_StepSheet> {
  late final TextEditingController _label = TextEditingController(
    text: widget.initial.label,
  );
  late TimerPhase _phase = widget.initial.phase;
  late int? _seconds = widget.initial.durationMs == null
      ? null
      : (widget.initial.durationMs! / 1000).round();
  late String? _exerciseId = widget.initial.exerciseId;
  String? _exerciseName;

  static const List<TimerPhase> _phases = <TimerPhase>[
    TimerPhase.prepare,
    TimerPhase.work,
    TimerPhase.rest,
    TimerPhase.roundRest,
    TimerPhase.cooldown,
  ];

  @override
  void initState() {
    super.initState();
    _resolveName();
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _resolveName() async {
    final String? id = _exerciseId;
    if (id == null) return;
    try {
      final ExerciseResolver r = await ref.read(
        exerciseResolverProvider.future,
      );
      final Map<String, Exercise> found = await r.resolve(<String>[id]);
      if (mounted) setState(() => _exerciseName = found[id]?.name);
    } on Object {
      // The id alone is still shown.
    }
  }

  Future<void> _pick() async {
    final List<String>? ids = await pickExercises(
      context,
      multiple: false,
      title: widget.kind == StepEditorKind.pose ? 'Choose a pose' : null,
    );
    if (ids == null || ids.isEmpty || !mounted) return;
    setState(() {
      _exerciseId = ids.first;
      _exerciseName = null;
    });
    await _resolveName();
    if (_label.text.trim().isEmpty && _exerciseName != null) {
      _label.text = _exerciseName!;
    }
  }

  void _save() {
    final String typed = _label.text.trim();
    final String label = typed.isNotEmpty
        ? typed
        : (_exerciseName ?? phaseName(_phase));
    Navigator.of(context).pop(
      TimerStepSpec(
        label: label,
        phase: widget.kind == StepEditorKind.pose ? TimerPhase.work : _phase,
        durationMs: _seconds == null ? null : _seconds! * 1000,
        exerciseId: _exerciseId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool custom = widget.kind == StepEditorKind.custom;
    return SinewBottomSheet(
      title: widget.isNew
          ? (custom ? 'Add step' : 'Add pose')
          : (custom ? 'Edit step' : 'Edit pose'),
      actions: Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              label: 'Cancel',
              type: AppButtonType.outline,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: AppButton(
              label: 'Save',
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: _save,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SinewTextField(
            label: custom ? 'Name' : 'Pose name',
            controller: _label,
            hint: custom ? phaseName(_phase) : 'Downward dog',
            textCapitalization: TextCapitalization.sentences,
          ),
          if (custom) ...<Widget>[
            const SizedBox(height: Space.lg),
            Text('Phase', style: context.text.labelLarge),
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: <Widget>[
                for (final TimerPhase p in _phases)
                  SinewChip(
                    label: phaseName(p),
                    selected: _phase == p,
                    onTap: () => setState(() => _phase = p),
                  ),
              ],
            ),
          ],
          const SizedBox(height: Space.lg),
          if (custom)
            SinewSwitchRow(
              icon: Icons.all_inclusive_rounded,
              label: 'Open ended',
              subtitle: 'Runs until you skip it',
              value: _seconds == null,
              onChanged: (bool open) =>
                  setState(() => _seconds = open ? null : 30),
            ),
          if (_seconds != null)
            Padding(
              padding: const EdgeInsets.only(top: Space.sm),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      custom ? 'Duration' : 'Hold',
                      style: context.text.titleMedium,
                    ),
                  ),
                  NumericStepper(
                    value: _seconds!.toDouble(),
                    min: 1,
                    max: 3600,
                    step: custom ? 5 : 5,
                    semanticLabel: custom ? 'Duration in seconds' : 'Hold',
                    format: (double v) => ClockText.format(v.round()),
                    onChanged: (double v) =>
                        setState(() => _seconds = v.round()),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Space.lg),
          SinewListRowButton(
            icon: Icons.fitness_center_rounded,
            title: _exerciseId == null
                ? (custom ? 'Attach an exercise' : 'Link to a library pose')
                : (_exerciseName ?? _exerciseId!),
            subtitle: _exerciseId == null ? 'Optional' : 'Tap to change',
            onTap: _pick,
            clearLabel: 'Remove link to ${_exerciseName ?? _exerciseId}',
            onClear: _exerciseId == null
                ? null
                : () => setState(() {
                    _exerciseId = null;
                    _exerciseName = null;
                  }),
          ),
        ],
      ),
    );
  }
}

/// A tappable row with an icon, a title and an optional clear button.
class SinewListRowButton extends StatelessWidget {
  const SinewListRowButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onClear,
    this.clearLabel = 'Remove',
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  /// What the clear button says to a screen reader and in its tooltip: it
  /// names what is removed ("Remove link to Downward dog").
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Material(
      color: cs.surfaceContainer,
      borderRadius: Radii.largeR,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Space.listItem2),
          child: Padding(
            padding: const EdgeInsets.only(left: Space.lg),
            child: Row(
              children: <Widget>[
                Icon(icon, color: cs.onSurfaceVariant),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(title, style: context.text.titleMedium),
                      Text(
                        subtitle,
                        style: context.text.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onClear != null)
                  IconButton(
                    tooltip: clearLabel,
                    constraints: const BoxConstraints(
                      minWidth: IconSpec.tapTarget,
                      minHeight: IconSpec.tapTarget,
                    ),
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                  )
                else
                  const SizedBox(width: Space.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
