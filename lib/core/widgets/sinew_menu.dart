import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One row of [showSinewMenu], or a divider, or a caps group header.
@immutable
class SinewMenuEntry<T> {
  const SinewMenuEntry({
    required T this.value,
    required this.label,
    this.icon,
    this.subtitle,
    this.destructive = false,
    this.selected = false,
  }) : divider = false,
       header = false;

  const SinewMenuEntry.divider()
    : value = null,
      label = '',
      icon = null,
      subtitle = null,
      destructive = false,
      selected = false,
      divider = true,
      header = false;

  /// Non-tappable caps label that names the group of rows below it.
  const SinewMenuEntry.header(this.label)
    : value = null,
      icon = null,
      subtitle = null,
      destructive = false,
      selected = false,
      divider = false,
      header = true;

  final T? value;
  final String label;
  final IconData? icon;
  final String? subtitle;
  final bool destructive;

  /// secondaryContainer row + trailing check.
  final bool selected;
  final bool divider;
  final bool header;
}

/// The anchored overflow menu: surfaceContainer, radius 20, 1dp outlineVariant,
/// no shadow, padding 8, min width 200; rows min 48, radius 12, icon 20 + gap
/// 12, labelLarge with an optional bodySmall line.
///
/// Anchored to the control that raised it: pass that control's own [context]
/// (wrap it in a `Builder`). Opens below the anchor, or above when it would
/// run off the bottom. Returns the picked value, or null when dismissed.
Future<T?> showSinewMenu<T>({
  required BuildContext context,
  required List<SinewMenuEntry<T>> entries,
  double minWidth = Sizes.menuMinWidth,
}) {
  final ColorScheme cs = context.cs;
  final RenderBox button = context.findRenderObject()! as RenderBox;
  final RenderBox overlay =
      Navigator.of(
            context,
            rootNavigator: true,
          ).overlay!.context.findRenderObject()!
          as RenderBox;
  final Offset topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
  final Offset bottomRight = button.localToGlobal(
    button.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );

  // Opens below the anchor; when that would run off the bottom (a sheet's
  // action row), it opens above instead. The height is estimated from the row
  // metrics below.
  final double menuHeight =
      2 * Space.sm +
      Strokes.hairline * 2 +
      entries.fold<double>(
        0,
        (double h, SinewMenuEntry<T> e) =>
            h +
            (e.divider
                ? Sizes.menuDivider
                : e.header
                ? Sizes.menuHeader
                : e.subtitle != null
                ? Sizes.menuSubtitleRow
                : IconSpec.tapTarget),
      );
  final double bottomLimit =
      overlay.size.height - MediaQuery.viewPaddingOf(context).bottom - Space.sm;
  final bool above =
      bottomRight.dy + Space.xs + menuHeight > bottomLimit &&
      topLeft.dy - Space.xs - menuHeight > 0;
  final double top = above
      ? topLeft.dy - Space.xs - menuHeight
      : bottomRight.dy + Space.xs;

  return showMenu<T>(
    context: context,
    useRootNavigator: true,
    position: RelativeRect.fromLTRB(
      topLeft.dx,
      top,
      overlay.size.width - bottomRight.dx,
      overlay.size.height - top,
    ),
    color: cs.surfaceContainer,
    surfaceTintColor: Colors.transparent,
    elevation: Elevations.none,
    menuPadding: const EdgeInsets.all(Space.sm),
    shape: RoundedRectangleBorder(
      borderRadius: Radii.cardR,
      side: BorderSide(color: cs.outlineVariant),
    ),
    constraints: BoxConstraints(
      minWidth: minWidth,
      maxWidth: Sizes.menuMaxWidth,
    ),
    items: <PopupMenuEntry<T>>[
      for (final SinewMenuEntry<T> e in entries)
        if (e.divider)
          PopupMenuItem<T>(
            enabled: false,
            height: Sizes.menuDivider,
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md,
                vertical: Space.sm,
              ),
              child: Divider(
                color: cs.outlineVariant,
                height: Strokes.hairline,
              ),
            ),
          )
        else if (e.header)
          PopupMenuItem<T>(
            enabled: false,
            height: Sizes.menuHeader,
            padding: const EdgeInsets.fromLTRB(
              Space.md,
              Space.sm,
              Space.md,
              Space.xs,
            ),
            child: Text(e.label.toUpperCase(), style: context.sectionHeader),
          )
        else
          PopupMenuItem<T>(
            value: e.value,
            height: 0,
            padding: EdgeInsets.zero,
            child: _MenuRow<T>(entry: e),
          ),
    ],
  );
}

class _MenuRow<T> extends StatelessWidget {
  const _MenuRow({required this.entry});

  final SinewMenuEntry<T> entry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Color fg = entry.destructive
        ? cs.error
        : (entry.selected ? cs.onSecondaryContainer : cs.onSurface);
    final Color iconColor = entry.destructive
        ? cs.error
        : (entry.selected ? cs.onSecondaryContainer : cs.onSurfaceVariant);
    return Semantics(
      button: true,
      selected: entry.selected,
      child: Container(
        constraints: const BoxConstraints(minHeight: IconSpec.tapTarget),
        padding: const EdgeInsets.symmetric(horizontal: Space.md),
        decoration: BoxDecoration(
          color: entry.selected ? cs.secondaryContainer : Colors.transparent,
          borderRadius: Radii.mediumR,
        ),
        child: Row(
          children: <Widget>[
            if (entry.icon != null) ...<Widget>[
              Icon(entry.icon, size: IconSpec.glyph, color: iconColor),
              const SizedBox(width: Space.md),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.label,
                      style: tt.labelLarge!.copyWith(color: fg),
                    ),
                    if (entry.subtitle != null)
                      Text(
                        entry.subtitle!,
                        style: tt.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (entry.selected) ...<Widget>[
              const SizedBox(width: Space.md),
              Icon(
                Icons.check_rounded,
                size: IconSpec.glyph,
                color: cs.onSecondaryContainer,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
