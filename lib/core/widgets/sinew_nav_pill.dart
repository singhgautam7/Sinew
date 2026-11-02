import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The five destination glyphs, drawn as paths in the Perch nav language: 20x16
/// art in a 24 slot, 1.75 stroke, rounded caps and joins, outlined always (the
/// active tab changes colour only). The geometry is the design's
/// (`NavPill.dc.html`, `sinew-art.js`); [index] picks Today (0), Train (1),
/// Timer (2), Body (3) or the grid used for More (4, and any other).
class SinewNavGlyph extends StatelessWidget {
  const SinewNavGlyph({super.key, required this.index, required this.color});

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: Sizes.glyphSlot,
        height: Sizes.glyphSlot,
        child: Center(
          child: CustomPaint(
            size: const Size(Sizes.glyphWidth, Sizes.glyphHeight),
            painter: _NavGlyphPainter(index, color),
          ),
        ),
      ),
    );
  }
}

class _NavGlyphPainter extends CustomPainter {
  _NavGlyphPainter(this.index, this.color);

  final int index;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = IconSpec.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint fill = Paint()..color = color;
    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke);

    switch (index) {
      case 0: // Today: a calendar with a dot.
        canvas.drawRRect(rr(2.6, 2.2, 14.8, 12.9, 3), stroke);
        line(2.6, 6.4, 17.4, 6.4);
        line(6.6, 0.9, 6.6, 3.4);
        line(13.4, 0.9, 13.4, 3.4);
        canvas.drawCircle(const Offset(10, 10.7), 1.7, fill);
      case 1: // Train: a dumbbell.
        line(6.4, 8, 13.6, 8);
        canvas.drawRRect(rr(3.4, 3.4, 3, 9.2, 1.5), stroke);
        canvas.drawRRect(rr(13.6, 3.4, 3, 9.2, 1.5), stroke);
        line(1.2, 6.4, 1.2, 9.6);
        line(18.8, 6.4, 18.8, 9.6);
      case 2: // Timer: a stopwatch.
        canvas.drawCircle(const Offset(10, 9.2), 5.9, stroke);
        line(8.2, 0.9, 11.8, 0.9);
        line(10, 9.2, 10, 6.2);
        line(15, 3.6, 16.2, 2.4);
      case 3: // Body: head and shoulders.
        canvas.drawCircle(const Offset(10, 3.4), 2.2, stroke);
        final Path p = Path()
          ..moveTo(5, 15.1)
          ..lineTo(5, 10.6)
          ..arcToPoint(const Offset(15, 10.6), radius: const Radius.circular(5))
          ..lineTo(15, 15.1);
        canvas.drawPath(p, stroke);
      default: // More: four rounded tiles.
        for (final Offset o in const <Offset>[
          Offset(2.4, 0.9),
          Offset(10.8, 0.9),
          Offset(2.4, 8.3),
          Offset(10.8, 8.3),
        ]) {
          canvas.drawRRect(rr(o.dx, o.dy, 6.8, 6.8, 2.2), stroke);
        }
    }
  }

  @override
  bool shouldRepaint(_NavGlyphPainter old) =>
      old.index != index || old.color != color;
}

