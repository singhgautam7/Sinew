import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../core/models/plate_inventory.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/units.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/domain/numeric_stepper.dart';
import '../../core/widgets/domain/plate_loader.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_segmented_control.dart';
import '../../core/widgets/sinew_states.dart';
import '../../core/settings/haptics.dart';
import '../../core/widgets/sinew_settings.dart';
import '../../engines/plates/plates.dart';
import 'profile_form.dart';

/// Common pound plates. Stored as exact kilograms.
const List<double> kLbPlateSizes = <double>[45, 35, 25, 10, 5, 2.5];

/// Common kilogram plates.
const List<double> kKgPlateSizes = <double>[25, 20, 15, 10, 5, 2.5, 1.25];

/// Two weights are the same plate when they differ by less than this (kg).
const double _sameKg = 1e-4;

bool _same(double a, double b) => (a - b).abs() < _sameKg;

/// The plate sizes shown for [unit]: the standard set, plus any other size
/// the inventory already holds, heaviest first.
List<double> plateRows(PlateInventory inv, WeightUnit unit) {
  final List<double> standard = <double>[
    for (final double w
        in unit == WeightUnit.kg ? kKgPlateSizes : kLbPlateSizes)
      Units.toKg(w, unit),
  ];
  final List<double> rows = <double>[...standard];
  for (final PlateStock s in inv.plates) {
    if (!rows.any((double r) => _same(r, s.weightKg))) rows.add(s.weightKg);
  }
  rows.sort((double a, double b) => b.compareTo(a));
  return rows;
}

int _countOf(PlateInventory inv, double kg) {
  for (final PlateStock s in inv.plates) {
    if (_same(s.weightKg, kg)) return s.count;
  }
  return 0;
}

/// The heaviest load the inventory can make on [bar], from the engine's own
/// total so the number matches what the loader draws.
double heaviestKg(PlateInventory inv, Bar bar) {
  final int divisor = bar.isDumbbell ? 4 : 2;
  final List<double> perSide = <double>[
    for (final PlateStock s in inv.plates)
      for (int i = 0; i < s.count ~/ divisor; i++) s.weightKg,
  ];
  return PlateEngine.totalFor(bar, perSide);
}

/// Plates and bars: what you own, so loads can be drawn and rounded.
class PlatesScreen extends ConsumerWidget {
  const PlatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PlateInventory> inv = ref.watch(
      currentPlateInventoryProvider,
    );
    return Scaffold(
      appBar: const SinewAppBar(
        title: 'Plates and bars',
        subtitle: 'Used to draw and round your loads',
        showBack: true,
      ),
      body: inv.when(
        loading: () => const Delayed(child: SinewLoader()),
        error: (Object e, StackTrace st) => const SinewEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not load your plates',
          description: 'Your data is safe. Go back and try again.',
        ),
        data: (PlateInventory i) => _PlatesBody(inventory: i),
      ),
    );
  }
}

class _PlatesBody extends ConsumerStatefulWidget {
  const _PlatesBody({required this.inventory});

  final PlateInventory inventory;

  @override
  ConsumerState<_PlatesBody> createState() => _PlatesBodyState();
}

class _PlatesBodyState extends ConsumerState<_PlatesBody> {
  /// Preview: which bar, or the machine stack when null with [_machine].
  int _barIndex = 0;
  bool _machine = false;
  double _targetKg = 60;

  PlateInventory get inv => widget.inventory;

  Future<void> _save(PlateInventory next) =>
      ref.read(plateInventoryRepositoryProvider).save(next);

  Future<void> _setCount(double kg, int count) {
    final bool standard =
        (inv.unit == WeightUnit.kg ? kKgPlateSizes : kLbPlateSizes).any(
          (double w) => _same(Units.toKg(w, inv.unit), kg),
        );
    final List<PlateStock> next = <PlateStock>[
      for (final PlateStock s in inv.plates)
        if (!_same(s.weightKg, kg)) s,
      if (count > 0 || standard) PlateStock(weightKg: kg, count: count),
    ]..sort((PlateStock a, PlateStock b) => b.weightKg.compareTo(a.weightKg));
    return _save(inv.copyWith(plates: next));
  }

