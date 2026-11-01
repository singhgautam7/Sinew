import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/enums.dart';
import '../../theme/app_theme.dart';
import '../../units/units.dart';
import '../app_icon_button.dart';
import '../sinew_list.dart';
import '../sinew_menu.dart';

/// How a field's metric value is shown and typed. Storage is always metric;
/// the row converts at its edge with these two functions and nowhere else.
@immutable
class FieldUnit {
  const FieldUnit({
    required this.label,
    required this.toDisplay,
    required this.toMetric,
    this.decimals = 1,
  });

  /// A unit that needs no conversion: percent, count or a custom label.
  factory FieldUnit.plain(String label, {int decimals = 1}) => FieldUnit(
    label: label,
    toDisplay: _identity,
    toMetric: _identity,
    decimals: decimals,
  );

  /// Body lengths stored in cm.
  factory FieldUnit.length(LengthUnit unit) => FieldUnit(
    label: Units.lengthLabel(unit),
    toDisplay: (double cm) => Units.fromCm(cm, unit),
    toMetric: (double v) => Units.toCm(v, unit),
  );

  /// Body weight stored in kg.
  factory FieldUnit.weight(WeightUnit unit) => FieldUnit(
    label: Units.weightLabel(unit),
    toDisplay: (double kg) => Units.fromKg(kg, unit),
    toMetric: (double v) => Units.toKg(v, unit),
  );

  /// The unit shown beside the number: "cm", "in", "kg".
  final String label;

  /// Metric to display unit.
  final double Function(double metric) toDisplay;

  /// Display unit to metric.
  final double Function(double display) toMetric;
  final int decimals;

  static double _identity(double v) => v;

  /// A trimmed display number for a metric value: "34.5".
  String format(double metric) =>
      Units.trim(toDisplay(metric), maxDecimals: decimals);
}

String _sideWord(BodySide s) => switch (s) {
  BodySide.left => 'left',
  BodySide.right => 'right',
  BodySide.none => '',
};

String? _sideTag(BodySide s) => switch (s) {
  BodySide.left => 'L',
  BodySide.right => 'R',
  BodySide.none => null,
};

