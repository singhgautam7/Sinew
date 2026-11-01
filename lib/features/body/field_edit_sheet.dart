import 'package:flutter/material.dart';

import '../../core/db/ids.dart';
import '../../core/models/enums.dart';
import '../../core/models/measurement.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/domain/silhouette_view.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_settings.dart';
import 'body_format.dart';

/// Opens the field editor. [field] null adds a custom field; [nextPosition]
/// is where a new one goes. [hasData] locks the unit of a field that already
/// has values (their meaning would change). Resolves with the field or
/// fields to save (a left and right pair is two), or null when dismissed.
Future<List<MeasurementField>?> showFieldEditSheet(
  BuildContext context, {
  MeasurementField? field,
  required int nextPosition,
  required bool hasData,
  required DateTime now,
}) {
  return showSinewBottomSheet<List<MeasurementField>>(
    context: context,
    builder: (BuildContext _) => _FieldEditor(
      field: field,
      nextPosition: nextPosition,
      hasData: hasData,
      now: now,
    ),
  );
}

class _FieldEditor extends StatefulWidget {
  const _FieldEditor({
    required this.field,
    required this.nextPosition,
    required this.hasData,
    required this.now,
  });

  final MeasurementField? field;
  final int nextPosition;
  final bool hasData;
  final DateTime now;

  @override
  State<_FieldEditor> createState() => _FieldEditorState();
}

class _FieldEditorState extends State<_FieldEditor> {
  late final TextEditingController _name = TextEditingController(
    text: widget.field?.name ?? '',
  );
  late final TextEditingController _unit = TextEditingController(
    text: widget.field?.customUnit ?? '',
  );
  late MeasurementUnitType _type =
      widget.field?.unitType ?? MeasurementUnitType.length;
  late BodyAnchor? _anchor = widget.field?.bodyAnchor;
  bool _pair = false;

  bool get _builtIn => widget.field?.builtIn ?? false;
  bool get _isNew => widget.field == null;
  bool get _unitLocked => _builtIn || (!_isNew && widget.hasData);

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      (_type != MeasurementUnitType.custom || _unit.text.trim().isNotEmpty);

  void _done() {
    final String name = _name.text.trim();
    final String? unitLabel = _type == MeasurementUnitType.custom
        ? _unit.text.trim()
        : null;
    final BodyAnchor? anchor = _type == MeasurementUnitType.length
        ? _anchor
        : null;
    final MeasurementField? existing = widget.field;
    if (existing != null) {
      Navigator.of(context, rootNavigator: true).pop(<MeasurementField>[
        existing.copyWith(
          name: name,
          unitType: _builtIn ? existing.unitType : _type,
          customUnit: _builtIn ? existing.customUnit : unitLabel,
          bodyAnchor: _builtIn ? existing.bodyAnchor : anchor,
        ),
      ]);
      return;
    }
    if (_pair) {
      final String pairId = newId();
      MeasurementField side(BodySide s, int offset) => MeasurementField(
        id: newId(),
        name: '${s == BodySide.left ? 'Left' : 'Right'} ${name.toLowerCase()}',
        unitType: _type,
        customUnit: unitLabel,
        side: s,
        pairId: pairId,
        bodyAnchor: anchor,
        position: widget.nextPosition + offset,
        updatedAt: widget.now,
      );
      Navigator.of(context, rootNavigator: true).pop(<MeasurementField>[
        side(BodySide.left, 0),
        side(BodySide.right, 1),
      ]);
      return;
    }
    Navigator.of(context, rootNavigator: true).pop(<MeasurementField>[
      MeasurementField(
        id: newId(),
        name: name,
        unitType: _type,
        customUnit: unitLabel,
        bodyAnchor: anchor,
        position: widget.nextPosition,
        updatedAt: widget.now,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    return SinewBottomSheet(
      title: _isNew ? 'New field' : 'Edit field',
      subtitle: _builtIn ? 'Built in' : null,
      actions: AppButton(
        label: 'Done',
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: _valid ? _done : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SinewTextField(
            label: 'Name',
            controller: _name,
            hint: 'Wrist',
            textCapitalization: TextCapitalization.sentences,
            onChanged: (String _) => setState(() {}),
          ),
          const SizedBox(height: Space.xl),
          if (_builtIn)
            Text(
              'Built-in fields keep their unit and place on the silhouette. '
              'You can rename them or hide them from new entries.',
              style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            )
          else ...<Widget>[
            Text('UNIT', style: context.sectionHeader),
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: <Widget>[
                for (final MeasurementUnitType t in MeasurementUnitType.values)
                  SinewChip(
                    label: unitTypeLabel(t),
                    shrink: true,
                    selected: _type == t,
                    enabled: !_unitLocked || _type == t,
                    onTap: _unitLocked ? null : () => setState(() => _type = t),
                  ),
              ],
            ),
            if (_unitLocked)
              Padding(
                padding: const EdgeInsets.only(top: Space.sm),
                child: Text(
                  'The unit is fixed because this field already has values.',
                  style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            if (_type == MeasurementUnitType.custom) ...<Widget>[
              const SizedBox(height: Space.lg),
              SinewTextField(
                label: 'Unit label',
                controller: _unit,
                hint: 'reps, mmHg, cups',
                enabled: !_unitLocked,
                onChanged: (String _) => setState(() {}),
              ),
            ],
            if (_isNew) ...<Widget>[
              const SizedBox(height: Space.lg),
              SinewSwitchRow(
                icon: Icons.swap_horiz_rounded,
                label: 'Left and right',
                subtitle: 'Log each side separately',
                value: _pair,
                onChanged: (bool v) => setState(() => _pair = v),
              ),
            ],
            if (_type == MeasurementUnitType.length) ...<Widget>[
              const SizedBox(height: Space.xl),
              Text('DRAW ON SILHOUETTE AT', style: context.sectionHeader),
              const SizedBox(height: Space.sm),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: <Widget>[
                  for (final BodyAnchor a in BodyAnchor.values)
                    SinewChip(
                      label: bodyAnchorLabel(a),
                      shrink: true,
                      selected: _anchor == a,
                      onTap: () => setState(() => _anchor = a),
                    ),
                  SinewChip(
                    label: 'None',
                    shrink: true,
                    selected: _anchor == null,
                    onTap: () => setState(() => _anchor = null),
                  ),
                ],
              ),
            ],
          ],
          const SizedBox(height: Space.lg),
        ],
      ),
    );
  }
}
