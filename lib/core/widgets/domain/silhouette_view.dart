import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../engines/silhouette/silhouette_engine.dart';
import '../../models/enums.dart';
import '../../theme/app_theme.dart';

/// Plain-words name of a body anchor, for labels and TalkBack.
String bodyAnchorLabel(BodyAnchor a) => switch (a) {
  BodyAnchor.neck => 'Neck',
  BodyAnchor.shoulders => 'Shoulders',
  BodyAnchor.chest => 'Chest',
  BodyAnchor.upperArm => 'Upper arm',
  BodyAnchor.forearm => 'Forearm',
  BodyAnchor.aboveNavel => 'Above navel',
  BodyAnchor.waist => 'Waist',
  BodyAnchor.belowNavel => 'Below navel',
  BodyAnchor.hips => 'Hips',
  BodyAnchor.thigh => 'Thigh',
  BodyAnchor.calf => 'Calf',
};

/// The front-view body silhouette, painted from a [SilhouetteGeometry].
///
/// Measured segments are drawn solid in the primary colour; estimated ones
/// are dashed and grey. When [geometry] changes the figure morphs from the old
/// one over 480ms (easeOutCubic) with `SilhouetteGeometry.lerp`; under reduced
/// motion, or with [animate] false (a scrubber), it jumps. Build [geometry]
/// once per input (a provider or a memo), not on every frame.
///
/// Three states from the design:
/// - no data: pass [hasData] false (every outline estimated, no fill),
/// - partial: the geometry marks the estimated segments,
/// - full: all solid with the tonal fill.
class SilhouetteView extends StatefulWidget {
  const SilhouetteView({
    super.key,
    required this.geometry,
    this.compareGeometry,
    this.hasData = true,
    this.animate = true,
    this.highlight,
    this.showLevelMarkers = false,
    this.showLevelLabels = false,
    this.onLevelTap,
    this.levelValueText,
    this.semanticLabel,
  });

  final SilhouetteGeometry geometry;

  /// An older geometry drawn behind as a faint dotted outline (the Compare
  /// scrubber).
  final SilhouetteGeometry? compareGeometry;

  /// False draws the all-estimated empty state.
  final bool hasData;

  /// False skips the morph (continuous input such as a slider).
  final bool animate;

  /// Draws a dashed line across the figure at this anchor, with a dot.
  final BodyAnchor? highlight;

  /// A dot at the right edge for every level (hollow when estimated).
  final bool showLevelMarkers;

  /// The anchor name beside each marker (implies markers).
  final bool showLevelLabels;

  /// Tapping near a level reports its anchor. Each level also becomes a
  /// 48dp TalkBack target.
  final ValueChanged<BodyAnchor>? onLevelTap;

  /// Text after the name in a level's label, such as "84 cm" (the caller
  /// converts units).
  final String Function(SilhouetteLevel level)? levelValueText;

  /// Overrides the generated summary.
  final String? semanticLabel;

  /// The nine anchors every geometry carries, without the optional navel
  /// ones.
  static bool _isCore(SilhouetteLevel l) =>
      l.anchor != BodyAnchor.aboveNavel && l.anchor != BodyAnchor.belowNavel;

  /// "Body silhouette. 6 of 9 measurements drawn from your data, 3
  /// estimated."
  static String describe(
    SilhouetteGeometry g, {
    bool hasData = true,
    bool comparing = false,
  }) {
    if (!hasData) {
      return 'Body silhouette. No measurements yet, so the whole outline is '
          'an estimate';
    }
    final List<SilhouetteLevel> core = g.levels.where(_isCore).toList();
    final int measured = core.where((SilhouetteLevel l) => !l.estimated).length;
    final int estimated = core.length - measured;
    final String base =
        'Body silhouette. $measured of ${core.length} measurements drawn from '
        'your data, $estimated estimated';
    return comparing ? '$base. Compared with an earlier date' : base;
  }