/// The small "L", "R" or "L / R" tag beside a field name.
class _SideTag extends StatelessWidget {
  const _SideTag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FieldSpec.tagPadH,
        vertical: FieldSpec.tagPadV,
      ),
      decoration: BoxDecoration(
        color: context.cs.surfaceContainerHigh,
        borderRadius: Radii.extraSmallR,
      ),
      child: Text(
        text,
        maxLines: 1,
        style: context.text.labelSmall!.copyWith(
          color: context.cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// The numeric box shared by the entry rows: shows the metric value in the
/// display unit, reports edits back in metric.
class _NumberInput extends StatefulWidget {
  const _NumberInput({
    required this.unit,
    required this.valueMetric,
    required this.previousMetric,
    required this.onChanged,
    required this.enabled,
    required this.semanticLabel,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.estimated = false,
  });

  final FieldUnit unit;
  final double? valueMetric;
  final double? previousMetric;
  final ValueChanged<double?>? onChanged;
  final bool enabled;
  final String semanticLabel;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool estimated;

  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _textFor(widget.valueMetric));
  }

  String _textFor(double? metric) =>
      metric == null ? '' : widget.unit.format(metric);

  double? _parse(String text) => double.tryParse(text.replaceAll(',', '.'));

  double? get _typedMetric {
    final double? v = _parse(_c.text);
    return v == null ? null : widget.unit.toMetric(v);
  }

  @override
  void didUpdateWidget(_NumberInput old) {
    super.didUpdateWidget(old);
    final bool unitChanged = old.unit.label != widget.unit.label;
    final double? typed = _typedMetric;
    final double? want = widget.valueMetric;
    final bool same = typed == null || want == null
        ? typed == want
        : widget.unit.format(typed) == widget.unit.format(want);
    // Leave what the user is typing alone unless the value really moved.
    if (unitChanged || (!same && old.valueMetric != want)) {
      _c.text = _textFor(want);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Semantics(
      label: widget.semanticLabel,
      child: TextField(
        controller: _c,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        textAlign: TextAlign.end,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: widget.textInputAction,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        onChanged: (String _) => widget.onChanged?.call(_typedMetric),
        onTapOutside: (PointerDownEvent _) =>
            FocusManager.instance.primaryFocus?.unfocus(),
        style: tt.titleMedium!.copyWith(
          color: widget.estimated ? cs.onSurfaceVariant : cs.onSurface,
          fontStyle: widget.estimated ? FontStyle.italic : FontStyle.normal,
        ),
        decoration: InputDecoration(
          hintText: widget.previousMetric == null
              ? null
              : widget.unit.format(widget.previousMetric!),
          hintStyle: tt.titleMedium!.copyWith(color: cs.onSurfaceVariant),
          suffixText: widget.unit.label,
          suffixStyle: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// A measurement entry row: the field name with an optional L / R tag, the
/// unit, what it was last time, and a numeric box.
///
/// [valueMetric] and [previousMetric] are stored (metric) values; the box
/// shows them in [unit] and [onChanged] reports what was typed converted back
/// to metric, or null when the box is empty. The previous value shows as a
/// grey hint inside the box, so leaving the box alone means "no new value".
/// At large text sizes the box drops under the name.
class FieldRow extends StatelessWidget {
  const FieldRow({
    super.key,
    required this.name,
    required this.unit,
    required this.onChanged,
    this.valueMetric,
    this.previousMetric,
    this.previousLabel,
    this.deltaText,
    this.side = BodySide.none,
    this.estimated = false,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  final String name;
  final FieldUnit unit;
  final ValueChanged<double?>? onChanged;
  final double? valueMetric;
  final double? previousMetric;

  /// The date of [previousMetric], "24 Oct".
  final String? previousLabel;

  /// Change against the previous value, already formatted ("+0.5").
  final String? deltaText;
  final BodySide side;

  /// The value is derived, not entered: shown muted with an "Estimated" pill.
  final bool estimated;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  /// Above this text scale the box moves under the name.
  static const double _stackFrom = 1.3;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final String? tag = _sideTag(side);
    final String spokenSide = _sideWord(side);
    final bool stacked = MediaQuery.textScalerOf(context).scale(1) > _stackFrom;

    final List<String> sub = <String>[
      unit.label,
      if (previousMetric != null)
        'last ${unit.format(previousMetric!)}'
            '${previousLabel == null ? '' : ', $previousLabel'}',
    ];
    final Widget title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(name, style: tt.titleMedium),
            if (tag != null) _SideTag(tag),
            if (estimated)
              const SinewPill(label: 'Estimated', tone: SinewTone.neutral),
          ],
        ),
        Text(
          sub.join(' · '),
          style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        ),
        if (deltaText != null)
          Text(deltaText!, style: tt.labelMedium!.copyWith(color: cs.primary)),
      ],
    );
    final Widget input = _NumberInput(
      unit: unit,
      valueMetric: valueMetric,
      previousMetric: previousMetric,
      onChanged: onChanged,
      enabled: enabled,
      estimated: estimated,
      focusNode: focusNode,
      textInputAction: textInputAction,
      autofocus: autofocus,
      semanticLabel:
          '$name${spokenSide.isEmpty ? '' : ' $spokenSide'}, ${unit.label}',
    );
    return Opacity(
      opacity: enabled ? 1 : Opacities.disabled,
      child: Container(
        constraints: const BoxConstraints(minHeight: Space.listItem2),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.listRowPadH,
          vertical: Space.md,
        ),
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ExcludeSemantics(child: title),
                  const SizedBox(height: Space.sm),
                  input,
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(child: ExcludeSemantics(child: title)),
                  const SizedBox(width: FieldSpec.inputGap),
                  SizedBox(width: FieldSpec.inputWidth, child: input),
                ],
              ),
      ),
    );
  }
}

