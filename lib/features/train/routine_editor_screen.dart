import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/ids.dart';
import '../../core/db/repositories/exercise_repository.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/models/profile.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/routing/nav_visibility.dart';
import '../../core/settings/app_settings.dart';
import '../../core/settings/haptics.dart';
import '../../engines/records/train_stats.dart';
import 'routine_actions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/picker_palette.dart';
import '../../core/units/units.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/configs.dart';
import '../../core/widgets/domain/muscle_map.dart';
import '../../core/widgets/domain/numeric_stepper.dart';
import '../../core/widgets/domain/timer_ring.dart' show ClockText;
import '../../core/widgets/icon_color_picker_sheet.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_segmented_control.dart';
import 'routine_style.dart';
import 'train_format.dart';
import 'train_providers.dart';
import 'train_widgets.dart';

/// One row of the editor: the item plus UI-only state.
class _Row {
  _Row(this.item) : key = newId();

  final String key;
  RoutineItem item;
  bool expanded = false;
}

/// Create or edit a routine (`Routes.newRoutine`, `Routes.routine(id)`).
class RoutineEditorScreen extends ConsumerStatefulWidget {
  const RoutineEditorScreen({super.key, this.routineId});

  /// Null creates a new routine.
  final String? routineId;

  @override
  ConsumerState<RoutineEditorScreen> createState() =>
      _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final List<_Row> _rows = <_Row>[];
  Map<String, Exercise> _exercises = <String, Exercise>{};

  late final String _id = widget.routineId ?? newId();
  Routine? _existing;
  RoutineStyle _style = RoutineStyle.fallback;
  bool _loading = true;
  bool _missing = false;
  bool _dirty = false;
  bool _saving = false;
  String? _nameError;
  late final NavHideReasons _nav;

  @override
  void initState() {
    super.initState();
    _nav = ref.read(navHideReasonsProvider.notifier);
    holdNavHidden(_nav, const <NavHideReason>[NavHideReason.fullScreen]);
    unawaited(_load());
  }

