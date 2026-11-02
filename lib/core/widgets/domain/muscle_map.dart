import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/enums.dart';
import '../../theme/app_theme.dart';
import 'muscle_map_data.dart';

export 'muscle_map_data.dart'
    show
        MuscleMapSide,
        MuscleRegion,
        cropSideFor,
        kBackMuscles,
        kFrontMuscles,
        kMuscleRegions,
        regionsForMuscle;

/// Which faces of the body a [MuscleMap] shows.
enum MuscleMapView {
  front,
  back,

  /// Both, side by side. With [MuscleMapFit.crop] this means "pick the side
  /// with more primary muscles".
  both,
}

/// How the map sits in its box.
enum MuscleMapFit {
  /// The whole body, letterboxed.
  contain,

  /// One side, zoomed to the worked muscles so it fills a list tile.
  crop,
}

/// The front and back muscle map: 15 regions on a male or female base.
///
/// Library muscle ids map onto regions through [kMuscleRegions]: `fullBody`
/// tints everything with the secondary colour; `neck` and `hipFlexors` are
/// drawn as body, not as muscles. In [heat] mode the map shows a weekly-volume
/// ramp instead of primary and secondary.
///
/// [onRegionTap] receives the library id of the tapped region (`quadriceps`
/// for quads, `core` for abs, `trapezius`, `lowerBack` and so on). Each region
/// is then also an accessibility target of at least 48dp.
class MuscleMap extends StatelessWidget {
  const MuscleMap({
    super.key,
    this.primary = const <String>[],
    this.secondary = const <String>[],
    this.view = MuscleMapView.both,
    this.fit = MuscleMapFit.contain,
    this.sex,
    this.tint,
    this.heat,
    this.onRegionTap,
    this.showLabels = true,
    this.semanticLabel,
  });

  /// Library muscle ids worked as the main movers.
  final List<String> primary;

  /// Library muscle ids that help.
  final List<String> secondary;
  final MuscleMapView view;
  final MuscleMapFit fit;

  /// Picks the base; the male base when null.
  final Sex? sex;

  /// Replaces the primary colour (a routine's colour). The secondary colour
  /// becomes a pale mix of it.
  final Color? tint;

  /// Muscle id to intensity, 0 to 1, drawn with the five heat steps. When
  /// set, [primary] and [secondary] are ignored.
  final Map<String, double>? heat;

  /// Called with a library muscle id when a region is tapped.
  final ValueChanged<String>? onRegionTap;

  /// "Front" and "Back" captions under a two-sided map.
  final bool showLabels;

  /// Overrides the generated TalkBack label.
  final String? semanticLabel;

  /// The TalkBack label for these inputs: "Worked: chest, triceps; also
  /// shoulders".
  static String describe({
    List<String> primary = const <String>[],
    List<String> secondary = const <String>[],
    Map<String, double>? heat,
  }) {
    if (heat != null) {
      final List<MapEntry<String, double>> hot =
          heat.entries
              .where((MapEntry<String, double> e) => e.value > 0)
              .toList()
            ..sort(
              (MapEntry<String, double> a, MapEntry<String, double> b) =>
                  b.value.compareTo(a.value),
            );
      if (hot.isEmpty) return 'Muscle map. No training this week';
      return 'Muscle map. Most trained: '
          '${hot.take(_spokenHeatCount).map((MapEntry<String, double> e) => muscleSpokenName(e.key)).join(', ')}';
    }
    String names(List<String> ids) => ids.map(muscleSpokenName).join(', ');
    if (primary.isEmpty && secondary.isEmpty) return 'Muscle map. None marked';
    if (primary.isEmpty) return 'Also worked: ${names(secondary)}';
    return secondary.isEmpty
        ? 'Worked: ${names(primary)}'
        : 'Worked: ${names(primary)}; also ${names(secondary)}';
  }

  static const int _spokenHeatCount = 3;

  @override
  Widget build(BuildContext context) {
    final _MapPalette palette = _MapPalette.of(
      context,
      tint: tint,
      heat: heat,
      primary: primary,
      secondary: secondary,
    );
    final String label =
        semanticLabel ??
        describe(primary: primary, secondary: secondary, heat: heat);
    final Widget body = fit == MuscleMapFit.crop
        ? _buildCrop(context, palette)
        : _buildContain(context, palette);
    return Semantics(
      label: label,
      image: true,
      explicitChildNodes: onRegionTap != null,
      child: RepaintBoundary(child: body),
    );
  }