/// A left and right entry in one row (Bicep L 34.0 / R 33.5).
class FieldPairRow extends StatelessWidget {
  const FieldPairRow({
    super.key,
    required this.name,
    required this.unit,
    required this.onLeftChanged,
    required this.onRightChanged,
    this.leftMetric,
    this.rightMetric,
    this.previousLeftMetric,
    this.previousRightMetric,
    this.enabled = true,
  });

  final String name;
  final FieldUnit unit;
  final ValueChanged<double?>? onLeftChanged;
  final ValueChanged<double?>? onRightChanged;
  final double? leftMetric;
  final double? rightMetric;
  final double? previousLeftMetric;
  final double? previousRightMetric;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    Widget side(
      String word,
      double? value,
      double? prev,
      ValueChanged<double?>? cb,
    ) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _NumberInput(
              unit: unit,
              valueMetric: value,
              previousMetric: prev,
              onChanged: cb,
              enabled: enabled,
              semanticLabel: '$name $word, ${unit.label}',
            ),
            const SizedBox(height: Space.xs),
            ExcludeSemantics(
              child: Text(
                '$word · ${unit.label}',
                textAlign: TextAlign.end,
                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    return Opacity(
      opacity: enabled ? 1 : Opacities.disabled,
      child: Container(
        constraints: const BoxConstraints(minHeight: Space.listItem2),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.listRowPadH,
          vertical: Space.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(name, style: tt.titleMedium),
            const SizedBox(height: Space.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                side('left', leftMetric, previousLeftMetric, onLeftChanged),
                const SizedBox(width: FieldSpec.inputGap),
                side('right', rightMetric, previousRightMetric, onRightChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The row in the measurement fields manager: a drag handle slot, the field
/// name with an L / R tag, a meta line ("cm, Silhouette: waist"), an enabled
/// switch and an overflow menu.
///
/// [dragHandle] is a slot: wrap it in a `ReorderableDragStartListener` in the
/// list; left null it shows a static handle glyph.
class FieldManagerRow extends StatelessWidget {
  const FieldManagerRow({
    super.key,
    required this.name,
    required this.meta,
    required this.fieldEnabled,
    required this.onEnabledChanged,
    this.paired = false,
    this.dragHandle,
    this.overflow = const <SinewMenuEntry<String>>[],
    this.onOverflow,
    this.onTap,
  });

  final String name;
  final String meta;

  /// Whether the field shows on new entries.
  final bool fieldEnabled;
  final ValueChanged<bool>? onEnabledChanged;

  /// Left and right are logged separately: shows the "L / R" tag.
  final bool paired;
  final Widget? dragHandle;
  final List<SinewMenuEntry<String>> overflow;
  final ValueChanged<String>? onOverflow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Widget row = Container(
      constraints: const BoxConstraints(
        minHeight: FieldSpec.switchRowMinHeight,
      ),
      padding: const EdgeInsets.fromLTRB(
        Space.sm,
        Space.md,
        Space.sm,
        Space.md,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: IconSpec.tapTarget,
            height: IconSpec.tapTarget,
            child:
                dragHandle ??
                ExcludeSemantics(
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    size: IconSpec.size,
                    color: cs.outline,
                  ),
                ),
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium,
                    ),
                    if (paired) const _SideTag('L / R'),
                  ],
                ),
                Text(
                  meta,
                  style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: Space.sm),
          Semantics(
            label: 'Show $name on new entries',
            toggled: fieldEnabled,
            excludeSemantics: true,
            onTap: onEnabledChanged == null
                ? null
                : () => onEnabledChanged!(!fieldEnabled),
            child: Switch(value: fieldEnabled, onChanged: onEnabledChanged),
          ),
          if (overflow.isNotEmpty)
            Builder(
              builder: (BuildContext ctx) => AppIconButton(
                icon: Icons.more_vert_rounded,
                kind: AppIconButtonKind.plain,
                semanticLabel: 'More options for $name',
                onPressed: () async {
                  final String? v = await showSinewMenu<String>(
                    context: ctx,
                    entries: overflow,
                  );
                  if (v != null) onOverflow?.call(v);
                },
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