  Future<void> _editBar({Bar? existing}) async {
    final Object? picked = await showSinewBottomSheet<Object>(
      context: context,
      builder: (BuildContext c) =>
          _BarSheet(existing: existing, unit: inv.unit),
    );
    if (picked == _BarSheet.deleteResult && existing != null) {
      await _deleteBar(existing);
      return;
    }
    if (picked is! Bar) return;
    final Bar result = picked;
    final List<Bar> bars = <Bar>[...inv.bars];
    if (existing == null) {
      bars.add(result);
    } else {
      final int i = bars.indexOf(existing);
      if (i >= 0) bars[i] = result;
    }
    await _save(inv.copyWith(bars: bars));
  }

  Future<void> _deleteBar(Bar bar) async {
    final bool ok = await showSinewConfirmDialog(
      context: context,
      title: 'Delete ${bar.name}?',
      message: 'It will no longer appear when loading plates.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    await _save(inv.copyWith(bars: <Bar>[...inv.bars]..remove(bar)));
  }

  Future<void> _addPlate() async {
    final double? kg = await showSinewBottomSheet<double>(
      context: context,
      builder: (BuildContext c) => _PlateSizeSheet(unit: inv.unit),
    );
    if (kg == null) return;
    if (_countOf(inv, kg) == 0) await _setCount(kg, 2);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final WeightUnit unit = inv.unit;
    final List<Bar> bars = inv.bars;
    final int barIndex = bars.isEmpty ? 0 : _barIndex.clamp(0, bars.length - 1);
    final Bar? bar = bars.isEmpty ? null : bars[barIndex];
    final bool machine = _machine || bar == null;
    final double step = unit == WeightUnit.kg ? 2.5 : 5;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.xs,
        Space.screen,
        Space.bottomSafe,
      ),
      children: <Widget>[
        SinewCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (machine)
                PlateLoader.stack(
                  targetKg: _targetKg,
                  stepKg: inv.machineStepKg,
                  unit: unit,
                  haptics: ref.watch(hapticsEnabledProvider),
                )
              else
                PlateLoader(
                  result: PlateEngine.solve(
                    targetKg: _targetKg,
                    bar: bar,
                    inventory: inv,
                  ),
                  targetKg: _targetKg,
                  bar: bar,
                  unit: unit,
                  haptics: ref.watch(hapticsEnabledProvider),
                ),
              const SizedBox(height: Space.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    for (int i = 0; i < bars.length; i++) ...<Widget>[
                      SinewChip(
                        label: bars[i].name,
                        selected: !machine && i == barIndex,
                        onTap: () => setState(() {
                          _barIndex = i;
                          _machine = false;
                        }),
                      ),
                      const SizedBox(width: Space.sm),
                    ],
                    SinewChip(
                      label: 'Machine',
                      selected: machine,
                      onTap: () => setState(() => _machine = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.md),
              Center(
                child: NumericStepper(
                  value: Units.fromKg(_targetKg, unit),
                  step: step,
                  min: 0,
                  max: Units.fromKg(MoreSpec.previewMaxKg, unit),
                  unit: Units.weightLabel(unit),
                  maxDecimals: 2,
                  semanticLabel: 'Target weight',
                  haptics: ref.watch(hapticsEnabledProvider),
                  onChanged: (double v) =>
                      setState(() => _targetKg = Units.toKg(v, unit)),
                ),
              ),
              if (!machine) ...<Widget>[
                const SizedBox(height: Space.sm),
                Text(
                  'Heaviest you can load: '
                  '${Units.formatWeight(heaviestKg(inv, bar), unit)}',
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.section),
        const SinewSectionHeader(title: 'Plate set'),
        SinewSegmentedControl<WeightUnit>(
          values: WeightUnit.values,
          labels: const <String>['Kilograms', 'Pounds'],
          selected: unit,
          onSelected: (WeightUnit u) => _save(inv.copyWith(unit: u)),
        ),
        const SizedBox(height: Space.section),
        SinewSectionHeader(
          title: 'Bars',
          trailing: SinewSectionAction(
            label: 'Add bar',
            onTap: () => _editBar(),
          ),
        ),
        if (bars.isEmpty)
          const SinewCallout(
            tone: SinewCalloutTone.info,
            child: Text('No bars yet. Add one to draw barbell loads.'),
          )
        else
          SinewGroup(
            children: <Widget>[
              for (final Bar b in bars)
                SinewListRow(
                  title: b.name,
                  subtitle:
                      '${Units.formatWeight(b.weightKg, unit, maxDecimals: 2)}'
                      '${b.isDumbbell ? ' · dumbbell handle' : ''}',
                  leading: SinewIconTile(
                    icon: b.isDumbbell
                        ? Icons.fitness_center_rounded
                        : Icons.horizontal_rule_rounded,
                  ),
                  trailing: const SinewChevron(),
                  onTap: () => _editBar(existing: b),
                  onLongPress: () => _deleteBar(b),
                ),
            ],
          ),
        const SizedBox(height: Space.section),
        SinewSectionHeader(
          title: 'Plates you own',
          trailing: SinewSectionAction(label: 'Add size', onTap: _addPlate),
        ),
        SinewGroup(
          children: <Widget>[
            for (final double kg in plateRows(inv, unit))
              _PlateRow(
                key: ValueKey<String>(
                  'plate-${Units.trim(kg, maxDecimals: 4)}',
                ),
                kg: kg,
                unit: unit,
                count: _countOf(inv, kg),
                onChanged: (int n) => _setCount(kg, n),
              ),
          ],
        ),
        const SizedBox(height: Space.xs),
        Text(
          'Count single plates. They load in pairs, so 4 plates is 2 per '
          'side. A dumbbell handle uses a quarter of each size per hand.',
          style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: Space.section),
        const SinewSectionHeader(title: 'Machine stack'),
        SinewCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Weight step', style: tt.titleMedium),
                    Text(
                      'One plate on a selector stack',
                      style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              NumericStepper(
                key: const ValueKey<String>('machine-step'),
                value: Units.fromKg(inv.machineStepKg, unit),
                step: unit == WeightUnit.kg ? 0.5 : 1,
                min: unit == WeightUnit.kg ? 0.5 : 1,
                max: 50,
                unit: Units.weightLabel(unit),
                maxDecimals: 2,
                semanticLabel: 'Machine weight step',
                haptics: ref.watch(hapticsEnabledProvider),
                onChanged: (double v) =>
                    _save(inv.copyWith(machineStepKg: Units.toKg(v, unit))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlateRow extends ConsumerWidget {
  const _PlateRow({
    super.key,
    required this.kg,
    required this.unit,
    required this.count,
    required this.onChanged,
  });

  final double kg;
  final WeightUnit unit;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlateColor? colour = context.accents.plate(kg);
    final ColorScheme cs = context.cs;
    final String label = Units.formatWeight(kg, unit, maxDecimals: 2);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.sm,
      ),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Container(
              width: MoreSpec.plateSwatch,
              height: MoreSpec.plateSwatch,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colour?.fill ?? cs.surfaceContainerHigh,
                border: Border.all(
                  color: colour?.edge ?? cs.outline,
                  width: Strokes.focus,
                ),
              ),
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(child: Text(label, style: context.text.titleMedium)),
          NumericStepper(
            value: count.toDouble(),
            step: 1,
            min: 0,
            max: 99,
            maxDecimals: 0,
            semanticLabel: '$label plates',
            haptics: ref.watch(hapticsEnabledProvider),
            onChanged: (double v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

/// Add or edit a bar. Pops with the new [Bar].
class _BarSheet extends StatefulWidget {
  const _BarSheet({required this.existing, required this.unit});

  final Bar? existing;
  final WeightUnit unit;

  /// Popped instead of a [Bar] when the person taps Delete.
  static const String deleteResult = 'delete';

  @override
  State<_BarSheet> createState() => _BarSheetState();
}

class _BarSheetState extends State<_BarSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _weight = TextEditingController(
    text: widget.existing == null
        ? ''
        : Units.trim(Units.fromKg(widget.existing!.weightKg, widget.unit)),
  );
  late bool _dumbbell = widget.existing?.isDumbbell ?? false;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    super.dispose();
  }

  double? get _kg {
    final double? v = parseNumber(_weight.text);
    return v == null || v <= 0 ? null : Units.toKg(v, widget.unit);
  }

  bool get _valid => _name.text.trim().isNotEmpty && _kg != null;

  @override
  Widget build(BuildContext context) {
    return SinewBottomSheet(
      title: widget.existing == null ? 'Add bar' : 'Edit bar',
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppButton(
            label: 'Save',
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: _valid
                ? () => Navigator.of(context).pop(
                    Bar(
                      name: _name.text.trim(),
                      weightKg: _kg!,
                      isDumbbell: _dumbbell,
                    ),
                  )
                : null,
          ),
          if (widget.existing != null) ...<Widget>[
            const SizedBox(height: Space.sm),
            AppButton(
              label: 'Delete',
              type: AppButtonType.outline,
              fullWidth: true,
              onPressed: () =>
                  Navigator.of(context).pop(_BarSheet.deleteResult),
            ),
          ],
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SinewTextField(
            key: const ValueKey<String>('bar-name'),
            textInputAction: TextInputAction.next,
            label: 'Name',
            controller: _name,
            hint: 'Olympic bar',
            textCapitalization: TextCapitalization.sentences,
            onChanged: (String _) => setState(() {}),
          ),
          const SizedBox(height: Space.lg),
          SinewTextField.number(
            key: const ValueKey<String>('bar-weight'),
            textInputAction: TextInputAction.done,
            label: 'Weight',
            controller: _weight,
            suffixText: Units.weightLabel(widget.unit),
            onChanged: (String _) => setState(() {}),
          ),
          const SizedBox(height: Space.md),
          SinewSwitchRow(
            icon: Icons.fitness_center_rounded,
            card: true,
            label: 'Dumbbell handle',
            subtitle: 'Loaded one per hand, with plates on both ends',
            value: _dumbbell,
            onChanged: (bool v) => setState(() => _dumbbell = v),
          ),
        ],
      ),
    );
  }
}

/// Add a plate size. Pops with its weight in kilograms.
class _PlateSizeSheet extends StatefulWidget {
  const _PlateSizeSheet({required this.unit});

  final WeightUnit unit;

  @override
  State<_PlateSizeSheet> createState() => _PlateSizeSheetState();
}

class _PlateSizeSheetState extends State<_PlateSizeSheet> {
  final TextEditingController _weight = TextEditingController();

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  double? get _kg {
    final double? v = parseNumber(_weight.text);
    return v == null || v <= 0 ? null : Units.toKg(v, widget.unit);
  }

  @override
  Widget build(BuildContext context) {
    return SinewBottomSheet(
      title: 'Add a plate size',
      actions: AppButton(
        label: 'Add',
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: _kg == null ? null : () => Navigator.of(context).pop(_kg),
      ),
      child: SinewTextField.number(
        key: const ValueKey<String>('plate-weight'),
        textInputAction: TextInputAction.done,
        label: 'Weight',
        controller: _weight,
        suffixText: Units.weightLabel(widget.unit),
        onChanged: (String _) => setState(() {}),
      ),
    );
  }
}
