import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'sinew_menu.dart';

/// Filter / choice chip: 32 high, radius 8. Unselected = 1dp outlineVariant;
/// selected = secondaryContainer (+ an 18 check unless [showCheck] is false).
/// Optional leading [icon], trailing close ([onDeleted]) or drop-down arrow
/// ([dropdown]) and a count [badge]. A chip that opens a sheet shows what was
/// picked in its label.
class SinewChip extends StatelessWidget {
  const SinewChip({
    super.key,
    required this.label,
    this.selected = false,
    this.showCheck = true,
    this.icon,
    this.iconColor,
    this.dropdown = false,
    this.badge,
    this.onTap,
    this.onDeleted,
    this.shrink = false,
    this.pill = false,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final bool showCheck;
  final IconData? icon;
  final Color? iconColor;
  final bool dropdown;
  final String? badge;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  /// Let the label ellipsize inside a flexible row.
  final bool shrink;

  /// Stadium corners instead of radius 8.
  final bool pill;

  /// False dims the chip to 38% and ignores taps.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Color fg = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    final Icon? lead = selected && showCheck && onDeleted == null && !dropdown
        ? Icon(
            Icons.check_rounded,
            size: IconSpec.small,
            color: cs.onSecondaryContainer,
          )
        : (icon == null
              ? null
              : Icon(
                  icon,
                  size: IconSpec.small,
                  color:
                      iconColor ??
                      (selected ? cs.onSecondaryContainer : cs.primary),
                ));
    final bool hasTrail = dropdown || onDeleted != null;

    final Text text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: tt.labelLarge!.copyWith(color: fg),
    );

    return Opacity(
      opacity: enabled ? 1 : Opacities.disabled,
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        label: badge == null ? label : '$label, $badge',
        excludeSemantics: true,
        onTap: enabled ? onTap : null,
        child: Material(
          color: selected ? cs.secondaryContainer : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: pill ? Radii.fullR : Radii.chipR,
            side: selected
                ? BorderSide.none
                : BorderSide(color: cs.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Container(
              height: Sizes.chip,
              padding: EdgeInsets.only(
                left: lead != null ? Space.sm : Space.lg,
                right: hasTrail ? Space.sm : Space.lg,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (lead != null) ...<Widget>[
                    lead,
                    const SizedBox(width: Space.sm),
                  ],
                  if (shrink) Flexible(child: text) else text,
                  if (badge != null) ...<Widget>[
                    const SizedBox(width: Space.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.xs + Space.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: Radii.fullR,
                      ),
                      child: Text(
                        badge!,
                        style: tt.labelSmall!.copyWith(
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                  if (dropdown) ...<Widget>[
                    const SizedBox(width: Space.sm),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: IconSpec.small,
                      color: fg,
                    ),
                  ],
                  if (onDeleted != null) ...<Widget>[
                    const SizedBox(width: Space.sm),
                    GestureDetector(
                      onTap: onDeleted,
                      behavior: HitTestBehavior.opaque,
                      child: Semantics(
                        button: true,
                        label: 'Remove $label',
                        child: Icon(
                          Icons.close_rounded,
                          size: IconSpec.small,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One option of a [SinewDropdownChip].
class SinewDropdownOption<T> {
  const SinewDropdownOption(this.value, this.label, {this.subtitle, this.icon});

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

/// A dropdown chip that opens an anchored menu (chart period, sort order).
/// Drawn selected while its menu is open.
class SinewDropdownChip<T> extends StatefulWidget {
  const SinewDropdownChip({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
    this.icon,
    this.shrink = false,
  });

  final T value;
  final List<SinewDropdownOption<T>> options;
  final ValueChanged<T> onChanged;

  /// Overrides the chip label (defaults to the selected option's label).
  final String? label;
  final IconData? icon;
  final bool shrink;

  @override
  State<SinewDropdownChip<T>> createState() => _SinewDropdownChipState<T>();
}

class _SinewDropdownChipState<T> extends State<SinewDropdownChip<T>> {
  bool _open = false;

  Future<void> _show(BuildContext anchor) async {
    setState(() => _open = true);
    final T? picked = await showSinewMenu<T>(
      context: anchor,
      minWidth: Sizes.chipMenuMinWidth,
      entries: <SinewMenuEntry<T>>[
        for (final SinewDropdownOption<T> o in widget.options)
          SinewMenuEntry<T>(
            value: o.value,
            label: o.label,
            subtitle: o.subtitle,
            icon: o.icon,
            selected: o.value == widget.value,
          ),
      ],
    );
    if (mounted) setState(() => _open = false);
    if (picked != null && picked != widget.value) widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final String? current = widget.options
        .where((SinewDropdownOption<T> o) => o.value == widget.value)
        .map((SinewDropdownOption<T> o) => o.label)
        .firstOrNull;
    return Builder(
      builder: (BuildContext anchor) => SinewChip(
        label: widget.label ?? current ?? '',
        icon: widget.icon,
        selected: _open,
        dropdown: true,
        shrink: widget.shrink,
        onTap: () => _show(anchor),
      ),
    );
  }
}
