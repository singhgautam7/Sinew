import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Matrix4;

import '../../models/enums.dart';

// Geometry and mapping for the muscle map. Ported from the design reference
// `sinew-art.js` (M_FRONT, M_BACK, F_FRONT, F_BACK, BASE_FIG, BASE_FEM). All
// coordinates are the reference's own SVG units on a 120 wide, 242 tall
// canvas, drawn for the left half of the body and mirrored across x = 60.
// Colours and sizes live in the theme; this file holds shape only.

/// The 15 drawn regions (handoff departure 5).
enum MuscleRegion {
  shoulders('shoulders', 'Shoulders'),
  chest('chest', 'Chest'),
  biceps('biceps', 'Biceps'),
  forearms('forearms', 'Forearms'),
  abs('core', 'Abs'),
  obliques('obliques', 'Obliques'),
  quads('quadriceps', 'Quads'),
  adductors('adductors', 'Adductors'),
  calves('calves', 'Calves'),
  traps('trapezius', 'Traps'),
  triceps('triceps', 'Triceps'),
  lats('lats', 'Lats'),
  lowerBack('lowerBack', 'Lower back'),
  glutes('glutes', 'Glutes'),
  hamstrings('hamstrings', 'Hamstrings');

  const MuscleRegion(this.muscleId, this.label);

  /// The library muscle id that names this region in callbacks.
  final String muscleId;

  /// Plain words for TalkBack and tooltips.
  final String label;
}

/// A face of the body.
enum MuscleMapSide { front, back }

/// How a library muscle id (the 22 ids of `vocab.json`) lands on the map.
///
/// - `neck` and `hipFlexors` are drawn as body, not as muscles: no region.
/// - `fullBody` tints every region.
/// - `rearDeltoids` shares the shoulders region (the back view draws it).
/// - `rhomboids` shares the traps region (the back trapezoid covers the
///   upper and mid back).
/// - `abductors` shares glutes; `tibialis` shares calves (the shin is the
///   front of the lower leg).
const Map<String, Set<MuscleRegion>> kMuscleRegions =
    <String, Set<MuscleRegion>>{
      'chest': <MuscleRegion>{MuscleRegion.chest},
      'shoulders': <MuscleRegion>{MuscleRegion.shoulders},
      'rearDeltoids': <MuscleRegion>{MuscleRegion.shoulders},
      'biceps': <MuscleRegion>{MuscleRegion.biceps},
      'triceps': <MuscleRegion>{MuscleRegion.triceps},
      'forearms': <MuscleRegion>{MuscleRegion.forearms},
      'trapezius': <MuscleRegion>{MuscleRegion.traps},
      'lats': <MuscleRegion>{MuscleRegion.lats},
      'rhomboids': <MuscleRegion>{MuscleRegion.traps},
      'lowerBack': <MuscleRegion>{MuscleRegion.lowerBack},
      'core': <MuscleRegion>{MuscleRegion.abs},
      'obliques': <MuscleRegion>{MuscleRegion.obliques},
      'hipFlexors': <MuscleRegion>{},
      'glutes': <MuscleRegion>{MuscleRegion.glutes},
      'quadriceps': <MuscleRegion>{MuscleRegion.quads},
      'hamstrings': <MuscleRegion>{MuscleRegion.hamstrings},
      'adductors': <MuscleRegion>{MuscleRegion.adductors},
      'abductors': <MuscleRegion>{MuscleRegion.glutes},
      'calves': <MuscleRegion>{MuscleRegion.calves},
      'tibialis': <MuscleRegion>{MuscleRegion.calves},
      'neck': <MuscleRegion>{},
    };

/// The library id that tints everything.
const String kFullBodyMuscle = 'fullBody';

/// Regions that [muscleId] tints. Unknown ids tint nothing.
Set<MuscleRegion> regionsForMuscle(String muscleId) {
  if (muscleId == kFullBodyMuscle) {
    return Set<MuscleRegion>.of(MuscleRegion.values);
  }
  return kMuscleRegions[muscleId] ?? const <MuscleRegion>{};
}

/// Muscles that sit on the front of the body and on the back, for choosing
/// the side of a cropped thumbnail. Muscles on neither list (shoulders,
/// forearms, calves, traps, full body) do not tip the balance.
const Set<String> kFrontMuscles = <String>{
  'chest',
  'biceps',
  'core',
  'obliques',
  'quadriceps',
  'adductors',
  'hipFlexors',
  'tibialis',
};
const Set<String> kBackMuscles = <String>{
  'triceps',
  'lats',
  'rhomboids',
  'rearDeltoids',
  'lowerBack',
  'glutes',
  'abductors',
  'hamstrings',
};

