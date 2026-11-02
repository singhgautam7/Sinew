import 'dart:math';

import '../../core/models/enums.dart';
import 'silhouette_types.dart';

// PURE DART.
//
// Ported from the design reference `sinew-art.js` (`figure`, `crPaths`):
// a front view built from levels at fixed fractions of height. Torso widths
// are circumference x 0.36, limb widths circumference / pi. Everything is
// scaled against height (height = 1.0 in the output).
//
// Smoothing is a *uniform* Catmull-Rom spline, converted to cubic Beziers
// exactly as the reference does (c1 = p1 + (p2 - p0) / 6,
// c2 = p2 - (p3 - p1) / 6) and sampled at [kSamplesPerSpan] points per span.

/// Sample points per Catmull-Rom span. Fixed so point counts never change.
const int kSamplesPerSpan = 8;

/// Default measurements by sex, from the reference `BASES` (cm).
const Map<BodyAnchor, double> _maleDefaults = <BodyAnchor, double>{
  BodyAnchor.neck: 39,
  BodyAnchor.shoulders: 118,
  BodyAnchor.chest: 100,
  BodyAnchor.waist: 84,
  BodyAnchor.hips: 98,
  BodyAnchor.upperArm: 33,
  BodyAnchor.forearm: 28,
  BodyAnchor.thigh: 56,
  BodyAnchor.calf: 37,
};

const Map<BodyAnchor, double> _femaleDefaults = <BodyAnchor, double>{
  BodyAnchor.neck: 32,
  BodyAnchor.shoulders: 102,
  BodyAnchor.chest: 90,
  BodyAnchor.waist: 71,
  BodyAnchor.hips: 100,
  BodyAnchor.upperArm: 28,
  BodyAnchor.forearm: 24,
  BodyAnchor.thigh: 58,
  BodyAnchor.calf: 36,
};

const double _maleHeight = 178;
const double _femaleHeight = 165;

/// Level positions as fractions of height (from the reference `LEVEL`).
const Map<BodyAnchor, double> _levelY = <BodyAnchor, double>{
  BodyAnchor.neck: 0.145,
  BodyAnchor.shoulders: 0.195,
  BodyAnchor.chest: 0.26,
  BodyAnchor.upperArm: 0.27,
  BodyAnchor.aboveNavel: 0.35,
  BodyAnchor.waist: 0.40,
  BodyAnchor.forearm: 0.40,
  BodyAnchor.belowNavel: 0.45,
  BodyAnchor.hips: 0.50,
  BodyAnchor.thigh: 0.60,
  BodyAnchor.calf: 0.80,
};

/// Neighbour chains used to interpolate a missing anchor.
const List<BodyAnchor> _torsoChain = <BodyAnchor>[
  BodyAnchor.neck,
  BodyAnchor.shoulders,
  BodyAnchor.chest,
  BodyAnchor.waist,
  BodyAnchor.hips,
];

const List<BodyAnchor> _required = <BodyAnchor>[
  BodyAnchor.neck,
  BodyAnchor.shoulders,
  BodyAnchor.chest,
  BodyAnchor.upperArm,
  BodyAnchor.waist,
  BodyAnchor.forearm,
  BodyAnchor.hips,
  BodyAnchor.thigh,
  BodyAnchor.calf,
];

double? _valid(double? v) => (v != null && v.isFinite && v > 0) ? v : null;

class _Ctl {
  const _Ctl(this.y, this.x, this.anchor);
  final double y;
  final double x;
  final BodyAnchor? anchor;
  _Ctl mirror() => _Ctl(y, -x, anchor);
}