  @override
  State<SilhouetteView> createState() => _SilhouetteViewState();
}

class _SilhouetteViewState extends State<SilhouetteView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late SilhouetteGeometry _from;
  late SilhouetteGeometry _to;

  @override
  void initState() {
    super.initState();
    _from = widget.geometry;
    _to = widget.geometry;
    _ctrl = AnimationController(
      vsync: this,
      duration: SinewMotion.silhouetteMorph,
      value: 1,
    );
  }

  SilhouetteGeometry _current() => SilhouetteGeometry.lerp(
    _from,
    _to,
    Motion.decelerate.transform(_ctrl.value),
  );

  @override
  void didUpdateWidget(SilhouetteView old) {
    super.didUpdateWidget(old);
    if (identical(old.geometry, widget.geometry)) return;
    if (!widget.animate || Motion.reduced(context)) {
      _ctrl.value = 1;
      _from = widget.geometry;
      _to = widget.geometry;
      return;
    }
    _from = _current();
    _to = widget.geometry;
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final SinewAccents accents = context.accents;
    final TextStyle labelStyle = context.text.labelSmall!.copyWith(
      color: cs.onSurfaceVariant,
    );
    final String label =
        widget.semanticLabel ??
        SilhouetteView.describe(
          widget.geometry,
          hasData: widget.hasData,
          comparing: widget.compareGeometry != null,
        );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double h = c.hasBoundedHeight
            ? c.maxHeight
            : SilhouetteSpec.defaultHeight;
        final double w = c.hasBoundedWidth
            ? c.maxWidth
            : h * SilhouetteSpec.viewWidth / SilhouetteSpec.viewHeight;
        final Size size = Size(w, h);
        final _CanvasFit fit = _CanvasFit(size);
        final ValueChanged<BodyAnchor>? tap = widget.onLevelTap;

        return Semantics(
          label: label,
          image: true,
          explicitChildNodes: tap != null,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (BuildContext context, Widget? _) {
                final SilhouetteGeometry g = _current();
                final Widget paint = CustomPaint(
                  size: size,
                  painter: SilhouettePainter(
                    geometry: g,
                    compare: widget.compareGeometry,
                    hasData: widget.hasData,
                    highlight: widget.highlight,
                    markers: widget.showLevelMarkers || widget.showLevelLabels,
                    labels: widget.showLevelLabels
                        ? <BodyAnchor, String>{
                            for (final SilhouetteLevel l in g.levels)
                              l.anchor: bodyAnchorLabel(l.anchor),
                          }
                        : null,
                    measured: cs.primary,
                    fill: cs.primaryContainer,
                    estimated: accents.muscleIdle,
                    older: cs.outline,
                    ink: cs.onSurface,
                    labelStyle: labelStyle,
                    levelSemantics: tap == null
                        ? null
                        : (Size s) => _levelSemantics(s, fit, g, tap),
                  ),
                );
                if (tap == null) return ExcludeSemantics(child: paint);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (TapUpDetails d) {
                    final BodyAnchor? a = _hit(d.localPosition, fit, g);
                    if (a != null) tap(a);
                  },
                  child: paint,
                );
              },
            ),
          ),
        );
      },
    );
  }

  static const Set<BodyAnchor> _armAnchors = <BodyAnchor>{
    BodyAnchor.upperArm,
    BodyAnchor.forearm,
  };

  /// The level nearest [local]. Within a touch target of a level in y; where
  /// an arm level and a torso level share a height, x decides.
  BodyAnchor? _hit(Offset local, _CanvasFit fit, SilhouetteGeometry g) {
    final Offset c = fit.toCanvas(local);
    final double ny =
        (c.dy - SilhouetteSpec.topInset) / SilhouetteSpec.figureHeight;
    final double nx =
        (c.dx - SilhouetteSpec.viewWidth / 2) / SilhouetteSpec.figureHeight;
    final double tol =
        (IconSpec.tapTarget / 2) / fit.scale / SilhouetteSpec.figureHeight;
    final List<SilhouetteLevel> near = g.levels
        .where((SilhouetteLevel l) => (l.y - ny).abs() <= tol)
        .toList();
    if (near.isEmpty) return null;
    double torsoHalf = 0;
    for (final SilhouetteLevel l in g.levels) {
      if (_armAnchors.contains(l.anchor)) continue;
      if (l.anchor == BodyAnchor.thigh || l.anchor == BodyAnchor.calf) {
        continue;
      }
      if ((l.y - ny).abs() <= (near.first.y - ny).abs() + tol) {
        torsoHalf = math.max(torsoHalf, l.halfWidth);
      }
    }
    final bool outside = nx.abs() > torsoHalf;
    final List<SilhouetteLevel> pool = near
        .where((SilhouetteLevel l) => _armAnchors.contains(l.anchor) == outside)
        .toList();
    final List<SilhouetteLevel> use = pool.isEmpty ? near : pool;
    use.sort(
      (SilhouetteLevel a, SilhouetteLevel b) =>
          (a.y - ny).abs().compareTo((b.y - ny).abs()),
    );
    return use.first.anchor;
  }

  List<CustomPainterSemantics> _levelSemantics(
    Size size,
    _CanvasFit fit,
    SilhouetteGeometry g,
    ValueChanged<BodyAnchor> tap,
  ) {
    final List<CustomPainterSemantics> out = <CustomPainterSemantics>[];
    for (final SilhouetteLevel l in g.levels) {
      final double y = fit
          .toLocal(
            Offset(
              0,
              SilhouetteSpec.topInset + l.y * SilhouetteSpec.figureHeight,
            ),
          )
          .dy;
      final String value = widget.levelValueText?.call(l) ?? '';
      final String status = l.estimated ? 'estimated' : 'measured';
      out.add(
        CustomPainterSemantics(
          key: ValueKey<BodyAnchor>(l.anchor),
          rect: Rect.fromLTRB(
            0,
            y - IconSpec.tapTarget / 2,
            size.width,
            y + IconSpec.tapTarget / 2,
          ).intersect(Offset.zero & size),
          properties: SemanticsProperties(
            label: value.isEmpty
                ? '${bodyAnchorLabel(l.anchor)}, $status'
                : '${bodyAnchorLabel(l.anchor)}, $value, $status',
            button: true,
            onTap: () => tap(l.anchor),
          ),
        ),
      );
    }
    return out;
  }
}