/// The side a cropped map shows: the one with more primary muscles (a primary
/// counts twice, a secondary once, as in the reference); the front on a tie.
MuscleMapSide cropSideFor(
  Iterable<String> primary,
  Iterable<String> secondary,
) {
  int score(Set<String> side) =>
      primary.where(side.contains).length * 2 +
      secondary.where(side.contains).length;
  return score(kBackMuscles) > score(kFrontMuscles)
      ? MuscleMapSide.back
      : MuscleMapSide.front;
}

/// Regions drawn on [side].
const Map<MuscleMapSide, List<MuscleRegion>> kSideRegions =
    <MuscleMapSide, List<MuscleRegion>>{
      MuscleMapSide.front: <MuscleRegion>[
        MuscleRegion.shoulders,
        MuscleRegion.chest,
        MuscleRegion.biceps,
        MuscleRegion.forearms,
        MuscleRegion.abs,
        MuscleRegion.obliques,
        MuscleRegion.quads,
        MuscleRegion.adductors,
        MuscleRegion.calves,
        MuscleRegion.traps,
      ],
      MuscleMapSide.back: <MuscleRegion>[
        MuscleRegion.traps,
        MuscleRegion.shoulders,
        MuscleRegion.triceps,
        MuscleRegion.forearms,
        MuscleRegion.lats,
        MuscleRegion.lowerBack,
        MuscleRegion.glutes,
        MuscleRegion.hamstrings,
        MuscleRegion.calves,
      ],
    };

/// Lower-case, plain-words names of the 22 library ids, for TalkBack.
String muscleSpokenName(String muscleId) => switch (muscleId) {
  'rearDeltoids' => 'rear deltoids',
  'lowerBack' => 'lower back',
  'hipFlexors' => 'hip flexors',
  'fullBody' => 'full body',
  _ => muscleId,
};

// ── Shapes ──────────────────────────────────────────────────────────────────

/// One primitive of the reference art.
sealed class MapShape {
  const MapShape();

  Path toPath();
}

class MapEllipse extends MapShape {
  const MapEllipse(this.cx, this.cy, this.rx, this.ry);

  final double cx;
  final double cy;
  final double rx;
  final double ry;

  @override
  Path toPath() =>
      Path()..addOval(Rect.fromLTRB(cx - rx, cy - ry, cx + rx, cy + ry));
}

class MapRect extends MapShape {
  const MapRect(this.x, this.y, this.w, this.h, [this.r = 0]);

  final double x;
  final double y;
  final double w;
  final double h;
  final double r;

  @override
  Path toPath() => Path()
    ..addRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
    );
}

/// An SVG path in absolute `M`, `L`, `Q` and `Z` commands, as the reference
/// writes them.
class MapSvgPath extends MapShape {
  const MapSvgPath(this.d);

  final String d;

  static final RegExp _token = RegExp(r'[MLQZ]|-?\d+(?:\.\d+)?');

  @override
  Path toPath() {
    final Path path = Path();
    final List<String> t = _token
        .allMatches(d)
        .map((RegExpMatch m) => m[0]!)
        .toList();
    int i = 0;
    double n() => double.parse(t[i++]);
    while (i < t.length) {
      final String cmd = t[i++];
      switch (cmd) {
        case 'M':
          path.moveTo(n(), n());
        case 'L':
          path.lineTo(n(), n());
        case 'Q':
          path.quadraticBezierTo(n(), n(), n(), n());
        case 'Z':
          path.close();
      }
    }
    return path;
  }
}

typedef _RegionShapes = Map<MuscleRegion, List<MapShape>>;

const _RegionShapes _maleFront = <MuscleRegion, List<MapShape>>{
  MuscleRegion.shoulders: <MapShape>[MapEllipse(34, 52, 9, 10)],
  MuscleRegion.chest: <MapShape>[
    MapSvgPath('M44 45 Q52 42 58.5 45 L58.5 64 Q51 68 44 63 Q41 54 44 45Z'),
  ],
  MuscleRegion.biceps: <MapShape>[MapEllipse(29, 76, 6, 13)],
  MuscleRegion.forearms: <MapShape>[MapEllipse(25, 103, 5.5, 14)],
  MuscleRegion.abs: <MapShape>[
    MapRect(52, 70, 7, 11, 3),
    MapRect(52, 83, 7, 11, 3),
    MapRect(52, 96, 7, 11, 3),
  ],
  MuscleRegion.obliques: <MapShape>[MapEllipse(45.5, 88, 4.5, 15)],
  MuscleRegion.quads: <MapShape>[MapEllipse(47.5, 150, 9.5, 26)],
  MuscleRegion.adductors: <MapShape>[MapEllipse(56.5, 141, 3.2, 15)],
  MuscleRegion.calves: <MapShape>[MapEllipse(47, 205, 6.5, 19)],
  MuscleRegion.traps: <MapShape>[MapSvgPath('M53 35 L41 43 L53 43Z')],
};

