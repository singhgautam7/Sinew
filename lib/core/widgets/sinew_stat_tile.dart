import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One plain figure with its name under it: "52 min / Duration". For summary
/// grids (a finished workout, a session). Not the body-stat card (that one
/// carries ranges and info sheets); this one only shows text it is given.
class SinewStatTile extends StatelessWidget {
  const SinewStatTile({
    super.key,
    required this.value,
    required this.label,
    this.caption,
    this.emphasis = false,
  });

  final String value;
  final String label;

  /// A quiet line under the label ("estimate").
  final String? caption;

  /// Tonal fill, for the figure the screen is about.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Semantics(
      container: true,
      label: '$label, $value${caption == null ? '' : ', $caption'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(Space.md),
        decoration: BoxDecoration(
          color: emphasis ? cs.primaryContainer : cs.surfaceContainer,
          borderRadius: Radii.largeR,
          border: Border.all(
            color: emphasis ? cs.primaryContainer : cs.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value,
              style: tt.titleLarge!.copyWith(
                color: emphasis ? cs.onPrimaryContainer : cs.onSurface,
              ),
            ),
            const SizedBox(height: Space.xxs),
            Text(
              label,
              style: tt.bodySmall!.copyWith(
                color: emphasis ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
            if (caption != null)
              Text(
                caption!,
                style: tt.labelSmall!.copyWith(
                  color: emphasis ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// [children] laid out in equal columns: [columns] normally, one fewer for
/// every step the text size would squeeze them below [minTileWidth].
class SinewStatGrid extends StatelessWidget {
  const SinewStatGrid({
    super.key,
    required this.children,
    this.columns = 3,
    this.minTileWidth = defaultMinTile,
  });

  /// Narrowest a tile may get at 100% text.
  static const double defaultMinTile = 96;

  final List<Widget> children;
  final int columns;
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double scale = MediaQuery.textScalerOf(context).scale(1);
        int cols = columns;
        while (cols > 1 &&
            (box.maxWidth - (cols - 1) * Space.sm) / cols <
                minTileWidth * scale) {
          cols--;
        }
        final double w = (box.maxWidth - (cols - 1) * Space.sm) / cols;
        return Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: <Widget>[
            for (final Widget c in children) SizedBox(width: w, child: c),
          ],
        );
      },
    );
  }
}
