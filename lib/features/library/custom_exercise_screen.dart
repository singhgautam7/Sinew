import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/repositories/exercise_repository.dart';
import '../../core/db/repositories/exercise_search_service.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/domain/exercise_tile.dart';
import '../../core/widgets/domain/muscle_map.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_settings.dart';
import '../../core/widgets/sinew_snackbar.dart';
import '../../core/widgets/sinew_states.dart';
import 'library_labels.dart';
import 'library_providers.dart';

/// Closes a screen with a result, whether it was pushed by go_router or by a
/// plain `Navigator` (the picker pushes it that way inside tests).
void popWithResult<T>(BuildContext context, [T? result]) {
  if (GoRouter.maybeOf(context) != null && context.canPop()) {
    context.pop(result);
  } else {
    Navigator.of(context).pop(result);
  }
}

/// Create or edit a custom exercise. Pops with the saved exercise id.
class CustomExerciseScreen extends ConsumerWidget {
  const CustomExerciseScreen({super.key, this.exerciseId});

  /// Null creates a new exercise.
  final String? exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? id = exerciseId;
    if (id == null) return const _CustomExerciseForm();
    final AsyncValue<Exercise?> async = ref.watch(libraryExerciseProvider(id));
    return async.when(
      loading: () => const Scaffold(
        appBar: SinewAppBar(
          title: 'Edit exercise',
          showBack: true,
          closeIcon: true,
        ),
        body: Delayed(child: SinewLoader()),
      ),
      error: (Object e, StackTrace _) => Scaffold(
        appBar: const SinewAppBar(
          title: 'Edit exercise',
          showBack: true,
          closeIcon: true,
        ),
        body: SinewEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not open this exercise',
          description: 'Something went wrong reading it.',
          actionLabel: 'Try again',
          actionIcon: Icons.refresh_rounded,
          onAction: () => ref.invalidate(libraryExerciseProvider(id)),
        ),
      ),
      data: (Exercise? e) {
        if (e == null || !e.isCustom) {
          return const Scaffold(
            appBar: SinewAppBar(
              title: 'Edit exercise',
              showBack: true,
              closeIcon: true,
            ),
            body: SinewEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Exercise not found',
              description: 'Only your own exercises can be edited.',
            ),
          );
        }
        return _CustomExerciseForm(initial: e);
      },
    );
  }
}

class _CustomExerciseForm extends ConsumerStatefulWidget {
  const _CustomExerciseForm({this.initial});

  final Exercise? initial;

  @override
  ConsumerState<_CustomExerciseForm> createState() =>
      _CustomExerciseFormState();
}