  @override
  void dispose() {
    releaseNav(_nav, const <NavHideReason>[NavHideReason.fullScreen]);
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final String? id = widget.routineId;
    if (id != null) {
      final Routine? r = await ref.read(routineRepositoryProvider).byId(id);
      if (!mounted) return;
      if (r == null) {
        setState(() {
          _loading = false;
          _missing = true;
        });
        return;
      }
      _existing = r;
      _name.text = r.name;
      _notes.text = r.notes ?? '';
      _rows.addAll(r.items.map(_Row.new));
      _style = ref.read(routineStyleProvider(id));
      await _resolve(r.items.map((RoutineItem i) => i.exerciseId));
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _resolve(Iterable<String> ids) async {
    final List<String> need = <String>[
      for (final String id in ids)
        if (!_exercises.containsKey(id)) id,
    ];
    if (need.isEmpty) return;
    try {
      final ExerciseResolver resolver = await ref.read(
        exerciseResolverProvider.future,
      );
      final Map<String, Exercise> found = await resolver.resolve(need);
      if (!mounted) return;
      setState(() => _exercises = <String, Exercise>{..._exercises, ...found});
    } on Object {
      // No library yet: rows fall back to ids and reps.
    }
  }

  Exercise _exerciseOf(String id) =>
      _exercises[id] ??
      Exercise(
        id: id,
        name: id.replaceAll('-', ' '),
        category: 'unknown',
        trackingType: TrackingType.reps,
      );

  void _touch() => _dirty = true;

  List<RoutineItem> get _items => <RoutineItem>[
    for (final _Row r in _rows) r.item,
  ];

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _add() async {
    final List<String>? picked = await ref.read(exercisePickerProvider)(
      context,
      exclude: <String>{for (final _Row r in _rows) r.item.exerciseId},
      title: 'Add exercises',
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    await _resolve(picked);
    setState(() {
      _touch();
      for (final String id in picked) {
        final Exercise e = _exerciseOf(id);
        _rows.add(
          _Row(
            RoutineItem(
              id: newId(),
              exerciseId: id,
              position: _rows.length,
              restSec: e.defaultRestSec,
              targetDurationSec: e.trackingType == TrackingType.hold
                  ? e.defaultHoldSec
                  : null,
            ),
          ),
        );
      }
      _renumber();
    });
  }

  Future<void> _swap(_Row row) async {
    final List<String>? picked = await ref.read(exercisePickerProvider)(
      context,
      multiple: false,
      exclude: <String>{for (final _Row r in _rows) r.item.exerciseId},
      title: 'Swap exercise',
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    await _resolve(picked);
    setState(() {
      _touch();
      row.item = row.item.copyWith(exerciseId: picked.first);
    });
  }

  void _renumber() {
    for (int i = 0; i < _rows.length; i++) {
      _rows[i].item = _rows[i].item.copyWith(position: i);
    }
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      _touch();
      _rows.insert(newIndex, _rows.removeAt(oldIndex));
      _renumber();
    });
  }

  void _remove(_Row row) {
    setState(() {
      _touch();
      _rows.remove(row);
      _renumber();
      _dropLoneGroups();
    });
  }

  /// Links the item at [i] with the next one as a superset, or unlinks it.
  void _toggleSuperset(int i) {
    if (i + 1 >= _rows.length) return;
    final RoutineItem a = _rows[i].item;
    final RoutineItem b = _rows[i + 1].item;
    setState(() {
      _touch();
      if (a.supersetGroup != null && a.supersetGroup == b.supersetGroup) {
        _rows[i + 1].item = b.copyWith(supersetGroup: null);
      } else {
        int maxGroup = 0;
        for (final _Row r in _rows) {
          final int g = r.item.supersetGroup ?? 0;
          if (g > maxGroup) maxGroup = g;
        }
        final int group = a.supersetGroup ?? maxGroup + 1;
        _rows[i].item = a.copyWith(supersetGroup: group);
        _rows[i + 1].item = b.copyWith(supersetGroup: group);
      }
      _dropLoneGroups();
    });
  }

  /// A group of one is not a superset.
  void _dropLoneGroups() {
    final Map<int, int> sizes = <int, int>{};
    for (final _Row r in _rows) {
      final int? g = r.item.supersetGroup;
      if (g != null) sizes[g] = (sizes[g] ?? 0) + 1;
    }
    for (final _Row r in _rows) {
      final int? g = r.item.supersetGroup;
      if (g != null && sizes[g] == 1) {
        r.item = r.item.copyWith(supersetGroup: null);
      }
    }
  }

  Future<void> _save() async {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Give the routine a name');
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(routineRepositoryProvider);
    int position = _existing?.position ?? 0;
    if (_existing == null) {
      position = (await repo.allWithItems()).length;
    }
    final DateTime now = DateTime.now();
    final String notes = _notes.text.trim();
    await repo.save(
      Routine(
        id: _id,
        name: name,
        notes: notes.isEmpty ? null : notes,
        position: position,
        archived: _existing?.archived ?? false,
        items: _items,
        createdAt: _existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
    await ref.read(routineStyleStoreProvider).save(_id, _style);
    if (!mounted) return;
    _dirty = false;
    context.pop();
  }

  Future<void> _delete() async {
    final bool yes = await showSinewConfirmDialog(
      context: context,
      title: 'Delete this routine?',
      message:
          'The routine is removed. Workouts you did with it stay in your '
          'history.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!yes || !mounted) return;
    final Routine? existing = _existing;
    if (existing == null) return;
    // Deleted with Undo; the snackbar outlives this screen.
    await deleteRoutineWithUndo(
      context,
      ref,
      existing.copyWith(
        items: _items.isEmpty ? existing.items : existing.items,
      ),
    );
    if (!mounted) return;
    _dirty = false;
    context.pop();
  }

  Future<void> _confirmDiscard() async {
    final bool yes = await showSinewConfirmDialog(
      context: context,
      title: 'Discard changes?',
      message: 'Your changes to this routine have not been saved.',
      confirmLabel: 'Discard',
      destructive: true,
    );
    if (yes && mounted) {
      setState(() => _dirty = false);
      context.pop();
    }
  }

  Future<void> _pickStyle() {
    final muscles = routineMuscles(
      _rows.map((_Row r) => r.item.exerciseId),
      _exercises,
    );
    final Sex? sex = ref.read(trainProfileProvider).value?.sex;
    return showIconColorPicker(
      context: context,
      icons: kRoutineIcons,
      initial: SinewIconColor(
        iconKey: _style.iconKey,
        colorValue: pickerColorOf(_style),
        extra: <String, Object?>{'map': _style.useMap},
      ),
      extraTabs: <SinewPickerTab>[
        SinewPickerTab(
          id: 'map',
          label: 'Muscle map',
          title: 'Muscle map',
          builder:
              (
                BuildContext context,
                SinewIconColor value,
                ValueChanged<SinewIconColor> onChanged,
              ) => _MapTab(
                value: value,
                onChanged: onChanged,
                primary: muscles.primary,
                secondary: muscles.secondary,
                sex: sex,
                colourChosen:
                    _style.colorValue != null ||
                    value.colorValue != SinewPickerPalette.defaultColor,
              ),
        ),
      ],
      onDone: (SinewIconColor v) {
        final bool colourChosen =
            _style.colorValue != null ||
            v.colorValue != SinewPickerPalette.defaultColor;
        setState(() {
          _touch();
          _style = RoutineStyle(
            iconKey: v.iconKey,
            colorValue: colourChosen ? v.colorValue : null,
            useMap: v.extra['map'] as bool? ?? _style.useMap,
          );
        });
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool editing = widget.routineId != null;
    final Profile profile =
        ref.watch(trainProfileProvider).value ?? const Profile();
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) unawaited(_confirmDiscard());
      },
      child: Scaffold(
        appBar: SinewAppBar(
          title: editing ? 'Edit routine' : 'New routine',
          showBack: true,
          closeIcon: true,
          showBrand: false,
          overflowConfig: editing && !_loading
              ? SinewOverflowConfig(
                  items: <SinewOverflowItem>[
                    SinewOverflowItem(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete routine',
                      isDestructive: true,
                      onTap: () => unawaited(_delete()),
                    ),
                  ],
                )
              : null,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: Space.xs),
              child: AppButton(
                label: 'Save',
                type: AppButtonType.primary,
                height: Sizes.buttonSmall,
                isLoading: _saving,
                onPressed: _loading || _missing ? null : _save,
              ),
            ),
          ],
        ),
        body: _body(context, profile),
      ),
    );
  }

  Widget _body(BuildContext context, Profile profile) {
    if (_loading) {
      return const TrainLoading();
    }
    if (_missing) {
      return const SinewErrorState(
        title: 'Routine not found',
        description: 'It may have been deleted.',
      );
    }
    final muscles = routineMuscles(
      _rows.map((_Row r) => r.item.exerciseId),
      _exercises,
    );
    final int minutes = estimateRoutineMinutes(
      _items,
      defaultRestSec: ref.watch(
        settingsProvider.select((AppSettings s) => s.restSeconds),
      ),
    );
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Space.screen),
          sliver: SliverList.list(
            children: <Widget>[
              const SizedBox(height: Space.sm),
              SinewTextField(
                label: 'Name',
                controller: _name,
                hint: 'Upper body A',
                errorText: _nameError,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (String _) {
                  _dirty = true;
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: Space.md),
              SinewTextField(
                label: 'Notes',
                controller: _notes,
                optional: true,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (String _) => _dirty = true,
              ),
              const SizedBox(height: Space.md),
              _StyleRow(
                style: _style,
                primary: muscles.primary,
                secondary: muscles.secondary,
                onTap: _pickStyle,
              ),
              const SizedBox(height: Space.xl),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        _rows.isEmpty
                            ? 'EXERCISES'
                            : 'EXERCISES · ${_rows.length}'
                                  '${minutes > 0 ? ' · ABOUT $minutes MIN' : ''}',
                        style: context.sectionHeader,
                      ),
                    ),
                  ),
                ],
              ),
              if (_rows.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: Space.xxs),
                  child: Text(
                    'Hold the handle to reorder',
                    style: context.text.bodySmall!.copyWith(
                      color: context.cs.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: Space.sm),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Space.screen),
          sliver: SliverReorderableList(
            itemCount: _rows.length,
            onReorderItem: _reorder,
            proxyDecorator: (Widget child, int index, Animation<double> a) =>
                Material(type: MaterialType.transparency, child: child),
            itemBuilder: (BuildContext context, int i) {
              final _Row row = _rows[i];
              return Padding(
                key: ValueKey<String>(row.key),
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: _ItemCard(
                  index: i,
                  row: row,
                  exercise: _exerciseOf(row.item.exerciseId),
                  weightUnit: profile.weightUnit,
                  distanceUnit: profile.distanceUnit,
                  weightStep: profile.weightUnit == WeightUnit.kg
                      ? ref.watch(
                          settingsProvider.select(
                            (AppSettings s) => s.incrementKg,
                          ),
                        )
                      : ref.watch(
                          settingsProvider.select(
                            (AppSettings s) => s.incrementLb,
                          ),
                        ),
                  haptics: ref.watch(hapticsEnabledProvider),
                  isLast: i == _rows.length - 1,
                  onToggle: () => setState(() => row.expanded = !row.expanded),
                  onChanged: (RoutineItem item) => setState(() {
                    _touch();
                    row.item = item;
                  }),
                  onSuperset: () => _toggleSuperset(i),
                  onSwap: () => unawaited(_swap(row)),
                  onDelete: () => _remove(row),
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.sm,
            Space.screen,
            Space.bottomSafe,
          ),
          sliver: SliverToBoxAdapter(
            child: AppButton(
              label: 'Add exercise',
              icon: Icons.add_rounded,
              type: AppButtonType.dotted,
              fullWidth: true,
              onPressed: _add,
            ),
          ),
        ),
      ],
    );
  }
}