/// The canvas-to-widget fit, "meet" like an SVG viewBox.
class _CanvasFit {
  _CanvasFit(this.size)
    : scale = math.min(
        size.width / SilhouetteSpec.viewWidth,
        size.height / SilhouetteSpec.viewHeight,
      ) {
    offset = Offset(
      (size.width - SilhouetteSpec.viewWidth * scale) / 2,
      (size.height - SilhouetteSpec.viewHeight * scale) / 2,
    );
  }

  final Size size;
  final double scale;
  late final Offset offset;

  Offset toCanvas(Offset local) => (local - offset) / scale;
  Offset toLocal(Offset canvas) => canvas * scale + offset;
}

/// Paints a [SilhouetteGeometry]. Public so tests can read the geometry that
/// was drawn mid-morph.
class SilhouettePainter extends CustomPainter {
  const SilhouettePainter({
    required this.geometry,
    required this.hasData,
    required this.measured,
    required this.fill,
    required this.estimated,
    required this.older,
    required this.ink,
    required this.labelStyle,
    this.compare,
    this.highlight,
    this.markers = false,
    this.labels,
    this.levelSemantics,
  });

  final SilhouetteGeometry geometry;
  final SilhouetteGeometry? compare;
  final bool hasData;
  final BodyAnchor? highlight;
  final bool markers;
  final Map<BodyAnchor, String>? labels;
  final Color measured;
  final Color fill;
  final Color estimated;
  final Color older;
  final Color ink;
  final TextStyle labelStyle;
  final SemanticsBuilderCallback? levelSemantics;

