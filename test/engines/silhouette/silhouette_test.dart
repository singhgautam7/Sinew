import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/engines/silhouette/silhouette_engine.dart';

const Map<BodyAnchor, double> _full = <BodyAnchor, double>{
  BodyAnchor.neck: 38,
  BodyAnchor.shoulders: 115,
  BodyAnchor.chest: 98,
  BodyAnchor.waist: 82,
  BodyAnchor.hips: 97,
  BodyAnchor.upperArm: 32,
  BodyAnchor.forearm: 27,
  BodyAnchor.thigh: 55,
  BodyAnchor.calf: 36,
};

SilhouetteInput _input([Map<BodyAnchor, double> m = _full, double h = 175]) =>
    SilhouetteInput(measurements: m, heightCm: h, sex: Sex.male);

bool _mirrored(List<Point> pts) {
  for (final Point p in pts) {
    final bool found = pts.any(
      (Point q) => (q.x + p.x).abs() < 1e-9 && (q.y - p.y).abs() < 1e-9,
    );
    if (!found) return false;
  }
  return true;
}

void main() {
  test('torso outline is symmetric about x = 0', () {
    final SilhouetteGeometry g = buildSilhouette(_input());
    expect(_mirrored(g.torso.points), isTrue);
    // Left arm is the mirror of the right arm.
    final List<Point> both = <Point>[...g.armRight.points, ...g.armLeft.points];
    expect(_mirrored(both), isTrue);
    expect(g.bounds.minX, closeTo(-g.bounds.maxX, 1e-9));
  });

  test('levels are ordered top to bottom and in the reference positions', () {
    final SilhouetteGeometry g = buildSilhouette(_input());
    for (int i = 1; i < g.levels.length; i++) {
      expect(g.levels[i].y, greaterThanOrEqualTo(g.levels[i - 1].y));
    }
    expect(g.levels, hasLength(9));
    expect(g.level(BodyAnchor.waist)!.y, 0.40);
    expect(g.level(BodyAnchor.calf)!.y, 0.80);
    // Torso = circumference x 0.36 / 2, scaled by height.
    expect(
      g.level(BodyAnchor.waist)!.halfWidth,
      closeTo(82 * 0.36 / 2 / 175, 1e-12),
    );
    // Limb = circumference / pi / 2.
    expect(
      g.level(BodyAnchor.thigh)!.halfWidth,
      closeTo(55 / pi / 2 / 175, 1e-12),
    );
    expect(g.heightCm, 175);
    expect(g.heightEstimated, isFalse);
  });

  test('a bigger waist widens only the waist region', () {
    final SilhouetteGeometry a = buildSilhouette(_input());
    final SilhouetteGeometry b = buildSilhouette(
      _input(<BodyAnchor, double>{..._full, BodyAnchor.waist: 110}),
    );
    expect(a.torso.points.length, b.torso.points.length);
    int widened = 0;
    for (int i = 0; i < a.torso.points.length; i++) {
      final Point p = a.torso.points[i];
      final Point q = b.torso.points[i];
      expect(q.y, closeTo(p.y, 1e-12));
      if ((q.x - p.x).abs() > 1e-12) {
        widened++;
        expect(p.y, inInclusiveRange(0.24, 0.60));
      }
    }
    expect(widened, greaterThan(0));
    expect(
      b.level(BodyAnchor.waist)!.halfWidth,
      greaterThan(a.level(BodyAnchor.waist)!.halfWidth),
    );
    expect(
      b.level(BodyAnchor.hips)!.halfWidth,
      a.level(BodyAnchor.hips)!.halfWidth,
    );
    // Arms and head are untouched.
    for (int i = 0; i < a.armRight.points.length; i++) {
      expect(b.armRight.points[i], a.armRight.points[i]);
    }
    expect(b.head.rx, a.head.rx);
  });

  test('missing anchors are flagged and interpolated from neighbours', () {
    final Map<BodyAnchor, double> m = <BodyAnchor, double>{..._full}
      ..remove(BodyAnchor.chest)
      ..remove(BodyAnchor.calf);
    final SilhouetteGeometry g = buildSilhouette(_input(m));
    final SilhouetteLevel chest = g.level(BodyAnchor.chest)!;
    expect(chest.estimated, isTrue);
    // Chest sits between shoulders (y .195) and waist (y .40), at y .26.
    const double f = (0.26 - 0.195) / (0.40 - 0.195);
    expect(chest.valueCm, closeTo(115 * (1 - f) + 82 * f, 1e-9));
    // Calf has no neighbour on the chain, so it takes the male default.
    final SilhouetteLevel calf = g.level(BodyAnchor.calf)!;
    expect(calf.estimated, isTrue);
    expect(calf.valueCm, 37);
    expect(g.level(BodyAnchor.waist)!.estimated, isFalse);
    // Segments touching an estimated level are estimated; others are not.
    expect(g.torso.segments.any((SilhouetteSegment s) => s.estimated), isTrue);
    expect(g.torso.segments.any((SilhouetteSegment s) => !s.estimated), isTrue);
    expect(
      g.armRight.segments.every((SilhouetteSegment s) => !s.estimated),
      isTrue,
    );
  });

  test('a fully measured figure has no estimated segment', () {
    final SilhouetteGeometry g = buildSilhouette(_input());
    expect(
      g.torso.segments.every((SilhouetteSegment s) => !s.estimated),
      isTrue,
    );
    expect(g.head.estimated, isFalse);
  });

  test('all missing uses the sex defaults', () {
    final SilhouetteGeometry male = buildSilhouette(const SilhouetteInput());
    final SilhouetteGeometry maleExplicit = buildSilhouette(
      const SilhouetteInput(sex: Sex.male),
    );
    final SilhouetteGeometry female = buildSilhouette(
      const SilhouetteInput(sex: Sex.female),
    );
    expect(male.heightCm, 178);
    expect(male.heightEstimated, isTrue);
    expect(male.head.estimated, isTrue);
    expect(male.levels.every((SilhouetteLevel l) => l.estimated), isTrue);
    expect(male.level(BodyAnchor.waist)!.valueCm, 84);
    expect(female.heightCm, 165);
    expect(female.level(BodyAnchor.waist)!.valueCm, 71);
    for (int i = 0; i < male.torso.points.length; i++) {
      expect(maleExplicit.torso.points[i], male.torso.points[i]);
    }
    expect(female.torso.points, isNot(male.torso.points));
    expect(
      male.torso.segments.every((SilhouetteSegment s) => s.estimated),
      isFalse, // unlabelled foot and crotch spans are never flagged
    );
  });

  test('navel anchors refine the torso without changing point counts', () {
    final SilhouetteGeometry a = buildSilhouette(_input());
    final SilhouetteGeometry b = buildSilhouette(
      _input(<BodyAnchor, double>{
        ..._full,
        BodyAnchor.aboveNavel: 95,
        BodyAnchor.belowNavel: 100,
      }),
    );
    expect(b.torso.points.length, a.torso.points.length);
    expect(b.levels, hasLength(11));
    expect(b.level(BodyAnchor.aboveNavel)!.y, 0.35);
    expect(b.torso.points, isNot(a.torso.points));
  });

  test('point count is stable', () {
    final int n = buildSilhouette(const SilhouetteInput()).torso.points.length;
    expect(n, 43 * kSamplesPerSpan);
    for (final double s in <double>[0.5, 1, 1.5]) {
      final SilhouetteGeometry g = buildSilhouette(
        _input(<BodyAnchor, double>{
          for (final MapEntry<BodyAnchor, double> e in _full.entries)
            e.key: e.value * s,
        }),
      );
      expect(g.torso.points.length, n);
      expect(g.armRight.points.length, 14 * kSamplesPerSpan);
      expect(g.armLeft.points.length, 14 * kSamplesPerSpan);
    }
  });

  group('morph', () {
    final SilhouetteInput a = _input();
    final SilhouetteInput b = _input(<BodyAnchor, double>{
      ..._full,
      BodyAnchor.waist: 100,
      BodyAnchor.thigh: 62,
    }, 180);

    test('lerpInputs endpoints and midpoint', () {
      expect(lerpInputs(a, b, 0), a);
      expect(lerpInputs(a, b, 1), b);
      final SilhouetteInput m = lerpInputs(a, b, 0.5);
      expect(m.measurements[BodyAnchor.waist], 91);
      expect(m.heightCm, 177.5);
      expect(m.measurements[BodyAnchor.neck], 38);
    });

    test('lerpInputs keeps a value present on only one side', () {
      final SilhouetteInput c = lerpInputs(
        const SilhouetteInput(),
        const SilhouetteInput(
          measurements: <BodyAnchor, double>{BodyAnchor.waist: 90},
        ),
        0.3,
      );
      expect(c.measurements[BodyAnchor.waist], 90);
    });

    test('geometry lerp at 0 and 1 equals the ends, 0.5 lies between', () {
      final SilhouetteGeometry ga = buildSilhouette(a);
      final SilhouetteGeometry gb = buildSilhouette(b);
      final SilhouetteGeometry g0 = SilhouetteGeometry.lerp(ga, gb, 0);
      final SilhouetteGeometry g1 = SilhouetteGeometry.lerp(ga, gb, 1);
      expect(g0.torso.points, ga.torso.points);
      expect(g1.torso.points, gb.torso.points);
      final SilhouetteGeometry gm = SilhouetteGeometry.lerp(ga, gb, 0.5);
      expect(gm.torso.points.length, ga.torso.points.length);
      for (int i = 0; i < ga.torso.points.length; i++) {
        final Point p = ga.torso.points[i];
        final Point q = gb.torso.points[i];
        final Point m = gm.torso.points[i];
        expect(
          m.x,
          inInclusiveRange(min(p.x, q.x) - 1e-12, max(p.x, q.x) + 1e-12),
        );
        expect(
          m.y,
          inInclusiveRange(min(p.y, q.y) - 1e-12, max(p.y, q.y) + 1e-12),
        );
      }
      expect(gm.levels, hasLength(ga.levels.length));
    });

    test('building from lerped inputs matches the endpoints', () {
      final SilhouetteGeometry g0 = buildSilhouette(lerpInputs(a, b, 0));
      expect(g0.torso.points, buildSilhouette(a).torso.points);
      final SilhouetteGeometry g1 = buildSilhouette(lerpInputs(a, b, 1));
      expect(g1.torso.points, buildSilhouette(b).torso.points);
    });
  });

  test('no NaN or infinity for tiny, huge or invalid values', () {
    final List<SilhouetteInput> inputs = <SilhouetteInput>[
      SilhouetteInput(
        measurements: <BodyAnchor, double>{
          for (final BodyAnchor a in BodyAnchor.values) a: 0.0001,
        },
        heightCm: 0.01,
      ),
      SilhouetteInput(
        measurements: <BodyAnchor, double>{
          for (final BodyAnchor a in BodyAnchor.values) a: 1e9,
        },
        heightCm: 1e9,
      ),
      const SilhouetteInput(
        measurements: <BodyAnchor, double>{
          BodyAnchor.waist: double.nan,
          BodyAnchor.hips: double.infinity,
          BodyAnchor.chest: -5,
          BodyAnchor.neck: 0,
        },
        heightCm: double.nan,
        sex: Sex.female,
      ),
    ];
    for (final SilhouetteInput i in inputs) {
      final SilhouetteGeometry g = buildSilhouette(i);
      final Iterable<Point> pts = <Point>[
        ...g.torso.points,
        ...g.armRight.points,
        ...g.armLeft.points,
      ];
      for (final Point p in pts) {
        expect(p.x.isFinite && p.y.isFinite, isTrue);
      }
      expect(g.bounds.width.isFinite && g.bounds.height.isFinite, isTrue);
      expect(g.head.rx.isFinite, isTrue);
      for (final SilhouetteLevel l in g.levels) {
        expect(l.halfWidth.isFinite, isTrue);
      }
    }
  });
}
