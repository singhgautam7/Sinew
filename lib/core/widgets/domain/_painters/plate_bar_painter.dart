import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Which bar the plates hang on.
enum PlateBarKind { barbell, dumbbell }

/// The plate size (an index into [PlateSpec.sizes]) closest to [kg].
int plateSizeIndex(double kg) {
  int best = 0;
  double bestDiff = double.infinity;
  for (int i = 0; i < PlateSpec.sizes.length; i++) {
    final double d = (PlateSpec.sizes[i] - kg).abs();
    if (d < bestDiff) {
      bestDiff = d;
      best = i;
    }
  }
  return best;
}

/// Face height and thickness a plate of size [index] is drawn at.
({double height, double thickness}) plateDims(PlateBarKind kind, int index) {
  if (kind == PlateBarKind.barbell) {
    return (
      height: PlateSpec.barbellHeights[index],
      thickness: PlateSpec.barbellThickness[index],
    );
  }
  final int i = math.max(0, index - PlateSpec.dumbbellFirstIndex);
  return (
    height: PlateSpec.dumbbellHeights[i],
    thickness: PlateSpec.dumbbellThickness[i],
  );
}

/// The geometry of one drawn bar, shared by the painter and the widget.
class PlateGeometry {
  const PlateGeometry(this.kind);

  final PlateBarKind kind;

  bool get isBarbell => kind == PlateBarKind.barbell;
  double get width =>
      isBarbell ? PlateSpec.barbellWidth : PlateSpec.dumbbellWidth;
  double get height =>
      isBarbell ? PlateSpec.barbellHeight : PlateSpec.dumbbellHeight;
  double get collar =>
      isBarbell ? PlateSpec.barbellCollar : PlateSpec.dumbbellCollar;
  double get firstGap =>
      isBarbell ? PlateSpec.barbellFirstGap : PlateSpec.dumbbellFirstGap;

  /// Width plates may use on one side before they are squeezed.
  double get room => width / 2 - collar - PlateSpec.roomMargin;

  /// Total thickness (with gaps) of [sizes] at full size.
  double span(List<int> sizes) {
    double total = 0;
    for (final int s in sizes) {
      total += plateDims(kind, s).thickness + PlateSpec.plateGap;
    }
    return total;
  }

  /// The factor that squeezes plates so they fit the sleeve.
  double squeeze(double span) => span > room ? room / span : 1;

  /// Distance from the bar's centre to the inner face of each plate.
  List<double> insets(List<int> sizes, double k) {
    final List<double> out = <double>[];
    double x = collar + firstGap;
    for (final int s in sizes) {
      out.add(x);
      x += plateDims(kind, s).thickness * k + PlateSpec.plateGap * k;
    }
    return out;
  }
}

/// How the plates on one side change, in size indexes, for the painter.
class PlateMotion {
  const PlateMotion({
    required this.to,
    required this.kept,
    required this.exiting,
    required this.from,
    required this.progressMs,
  });

  /// A settled load: nothing moves.
  PlateMotion.settled(List<int> sizes)
    : to = sizes,
      kept = sizes.length,
      exiting = const <int>[],
      from = sizes,
      progressMs = 0;

  /// The load being shown (kept plates first, then the entering ones).
  final List<int> to;
  final int kept;

  /// Leaving plates, outermost first.
  final List<int> exiting;

  /// The load before the change (exiting plates sit where it had them).
  final List<int> from;

  /// Milliseconds into the transition.
  final double progressMs;
}

/// Paints a barbell or a dumbbell with plates on both sides, in the design's
/// coordinate space scaled to the available width. Colours are passed in so
/// the painter never reads the theme.
class PlateBarPainter extends CustomPainter {
  PlateBarPainter({
    required this.kind,
    required this.motion,
    required this.squeezeK,
    required this.plateColors,
    required this.bar,
    required this.collar,
    super.repaint,
  });

  final PlateBarKind kind;
  final PlateMotion Function() motion;
  final double squeezeK;

  /// One entry per [PlateSpec.sizes].
  final List<PlateColor> plateColors;
  final Color bar;
  final Color collar;

  @override
  void paint(Canvas canvas, Size size) {
    final PlateGeometry g = PlateGeometry(kind);
    canvas.save();
    canvas.scale(size.width / g.width);
    _paintBar(canvas, g);
    _paintPlates(canvas, g, motion());
    canvas.restore();
  }