const _RegionShapes _maleBack = <MuscleRegion, List<MapShape>>{
  MuscleRegion.traps: <MapShape>[MapSvgPath('M60 32 L45 45 L60 76Z')],
  MuscleRegion.shoulders: <MapShape>[MapEllipse(34, 52, 9, 10)],
  MuscleRegion.triceps: <MapShape>[MapEllipse(29, 76, 6, 13)],
  MuscleRegion.forearms: <MapShape>[MapEllipse(25, 103, 5.5, 14)],
  MuscleRegion.lats: <MapShape>[
    MapSvgPath('M46 58 L58 66 L58.5 96 L49 92 L42 70Z'),
  ],
  MuscleRegion.lowerBack: <MapShape>[MapRect(53.5, 94, 6, 16, 3)],
  MuscleRegion.glutes: <MapShape>[MapEllipse(51, 121, 9.5, 11)],
  MuscleRegion.hamstrings: <MapShape>[MapEllipse(48, 155, 8.5, 23)],
  MuscleRegion.calves: <MapShape>[MapEllipse(47, 203, 7.5, 18)],
};

// The female maps override only what differs, exactly as the reference does
// with Object.assign.
const _RegionShapes _femaleFrontOverrides = <MuscleRegion, List<MapShape>>{
  MuscleRegion.shoulders: <MapShape>[MapEllipse(36.5, 52, 8, 9)],
  MuscleRegion.chest: <MapShape>[
    MapSvgPath(
      'M45.5 47 Q52 45 58.5 47 L58.5 61 Q51 67 45.5 62 Q43.5 54 45.5 47Z',
    ),
  ],
  MuscleRegion.biceps: <MapShape>[MapEllipse(31.5, 76, 5, 12.5)],
  MuscleRegion.forearms: <MapShape>[MapEllipse(28, 103, 4.5, 13.5)],
  MuscleRegion.obliques: <MapShape>[MapEllipse(48, 88, 3.8, 13)],
  MuscleRegion.quads: <MapShape>[MapEllipse(46.5, 150, 10.5, 26)],
  MuscleRegion.calves: <MapShape>[MapEllipse(46.5, 205, 6, 19)],
};

const _RegionShapes _femaleBackOverrides = <MuscleRegion, List<MapShape>>{
  MuscleRegion.traps: <MapShape>[MapSvgPath('M60 33 L47 45 L60 72Z')],
  MuscleRegion.shoulders: <MapShape>[MapEllipse(36.5, 52, 8, 9)],
  MuscleRegion.triceps: <MapShape>[MapEllipse(31.5, 76, 5, 12.5)],
  MuscleRegion.forearms: <MapShape>[MapEllipse(28, 103, 4.5, 13.5)],
  MuscleRegion.lats: <MapShape>[
    MapSvgPath('M47 59 L58 66 L58.5 92 L50.5 90 L44.5 70Z'),
  ],
  MuscleRegion.glutes: <MapShape>[MapEllipse(50, 121, 10.5, 12)],
  MuscleRegion.hamstrings: <MapShape>[MapEllipse(47.5, 155, 9, 23)],
  MuscleRegion.calves: <MapShape>[MapEllipse(46.5, 203, 7, 18)],
};

/// The body (head, torso, hands, feet) under the muscles, per base.
const List<MapShape> _baseMale = <MapShape>[
  MapEllipse(60, 17, 12, 12),
  MapRect(54.5, 27, 11, 10, 4),
  MapSvgPath(
    'M42 42 Q60 36 78 42 L80 66 Q78 108 76 110 L44 110 Q42 108 40 66Z',
  ),
  MapSvgPath('M44 108 L76 108 L71 126 L49 126Z'),
  MapEllipse(23, 122, 5, 5),
  MapEllipse(97, 122, 5, 5),
  MapEllipse(48, 180, 6, 6),
  MapEllipse(72, 180, 6, 6),
  MapEllipse(46, 232, 7, 4),
  MapEllipse(74, 232, 7, 4),
];

