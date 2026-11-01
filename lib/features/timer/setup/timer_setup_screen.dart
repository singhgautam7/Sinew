import 'dart:async';

import 'package:flutter/material.dart' hide Flow;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/ids.dart';
import '../../../core/db/repositories/library_repository.dart';
import '../../../core/db/repositories/library_types.dart';
import '../../../core/db/repositories/timer_preset_repository.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/timer_preset.dart';
import '../../../core/providers.dart';
import '../../../core/routing/router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../core/widgets/domain/numeric_stepper.dart';
import '../../../core/widgets/domain/timer_ring.dart';
import '../../../core/widgets/sinew_app_bar.dart';
import '../../../core/widgets/sinew_dialogs.dart';
import '../../../core/widgets/sinew_form.dart';
import '../../../core/widgets/sinew_list.dart';
import '../../../core/widgets/sinew_settings.dart';
import '../../../core/widgets/sinew_snackbar.dart';
import '../../../core/widgets/sinew_toggle_tile.dart';
import '../../../engines/timer/timer_engine.dart';
import '../controller/timer_session.dart';
import '../data/timer_modes.dart';
import '../data/timer_presets.dart';
import '../widgets/labelled_row.dart';
import '../widgets/name_dialog.dart';
import 'sequence_editor.dart';
import 'setup_model.dart';

/// Setup for one timer mode: its fields, a live total, the cues, Save as
/// preset and Start. Opened from `Routes.timerSetup(mode)`, optionally with a
/// saved preset (`?preset=<id>`) or a library flow (`?flow=<id>`).
class TimerSetupScreen extends ConsumerStatefulWidget {
  const TimerSetupScreen({
    super.key,
    required this.mode,
    this.presetId,
    this.flowId,
  });

  final TimerMode mode;
  final String? presetId;
  final String? flowId;