  Widget _buildCrop(BuildContext context, _MapPalette palette) {
    final MuscleMapSide side = switch (view) {
      MuscleMapView.front => MuscleMapSide.front,
      MuscleMapView.back => MuscleMapSide.back,
      MuscleMapView.both => cropSideFor(primary, secondary),
    };
    final MuscleMapGeometry geo = MuscleMapGeometry.forSex(sex, side);
    final Rect rect = geo.cropRect(
      palette.highlighted,
      minSize: kCropMinSize,
      pad: kCropPad,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double w = c.hasBoundedWidth ? c.maxWidth : MapSpec.thumb;
        final double h = c.hasBoundedHeight ? c.maxHeight : w;
        return SizedBox(
          width: w,
          height: h,
          child: _Figure(
            geometry: geo,
            side: side,
            palette: palette,
            viewRect: rect,
            fit: BoxFit.cover,
            onRegionTap: onRegionTap,
          ),
        );
      },
    );
  }

  Widget _buildContain(BuildContext context, _MapPalette palette) {
    final List<MuscleMapSide> sides = switch (view) {
      MuscleMapView.front => const <MuscleMapSide>[MuscleMapSide.front],
      MuscleMapView.back => const <MuscleMapSide>[MuscleMapSide.back],
      MuscleMapView.both => const <MuscleMapSide>[
        MuscleMapSide.front,
        MuscleMapSide.back,
      ],
    };
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final bool bounded = c.hasBoundedHeight;
        Widget column(MuscleMapSide side) {
          final Widget figure = _Figure(
            geometry: MuscleMapGeometry.forSex(sex, side),
            side: side,
            palette: palette,
            viewRect: kMapViewBox,
            fit: BoxFit.contain,
            onRegionTap: onRegionTap,
          );
          return Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            children: <Widget>[
              if (bounded)
                Expanded(child: figure)
              else
                AspectRatio(
                  aspectRatio: kMapViewBox.width / kMapViewBox.height,
                  child: figure,
                ),
              if (showLabels && sides.length > 1) ...<Widget>[
                const SizedBox(height: MapSpec.labelGap),
                ExcludeSemantics(
                  child: Text(
                    side == MuscleMapSide.front ? 'Front' : 'Back',
                    style: context.text.labelSmall!.copyWith(
                      color: context.cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          );
        }

        final Widget row = Row(
          crossAxisAlignment: bounded
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < sides.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: MapSpec.figureGap),
              Expanded(child: column(sides[i])),
            ],
          ],
        );
        return row;
      },
    );
  }
}

/// Resolved colours for one build: which region gets which colour.
class _MapPalette {
  const _MapPalette({
    required this.body,
    required this.idle,
    required this.fills,
  });

  final Color body;
  final Color idle;

  /// Highlighted regions only; everything else is [idle].
  final Map<MuscleRegion, Color> fills;

  Set<MuscleRegion> get highlighted => fills.keys.toSet();

  Color colorOf(MuscleRegion r) => fills[r] ?? idle;

  factory _MapPalette.of(
    BuildContext context, {
    required Color? tint,
    required Map<String, double>? heat,
    required List<String> primary,
    required List<String> secondary,
  }) {
    final SinewAccents a = context.accents;
    final Map<MuscleRegion, Color> fills = <MuscleRegion, Color>{};
    if (heat != null) {
      final Map<MuscleRegion, double> level = <MuscleRegion, double>{};
      for (final MapEntry<String, double> e in heat.entries) {
        if (!(e.value > 0)) continue;
        for (final MuscleRegion r in regionsForMuscle(e.key)) {
          level[r] = math.max(level[r] ?? 0, e.value);
        }
      }
      final int top = a.heat.length - 1;
      level.forEach((MuscleRegion r, double v) {
        final int step = (v.clamp(0.0, 1.0) * a.heat.length).ceil() - 1;
        fills[r] = a.heat[step.clamp(0, top)];
      });
    } else {
      final Color p = tint ?? a.musclePrimary;
      final Color s = tint == null
          ? a.muscleSecondary
          : Color.lerp(context.cs.surface, tint, MapSpec.tintSecondaryMix)!;
      for (final String id in secondary) {
        for (final MuscleRegion r in regionsForMuscle(id)) {
          fills[r] = s;
        }
      }
      for (final String id in primary) {
        for (final MuscleRegion r in regionsForMuscle(id)) {
          fills[r] = p;
        }
      }
    }
    return _MapPalette(body: a.muscleBody, idle: a.muscleIdle, fills: fills);
  }
}

/// Maps canvas units onto a widget box the way SVG `preserveAspectRatio`
/// does: `contain` is "meet", `cover` is "slice".
class _FigureTransform {
  _FigureTransform(this.size, this.viewRect, this.fit)
    : scale = fit == BoxFit.cover
          ? math.max(size.width / viewRect.width, size.height / viewRect.height)
          : math.min(
              size.width / viewRect.width,
              size.height / viewRect.height,
            ) {
    offset = Offset(
      (size.width - viewRect.width * scale) / 2 - viewRect.left * scale,
      (size.height - viewRect.height * scale) / 2 - viewRect.top * scale,
    );
  }

  final Size size;
  final Rect viewRect;
  final BoxFit fit;
  final double scale;
  late final Offset offset;