  static const double _cx = SilhouetteSpec.viewWidth / 2;

  static Offset _pt(Point p) => Offset(
    _cx + p.x * SilhouetteSpec.figureHeight,
    SilhouetteSpec.topInset + p.y * SilhouetteSpec.figureHeight,
  );

  static double _y(double f) =>
      SilhouetteSpec.topInset + f * SilhouetteSpec.figureHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final _CanvasFit fit = _CanvasFit(size);
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..translate(fit.offset.dx, fit.offset.dy)
      ..scale(fit.scale);

    if (compare != null) _paintOlder(canvas, compare!);
    _paintFigure(canvas);
    _paintLevels(canvas);
    canvas.restore();
  }

  Paint _stroke(Color c, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = w
    ..color = c
    ..isAntiAlias = true;

  Path _closed(SilhouettePath p) {
    final Path path = Path();
    for (int i = 0; i < p.points.length; i++) {
      final Offset o = _pt(p.points[i]);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    return path..close();
  }

  Path _headPath(SilhouetteHead h) {
    final Offset c = _pt(h.center);
    return Path()..addOval(
      Rect.fromCenter(
        center: c,
        width: h.rx * 2 * SilhouetteSpec.figureHeight,
        height: h.ry * 2 * SilhouetteSpec.figureHeight,
      ),
    );
  }

  /// One open path per run of equally-styled segments, so dashes flow across
  /// joints. [skipLast] leaves out the closing span (the top of the neck).
  List<(Path, bool)> _runs(SilhouettePath p, {bool skipLast = false}) {
    final int len = p.points.length;
    final List<(Path, bool)> out = <(Path, bool)>[];
    Path? cur;
    bool? curEst;
    final int count = skipLast ? p.segments.length - 1 : p.segments.length;
    for (int s = 0; s < count; s++) {
      final SilhouetteSegment seg = p.segments[s];
      if (cur == null || curEst != seg.estimated) {
        if (cur != null) out.add((cur, curEst!));
        cur = Path();
        curEst = seg.estimated;
        final Offset o = _pt(p.points[seg.start]);
        cur.moveTo(o.dx, o.dy);
      }
      int n = (seg.end - seg.start + len) % len;
      if (n == 0) n = len;
      for (int j = 1; j <= n; j++) {
        final Offset o = _pt(p.points[(seg.start + j) % len]);
        cur.lineTo(o.dx, o.dy);
      }
    }
    if (cur != null) out.add((cur, curEst!));
    return out;
  }

  void _paintOlder(Canvas canvas, SilhouetteGeometry g) {
    final Paint paint = _stroke(older, SilhouetteSpec.strokeCompare);
    Path dotted(Path p) =>
        _dash(p, SilhouetteSpec.dotOn, SilhouetteSpec.dotOff);
    canvas
      ..drawPath(dotted(_closed(g.torso)), paint)
      ..drawPath(dotted(_closed(g.armRight)), paint)
      ..drawPath(dotted(_closed(g.armLeft)), paint)
      ..drawPath(dotted(_headPath(g.head)), paint);
  }

  void _paintFigure(Canvas canvas) {
    final SilhouetteGeometry g = geometry;
    if (hasData) {
      final Paint f = Paint()
        ..style = PaintingStyle.fill
        ..color = fill
        ..isAntiAlias = true;
      canvas
        ..drawPath(_closed(g.torso), f)
        ..drawPath(_closed(g.armRight), f)
        ..drawPath(_closed(g.armLeft), f)
        ..drawPath(_headPath(g.head), f);
    }
    final Paint solid = _stroke(
      hasData ? measured : estimated,
      SilhouetteSpec.strokeMeasured,
    );
    final Paint dashed = _stroke(estimated, SilhouetteSpec.strokeEstimated);
    void strokeRuns(SilhouettePath p, {bool skipLast = false}) {
      for (final (Path path, bool est) in _runs(p, skipLast: skipLast)) {
        canvas.drawPath(
          est
              ? _dash(path, SilhouetteSpec.dashOn, SilhouetteSpec.dashOff)
              : path,
          est || !hasData ? dashed : solid,
        );
      }
    }

    strokeRuns(g.torso, skipLast: true);
    strokeRuns(g.armRight);
    strokeRuns(g.armLeft);
    final Path head = _headPath(g.head);
    if (g.head.estimated || !hasData) {
      canvas.drawPath(
        _dash(head, SilhouetteSpec.dashOn, SilhouetteSpec.dashOff),
        dashed,
      );
    } else {
      canvas.drawPath(head, solid);
    }
  }

  void _paintLevels(Canvas canvas) {
    const double xr = SilhouetteSpec.viewWidth - SilhouetteSpec.highlightInset;
    if (markers) {
      for (final SilhouetteLevel l in geometry.levels) {
        final Offset o = Offset(xr, _y(l.y));
        if (l.estimated || !hasData) {
          canvas.drawCircle(
            o,
            SilhouetteSpec.markerRadiusSmall,
            _stroke(estimated, SilhouetteSpec.highlightStroke),
          );
        } else {
          canvas.drawCircle(
            o,
            SilhouetteSpec.markerRadiusSmall,
            Paint()..color = measured,
          );
        }
        final String? text = labels?[l.anchor];
        if (text != null) {
          final TextPainter tp = TextPainter(
            text: TextSpan(
              text: text,
              style: labelStyle.copyWith(fontSize: SilhouetteSpec.labelSize),
            ),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          tp.paint(
            canvas,
            Offset(
              xr -
                  SilhouetteSpec.markerRadius -
                  SilhouetteSpec.labelGap -
                  tp.width,
              o.dy - tp.height - SilhouetteSpec.labelGap / 2,
            ),
          );
        }
      }
    }
    final BodyAnchor? hl = highlight;
    final SilhouetteLevel? level = hl == null ? null : geometry.level(hl);
    if (level != null) {
      final double y = _y(level.y);
      final Path line = Path()
        ..moveTo(SilhouetteSpec.highlightInset, y)
        ..lineTo(xr, y);
      canvas
        ..drawPath(
          _dash(
            line,
            SilhouetteSpec.highlightDashOn,
            SilhouetteSpec.highlightDashOff,
          ),
          _stroke(ink, SilhouetteSpec.highlightStroke)
            ..strokeCap = StrokeCap.butt,
        )
        ..drawCircle(
          Offset(xr, y),
          SilhouetteSpec.markerRadius,
          Paint()..color = ink,
        );
    }
  }

  static Path _dash(Path src, double on, double off) {
    final Path out = Path();
    for (final PathMetric m in src.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        out.addPath(m.extractPath(d, math.min(d + on, m.length)), Offset.zero);
        d += on + off;
      }
    }
    return out;
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => levelSemantics;

  @override
  bool shouldRepaint(SilhouettePainter oldDelegate) =>
      !identical(oldDelegate.geometry, geometry) ||
      !identical(oldDelegate.compare, compare) ||
      oldDelegate.hasData != hasData ||
      oldDelegate.highlight != highlight ||
      oldDelegate.markers != markers ||
      oldDelegate.measured != measured ||
      oldDelegate.fill != fill ||
      oldDelegate.estimated != estimated ||
      oldDelegate.older != older ||
      oldDelegate.ink != ink ||
      oldDelegate.labels?.length != labels?.length;

  @override
  bool shouldRebuildSemantics(SilhouettePainter oldDelegate) =>
      !identical(oldDelegate.geometry, geometry) ||
      (oldDelegate.levelSemantics == null) != (levelSemantics == null);
}