class _StyleRow extends StatelessWidget {
  const _StyleRow({
    required this.style,
    required this.primary,
    required this.secondary,
    required this.onTap,
  });

  final RoutineStyle style;
  final List<String> primary;
  final List<String> secondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool map = style.useMap && primary.isNotEmpty;
    return SinewPickerRow(
      leading: RoutineTile(
        style: style,
        primary: primary,
        secondary: secondary,
        size: TrainSpec.routineEditorTile,
      ),
      label: 'Icon and colour',
      value: map ? 'Muscle map' : 'Icon',
      onTap: onTap,
    );
  }
}

/// The picker's third tab: a live map of the routine's muscles and the choice
/// between it and an icon.
class _MapTab extends StatelessWidget {
  const _MapTab({
    required this.value,
    required this.onChanged,
    required this.primary,
    required this.secondary,
    required this.sex,
    required this.colourChosen,
  });

  final SinewIconColor value;
  final ValueChanged<SinewIconColor> onChanged;
  final List<String> primary;
  final List<String> secondary;
  final Sex? sex;
  final bool colourChosen;

  @override
  Widget build(BuildContext context) {
    final bool useMap = value.extra['map'] as bool? ?? true;
    final TextTheme tt = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SinewSegmentedControl<bool>(
          values: const <bool>[true, false],
          labels: const <String>['Muscle map', 'Icon'],
          selected: useMap,
          onSelected: (bool v) => onChanged(
            value.copyWith(extra: <String, Object?>{...value.extra, 'map': v}),
          ),
        ),
        const SizedBox(height: Space.lg),
        SizedBox(
          height: TrainSpec.mapPreviewHeight * 2,
          child: primary.isEmpty
              ? Center(
                  child: Text(
                    'Add exercises and the muscles they work show up here.',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium!.copyWith(
                      color: context.cs.onSurfaceVariant,
                    ),
                  ),
                )
              : MuscleMap(
                  primary: primary,
                  secondary: secondary,
                  sex: sex,
                  tint: colourChosen ? Color(value.colorValue) : null,
                  showLabels: false,
                ),
        ),
        const SizedBox(height: Space.md),
        Text(
          'The muscle map is the default and updates as you add exercises. '
          'Colour works with either: it tints the map, or the icon. Pick an '
          'icon when a map says less, like yoga or boxing.',
          style: tt.bodySmall!.copyWith(color: context.cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.index,
    required this.row,
    required this.exercise,
    required this.weightUnit,
    required this.distanceUnit,
    required this.weightStep,
    required this.haptics,
    required this.isLast,
    required this.onToggle,
    required this.onChanged,
    required this.onSuperset,
    required this.onSwap,
    required this.onDelete,
  });

  final int index;
  final _Row row;
  final Exercise exercise;
  final WeightUnit weightUnit;
  final DistanceUnit distanceUnit;

  /// The weight stepper's step in the profile's unit (Settings).
  final double weightStep;
  final bool haptics;
  final bool isLast;
  final VoidCallback onToggle;
  final ValueChanged<RoutineItem> onChanged;
  final VoidCallback onSuperset;
  final VoidCallback onSwap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final RoutineItem item = row.item;
    final bool linked = item.supersetGroup != null;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: Radii.largeR,
        border: Border.all(
          color: linked ? cs.primary : cs.outlineVariant,
          width: linked ? Strokes.focus : Strokes.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              ReorderableDragStartListener(
                index: index,
                child: Semantics(
                  label: 'Reorder ${exercise.name}',
                  child: const SizedBox.square(
                    dimension: IconSpec.tapTarget,
                    child: Icon(Icons.drag_indicator_rounded),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: Radii.largeR,
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          exercise.name,
                          style: tt.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _targetLine(item),
                          style: tt.bodySmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        if (linked)
                          Padding(
                            padding: const EdgeInsets.only(top: Space.xxs),
                            child: Text(
                              'Superset',
                              style: tt.labelSmall!.copyWith(color: cs.primary),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: row.expanded
                    ? 'Close targets for ${exercise.name}'
                    : 'Edit targets for ${exercise.name}',
                excludeSemantics: true,
                child: InkWell(
                  onTap: onToggle,
                  child: SizedBox.square(
                    dimension: IconSpec.tapTarget,
                    child: Icon(
                      row.expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (row.expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                0,
                Space.lg,
                Space.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ..._targetEditors(),
                  const SizedBox(height: Space.sm),
                  Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.xs,
                    children: <Widget>[
                      if (!isLast)
                        SinewChip(
                          shrink: true,
                          label: item.supersetGroup == null
                              ? 'Superset with next'
                              : 'Unlink superset',
                          icon: Icons.link_rounded,
                          onTap: onSuperset,
                        ),
                      SinewChip(
                        shrink: true,
                        label: 'Swap',
                        icon: Icons.swap_horiz_rounded,
                        onTap: onSwap,
                      ),
                      SinewChip(
                        shrink: true,
                        label: 'Remove',
                        icon: Icons.delete_outline_rounded,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _targetLine(RoutineItem i) {
    final List<String> parts = <String>[];
    final String sets = '${i.targetSets} ×';
    switch (exercise.trackingType) {
      case TrackingType.weightReps:
        parts.add(
          i.targetReps == null ? '$sets any reps' : '$sets ${i.targetReps}',
        );
        if (i.targetWeightKg != null) {
          parts.add(Units.formatWeight(i.targetWeightKg!, weightUnit));
        }
      case TrackingType.reps || TrackingType.unknown:
        parts.add(
          i.targetReps == null ? '$sets any reps' : '$sets ${i.targetReps}',
        );
      case TrackingType.time || TrackingType.hold:
        parts.add(
          i.targetDurationSec == null
              ? '${i.targetSets} sets'
              : '$sets ${ClockText.format(i.targetDurationSec!)}',
        );
      case TrackingType.distanceTime:
        parts.add(
          i.targetDistanceM == null
              ? '${i.targetSets} sets'
              : '$sets ${Units.formatDistance(i.targetDistanceM!, distanceUnit)}',
        );
      case TrackingType.rounds || TrackingType.flow:
        parts.add(
          i.targetReps == null
              ? '${i.targetSets} sets'
              : '$sets ${plural(i.targetReps!, 'round')}',
        );
    }
    if (i.restSec != null) parts.add('rest ${ClockText.format(i.restSec!)}');
    return parts.join(' · ');
  }

  List<Widget> _targetEditors() {
    final RoutineItem item = row.item;
    final Widget sets = _Target(
      label: 'Sets',
      child: NumericStepper(
        haptics: haptics,
        value: item.targetSets.toDouble(),
        min: 1,
        max: TrainSpec.maxSets.toDouble(),
        semanticLabel: 'Sets for ${exercise.name}',
        maxDecimals: 0,
        onChanged: (double v) =>
            onChanged(item.copyWith(targetSets: v.round())),
      ),
    );
    Widget reps(String label) => _Target(
      label: label,
      child: NumericStepper(
        haptics: haptics,
        value: (item.targetReps ?? 0).toDouble(),
        max: 100,
        maxDecimals: 0,
        semanticLabel: '$label for ${exercise.name}',
        format: (double v) => v == 0 ? 'Any' : v.round().toString(),
        onChanged: (double v) =>
            onChanged(item.copyWith(targetReps: v == 0 ? null : v.round())),
      ),
    );
    Widget clock(
      String label,
      int? value,
      ValueChanged<int?> set, {
      int step = 5,
      String zero = 'Off',
    }) => _Target(
      label: label,
      child: NumericStepper(
        haptics: haptics,
        value: (value ?? 0).toDouble(),
        step: step.toDouble(),
        max: 3600,
        maxDecimals: 0,
        semanticLabel: '$label for ${exercise.name}',
        format: (double v) => v == 0 ? zero : ClockText.format(v.round()),
        onChanged: (double v) => set(v == 0 ? null : v.round()),
      ),
    );
    final Widget rest = _Target(
      label: 'Rest',
      child: NumericStepper(
        haptics: haptics,
        value: (item.restSec ?? 0).toDouble(),
        step: 15,
        max: TrainSpec.maxRestSec.toDouble(),
        maxDecimals: 0,
        semanticLabel: 'Rest after each set of ${exercise.name}',
        format: (double v) => v == 0 ? 'Default' : ClockText.format(v.round()),
        onChanged: (double v) =>
            onChanged(item.copyWith(restSec: v == 0 ? null : v.round())),
      ),
    );
    final List<Widget> byType = switch (exercise.trackingType) {
      TrackingType.weightReps => <Widget>[
        reps('Reps'),
        _Target(
          label: 'Weight',
          child: NumericStepper(
            haptics: haptics,
            value: Units.fromKg(item.targetWeightKg ?? 0, weightUnit),
            step: weightStep,
            max: 1000,
            unit: Units.weightLabel(weightUnit),
            semanticLabel: 'Weight for ${exercise.name}',
            format: (double v) => v == 0 ? 'Any' : Units.trim(v),
            onChanged: (double v) => onChanged(
              item.copyWith(
                targetWeightKg: v == 0 ? null : Units.toKg(v, weightUnit),
              ),
            ),
          ),
        ),
      ],
      TrackingType.reps || TrackingType.unknown => <Widget>[reps('Reps')],
      TrackingType.time => <Widget>[
        clock(
          'Time',
          item.targetDurationSec,
          (int? v) => onChanged(item.copyWith(targetDurationSec: v)),
        ),
      ],
      TrackingType.hold => <Widget>[
        clock(
          'Hold',
          item.targetDurationSec,
          (int? v) => onChanged(item.copyWith(targetDurationSec: v)),
        ),
      ],
      TrackingType.distanceTime => <Widget>[
        _Target(
          label: 'Distance',
          child: NumericStepper(
            haptics: haptics,
            value: Units.fromMetres(item.targetDistanceM ?? 0, distanceUnit),
            step: 0.5,
            max: 1000,
            unit: Units.distanceLabel(distanceUnit),
            semanticLabel: 'Distance for ${exercise.name}',
            format: (double v) => v == 0 ? 'Any' : Units.trim(v),
            onChanged: (double v) => onChanged(
              item.copyWith(
                targetDistanceM: v == 0
                    ? null
                    : Units.toMetres(v, distanceUnit),
              ),
            ),
          ),
        ),
        clock(
          'Time',
          item.targetDurationSec,
          (int? v) => onChanged(item.copyWith(targetDurationSec: v)),
          step: 30,
          zero: 'Any',
        ),
      ],
      TrackingType.rounds || TrackingType.flow => <Widget>[
        reps('Rounds'),
        clock(
          'Time per round',
          item.targetDurationSec,
          (int? v) => onChanged(item.copyWith(targetDurationSec: v)),
          step: 15,
        ),
      ],
    };
    return <Widget>[sets, ...byType, rest];
  }
}

/// A label with a stepper under it, for the targets list.
class _Target extends StatelessWidget {
  const _Target({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium!.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: Space.sm),
          child,
        ],
      ),
    );
  }
}