  Offset toCanvas(Offset local) => (local - offset) / scale;
  Offset toLocal(Offset canvas) => canvas * scale + offset;
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.geometry,
    required this.side,
    required this.palette,
    required this.viewRect,
    required this.fit,
    required this.onRegionTap,
  });

  final MuscleMapGeometry geometry;
  final MuscleMapSide side;
  final _MapPalette palette;
  final Rect viewRect;
  final BoxFit fit;
  final ValueChanged<String>? onRegionTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final Size size = c.biggest;
        final _FigureTransform t = _FigureTransform(size, viewRect, fit);
        final ValueChanged<String>? tap = onRegionTap;
        final Widget paint = CustomPaint(
          size: size,
          painter: MuscleFigurePainter(
            geometry: geometry,
            body: palette.body,
            idle: palette.idle,
            fills: palette.fills,
            viewRect: viewRect,
            fit: fit,
            regionSemantics: tap == null
                ? null
                : (Size s) =>
                      _regionSemantics(s, t, tap, Directionality.of(context)),
          ),
        );
        if (tap == null) return ExcludeSemantics(child: paint);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (TapUpDetails d) {
            final MuscleRegion? r = _hit(t.toCanvas(d.localPosition), t);
            if (r != null) tap(r.muscleId);
          },
          child: paint,
        );
      },
    );
  }

  /// The region under [p]: a region that contains it, else the nearest one
  /// whose bounds, grown by half a touch target, reach it.
  MuscleRegion? _hit(Offset p, _FigureTransform t) {
    for (final MuscleRegion r in geometry.regions.keys.toList().reversed) {
      if (geometry.regions[r]!.contains(p)) return r;
    }
    final double reach = (IconSpec.tapTarget / 2) / t.scale;
    MuscleRegion? best;
    double bestD = double.infinity;
    for (final MapEntry<MuscleRegion, RegionPaths> e
        in geometry.regions.entries) {
      if (!e.value.bounds.inflate(reach).contains(p)) continue;
      final double d = (e.value.bounds.center - p).distance;
      if (d < bestD) {
        bestD = d;
        best = e.key;
      }
    }
    return best;
  }

  List<CustomPainterSemantics> _regionSemantics(
    Size size,
    _FigureTransform t,
    ValueChanged<String> tap,
    TextDirection direction,
  ) {
    final Rect box = Offset.zero & size;
    final List<CustomPainterSemantics> out = <CustomPainterSemantics>[];
    for (final MapEntry<MuscleRegion, RegionPaths> e
        in geometry.regions.entries) {
      Rect r = Rect.fromPoints(
        t.toLocal(e.value.bounds.topLeft),
        t.toLocal(e.value.bounds.bottomRight),
      );
      final double w = math.max(r.width, IconSpec.tapTarget);
      final double h = math.max(r.height, IconSpec.tapTarget);
      r = Rect.fromCenter(center: r.center, width: w, height: h);
      r = r.intersect(box);
      if (r.isEmpty) continue;
      out.add(
        CustomPainterSemantics(
          key: ValueKey<MuscleRegion>(e.key),
          rect: r,
          properties: SemanticsProperties(
            textDirection: direction,
            label: e.key.label,
            button: true,
            onTap: () => tap(e.key.muscleId),
          ),
        ),
      );
    }
    return out;
  }
}

/// Paints one side of the body: the base, then every region (and its mirror)
/// in its colour. Public so tests can read what was drawn.
class MuscleFigurePainter extends CustomPainter {
  const MuscleFigurePainter({
    required this.geometry,
    required this.body,
    required this.idle,
    required this.fills,
    required this.viewRect,
    required this.fit,
    this.regionSemantics,
  });

  /// One accessibility node per region, when the map is tappable.
  final SemanticsBuilderCallback? regionSemantics;

  final MuscleMapGeometry geometry;
  final Color body;
  final Color idle;
  final Map<MuscleRegion, Color> fills;
  final Rect viewRect;
  final BoxFit fit;

  @override
  void paint(Canvas canvas, Size size) {
    final _FigureTransform t = _FigureTransform(size, viewRect, fit);
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..translate(t.offset.dx, t.offset.dy)
      ..scale(t.scale);
    final Paint paint = Paint()..isAntiAlias = true;
    canvas.drawPath(geometry.base, paint..color = body);
    for (final MapEntry<MuscleRegion, RegionPaths> e
        in geometry.regions.entries) {
      paint.color = fills[e.key] ?? idle;
      canvas
        ..drawPath(e.value.left, paint)
        ..drawPath(e.value.right, paint);
    }
    canvas.restore();
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => regionSemantics;

  @override
  bool shouldRepaint(MuscleFigurePainter oldDelegate) =>
      oldDelegate.geometry != geometry ||
      oldDelegate.body != body ||
      oldDelegate.idle != idle ||
      oldDelegate.viewRect != viewRect ||
      oldDelegate.fit != fit ||
      !_sameFills(oldDelegate.fills, fills);

  static bool _sameFills(
    Map<MuscleRegion, Color> a,
    Map<MuscleRegion, Color> b,
  ) {
    if (a.length != b.length) return false;
    for (final MapEntry<MuscleRegion, Color> e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }

  @override
  bool shouldRebuildSemantics(MuscleFigurePainter oldDelegate) =>
      oldDelegate.geometry != geometry ||
      oldDelegate.viewRect != viewRect ||
      (oldDelegate.regionSemantics == null) != (regionSemantics == null);
}