/// Builds the front-view silhouette for [input].
///
/// Missing anchors are filled in this order: linear interpolation by level
/// height between the nearest measured neighbours on the same chain (neck,
/// shoulders, chest, waist, hips), else the default for the sex (male when
/// null). Every filled level is flagged `estimated`. Values are clamped to a
/// plausible range (0.25x to 3x the default; height 50 to 272 cm) so absurd
/// input can never produce NaN or a degenerate figure. `aboveNavel` and
/// `belowNavel` refine the torso when present; when absent the torso still
/// has a control point there (interpolated, never flagged) so point counts
/// stay stable for morphing.
SilhouetteGeometry buildSilhouette(SilhouetteInput input) {
  final Map<BodyAnchor, double> defaults = input.sex == Sex.female
      ? _femaleDefaults
      : _maleDefaults;
  final double? hIn = _valid(input.heightCm);
  final double height =
      (hIn ?? (input.sex == Sex.female ? _femaleHeight : _maleHeight)).clamp(
        50.0,
        272.0,
      );

  double clampTo(BodyAnchor a, double v, double base) =>
      v.clamp(base * 0.25, base * 3.0);

  final Map<BodyAnchor, double> value = <BodyAnchor, double>{};
  final Set<BodyAnchor> estimated = <BodyAnchor>{};
  for (final BodyAnchor a in _required) {
    final double? m = _valid(input.measurements[a]);
    if (m != null) value[a] = clampTo(a, m, defaults[a]!);
  }
  final Set<BodyAnchor> measured = value.keys.toSet();
  // Interpolate along the torso chain where both sides are known.
  for (int i = 0; i < _torsoChain.length; i++) {
    final BodyAnchor a = _torsoChain[i];
    if (value.containsKey(a)) continue;
    BodyAnchor? prev;
    BodyAnchor? next;
    for (int j = i - 1; j >= 0; j--) {
      if (measured.contains(_torsoChain[j])) {
        prev = _torsoChain[j];
        break;
      }
    }
    for (int j = i + 1; j < _torsoChain.length; j++) {
      if (measured.contains(_torsoChain[j])) {
        next = _torsoChain[j];
        break;
      }
    }
    if (prev != null && next != null) {
      final double y0 = _levelY[prev]!;
      final double y1 = _levelY[next]!;
      final double f = (_levelY[a]! - y0) / (y1 - y0);
      value[a] = value[prev]! * (1 - f) + value[next]! * f;
    }
  }
  for (final BodyAnchor a in _required) {
    if (!measured.contains(a)) estimated.add(a);
    value.putIfAbsent(a, () => defaults[a]!);
  }

  final double k = 1 / height; // normalized units per cm
  double x(double cm) => cm * k;
  double tw(double c) => x(c * 0.36) / 2; // torso half width
  double lw(double c) => x(c / pi) / 2; // limb half width
  bool est(BodyAnchor a) => estimated.contains(a);

  final double neckC = value[BodyAnchor.neck]!;
  final double shC = value[BodyAnchor.shoulders]!;
  final double chC = value[BodyAnchor.chest]!;
  final double waC = value[BodyAnchor.waist]!;
  final double hiC = value[BodyAnchor.hips]!;
  final double thighC = value[BodyAnchor.thigh]!;
  final double calfC = value[BodyAnchor.calf]!;
  final double legC = tw(hiC) * 0.56;
  final double thH = lw(thighC);
  final double cfH = lw(calfC);

  // Optional navel refinements.
  final double? aboveIn = _valid(input.measurements[BodyAnchor.aboveNavel]);
  final double? belowIn = _valid(input.measurements[BodyAnchor.belowNavel]);
  final double chestMid = tw(chC) * 0.97;
  double between(double y, double y0, double w0, double y1, double w1) =>
      w0 + (w1 - w0) * ((y - y0) / (y1 - y0));
  final double aboveW = aboveIn != null
      ? tw(aboveIn.clamp(waC * 0.25, waC * 3.0))
      : between(0.35, 0.30, chestMid, 0.40, tw(waC));
  final double belowW = belowIn != null
      ? tw(belowIn.clamp(waC * 0.25, waC * 3.0))
      : between(0.45, 0.40, tw(waC), 0.50, tw(hiC));

  final List<_Ctl> r = <_Ctl>[
    _Ctl(0.112, lw(neckC) * 0.92, BodyAnchor.neck),
    _Ctl(0.145, lw(neckC), BodyAnchor.neck),
    _Ctl(0.162, lw(neckC) + x(5), BodyAnchor.shoulders),
    _Ctl(0.178, tw(shC) - x(2.2), BodyAnchor.shoulders),
    _Ctl(0.205, tw(shC), BodyAnchor.shoulders),
    _Ctl(0.25, tw(chC), BodyAnchor.chest),
    _Ctl(0.30, chestMid, BodyAnchor.chest),
    _Ctl(0.35, aboveW, aboveIn != null ? BodyAnchor.aboveNavel : null),
    _Ctl(0.40, tw(waC), BodyAnchor.waist),
    _Ctl(0.45, belowW, belowIn != null ? BodyAnchor.belowNavel : null),
    _Ctl(0.50, tw(hiC), BodyAnchor.hips),
    _Ctl(0.58, legC + thH, BodyAnchor.thigh),
    _Ctl(0.72, legC + thH * 0.62, BodyAnchor.thigh),
    _Ctl(0.80, legC + cfH, BodyAnchor.calf),
    _Ctl(0.95, legC + x(3.2), BodyAnchor.calf),
    _Ctl(0.985, legC + x(5), null),
    _Ctl(0.995, legC - x(3), null),
    _Ctl(0.95, legC - x(3.4), BodyAnchor.calf),
    _Ctl(0.80, max(x(1.5), legC - cfH * 0.9), BodyAnchor.calf),
    _Ctl(0.72, max(x(1.4), legC - thH * 0.55), BodyAnchor.thigh),
    _Ctl(0.58, max(x(0.8), legC - thH), BodyAnchor.thigh),
    const _Ctl(0.528, 0, null), // crotch, on the axis
  ];
  // Left side is the mirror of the right, walked upward; the crotch is shared.
  final List<_Ctl> left = <_Ctl>[
    for (int i = r.length - 2; i >= 0; i--) r[i].mirror(),
  ];
  final List<_Ctl> torsoCtl = <_Ctl>[...r, ...left];

  final double bw = lw(value[BodyAnchor.upperArm]!);
  final double fw = lw(value[BodyAnchor.forearm]!);
  final double ax = max(tw(shC) - bw * 0.55, tw(chC) + bw + x(1.8));
  final List<_Ctl> armCtl = <_Ctl>[
    _Ctl(0.19, ax + bw * 0.35, BodyAnchor.shoulders),
    _Ctl(0.215, ax + bw * 1.05, BodyAnchor.upperArm),
    _Ctl(0.29, ax + bw, BodyAnchor.upperArm),
    _Ctl(0.355, ax + x(1.2) + fw * 0.85, BodyAnchor.forearm),
    _Ctl(0.40, ax + x(1.8) + fw, BodyAnchor.forearm),
    _Ctl(0.47, ax + x(2.6) + fw * 0.55, BodyAnchor.forearm),
    _Ctl(0.53, ax + x(2.8) + x(2.2), null),
    _Ctl(0.545, ax + x(2.8), null),
    _Ctl(0.53, ax + x(2.8) - x(2.3), null),
    _Ctl(0.47, ax + x(2.4) - fw * 0.55, BodyAnchor.forearm),
    _Ctl(0.40, ax + x(1.6) - fw * 0.9, BodyAnchor.forearm),
    _Ctl(0.355, ax + x(1) - fw * 0.8, BodyAnchor.forearm),
    _Ctl(0.29, ax - bw * 0.85, BodyAnchor.upperArm),
    _Ctl(0.24, ax - bw * 0.7, BodyAnchor.upperArm),
  ];

  bool segEst(_Ctl a, _Ctl b) =>
      (a.anchor != null && est(a.anchor!)) ||
      (b.anchor != null && est(b.anchor!));

  SilhouettePath path(List<_Ctl> c, {required bool mirrorX}) {
    final int n = c.length;
    _Ctl p(int i) => c[(i % n + n) % n];
    double sx(double v) => mirrorX ? -v : v;
    final List<Point> pts = <Point>[];
    final List<SilhouetteSegment> segs = <SilhouetteSegment>[];
    for (int i = 0; i < n; i++) {
      final _Ctl p0 = p(i - 1);
      final _Ctl p1 = p(i);
      final _Ctl p2 = p(i + 1);
      final _Ctl p3 = p(i + 2);
      final double c1x = p1.x + (p2.x - p0.x) / 6;
      final double c1y = p1.y + (p2.y - p0.y) / 6;
      final double c2x = p2.x - (p3.x - p1.x) / 6;
      final double c2y = p2.y - (p3.y - p1.y) / 6;
      final int start = pts.length;
      for (int s = 0; s < kSamplesPerSpan; s++) {
        final double t = s / kSamplesPerSpan;
        final double u = 1 - t;
        final double bx =
            u * u * u * p1.x +
            3 * u * u * t * c1x +
            3 * u * t * t * c2x +
            t * t * t * p2.x;
        final double by =
            u * u * u * p1.y +
            3 * u * u * t * c1y +
            3 * u * t * t * c2y +
            t * t * t * p2.y;
        pts.add(Point(sx(bx), by));
      }
      segs.add(
        SilhouetteSegment(
          start: start,
          end: (start + kSamplesPerSpan) % (n * kSamplesPerSpan),
          estimated: segEst(p1, p2),
        ),
      );
    }
    return SilhouettePath(points: pts, segments: segs);
  }

  final SilhouettePath torso = path(torsoCtl, mirrorX: false);
  final SilhouettePath armR = path(armCtl, mirrorX: false);
  final SilhouettePath armL = path(armCtl, mirrorX: true);

  final SilhouetteHead head = SilhouetteHead(
    center: const Point(0, 0.064),
    rx: x(8),
    ry: x(11.6),
    estimated: hIn == null,
  );

  double minX = double.infinity;
  double minY = double.infinity;
  double maxX = -double.infinity;
  double maxY = -double.infinity;
  for (final SilhouettePath sp in <SilhouettePath>[torso, armR, armL]) {
    for (final Point q in sp.points) {
      minX = min(minX, q.x);
      maxX = max(maxX, q.x);
      minY = min(minY, q.y);
      maxY = max(maxY, q.y);
    }
  }
  minX = min(minX, -head.rx);
  maxX = max(maxX, head.rx);
  minY = min(minY, head.center.y - head.ry);
  maxY = max(maxY, head.center.y + head.ry);

  final List<SilhouetteLevel> levels = <SilhouetteLevel>[];
  for (final BodyAnchor a in _levelY.keys) {
    final bool isNavel =
        a == BodyAnchor.aboveNavel || a == BodyAnchor.belowNavel;
    final double? cm = isNavel
        ? (a == BodyAnchor.aboveNavel ? aboveIn : belowIn)
        : value[a];
    if (cm == null) continue;
    final bool limb =
        a == BodyAnchor.upperArm ||
        a == BodyAnchor.forearm ||
        a == BodyAnchor.thigh ||
        a == BodyAnchor.calf;
    levels.add(
      SilhouetteLevel(
        anchor: a,
        y: _levelY[a]!,
        halfWidth: limb ? lw(cm) : tw(cm),
        valueCm: cm,
        estimated: isNavel ? false : est(a),
      ),
    );
  }
  levels.sort((SilhouetteLevel p, SilhouetteLevel q) => p.y.compareTo(q.y));

  return SilhouetteGeometry(
    heightCm: height,
    heightEstimated: hIn == null,
    levels: levels,
    torso: torso,
    armRight: armR,
    armLeft: armL,
    head: head,
    bounds: SilhouetteBounds(minX, minY, maxX, maxY),
  );
}
