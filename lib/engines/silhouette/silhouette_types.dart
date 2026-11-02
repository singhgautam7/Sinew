import '../../core/models/enums.dart';

// PURE DART. No dart:ui: geometry uses [Point].

/// A point in the normalized silhouette space: height = 1.0, y grows downward
/// from the top of the head, x is centred on the body axis (0).
class Point {
  const Point(this.x, this.y);

  final double x;
  final double y;

  Point lerpTo(Point o, double t) =>
      Point(x * (1 - t) + o.x * t, y * (1 - t) + o.y * t);

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Point($x, $y)';
}

/// Measurements in cm keyed by [BodyAnchor], plus height and sex.
/// Missing, non-finite or non-positive values count as missing.
class SilhouetteInput {
  const SilhouetteInput({
    this.measurements = const <BodyAnchor, double>{},
    this.heightCm,
    this.sex,
  });

  final Map<BodyAnchor, double> measurements;
  final double? heightCm;

  /// Null draws the male base, as the design handoff specifies.
  final Sex? sex;

  @override
  bool operator ==(Object other) {
    if (other is! SilhouetteInput ||
        other.heightCm != heightCm ||
        other.sex != sex ||
        other.measurements.length != measurements.length) {
      return false;
    }
    for (final MapEntry<BodyAnchor, double> e in measurements.entries) {
      if (other.measurements[e.key] != e.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    heightCm,
    sex,
    Object.hashAllUnordered(
      measurements.entries.map((MapEntry<BodyAnchor, double> e) {
        return Object.hash(e.key, e.value);
      }),
    ),
  );
}

/// Linear interpolation of measurements, for the "lerp measurements, then
/// the path" morph. A value present on only one side is kept as is (so a
/// newly measured anchor does not pop in from a default). At t=0 the result
/// equals [a] and at t=1 it equals [b].
SilhouetteInput lerpInputs(SilhouetteInput a, SilhouetteInput b, double t) {
  if (t <= 0) return a;
  if (t >= 1) return b;
  double? mix(double? x, double? y) {
    if (x == null) return y;
    if (y == null) return x;
    return x * (1 - t) + y * t;
  }

  final Map<BodyAnchor, double> m = <BodyAnchor, double>{};
  for (final BodyAnchor k in BodyAnchor.values) {
    final double? v = mix(a.measurements[k], b.measurements[k]);
    if (v != null) m[k] = v;
  }
  return SilhouetteInput(
    measurements: m,
    heightCm: mix(a.heightCm, b.heightCm),
    sex: t < 0.5 ? a.sex : b.sex,
  );
}

/// One measured (or estimated) body level.
class SilhouetteLevel {
  const SilhouetteLevel({
    required this.anchor,
    required this.y,
    required this.halfWidth,
    required this.valueCm,
    required this.estimated,
  });

  final BodyAnchor anchor;

  /// Fraction of height from the top (0 to 1).
  final double y;

  /// Half the drawn width at this level, in height units.
  final double halfWidth;

  /// The circumference used, in cm (measured, interpolated or default).
  final double valueCm;

  /// True when the value was not measured. The UI draws it dashed/lighter.
  final bool estimated;
}

/// A span of a path between two control points: points `start..end`
/// inclusive (`end` wraps to 0 on a closed path).
class SilhouetteSegment {
  const SilhouetteSegment({
    required this.start,
    required this.end,
    required this.estimated,
  });

  final int start;
  final int end;
  final bool estimated;
}

/// A closed sampled outline.
class SilhouettePath {
  const SilhouettePath({required this.points, required this.segments});

  final List<Point> points;
  final List<SilhouetteSegment> segments;
}

class SilhouetteHead {
  const SilhouetteHead({
    required this.center,
    required this.rx,
    required this.ry,
    required this.estimated,
  });

  final Point center;
  final double rx;
  final double ry;
  final bool estimated;
}

class SilhouetteBounds {
  const SilhouetteBounds(this.minX, this.minY, this.maxX, this.maxY);

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;
}

/// The whole front-view figure in normalized space.
class SilhouetteGeometry {
  const SilhouetteGeometry({
    required this.heightCm,
    required this.heightEstimated,
    required this.levels,
    required this.torso,
    required this.armRight,
    required this.armLeft,
    required this.head,
    required this.bounds,
  });

  final double heightCm;
  final bool heightEstimated;

  /// Top to bottom. Aside from the nine required anchors, `aboveNavel` and
  /// `belowNavel` appear only when measured.
  final List<SilhouetteLevel> levels;

  /// Torso and both legs as one closed outline, symmetric about x = 0.
  final SilhouettePath torso;
  final SilhouettePath armRight;
  final SilhouettePath armLeft;
  final SilhouetteHead head;
  final SilhouetteBounds bounds;

  /// The main outline (torso and legs).
  List<Point> get outline => torso.points;

  SilhouetteLevel? level(BodyAnchor a) {
    for (final SilhouetteLevel l in levels) {
      if (l.anchor == a) return l;
    }
    return null;
  }

  /// Morphs between two geometries built by `buildSilhouette`. Point counts
  /// are identical by construction, so each point is lerped; estimated flags
  /// switch at t = 0.5. At t=0 the result is [a] and at t=1 it is [b].
  static SilhouetteGeometry lerp(
    SilhouetteGeometry a,
    SilhouetteGeometry b,
    double t,
  ) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    if (a.torso.points.length != b.torso.points.length ||
        a.armRight.points.length != b.armRight.points.length) {
      return t < 0.5 ? a : b;
    }
    final SilhouetteGeometry flags = t < 0.5 ? a : b;
    SilhouettePath path(SilhouettePath x, SilhouettePath y, SilhouettePath f) =>
        SilhouettePath(
          points: <Point>[
            for (int i = 0; i < x.points.length; i++)
              x.points[i].lerpTo(y.points[i], t),
          ],
          segments: f.segments,
        );

    final List<SilhouetteLevel> levels = <SilhouetteLevel>[];
    for (final SilhouetteLevel la in a.levels) {
      final SilhouetteLevel? lb = b.level(la.anchor);
      if (lb == null) {
        levels.add(la);
      } else {
        levels.add(
          SilhouetteLevel(
            anchor: la.anchor,
            y: la.y * (1 - t) + lb.y * t,
            halfWidth: la.halfWidth * (1 - t) + lb.halfWidth * t,
            valueCm: la.valueCm * (1 - t) + lb.valueCm * t,
            estimated: (t < 0.5 ? la : lb).estimated,
          ),
        );
      }
    }
    for (final SilhouetteLevel lb in b.levels) {
      if (a.level(lb.anchor) == null) levels.add(lb);
    }
    levels.sort((SilhouetteLevel p, SilhouetteLevel q) => p.y.compareTo(q.y));

    final Point c = a.head.center.lerpTo(b.head.center, t);
    final double rx = a.head.rx * (1 - t) + b.head.rx * t;
    final double ry = a.head.ry * (1 - t) + b.head.ry * t;
    final SilhouetteBounds ba = a.bounds;
    final SilhouetteBounds bb = b.bounds;
    return SilhouetteGeometry(
      heightCm: a.heightCm * (1 - t) + b.heightCm * t,
      heightEstimated: flags.heightEstimated,
      levels: levels,
      torso: path(a.torso, b.torso, flags.torso),
      armRight: path(a.armRight, b.armRight, flags.armRight),
      armLeft: path(a.armLeft, b.armLeft, flags.armLeft),
      head: SilhouetteHead(
        center: c,
        rx: rx,
        ry: ry,
        estimated: flags.head.estimated,
      ),
      bounds: SilhouetteBounds(
        ba.minX * (1 - t) + bb.minX * t,
        ba.minY * (1 - t) + bb.minY * t,
        ba.maxX * (1 - t) + bb.maxX * t,
        ba.maxY * (1 - t) + bb.maxY * t,
      ),
    );
  }
}