const List<MapShape> _baseFemale = <MapShape>[
  MapEllipse(60, 17, 11.5, 11.5),
  MapEllipse(60, 5, 5.5, 5.5),
  MapRect(55.5, 27, 9, 10, 4),
  MapSvgPath(
    'M44 43 Q60 38 76 43 L77 62 Q75 82 72.5 92 Q78 102 80 110 L40 110 Q42 102 47.5 92 Q45 82 43 62Z',
  ),
  MapSvgPath('M40 108 L80 108 L74 128 L46 128Z'),
  MapEllipse(26, 121, 4.5, 4.5),
  MapEllipse(94, 121, 4.5, 4.5),
  MapEllipse(47, 180, 6, 6),
  MapEllipse(73, 180, 6, 6),
  MapEllipse(46, 232, 6.5, 4),
  MapEllipse(74, 232, 6.5, 4),
];

/// The reference canvas the figure is drawn on (SVG units).
const double kMapCanvasWidth = 120;

/// The viewBox the reference shows: `8 0 104 242`.
const Rect kMapViewBox = Rect.fromLTWH(8, 0, 104, 242);

/// A region on one side: its left path, its mirror, and the bounds of both.
@immutable
class RegionPaths {
  const RegionPaths(this.left, this.right, this.bounds);

  final Path left;
  final Path right;
  final Rect bounds;

  bool contains(Offset p) => left.contains(p) || right.contains(p);
}

/// Cached paths for a (sex, side). Built once; thumbnails reuse them.
class MuscleMapGeometry {
  MuscleMapGeometry._(this.base, this.regions);

  /// Head, torso, hands and feet, as one path.
  final Path base;

  /// Region paths in paint order.
  final Map<MuscleRegion, RegionPaths> regions;

  static final Map<(bool, MuscleMapSide), MuscleMapGeometry> _cache =
      <(bool, MuscleMapSide), MuscleMapGeometry>{};

  /// The geometry for the female base when [female], else the male one.
  static MuscleMapGeometry of({
    required bool female,
    required MuscleMapSide side,
  }) => _cache.putIfAbsent((female, side), () => _build(female, side));

  /// The geometry for [sex] (male when null, as the handoff says).
  static MuscleMapGeometry forSex(Sex? sex, MuscleMapSide side) =>
      of(female: sex == Sex.female, side: side);

  static Path _union(List<MapShape> shapes) {
    final Path p = Path();
    for (final MapShape s in shapes) {
      p.addPath(s.toPath(), Offset.zero);
    }
    return p;
  }

  static final Matrix4 _mirror = Matrix4.identity()
    ..translateByDouble(kMapCanvasWidth, 0, 0, 1)
    ..scaleByDouble(-1, 1, 1, 1);

  static MuscleMapGeometry _build(bool female, MuscleMapSide side) {
    final _RegionShapes front = female
        ? <MuscleRegion, List<MapShape>>{
            ..._maleFront,
            ..._femaleFrontOverrides,
          }
        : _maleFront;
    final _RegionShapes back = female
        ? <MuscleRegion, List<MapShape>>{..._maleBack, ..._femaleBackOverrides}
        : _maleBack;
    final _RegionShapes shapes = side == MuscleMapSide.front ? front : back;
    final Map<MuscleRegion, RegionPaths> regions =
        <MuscleRegion, RegionPaths>{};
    for (final MuscleRegion r in kSideRegions[side]!) {
      final Path left = _union(shapes[r]!);
      final Path right = left.transform(_mirror.storage);
      regions[r] = RegionPaths(
        left,
        right,
        left.getBounds().expandToInclude(right.getBounds()),
      );
    }
    return MuscleMapGeometry._(
      _union(female ? _baseFemale : _baseMale),
      regions,
    );
  }

  /// The square, in canvas units, that a cropped thumbnail shows: the bounds
  /// of [highlighted] regions, padded, at least [minSize] across. Falls back
  /// to the torso when nothing on this side is highlighted.
  Rect cropRect(
    Set<MuscleRegion> highlighted, {
    required double minSize,
    required double pad,
  }) {
    Rect? box;
    for (final MapEntry<MuscleRegion, RegionPaths> e in regions.entries) {
      if (!highlighted.contains(e.key)) continue;
      box = box == null ? e.value.bounds : box.expandToInclude(e.value.bounds);
    }
    box ??= const Rect.fromLTRB(20, 30, 100, 130);
    final double size =
        <double>[
          minSize,
          box.width,
          box.height,
        ].reduce((double a, double b) => a > b ? a : b) +
        pad;
    return Rect.fromCenter(center: box.center, width: size, height: size);
  }
}

/// Smallest square, in canvas units, a cropped thumbnail zooms to.
const double kCropMinSize = 64;

/// Padding, in canvas units, around the worked area of a cropped thumbnail.
const double kCropPad = 14;
