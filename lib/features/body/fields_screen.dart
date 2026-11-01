import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/measurement_repository.dart';
import '../../core/models/measurement.dart';
import '../../core/models/profile.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/domain/field_row.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_menu.dart';
import '../../core/widgets/sinew_snackbar.dart';
import '../../core/widgets/sinew_states.dart';
import 'body_format.dart';
import 'body_providers.dart';
import 'field_edit_sheet.dart';

/// Which fields exist, which show on new entries, and in what order. Built-in
/// fields can be renamed and hidden; custom ones can also be edited and
/// removed (deleted when empty, archived when they hold data).
class FieldsScreen extends ConsumerStatefulWidget {
  const FieldsScreen({super.key});

  @override
  ConsumerState<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends ConsumerState<FieldsScreen> {
  /// The order shown while a save is in flight, so a drop never snaps back.
  List<String>? _pendingOrder;
  Profile _profile = const Profile();

  static const String _edit = 'edit';
  static const String _remove = 'remove';

  List<MeasurementField> _ordered(List<MeasurementField> live) {
    final List<String>? pending = _pendingOrder;
    if (pending == null) return live;
    final Map<String, MeasurementField> byId = <String, MeasurementField>{
      for (final MeasurementField f in live) f.id: f,
    };
    return <MeasurementField>[
      for (final String id in pending)
        if (byId.containsKey(id)) byId[id]!,
      for (final MeasurementField f in live)
        if (!pending.contains(f.id)) f,
    ];
  }

  Future<void> _reorder(
    List<MeasurementField> builtIn,
    List<MeasurementField> custom,
    bool inBuiltIn,
    int oldIndex,
    int newIndex,
  ) async {
    final List<MeasurementField> section = inBuiltIn
        ? <MeasurementField>[...builtIn]
        : <MeasurementField>[...custom];
    section.insert(newIndex, section.removeAt(oldIndex));
    final List<String> ids = <String>[
      for (final MeasurementField f in inBuiltIn ? section : builtIn) f.id,
      for (final MeasurementField f in inBuiltIn ? custom : section) f.id,
    ];
    setState(() => _pendingOrder = ids);
    await ref.read(measurementRepositoryProvider).reorderFields(ids);
    if (mounted) setState(() => _pendingOrder = null);
  }

  Future<void> _setEnabled(MeasurementField f, bool on) => ref
      .read(measurementRepositoryProvider)
      .saveField(f.copyWith(enabled: on));

  Future<void> _openEditor(
    List<MeasurementField> all, {
    MeasurementField? field,
  }) async {
    final MeasurementRepository repo = ref.read(measurementRepositoryProvider);
    final bool hasData = field != null && await repo.fieldHasData(field.id);
    if (!mounted) return;
    final int next = all.isEmpty
        ? 0
        : all
                  .map((MeasurementField f) => f.position)
                  .reduce((int a, int b) => a > b ? a : b) +
              1;
    final List<MeasurementField>? result = await showFieldEditSheet(
      context,
      field: field,
      nextPosition: next,
      hasData: hasData,
      now: ref.read(bodyNowProvider),
    );
    if (result == null) return;
    for (final MeasurementField f in result) {
      await repo.saveField(f);
    }
  }

  Future<void> _removeField(MeasurementField f) async {
    final MeasurementRepository repo = ref.read(measurementRepositoryProvider);
    final bool hasData = await repo.fieldHasData(f.id);
    if (!mounted) return;
    final bool ok = await showSinewConfirmDialog(
      context: context,
      title: 'Remove ${f.name}?',
      message: hasData
          ? 'It has saved values, so it is archived instead of deleted. '
                'It disappears from new entries and your history keeps its '
                'numbers.'
          : 'It has no values yet, so it is deleted.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!ok || !mounted) return;
    final FieldRemoval result = await repo.removeField(f.id);
    if (!mounted) return;
    showSinewSnackBar(
      context,
      result == FieldRemoval.deleted
          ? '${f.name} deleted'
          : '${f.name} archived. Its past values are kept.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<MeasurementField>> async = ref.watch(
      bodyFieldsProvider,
    );
    final List<MeasurementField>? data = async.value;
    _profile = ref.watch(bodyProfileProvider).value ?? const Profile();
    final List<MeasurementField> live = data == null
        ? const <MeasurementField>[]
        : _ordered(<MeasurementField>[
            for (final MeasurementField f in data)
              if (!f.archived) f,
          ]);
    final List<MeasurementField> builtIn = <MeasurementField>[
      for (final MeasurementField f in live)
        if (f.builtIn) f,
    ];
    final List<MeasurementField> custom = <MeasurementField>[
      for (final MeasurementField f in live)
        if (!f.builtIn) f,
    ];
    final int shown = live.where((MeasurementField f) => f.enabled).length;

    return Scaffold(
      appBar: SinewAppBar(
        title: 'Measurement fields',
        subtitle: data == null
            ? null
            : '$shown of ${live.length} shown on new entries',
        showBack: true,
      ),
      body: data == null
          ? (async.hasError
                ? const SinewEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load fields',
                    description: 'Nothing was lost. Go back and try again.',
                  )
                : const Delayed(child: SinewLoader()))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.sm,
                  Space.lg,
                  Space.xxxl,
                ),
                children: <Widget>[
                  const SinewSectionHeader(title: 'Built in'),
                  _section(builtIn, builtIn, custom, true, live),
                  const SizedBox(height: Space.section),
                  const SinewSectionHeader(title: 'Custom'),
                  if (custom.isNotEmpty)
                    _section(custom, builtIn, custom, false, live),
                  if (custom.isNotEmpty) const SizedBox(height: Space.lg),
                  AppButton(
                    label: 'Add custom field',
                    icon: Icons.add_rounded,
                    type: AppButtonType.dotted,
                    fullWidth: true,
                    onPressed: () => _openEditor(live),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _section(
    List<MeasurementField> rows,
    List<MeasurementField> builtIn,
    List<MeasurementField> custom,
    bool inBuiltIn,
    List<MeasurementField> live,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: Radii.cardR,
        border: Border.all(color: context.cs.outlineVariant),
      ),
      position: DecorationPosition.foreground,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.cs.surfaceContainer,
          borderRadius: Radii.cardR,
        ),
        child: ClipRRect(
          borderRadius: Radii.cardR,
          child: Material(
            type: MaterialType.transparency,
            child: ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: (int from, int to) =>
                  _reorder(builtIn, custom, inBuiltIn, from, to),
              children: <Widget>[
                for (int i = 0; i < rows.length; i++) _row(rows[i], i, live),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(MeasurementField f, int index, List<MeasurementField> live) {
    final FieldUnit unit = fieldUnitFor(f, _profile);
    return KeyedSubtree(
      key: ValueKey<String>(f.id),
      child: FieldManagerRow(
        name: f.name,
        meta: '${unit.label} · ${anchorMeta(f.bodyAnchor)}',
        fieldEnabled: f.enabled,
        paired: f.pairId != null,
        onEnabledChanged: (bool v) => _setEnabled(f, v),
        onTap: () => _openEditor(live, field: f),
        dragHandle: ReorderableDragStartListener(
          index: index,
          child: Semantics(
            label: 'Reorder ${f.name}',
            child: Center(
              child: Icon(
                Icons.drag_indicator_rounded,
                size: IconSpec.size,
                color: context.cs.outline,
              ),
            ),
          ),
        ),
        overflow: <SinewMenuEntry<String>>[
          const SinewMenuEntry<String>(
            value: _edit,
            label: 'Edit',
            icon: Icons.edit_outlined,
          ),
          if (!f.builtIn)
            const SinewMenuEntry<String>(
              value: _remove,
              label: 'Remove',
              icon: Icons.delete_outline_rounded,
              destructive: true,
            ),
        ],
        onOverflow: (String v) {
          if (v == _edit) _openEditor(live, field: f);
          if (v == _remove) _removeField(f);
        },
      ),
    );
  }
}