  void _rrect(Canvas canvas, Rect r, double radius, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(radius)),
      Paint()..color = color,
    );
  }

  void _paintBar(Canvas canvas, PlateGeometry g) {
    final double cx = g.width / 2;
    final double cy = g.height / 2;
    final double c = g.collar;
    if (g.isBarbell) {
      const double sh = PlateSpec.shaftHalfHeight;
      _rrect(canvas, Rect.fromLTWH(cx - c, cy - sh, c * 2, sh * 2), sh, collar);
      const double sl = PlateSpec.sleeveHalfHeight;
      const double inset = PlateSpec.sleeveInset;
      final double sleeveW = cx - c - inset;
      _rrect(canvas, Rect.fromLTWH(inset, cy - sl, sleeveW, sl * 2), sl, bar);
      _rrect(canvas, Rect.fromLTWH(cx + c, cy - sl, sleeveW, sl * 2), sl, bar);
      const double stop = PlateSpec.stopHalfHeight;
      _rrect(
        canvas,
        Rect.fromLTWH(
          cx - c - PlateSpec.stopOutset,
          cy - stop,
          PlateSpec.stopWidth,
          stop * 2,
        ),
        PlateSpec.stopRadius,
        collar,
      );
      _rrect(
        canvas,
        Rect.fromLTWH(
          cx + c - PlateSpec.stopInset,
          cy - stop,
          PlateSpec.stopWidth,
          stop * 2,
        ),
        PlateSpec.stopRadius,
        collar,
      );
    } else {
      const double hh = PlateSpec.handleHalfHeight;
      _rrect(canvas, Rect.fromLTWH(cx - c, cy - hh, c * 2, hh * 2), hh, collar);
      const double gh = PlateSpec.gripHalfHeight;
      const double gl = PlateSpec.gripLength;
      _rrect(canvas, Rect.fromLTWH(cx - c - gl, cy - gh, gl, gh * 2), gh, bar);
      _rrect(canvas, Rect.fromLTWH(cx + c, cy - gh, gl, gh * 2), gh, bar);
    }
  }

  void _paintPlates(Canvas canvas, PlateGeometry g, PlateMotion m) {
    final double cx = g.width / 2;
    final double cy = g.height / 2;
    final double k = squeezeK;
    final List<double> toInsets = g.insets(m.to, k);
    final List<double> fromInsets = g.insets(m.from, k);

    for (final int dir in const <int>[-1, 1]) {
      for (int i = 0; i < m.to.length; i++) {
        double dx = 0;
        double alpha = 1;
        if (i >= m.kept) {
          final int j = i - m.kept;
          final double local =
              ((m.progressMs - j * SinewMotion.plateStagger.inMilliseconds) /
                      SinewMotion.plateEnter.inMilliseconds)
                  .clamp(0.0, 1.0);
          final double c = Motion.spring.transform(local);
          dx = (1 - c) * PlateSpec.slideTravel * dir;
          alpha = local <= 0 ? 0 : c.clamp(0.0, 1.0);
        }
        if (alpha > 0) {
          _plate(canvas, g, cx, cy, dir, m.to[i], toInsets[i], k, dx, alpha);
        }
      }
      for (int e = 0; e < m.exiting.length; e++) {
        final int slot = m.from.length - 1 - e;
        final double local =
            ((m.progressMs - e * SinewMotion.plateStagger.inMilliseconds) /
                    SinewMotion.plateExit.inMilliseconds)
                .clamp(0.0, 1.0);
        if (local >= 1) continue;
        final double c = Motion.decelerate.transform(local);
        _plate(
          canvas,
          g,
          cx,
          cy,
          dir,
          m.exiting[e],
          fromInsets[slot],
          k,
          c * PlateSpec.slideTravel * dir,
          1 - c,
        );
      }
    }
  }

  void _plate(
    Canvas canvas,
    PlateGeometry g,
    double cx,
    double cy,
    int dir,
    int sizeIndex,
    double inset,
    double k,
    double dx,
    double alpha,
  ) {
    final ({double height, double thickness}) d = plateDims(kind, sizeIndex);
    final double w = d.thickness * k;
    final double h = d.height;
    final double left = dir > 0 ? cx + inset : cx - inset - w;
    final Rect r = Rect.fromLTWH(left + dx, cy - h / 2, w, h);
    final RRect rr = RRect.fromRectAndRadius(
      r,
      Radius.circular(math.min(PlateSpec.plateRadius, w / 2)),
    );
    final PlateColor c = plateColors[sizeIndex];
    canvas.drawRRect(rr, Paint()..color = c.fill.withValues(alpha: alpha));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = PlateSpec.plateStroke
        ..color = c.edge.withValues(alpha: alpha),
    );
  }

  // The motion is read through a callback, so a new painter always repaints.
  @override
  bool shouldRepaint(PlateBarPainter old) => true;
}