  @override
  ConsumerState<TimerSetupScreen> createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends ConsumerState<TimerSetupScreen> {
  late SetupModel _model = SetupModel.defaults(widget.mode);
  final TextEditingController _name = TextEditingController();
  TimerPreset? _preset;
  String? _title;
  bool _loading = true;

  TimerModeInfo get _info => timerModeInfo(widget.mode);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final String? presetId = widget.presetId;
      if (presetId != null) {
        final TimerPreset? p = await ref
            .read(timerPresetRepositoryProvider)
            .byId(presetId);
        if (p != null) {
          _preset = p;
          _title = p.name;
          _name.text = p.name;
          _model = SetupModel.fromConfig(
            configFromSteps(p.mode, p.steps),
            cues: p.cues,
          );
        }
      } else if (widget.flowId != null && widget.mode == TimerMode.yogaFlow) {
        final LibraryRepository lib = await ref.read(
          libraryRepositoryProvider.future,
        );
        final Flow? flow = await lib.flowById(widget.flowId!);
        if (flow != null) {
          _title = flow.name;
          _name.text = flow.name;
          _model = SetupModel.fromConfig(flowConfig(flow));
        }
      }
    } on Object {
      // Fall back to the mode's defaults; the screen still works.
    }
    if (mounted) setState(() => _loading = false);
  }

  void _set(SetupModel m) => setState(() => _model = m);

  String get _runTitle {
    final String? t = _title;
    return t == null || t.trim().isEmpty ? _info.label : t.trim();
  }

  String _totalText() {
    final int? ms = _model.totalMs;
    return ms == null ? 'Open' : ClockText.format(ms ~/ 1000);
  }

  Future<void> _start() async {
    if (!_model.canStart) return;
    final TimerSession session = ref.read(timerSessionProvider.notifier);
    if (ref.read(timerRunningProvider)) {
      final bool ok = await showSinewConfirmDialog(
        context: context,
        title: 'Replace the running timer?',
        message: 'A timer is already running. Starting this one ends it.',
        confirmLabel: 'Replace',
        destructive: true,
      );
      if (!ok || !mounted) return;
    }
    await session.start(
      _model.toConfig(),
      title: _runTitle,
      cues: _model.cues,
      presetId: _preset?.id,
    );
    if (!mounted) return;
    context.go(Routes.timer);
    unawaited(context.push(Routes.timerRun));
  }

  Future<void> _savePreset() async {
    if (!_model.canStart) {
      showSinewSnackBar(
        context,
        _model.mode == TimerMode.yogaFlow
            ? 'Add at least one pose first.'
            : 'Add at least one step first.',
      );
      return;
    }
    final String? name = await showNameDialog(
      context,
      title: 'Save preset',
      initial: _preset?.builtIn == false ? _preset!.name : _runTitle,
    );
    if (name == null || name.isEmpty || !mounted) return;
    final TimerPresetRepository repo = ref.read(timerPresetRepositoryProvider);
    final TimerPreset? existing = _preset;
    final bool overwrite = existing != null && !existing.builtIn;
    final int position = overwrite
        ? existing.position
        : (await repo.all()).length;
    final TimerConfig config = _model.toConfig();
    final TimerPreset saved = TimerPreset(
      id: overwrite ? existing.id : newId(),
      name: name,
      mode: config.mode,
      steps: compile(config),
      cues: _model.cues,
      position: position,
      updatedAt: DateTime.now().toUtc(),
    );
    await repo.save(saved);
    if (!mounted) return;
    setState(() {
      _preset = saved;
      _title = name;
    });
    showSinewSnackBar(context, 'Saved "$name".');
  }

  @override
  Widget build(BuildContext context) {
    final String total = _totalText();
    final bool canStart = _model.canStart;
    return Scaffold(
      appBar: SinewAppBar(
        title: _info.label,
        showBack: true,
        actions: <Widget>[
          // Big text would push the title out of the bar: an icon instead.
          if (MediaQuery.textScalerOf(context).scale(1) > 1.3)
            AppIconButton(
              icon: Icons.bookmark_add_outlined,
              semanticLabel: 'Save preset',
              onPressed: _savePreset,
            )
          else
            TextButton(
              onPressed: _savePreset,
              child: const Text('Save preset'),
            ),
        ],
      ),
      body: _loading
          ? const SizedBox.shrink()
          : Stack(
              children: <Widget>[
                ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Space.screen,
                    Space.sm,
                    Space.screen,
                    TimerUi.startClearance,
                  ),
                  children: <Widget>[
                    _TotalCard(model: _model, total: total),
                    const SizedBox(height: Space.md),
                    if (widget.mode == TimerMode.custom ||
                        widget.mode == TimerMode.yogaFlow) ...<Widget>[
                      SinewTextField(
                        label: 'Name',
                        controller: _name,
                        hint: _info.label,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (String v) => setState(() => _title = v),
                      ),
                      const SizedBox(height: Space.md),
                    ],
                    if (widget.mode == TimerMode.stopwatch)
                      const _StopwatchNote()
                    else ...<Widget>[
                      if (widget.mode == TimerMode.custom) ...<Widget>[
                        _SectionLine(
                          left: 'STEPS, ${_model.steps.length}',
                          right: sequenceTotal(_model.steps),
                        ),
                        CustomSequenceEditor(
                          steps: _model.steps,
                          onChanged: (List<TimerStepSpec> s) =>
                              _set(_model.copyWith(steps: s)),
                        ),
                      ] else ...<Widget>[
                        if (widget.mode == TimerMode.yogaFlow) ...<Widget>[
                          _SectionLine(
                            left: 'POSES, ${_model.poses.length}',
                            right: '',
                          ),
                          PoseEditor(
                            poses: _model.poses,
                            onChanged: (List<YogaPose> p) =>
                                _set(_model.copyWith(poses: p)),
                          ),
                          const SizedBox(height: Space.md),
                        ],
                        _FieldsCard(model: _model, onChanged: _set),
                      ],
                    ],
                    const SizedBox(height: Space.section),
                    const SinewSectionHeader(title: 'Cues'),
                    _CuesBlock(model: _model, onChanged: _set),
                  ],
                ),
                Positioned(
                  left: Space.screen,
                  right: Space.screen,
                  bottom: TimerUi.startBottom,
                  child: SafeArea(
                    top: false,
                    child: AppButton(
                      label: canStart ? 'Start · $total' : 'Start',
                      icon: Icons.play_arrow_rounded,
                      type: AppButtonType.primary,
                      fullWidth: true,
                      onPressed: canStart ? _start : null,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// The yoga config for a library flow: its poses in order, repeated for its
/// rounds, with the flow's own transition between them.
YogaFlowConfig flowConfig(Flow flow) {
  final List<YogaPose> once = <YogaPose>[
    for (final FlowStep s in flow.steps)
      YogaPose(
        label: s.label ?? _prettyId(s.exerciseId),
        holdSec: s.holdSec,
        exerciseId: s.exerciseId,
      ),
  ];
  final int rounds = flow.rounds < 1 ? 1 : flow.rounds;
  return YogaFlowConfig(
    poses: <YogaPose>[for (int r = 0; r < rounds; r++) ...once],
    transitionSec: flow.steps.isEmpty ? 5 : flow.steps.first.transitionSec,
  );
}

String _prettyId(String id) {
  final String spaced = id.replaceAll('-', ' ');
  return spaced.isEmpty
      ? id
      : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

class _SectionLine extends StatelessWidget {
  const _SectionLine({required this.left, required this.right});

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = context.text.labelMedium!.copyWith(
      color: context.cs.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(child: Text(left, style: style)),
          Text(right, style: style),
        ],
      ),
    );
  }
}

class _StopwatchNote extends StatelessWidget {
  const _StopwatchNote();

  @override
  Widget build(BuildContext context) {
    return SinewCard(
      child: Text(
        'Counts up with no end. Tap Lap to mark a split.',
        style: context.text.bodyMedium!.copyWith(
          color: context.cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// The big total and a strip of bars that mirrors the sequence.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.model, required this.total});

  final SetupModel model;
  final String total;

  @override
  Widget build(BuildContext context) {
    final List<TimerStepSpec> steps = compile(model.toConfig());
    return SinewCard(
      hero: true,
      child: MergeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'TOTAL',
                    style: context.sectionHeader.copyWith(
                      color: context.cs.onSurfaceVariant,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      total,
                      maxLines: 1,
                      style: context.text.headlineLarge!.copyWith(
                        fontSize: TimerUi.totalNumeral,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Space.md),
            ExcludeSemantics(child: _BarStrip(steps: steps)),
          ],
        ),
      ),
    );
  }
}

class _BarStrip extends StatelessWidget {
  const _BarStrip({required this.steps});

  final List<TimerStepSpec> steps;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox(height: TimerUi.stripHeight);
    final int n = steps.length < TimerUi.stripBars
        ? steps.length
        : TimerUi.stripBars;
    final List<Widget> bars = <Widget>[];
    for (int i = 0; i < n; i++) {
      // Spread the bars over the whole sequence when it is longer.
      final TimerStepSpec s = steps[(i * steps.length / n).floor()];
      final bool work = s.phase == TimerPhase.work;
      bars.add(
        Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : TimerUi.stripGap),
          child: Container(
            width: TimerUi.stripBar,
            height: work
                ? TimerUi.stripHeight
                : TimerUi.stripHeight * TimerUi.stripLowShare,
            decoration: BoxDecoration(
              color: context.accents.phase(sinewPhaseOf(s.phase)).ring,
              borderRadius: BorderRadius.circular(Radii.extraSmall / 2),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: TimerUi.stripHeight,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: bars),
    );
  }
}

class _FieldsCard extends StatelessWidget {
  const _FieldsCard({required this.model, required this.onChanged});

  final SetupModel model;
  final ValueChanged<SetupModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<SetupFieldDef> defs = fieldsFor(model.mode);
    if (defs.isEmpty) return const SizedBox.shrink();
    return SinewGroup(
      children: <Widget>[
        for (final SetupFieldDef d in defs)
          if (d.id == 'cap' && model.noCap)
            const SizedBox.shrink()
          else
            _FieldRow(
              def: d,
              value: model.value(d.id),
              onChanged: (int v) => onChanged(model.withValue(d.id, v)),
            ),
        if (model.mode == TimerMode.amrap)
          SinewSwitchRow(
            icon: Icons.all_inclusive_rounded,
            label: 'No time cap',
            subtitle: 'Counts up until you stop',
            value: model.noCap,
            onChanged: (bool v) => onChanged(model.copyWith(noCap: v)),
          ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.def,
    required this.value,
    required this.onChanged,
  });

  final SetupFieldDef def;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final SinewPhase? dot = def.dot;
    return LabelledRow(
      label: def.label,
      dot: dot == null ? context.cs.outline : context.accents.phase(dot).ring,
      control: NumericStepper(
        value: value.toDouble(),
        min: def.min.toDouble(),
        max: (def.max ?? 999).toDouble(),
        step: def.step.toDouble(),
        maxDecimals: 0,
        semanticLabel: def.label,
        format: def.kind == FieldKind.seconds
            ? (double v) => ClockText.format(v.round())
            : null,
        onChanged: (double v) => onChanged(v.round()),
      ),
    );
  }
}

class _CuesBlock extends StatelessWidget {
  const _CuesBlock({required this.model, required this.onChanged});

  final SetupModel model;
  final ValueChanged<SetupModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final TimerCues cues = model.cues;
    final bool workModes = model.mode != TimerMode.stopwatch;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SinewToggleTile(
                icon: Icons.volume_up_rounded,
                label: 'Sound',
                value: cues.sound,
                onChanged: (bool v) =>
                    onChanged(model.copyWith(cues: cues.copyWith(sound: v))),
              ),
            ),
            const SizedBox(width: TimerUi.tileGap),
            Expanded(
              child: SinewToggleTile(
                icon: Icons.vibration_rounded,
                label: 'Vibration',
                value: cues.haptic,
                onChanged: (bool v) =>
                    onChanged(model.copyWith(cues: cues.copyWith(haptic: v))),
              ),
            ),
            const SizedBox(width: TimerUi.tileGap),
            Expanded(
              child: SinewToggleTile(
                icon: Icons.record_voice_over_rounded,
                label: 'Spoken',
                value: cues.voice,
                onChanged: (bool v) =>
                    onChanged(model.copyWith(cues: cues.copyWith(voice: v))),
              ),
            ),
          ],
        ),
        if (workModes) ...<Widget>[
          const SizedBox(height: Space.md),
          SinewGroup(
            children: <Widget>[
              _CueStepperRow(
                label: 'Countdown beeps',
                value: cues.countdownSec,
                max: 10,
                step: 1,
                suffix: 'Seconds before a phase ends',
                onChanged: (int v) => onChanged(
                  model.copyWith(cues: cues.copyWith(countdownSec: v)),
                ),
              ),
              _CueStepperRow(
                label: 'Warning',
                value: cues.warningSec ?? 0,
                max: 120,
                step: 5,
                suffix: 'Seconds before a work phase ends, 0 is off',
                onChanged: (int v) => onChanged(
                  model.copyWith(
                    cues: v == 0
                        ? TimerCues(
                            sound: cues.sound,
                            haptic: cues.haptic,
                            voice: cues.voice,
                            countdownSec: cues.countdownSec,
                          )
                        : cues.copyWith(warningSec: v),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CueStepperRow extends StatelessWidget {
  const _CueStepperRow({
    required this.label,
    required this.suffix,
    required this.value,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final String suffix;
  final int value;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LabelledRow(
      label: label,
      caption: suffix,
      control: NumericStepper(
        value: value.toDouble(),
        min: 0,
        max: max.toDouble(),
        step: step.toDouble(),
        maxDecimals: 0,
        semanticLabel: label,
        format: (double v) => v.round() == 0 ? 'Off' : '${v.round()}',
        onChanged: (double v) => onChanged(v.round()),
      ),
    );
  }
}
