import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/picker_palette.dart';
import 'app_button.dart';
import 'sinew_bottom_sheet.dart';
import 'sinew_form.dart';
import 'sinew_segmented_control.dart';

/// What the picker edits: an icon key, an ARGB colour and a free-form bag for
/// extra tabs (the "Muscle map" tab keeps its choice under its own key).
@immutable
class SinewIconColor {
  const SinewIconColor({
    required this.iconKey,
    this.colorValue = SinewPickerPalette.defaultColor,
    this.extra = const <String, Object?>{},
  });

  final String iconKey;
  final int colorValue;
  final Map<String, Object?> extra;

  SinewIconColor copyWith({
    String? iconKey,
    int? colorValue,
    Map<String, Object?>? extra,
  }) => SinewIconColor(
    iconKey: iconKey ?? this.iconKey,
    colorValue: colorValue ?? this.colorValue,
    extra: extra ?? this.extra,
  );
}

/// One tab of the picker. The built-in ones are [SinewPickerTab.iconId] and
/// [SinewPickerTab.colourId]; pass more through `extraTabs` (the handoff wants
/// a third "Muscle map" tab). [builder] draws the tab body from the working
/// value and reports edits through `onChanged`.
class SinewPickerTab {
  const SinewPickerTab({
    required this.id,
    required this.label,
    required this.title,
    required this.builder,
  });

  static const String iconId = 'icon';
  static const String colourId = 'colour';

  final String id;

  /// Segment label.
  final String label;

  /// Sheet title while this tab is open ("Choose icon").
  final String title;
  final Widget Function(
    BuildContext context,
    SinewIconColor value,
    ValueChanged<SinewIconColor> onChanged,
  )
  builder;
}

/// A round swatch: the chosen colour with the chosen icon on it, ink chosen
/// for contrast. Decorative (the row around it carries the label).
class SinewLeadingSwatch extends StatelessWidget {
  const SinewLeadingSwatch({
    super.key,
    required this.color,
    required this.icon,
    this.size = Sizes.pickerTile,
  });

  final Color color;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: size / 2, color: _tickColor(context, color)),
      ),
    );
  }
}

/// Ink that reads on [swatch]: a light tick on dark swatches and a dark one on
/// light swatches, in both themes.
Color _tickColor(BuildContext context, Color swatch) {
  final ColorScheme cs = context.cs;
  final bool swatchIsLight =
      ThemeData.estimateBrightnessForColor(swatch) == Brightness.light;
  final bool dark = cs.brightness == Brightness.dark;
  final Color lightTick = dark ? cs.onSurface : cs.surface;
  final Color darkTick = dark ? cs.surface : cs.onSurface;
  return swatchIsLight ? darkTick : lightTick;
}

/// The "Icon & colour" picker row: a live swatch in the chosen icon and
/// colour, [valueLabel] as the value and [label] under it. Opens the picker
/// through [onTap] (call [showIconColorPicker]).
class SinewIconColorPickerRow extends StatelessWidget {
  const SinewIconColorPickerRow({
    super.key,
    required this.icon,
    required this.colorValue,
    required this.label,
    required this.valueLabel,
    required this.onTap,
  });

  final IconData icon;
  final int colorValue;
  final String label;
  final String valueLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SinewPickerRow(
      leading: SinewLeadingSwatch(color: Color(colorValue), icon: icon),
      label: label,
      value: valueLabel,
      onTap: onTap,
    );
  }
}

/// The Icon / Colour bottom sheet: segmented tabs, the icon search + grid or
/// the colour banks, and Done. Picks stay local until Done, which reports the
/// value through [onDone]; closing discards them.
///
/// [icons] maps an icon key (what is stored) to its glyph. [extraTabs] append
/// more tabs after Icon and Colour.
Future<void> showIconColorPicker({
  required BuildContext context,
  required Map<String, IconData> icons,
  required SinewIconColor initial,
  required ValueChanged<SinewIconColor> onDone,
  List<SinewPickerTab> extraTabs = const <SinewPickerTab>[],
  String initialTabId = SinewPickerTab.iconId,
}) {
  return showSinewBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => _IconColorSheet(
      icons: icons,
      initial: initial,
      onDone: onDone,
      extraTabs: extraTabs,
      initialTabId: initialTabId,
    ),
  );
}

class _IconColorSheet extends StatefulWidget {
  const _IconColorSheet({
    required this.icons,
    required this.initial,
    required this.onDone,
    required this.extraTabs,
    required this.initialTabId,
  });

  final Map<String, IconData> icons;
  final SinewIconColor initial;
  final ValueChanged<SinewIconColor> onDone;
  final List<SinewPickerTab> extraTabs;
  final String initialTabId;

  @override
  State<_IconColorSheet> createState() => _IconColorSheetState();
}

class _IconColorSheetState extends State<_IconColorSheet> {
  late SinewIconColor _value = widget.initial;
  late String _tab = widget.initialTabId;