class _CustomExerciseFormState extends ConsumerState<_CustomExerciseForm> {
  late final TextEditingController _name;
  late final TextEditingController _steps;
  late final TextEditingController _notes;
  late final TextEditingController _met;
  late final TextEditingController _rest;
  late final TextEditingController _hold;
  late String _category;
  late TrackingType _tracking;
  late List<String> _primary;
  late List<String> _secondary;
  late List<String> _equipment;
  Difficulty? _difficulty;
  late bool _unilateral;
  bool _metEdited = false;
  bool _triedSave = false;
  bool _saving = false;
  bool _duplicate = false;
  Timer? _dupTimer;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final Exercise? e = widget.initial;
    _name = TextEditingController(text: e?.name ?? '');
    _steps = TextEditingController(text: e?.steps.join('\n') ?? '');
    _notes = TextEditingController(text: e?.tips.join('\n') ?? '');
    _category = e?.category ?? 'strength';
    _tracking = e?.trackingType ?? TrackingType.weightReps;
    _primary = <String>[...?e?.primaryMuscles];
    _secondary = <String>[...?e?.secondaryMuscles];
    _equipment = <String>[...?e?.equipment];
    _difficulty = e?.difficulty;
    _unilateral = e?.unilateral ?? false;
    _metEdited = e?.metValue != null;
    _met = TextEditingController(
      text: _fmt(e?.metValue ?? defaultMetFor(_category)),
    );
    _rest = TextEditingController(text: e?.defaultRestSec?.toString() ?? '');
    _hold = TextEditingController(text: e?.defaultHoldSec?.toString() ?? '');
  }

  @override
  void dispose() {
    _dupTimer?.cancel();
    for (final TextEditingController c in <TextEditingController>[
      _name,
      _steps,
      _notes,
      _met,
      _rest,
      _hold,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(1) : v.toString();

  void _onName(String _) {
    _dupTimer?.cancel();
    _dupTimer = Timer(LibrarySpec.searchDebounce, _checkDuplicate);
    setState(() {});
  }

  Future<void> _checkDuplicate() async {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      if (mounted) setState(() => _duplicate = false);
      return;
    }
    try {
      final ExerciseSearchService svc = await ref.read(
        exerciseSearchServiceProvider.future,
      );
      final List<ExerciseSummary> hits = await svc.search(
        query: name,
        limit: 10,
      );
      final bool dup = hits.any(
        (ExerciseSummary h) =>
            h.id != widget.initial?.id &&
            h.name.trim().toLowerCase() == name.toLowerCase(),
      );
      if (mounted && name == _name.text.trim()) {
        setState(() => _duplicate = dup);
      }
    } on Object {
      // The warning is a courtesy; a failed lookup is not worth showing.
    }
  }

  void _cycleMuscle(String id) {
    setState(() {
      if (_primary.contains(id)) {
        _primary.remove(id);
        _secondary.add(id);
      } else if (_secondary.contains(id)) {
        _secondary.remove(id);
      } else {
        _primary.add(id);
      }
    });
  }

  Future<void> _pickEquipment() async {
    final List<String>? next = await showSinewBottomSheet<List<String>>(
      context: context,
      builder: (BuildContext _) => _EquipmentSheet(initial: _equipment),
    );
    if (next != null && mounted) setState(() => _equipment = next);
  }

  List<String> _lines(String text) => text
      .split('\n')
      .map((String l) => l.trim())
      .where((String l) => l.isNotEmpty)
      .toList();

  Future<void> _save() async {
    setState(() => _triedSave = true);
    final String name = _name.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    final double? met = double.tryParse(_met.text.trim());
    final int? rest = int.tryParse(_rest.text.trim());
    final int? hold = int.tryParse(_hold.text.trim());
    final Exercise base =
        widget.initial ??
        Exercise(
          id: '',
          name: name,
          category: _category,
          trackingType: _tracking,
          isCustom: true,
        );
    final Exercise draft = base.copyWith(
      name: name,
      category: _category,
      trackingType: _tracking,
      primaryMuscles: _primary,
      secondaryMuscles: _secondary,
      equipment: _equipment,
      difficulty: _difficulty,
      unilateral: _unilateral,
      steps: _lines(_steps.text),
      tips: _lines(_notes.text),
      metValue: met,
      defaultRestSec: rest,
      defaultHoldSec: hold,
    );
    try {
      final Exercise saved = await ref
          .read(customExerciseRepositoryProvider)
          .save(draft);
      if (!mounted) return;
      popWithResult<String>(context, saved.id);
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
      showSinewSnackBar(context, 'Could not save the exercise', isError: true);
    }
  }

  Future<void> _archive() async {
    final Exercise e = widget.initial!;
    final bool ok = await showSinewConfirmDialog(
      context: context,
      title: 'Archive ${e.name}?',
      message: 'It is hidden from the picker and search. Your history keeps it and you can restore it later.',
      confirmLabel: 'Archive',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref
        .read(customExerciseRepositoryProvider)
        .setArchived(e.id, archived: true);
    if (!mounted) return;
    popWithResult<String>(context);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Sex? sex = ref.watch(librarySexProvider).value;
    final bool nameMissing = _triedSave && _name.text.trim().isEmpty;
    final bool showHold =
        _tracking == TrackingType.hold ||
        _tracking == TrackingType.flow ||
        _tracking == TrackingType.time;
    return Scaffold(
      appBar: SinewAppBar(
        title: _editing ? 'Edit exercise' : 'New exercise',
        showBack: true,
        closeIcon: true,
        showBrand: false,
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.sm,
          Space.screen,
          Space.xl,
        ),
        children: <Widget>[
          SinewTextField(
            label: 'Name',
            controller: _name,
            hint: 'Zercher lunge',
            errorText: nameMissing ? 'Give it a name' : null,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onChanged: _onName,
          ),
          if (_duplicate) ...<Widget>[
            const SizedBox(height: Space.sm),
            const SinewCallout(
              child: Text(
                'An exercise with this name already exists. You can still save it.',
              ),
            ),
          ],
          const SizedBox(height: Space.xl),
          const SinewFieldLabel('Category'),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: <Widget>[
              for (final String c in kCategories)
                SinewChip(
                  shrink: true,
                  label: categoryLabel(c),
                  selected: c == _category,
                  onTap: () => setState(() {
                    _category = c;
                    if (!_metEdited) _met.text = _fmt(defaultMetFor(c));
                  }),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
          const SinewSectionHeader(title: 'How you track it'),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: <Widget>[
              for (final TrackingType t in kTrackingTypes)
                SinewChip(
                  shrink: true,
                  label: trackingLabel(t),
                  icon: trackingTypeIcon(t),
                  selected: t == _tracking,
                  onTap: () => setState(() => _tracking = t),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
          const SinewSectionHeader(title: 'Muscles'),
          Text(
            'Tap once for primary, twice for secondary, three times to clear.',
            style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: Space.md),
          SinewCard(
            child: SizedBox(
              height: LibrarySpec.mapPreviewHeight,
              child: MuscleMap(
                primary: _primary,
                secondary: _secondary,
                sex: sex,
                onRegionTap: _cycleMuscle,
                semanticLabel:
                    'Muscle preview. Primary: ${_primary.map(muscleLabel).join(', ')}. '
                    'Secondary: ${_secondary.map(muscleLabel).join(', ')}.',
              ),
            ),
          ),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: <Widget>[
              for (final String m in kMuscles)
                SinewChip(
                  shrink: true,
                  label: muscleLabel(m),
                  selected: _primary.contains(m) || _secondary.contains(m),
                  badge: _secondary.contains(m) ? 'Secondary' : null,
                  showCheck: _primary.contains(m),
                  onTap: () => _cycleMuscle(m),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
          SinewPickerRow(
            leading: Icon(Icons.fitness_center_rounded, color: cs.primary),
            label: 'Equipment',
            value: _equipment.isEmpty
                ? 'None'
                : _equipment.map(equipmentLabel).join(', '),
            valueIsPlaceholder: _equipment.isEmpty,
            onTap: _pickEquipment,
          ),
          const SizedBox(height: Space.xl),
          const SinewFieldLabel('Difficulty'),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: <Widget>[
              SinewChip(
                shrink: true,
                label: 'Any',
                selected: _difficulty == null,
                onTap: () => setState(() => _difficulty = null),
              ),
              for (final Difficulty d in Difficulty.values)
                SinewChip(
                  shrink: true,
                  label: difficultyLabel(d),
                  selected: _difficulty == d,
                  onTap: () => setState(() => _difficulty = d),
                ),
            ],
          ),
          const SizedBox(height: Space.lg),
          SinewSwitchRow(
            icon: Icons.swap_horiz_rounded,
            label: 'One side at a time',
            subtitle: 'Log left and right separately',
            value: _unilateral,
            card: true,
            onChanged: (bool v) => setState(() => _unilateral = v),
          ),
          const SizedBox(height: Space.xl),
          SinewTextField(
            label: 'Steps',
            controller: _steps,
            hint: 'One step per line',
            optional: true,
            maxLines: LibrarySpec.stepsLines,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: Space.lg),
          SinewTextField(
            label: 'Notes',
            controller: _notes,
            hint: 'Cues, set-up, anything to remember',
            optional: true,
            maxLines: LibrarySpec.notesLines,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: Space.lg),
          SinewTextField.number(
            label: 'MET (estimate)',
            controller: _met,
            helperText:
                'Used to estimate calories. A starting guess for ${categoryLabel(_category).toLowerCase()}; change it if you know better.',
            onChanged: (String _) => _metEdited = true,
            optional: true,
          ),
          const SizedBox(height: Space.lg),
          SinewTextField.number(
            label: 'Default rest',
            controller: _rest,
            suffixText: 's',
            decimal: false,
            optional: true,
          ),
          if (showHold) ...<Widget>[
            const SizedBox(height: Space.lg),
            SinewTextField.number(
              label: 'Default hold',
              controller: _hold,
              suffixText: 's',
              decimal: false,
              optional: true,
            ),
          ],
          if (_editing) ...<Widget>[
            const SizedBox(height: Space.xxl),
            AppButton(
              label: 'Archive exercise',
              type: AppButtonType.danger,
              icon: Icons.archive_outlined,
              fullWidth: true,
              onPressed: _archive,
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            top: BorderSide(color: cs.outlineVariant, width: Strokes.hairline),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          Space.screen,
          Space.md,
          Space.screen,
          Space.lg + MediaQuery.of(context).padding.bottom,
        ),
        child: AppButton(
          label: _editing ? 'Save changes' : 'Save exercise',
          type: AppButtonType.primary,
          fullWidth: true,
          isLoading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }
}

class _EquipmentSheet extends StatefulWidget {
  const _EquipmentSheet({required this.initial});

  final List<String> initial;

  @override
  State<_EquipmentSheet> createState() => _EquipmentSheetState();
}

class _EquipmentSheetState extends State<_EquipmentSheet> {
  late final List<String> _picked = <String>[...widget.initial];

  @override
  Widget build(BuildContext context) {
    return SinewBottomSheet(
      title: 'Equipment',
      actions: AppButton(
        label: _picked.isEmpty ? 'No equipment' : 'Done',
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () => Navigator.of(context).pop(_picked),
      ),
      child: Wrap(
        spacing: Space.sm,
        runSpacing: Space.sm,
        children: <Widget>[
          for (final String e in kEquipment)
            SinewChip(
              shrink: true,
              label: equipmentLabel(e),
              selected: _picked.contains(e),
              onTap: () => setState(() {
                if (!_picked.remove(e)) _picked.add(e);
              }),
            ),
        ],
      ),
    );
  }
}