/// The floating nav pill: 56 tall, 8 padding, 40 items 2 apart, the active
/// item in secondaryContainer showing its glyph and label. No FAB. Each tab is
/// a button with its label and selected state for TalkBack, and keeps a 48dp
/// tall hit area (the pill is 56 tall; the indicator is drawn 40).
///
/// [labels] are the tab names in order; item `i` draws glyph `i`. The label of
/// the selected tab drops first when [showLabels] is false or the text scale
/// is large enough that it would not fit.
class SinewNavPill extends StatelessWidget {
  const SinewNavPill({
    super.key,
    required this.labels,
    required this.index,
    required this.onSelect,
    this.showLabels = true,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onSelect;

  /// False on narrow screens / large text where the label would not fit.
  final bool showLabels;

  /// Width of the pill: border 2, padding 8 less the 4 of hit slop each item
  /// carries per side, items 40 (24 glyph + 8 + 8) plus that slop (a 48 wide
  /// hit area, the drawn indicator unchanged); the selected one adds 11 + 8 + label + 14 - 16.
  static double widthFor(
    BuildContext context,
    List<String> labels, {
    required bool withLabel,
  }) {
    final int n = labels.length;
    final double w =
        Sizes.hairlineBorders +
        (Sizes.navPadding - Sizes.navHitInset) * 2 +
        n * (Sizes.navItem + Sizes.navHitInset * 2);
    if (!withLabel) return w;
    final TextStyle style = context.text.labelLarge!;
    double label = 0;
    for (final String text in labels) {
      final TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      if (tp.width > label) label = tp.width;
      tp.dispose();
    }
    // The selected item is wide enough to need no hit slop.
    return w -
        Sizes.navHitInset * 2 +
        Sizes.navLabelPadLeft +
        Sizes.navLabelGap +
        Sizes.navLabelPadRight -
        Sizes.navItem +
        Sizes.glyphSlot +
        label;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return RepaintBoundary(
      // Transparent Material: the ink of the tabs needs one above it even when
      // the pill is placed outside a Scaffold.
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          height: Sizes.navPillHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.navPadding - Sizes.navHitInset,
            vertical: Sizes.navPillInsetV,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: Radii.fullR,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < labels.length; i++)
                _PillItem(
                  key: ValueKey<String>('nav-${labels[i]}'),
                  index: i,
                  count: labels.length,
                  label: labels[i],
                  selected: i == index,
                  showLabel: showLabels,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillItem extends StatelessWidget {
  const _PillItem({
    super.key,
    required this.index,
    required this.count,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  final int index;
  final int count;
  final String label;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final Color fg = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    // Under a large OS text scale the label drops first; the glyph and the
    // indicator still say where you are.
    final bool withLabel =
        showLabel &&
        selected &&
        MediaQuery.textScalerOf(context)
                .scale(context.text.labelLarge!.fontSize!) <=
            Sizes.navLabelMaxText;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          // The 48dp hit area (48 wide even unselected); the indicator inside
          // is 40 tall and keeps its own width.
          padding: EdgeInsets.symmetric(
            horizontal: withLabel ? 0 : Sizes.navHitInset,
          ),
          child: SizedBox(
            height: IconSpec.tapTarget,
            child: Center(
              child: AnimatedContainer(
                duration: Motion.of(context, Motion.navIndicator),
                curve: Motion.curveOf(context, Motion.spring),
                height: Sizes.navItem,
                padding: EdgeInsets.only(
                  left: withLabel ? Sizes.navLabelPadLeft : Space.sm,
                  right: withLabel ? Sizes.navLabelPadRight : Space.sm,
                ),
                decoration: BoxDecoration(
                  color: selected ? cs.secondaryContainer : Colors.transparent,
                  borderRadius: Radii.fullR,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: withLabel ? Sizes.navLabelGap : 0,
                  children: <Widget>[
                    SinewNavGlyph(index: index, color: fg),
                    AnimatedSize(
                      duration: Motion.of(context, Motion.navIndicator),
                      curve: Motion.curveOf(context, Motion.spring),
                      child: withLabel
                          ? Text(
                              label,
                              maxLines: 1,
                              softWrap: false,
                              style: context.text.labelLarge!.copyWith(
                                color: fg,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The pill as the shell shows it: floating over the content with a surface
/// scrim behind it, bottom-anchored with the system inset (never less than 22).
/// It slides down 72 and fades over 160 ms when [hidden] is true (a
/// cross-fade only under reduced motion) and is then removed from the tree, so
/// it takes no touches and TalkBack skips it.
///
/// Put it in a `Stack` over the page: `Positioned(left: 0, right: 0, bottom:
/// 0, child: SinewNavBar(...))`.
class SinewNavBar extends StatelessWidget {
  const SinewNavBar({
    super.key,
    required this.labels,
    required this.index,
    required this.onSelect,
    this.hidden = false,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onSelect;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final double inset = MediaQuery.viewPaddingOf(context).bottom;
    final double bottom = inset > Sizes.navBottomMin
        ? inset
        : Sizes.navBottomMin;
    final bool reduced = Motion.reduced(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: hidden ? 1.0 : 0.0),
      duration: Motion.of(context, Motion.navHide),
      curve: Motion.decelerate,
      builder: (BuildContext context, double t, Widget? child) {
        if (t >= 1) return const SizedBox.shrink();
        return Opacity(
          opacity: 1 - t,
          child: Transform.translate(
            offset: Offset(0, reduced ? 0 : Sizes.navHideTravel * t),
            child: IgnorePointer(ignoring: t > 0.5, child: child),
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: bottom + Sizes.navPillHeight + Sizes.navScrim,
        child: Stack(
          children: <Widget>[
            // Static scrim so scrolled content fades out under the pill. Pure
            // gradient paint, no blur.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        cs.surface.withValues(alpha: 0),
                        cs.surface.withValues(alpha: Opacities.scrimFade),
                        cs.surface,
                      ],
                      stops: const <double>[0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: Space.md,
              right: Space.md,
              bottom: bottom,
              // Default look whenever it fits; on a narrow screen or with a
              // large OS font the label goes first, and if even that is too
              // wide the row scales down instead of running off the screen.
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  final bool labelsFit =
                      SinewNavPill.widthFor(context, labels, withLabel: true) <=
                      c.maxWidth;
                  return Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SinewNavPill(
                        labels: labels,
                        index: index,
                        onSelect: onSelect,
                        showLabels: labelsFit,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