  List<SinewPickerTab> get _tabs => <SinewPickerTab>[
    SinewPickerTab(
      id: SinewPickerTab.iconId,
      label: 'Icon',
      title: 'Choose icon',
      builder:
          (BuildContext c, SinewIconColor v, ValueChanged<SinewIconColor> on) =>
              SinewIconPickerBody(
                icons: widget.icons,
                selected: v.iconKey,
                onSelected: (String k) => on(v.copyWith(iconKey: k)),
              ),
    ),
    SinewPickerTab(
      id: SinewPickerTab.colourId,
      label: 'Colour',
      title: 'Choose colour',
      builder:
          (BuildContext c, SinewIconColor v, ValueChanged<SinewIconColor> on) =>
              SinewColorPickerBody(
                selected: v.colorValue,
                onSelected: (int k) => on(v.copyWith(colorValue: k)),
              ),
    ),
    ...widget.extraTabs,
  ];

  @override
  Widget build(BuildContext context) {
    final List<SinewPickerTab> tabs = _tabs;
    final SinewPickerTab current = tabs.firstWhere(
      (SinewPickerTab t) => t.id == _tab,
      orElse: () => tabs.first,
    );
    return SinewBottomSheet(
      title: current.title,
      leadingIcon: SinewLeadingSwatch(
        color: Color(_value.colorValue),
        icon: widget.icons[_value.iconKey] ?? Icons.fitness_center_rounded,
      ),
      actions: AppButton(
        label: 'Done',
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () {
          widget.onDone(_value);
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SinewSegmentedControl<String>(
            values: <String>[for (final SinewPickerTab t in tabs) t.id],
            labels: <String>[for (final SinewPickerTab t in tabs) t.label],
            selected: current.id,
            onSelected: (String id) => setState(() => _tab = id),
          ),
          const SizedBox(height: Space.lg),
          current.builder(
            context,
            _value,
            (SinewIconColor v) => setState(() => _value = v),
          ),
        ],
      ),
    );
  }
}

/// The colour banks (Vibrant / Muted / Neutral) as round swatches. The
/// selected one gets a 2dp primary ring and a check.
class SinewColorPickerBody extends StatelessWidget {
  const SinewColorPickerBody({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final int? selected;
  final ValueChanged<int> onSelected;

  static const int _columns = 6;

  @override
  Widget build(BuildContext context) {
    const List<PickerBank> banks = SinewPickerPalette.banks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final PickerBank bank in banks) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sectionHeaderGap),
            child: Text(bank.label.toUpperCase(), style: context.sectionHeader),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: _columns,
            mainAxisSpacing: Sizes.swatchGap,
            crossAxisSpacing: Sizes.swatchGap,
            children: <Widget>[
              for (final int value in bank.swatches)
                _SwatchCell(
                  key: ValueKey<int>(value),
                  value: value,
                  isSelected: selected == value,
                  onTap: () => onSelected(value),
                ),
            ],
          ),
          if (bank != banks.last) const SizedBox(height: Space.lg),
        ],
      ],
    );
  }
}

class _SwatchCell extends StatelessWidget {
  const _SwatchCell({
    super.key,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final Color swatchColor = Color(value);
    // Circle swatch; selected = a 2dp primary ring outside a gap, and a check.
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Colour ${value.toRadixString(16).toUpperCase().substring(2)}',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(
          side: BorderSide(
            color: isSelected ? cs.primary : Colors.transparent,
            width: Strokes.focus,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Space.xs),
            child: Ink(
              decoration: BoxDecoration(
                color: swatchColor,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: IconSpec.small,
                        color: _tickColor(context, swatchColor),
                      ),
                    )
                  : const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

/// A searchable grid of icons. Filters by key. The selected icon sits in a
/// secondaryContainer tile.
class SinewIconPickerBody extends StatefulWidget {
  const SinewIconPickerBody({
    super.key,
    required this.icons,
    required this.selected,
    required this.onSelected,
  });

  final Map<String, IconData> icons;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  State<SinewIconPickerBody> createState() => _SinewIconPickerBodyState();
}

class _SinewIconPickerBodyState extends State<SinewIconPickerBody> {
  final TextEditingController _query = TextEditingController();

  static const int _columns = 5;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String q = _query.text.trim().toLowerCase();
    final List<MapEntry<String, IconData>> shown = <MapEntry<String, IconData>>[
      for (final MapEntry<String, IconData> e in widget.icons.entries)
        if (q.isEmpty || e.key.toLowerCase().contains(q)) e,
    ];
    final ColorScheme cs = context.cs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SinewTextField(
          label: 'Search icons',
          showLabel: false,
          controller: _query,
          onChanged: (String _) => setState(() {}),
          textInputAction: TextInputAction.search,
        ),
        const SizedBox(height: Space.lg),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.xl),
            child: Text(
              'No icons match',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium!.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: _columns,
            mainAxisSpacing: Space.sm,
            crossAxisSpacing: Space.sm,
            children: <Widget>[
              for (final MapEntry<String, IconData> e in shown)
                Semantics(
                  button: true,
                  selected: widget.selected == e.key,
                  label: e.key,
                  excludeSemantics: true,
                  onTap: () => widget.onSelected(e.key),
                  child: Material(
                    color: widget.selected == e.key
                        ? cs.secondaryContainer
                        : Colors.transparent,
                    borderRadius: Radii.mediumR,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => widget.onSelected(e.key),
                      child: Center(
                        child: Icon(
                          e.value,
                          size: Sizes.pickerIcon,
                          color: widget.selected == e.key
                              ? cs.onSecondaryContainer
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
