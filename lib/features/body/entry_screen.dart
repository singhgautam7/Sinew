import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/ids.dart';
import '../../core/models/enums.dart';
import '../../core/models/measurement.dart';
import '../../core/models/profile.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/configs.dart';
import '../../core/widgets/domain/field_row.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_snackbar.dart';
import '../../core/widgets/sinew_states.dart';
import 'body_format.dart';
import 'body_model.dart';
import 'body_providers.dart';

/// Add or edit one dated entry. Every enabled field is a row; only the ones
/// with a typed value are stored. Last values show as grey hints and are
/// never saved by leaving them alone.
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, this.entryId, this.focusFieldId});

  /// Null starts a new entry.
  final String? entryId;

  /// A field to put the cursor in (from a tap on a silhouette level).
  final String? focusFieldId;

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  final TextEditingController _note = TextEditingController();
  final String _newEntryId = newId();

  bool _ready = false;
  bool _dirty = false;
  bool _saving = false;
  MeasurementEntry? _existing;
  late DateTime _today;
  late DateTime _date;
  final Map<String, double> _values = <String, double>{};
  Map<String, DatedValue> _previous = const <String, DatedValue>{};

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _init(List<MeasurementEntry> entries, DateTime now) {
    _ready = true;
    _today = dayOf(now);
    final String? id = widget.entryId;
    MeasurementEntry? existing;
    if (id != null) {
      for (final MeasurementEntry e in entries) {
        if (e.id == id) existing = e;
      }
    }
    _existing = existing;
    _date = existing == null ? dayOf(now) : dayOf(existing.date);
    _values
      ..clear()
      ..addAll(existing?.values ?? const <String, double>{});
    _note.text = existing?.note ?? '';
    _refreshPrevious(entries);
  }

  /// Hints: the last value of each field before this entry's date.
  void _refreshPrevious(List<MeasurementEntry> entries) {
    final List<MeasurementEntry> others = <MeasurementEntry>[
      for (final MeasurementEntry e in entries)
        if (e.id != _existing?.id) e,
    ];
    _previous = valuesAsOf(
      others,
      upTo: _existing == null && _date == _today
          ? null
          : _date.subtract(const Duration(milliseconds: 1)),
    );
  }

  Map<String, double> _cleanValues(List<MeasurementField> fields) {
    final Map<String, MeasurementField> byId = <String, MeasurementField>{
      for (final MeasurementField f in fields) f.id: f,
    };
    final Map<String, double> out = <String, double>{};
    for (final MapEntry<String, double> e in _values.entries) {
      final double v = e.value;
      if (!v.isFinite || v < 0) continue;
      final MeasurementUnitType? t = byId[e.key]?.unitType;
      final bool mayBeZero =
          t == MeasurementUnitType.count || t == MeasurementUnitType.custom;
      if (v == 0 && !mayBeZero) continue;
      out[e.key] = v;
    }
    return out;
  }

  Future<void> _pickDate(DateTime now, List<MeasurementEntry> entries) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(dayOf(now)) ? dayOf(now) : _date,
      firstDate: DateTime(BodySpec.firstYear),
      lastDate: dayOf(now),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = dayOf(picked);
      _dirty = true;
      _refreshPrevious(entries);
    });
  }

  Future<void> _save(List<MeasurementField> fields, DateTime now) async {
    if (_saving) return;
    final Map<String, double> values = _cleanValues(fields);
    if (values.isEmpty) {
      showSinewSnackBar(
        context,
        'Add at least one value to save this entry',
        isError: true,
      );
      return;
    }
    setState(() => _saving = true);
    final String note = _note.text.trim();
    final MeasurementEntry entry = MeasurementEntry(
      id: _existing?.id ?? _newEntryId,
      date: _date,
      values: values,
      note: note.isEmpty ? null : note,
      updatedAt: now,
    );
    try {
      await saveBodyEntry(ref, entry);
      if (!mounted) return;
      _dirty = false;
      context.pop();
    } on Object {
      if (!mounted) return;
      showSinewSnackBar(
        context,
        'Could not save this entry. Your values are still here.',
        isError: true,
      );
    } finally {
      if (mounted && _saving) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final MeasurementEntry? entry = _existing;
    if (entry == null) return;
    final bool ok = await showSinewConfirmDialog(
      context: context,
      title: 'Delete this entry?',
      message:
          'The ${entry.values.length} values saved on this date are removed '
          'from your history.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    // The screen is gone by the time Undo is tapped, so hold the container.
    final ProviderContainer container = ProviderScope.containerOf(context);
    await deleteBodyEntry(ref, entry.id);
    if (!mounted) return;
    _dirty = false;
    showSinewSnackBar(
      context,
      'Entry deleted',
      actionLabel: 'Undo',
      overlay: overlay,
      onAction: () async {
        await container.read(measurementRepositoryProvider).saveEntry(entry);
        container.invalidate(bodyEntriesProvider);
      },
    );
    context.pop();
  }

  Future<bool> _confirmDiscard() => showSinewConfirmDialog(
    context: context,
    title: 'Discard this entry?',
    message: 'The values you typed will be lost.',
    confirmLabel: 'Discard',
    destructive: true,
  );

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<MeasurementField>> fieldsAsync = ref.watch(
      bodyFieldsProvider,
    );
    final AsyncValue<Profile> profileAsync = ref.watch(currentProfileProvider);
    final AsyncValue<List<MeasurementEntry>> entriesAsync = ref.watch(
      bodyEntriesProvider,
    );
    final DateTime now = ref.watch(bodyNowProvider);
    final bool editing = widget.entryId != null;
    final String title = editing ? 'Edit entry' : 'New entry';

    final List<MeasurementField>? fields = fieldsAsync.value;
    final Profile? profile = profileAsync.value;
    final List<MeasurementEntry>? entries = entriesAsync.value;

    if (fields == null || profile == null || entries == null) {
      final Object? error =
          fieldsAsync.error ?? profileAsync.error ?? entriesAsync.error;
      return Scaffold(
        appBar: SinewAppBar(title: title, showBack: true, closeIcon: true),
        body: error != null
            ? SinewErrorState(
                title: 'Could not load this entry',
                description: 'Nothing was lost. Try again.',
                onRetry: () {
                  ref.invalidate(bodyFieldsProvider);
                  ref.invalidate(currentProfileProvider);
                  ref.invalidate(bodyEntriesProvider);
                },
              )
            : const Delayed(child: SinewLoader()),
      );
    }
    if (!_ready) _init(entries, now);

    if (editing && _existing == null) {
      return Scaffold(
        appBar: SinewAppBar(title: title, showBack: true, closeIcon: true),
        body: const SinewEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Entry not found',
          description: 'It may have been deleted.',
        ),
      );
    }

    final List<MeasurementField> shown = formFields(
      fields,
      _values,
      alsoShow: <String>{?widget.focusFieldId},
    );
    final List<FormRowSpec> rows = groupFormRows(shown);
    DateTime? hintDate;
    for (final MeasurementField f in shown) {
      final DatedValue? p = _previous[f.id];
      if (p != null && (hintDate == null || p.date.isAfter(hintDate))) {
        hintDate = p.date;
      }
    }

    void setValue(String id, double? v) {
      setState(() {
        _dirty = true;
        if (v == null) {
          _values.remove(id);
        } else {
          _values[id] = v;
        }
      });
    }

    Widget single(MeasurementField f) {
      final FieldUnit unit = fieldUnitFor(f, profile);
      final DatedValue? prev = _previous[f.id];
      final double? typed = _values[f.id];
      return FieldRow(
        key: ValueKey<String>(f.id),
        name: f.name,
        unit: unit,
        side: f.side,
        valueMetric: typed,
        previousMetric: prev?.value,
        previousLabel: prev == null ? null : bodyDateLabel(prev.date, now),
        deltaText: typed != null && prev != null
            ? signedDisplayDelta(unit, typed - prev.value)
            : null,
        autofocus: f.id == widget.focusFieldId,
        textInputAction: TextInputAction.next,
        onChanged: (double? v) => setValue(f.id, v),
      );
    }

    Widget pair(MeasurementField l, MeasurementField r) {
      final FieldUnit unit = fieldUnitFor(l, profile);
      return FieldPairRow(
        key: ValueKey<String>('${l.id}+${r.id}'),
        name: pairName(l, r),
        unit: unit,
        leftMetric: _values[l.id],
        rightMetric: _values[r.id],
        previousLeftMetric: _previous[l.id]?.value,
        previousRightMetric: _previous[r.id]?.value,
        onLeftChanged: (double? v) => setValue(l.id, v),
        onRightChanged: (double? v) => setValue(r.id, v),
      );
    }

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (bool didPop, Object? _) async {
        if (didPop) return;
        final bool discard = await _confirmDiscard();
        if (!discard || !context.mounted) return;
        setState(() => _dirty = false);
        if (context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: SinewAppBar(
          title: title,
          showBack: true,
          closeIcon: true,
          actions: <Widget>[
            AppButton(
              label: 'Save',
              type: AppButtonType.primary,
              height: Sizes.buttonSmall,
              isLoading: _saving,
              onPressed: () => _save(fields, now),
            ),
          ],
          overflowConfig: editing
              ? SinewOverflowConfig(
                  items: <SinewOverflowItem>[
                    SinewOverflowItem(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete entry',
                      isDestructive: true,
                      onTap: _delete,
                    ),
                  ],
                )
              : null,
        ),
        body: SafeArea(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.sm,
              Space.screen,
              Space.xxxl,
            ),
            children: <Widget>[
              SinewPickerRow(
                leading: const Icon(Icons.event_rounded),
                label: 'Date',
                value: bodyDateLabelLong(_date, now),
                onTap: () => _pickDate(now, entries),
              ),
              const SizedBox(height: Space.lg),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.xl),
                  child: Text(
                    'All fields are hidden. Turn some on in Measurement '
                    'fields.',
                    style: context.text.bodyMedium!.copyWith(
                      color: context.cs.onSurfaceVariant,
                    ),
                  ),
                )
              else
                SinewGroup(
                  children: <Widget>[
                    for (final FormRowSpec r in rows)
                      r.isPair ? pair(r.left!, r.right!) : single(r.field!),
                  ],
                ),
              if (hintDate != null) ...<Widget>[
                const SizedBox(height: Space.md),
                Text(
                  'Grey values are from ${bodyDateLabel(hintDate, now)}. '
                  'Leave them and they will not be saved for this date.',
                  style: context.text.bodySmall!.copyWith(
                    color: context.cs.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: Space.xl),
              SinewTextField(
                label: 'Note',
                optional: true,
                controller: _note,
                hint: 'How you measured, how you felt',
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (String _) => _dirty = true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
