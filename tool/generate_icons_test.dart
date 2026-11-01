import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/palette.dart';

/// Draws the legacy launcher icons, the Play Store icon and the splash art from
/// the design's Plate S glyph (variant A, round ends).
///
/// Not a test: a generator, run as one because `flutter test` is the only place
/// a Flutter canvas exists without a device (Kuber does the same). The adaptive
/// icon itself is the vector drawables in `res/drawable/`, ported from the same
/// geometry and not touched here; these PNGs are the pre-Android-8 fallback,
/// the store listing and the input of `flutter_native_splash`.
///
///     flutter test tool/generate_icons_test.dart
///     dart run flutter_native_splash:create
void main() {
  const String res = 'android/app/src/main/res';

  /// Paints [painter] into a square PNG of [size] pixels. Must run inside
  /// `tester.runAsync`: `toImage` needs the real rasteriser.
  Future<Uint8List> render(CustomPainter painter, double size) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    painter.paint(canvas, Size(size, size));
    final ui.Image image = await recorder.endRecording().toImage(
      size.round(),
      size.round(),
    );
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    return bytes!.buffer.asUint8List();
  }

  void write(String path, Uint8List bytes) {
    final File file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
  }

  testWidgets('draws the legacy launcher icons', (WidgetTester tester) async {
    // Android before 8 has no adaptive icon, so it gets the glyph on the tint
    // as a circle (what those launchers show). ic_launcher_round exists too
    // because the manifest names it and API 24 and 25 do not read the
    // mipmap-anydpi-v26 folder.
    const Map<String, double> densities = <String, double>{
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };
    for (final MapEntry<String, double> density in densities.entries) {
      final Uint8List png = (await tester.runAsync(
        () =>
            render(const _Clipped(_PlateS.light(ground: true)), density.value),
      ))!;
      write('$res/mipmap-${density.key}/ic_launcher.png', png);
      write('$res/mipmap-${density.key}/ic_launcher_round.png', png);
    }
  });

  testWidgets('draws the Play Store icon', (WidgetTester tester) async {
    // Square tint; Play applies its own mask.
    final Uint8List png = (await tester.runAsync(
      () => render(const _PlateS.light(ground: true), 512),
    ))!;
    write('assets/icon/play_store_512.png', png);
  });

  testWidgets('draws the splash marks', (WidgetTester tester) async {
    // Android 12+ masks the splash icon to a circle two thirds of a 288dp
    // canvas and shows only the middle of it. The art is the glyph alone on
    // transparent, drawn at 0.75 of the canvas; the ground is
    // `icon_background_color`.
    for (final (String name, _PlateS glyph) in <(String, _PlateS)>[
      ('splash_android12', const _PlateS.light()),
      ('splash_android12_dark', const _PlateS.night()),
    ]) {
      final Uint8List png = (await tester.runAsync(
        () => render(_Inset(glyph, factor: 0.75), 1152),
      ))!;
      write('assets/icon/$name.png', png);
    }

    // The pre-12 splash is the glyph on its tint circle, centred on the page
    // colour. The design scales the glyph by 1.155 on the splash circle.
    for (final (String name, _PlateS glyph) in <(String, _PlateS)>[
      ('splash', const _PlateS.light(ground: true, scale: _splashScale)),
      ('splash_dark', const _PlateS.night(ground: true, scale: _splashScale)),
    ]) {
      final Uint8List png = (await tester.runAsync(
        () => render(_Clipped(glyph), 384),
      ))!;
      write('assets/icon/$name.png', png);
    }
  });
}

/// The design's splash scale: glyph x 1.155 on the circle (8.3% stroke).
const double _splashScale = 1.155;

/// Plate S on the 512 grid of `sinew-art.js` (`plateS(d, m, 'round', t)`):
/// two face-on weight plates, each a 34 wide ring of radius 62 around a hub
/// of radius 31 with an 11 radius hole, open on one quarter, meeting at the
/// spine (256, 256). The whole group is drawn at 0.92 about the centre.
class _PlateS extends CustomPainter {
  const _PlateS({
    required this.dark,
    required this.mid,
    required this.tint,
    required this.ground,
    required this.scale,
  });

  /// Light: dark and mid on the brand tint.
  const _PlateS.light({bool ground = false, double scale = 1})
    : this(
        dark: SinewBrand.dark,
        mid: SinewBrand.mid,
        tint: SinewBrand.tint,
        ground: ground,
        scale: scale,
      );

  /// Dark: the design's lighter strokes on the #2A3310 circle.
  const _PlateS.night({bool ground = false, double scale = 1})
    : this(
        dark: _nightDark,
        mid: _nightMid,
        tint: SinewBrand.splashDarkTint,
        ground: ground,
        scale: scale,
      );

  // Foundations, "dark splash" mark: dark="#C9D79C" mid="#A1B567".
  static const Color _nightDark = Color(0xFFC9D79C);
  static const Color _nightMid = Color(0xFFA1B567);

  static const double _grid = 512;
  static const double _glyphScale = 0.92;
  static const double _ring = 62;
  static const double _stroke = 34;
  static const double _hub = 31;
  static const double _hole = 11;
  static const double _topY = 194;
  static const double _bottomY = 318;
  static const double _cx = 256;

  final Color dark;
  final Color mid;
  final Color tint;

  /// Fill the whole square with [tint] first.
  final bool ground;

  /// Extra scale about the centre, on top of the glyph's own 0.92.
  final double scale;

  Rect _ringRect(double cy) =>
      Rect.fromCircle(center: Offset(_cx, cy), radius: _ring);

  /// An SVG arc of [fromDeg] sweeping clockwise to [toDeg], as in plateS().
  Path _arc(double cy, double fromDeg, double toDeg) {
    final double sweep = (toDeg - fromDeg) % 360;
    return Path()
      ..addArc(_ringRect(cy), fromDeg * math.pi / 180, sweep * math.pi / 180);
  }

  /// A hub disc with its hole cut out, so the hole shows what is behind.
  Path _hubPath(double cy) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addOval(Rect.fromCircle(center: Offset(_cx, cy), radius: _hub))
      ..addOval(Rect.fromCircle(center: Offset(_cx, cy), radius: _hole));
  }

  Paint _strokePaint(Color color, StrokeCap cap) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = cap
      ..color = color
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _grid);
    if (ground) {
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, _grid, _grid),
        Paint()..color = tint,
      );
    }
    final double k = _glyphScale * scale;
    canvas
      ..translate(_grid / 2, _grid / 2)
      ..scale(k)
      ..translate(-_grid / 2, -_grid / 2);

    canvas
      ..drawPath(_arc(_topY, 90, 334), _strokePaint(dark, StrokeCap.round))
      ..drawPath(_hubPath(_topY), Paint()..color = dark)
      ..drawPath(_arc(_bottomY, 270, 154), _strokePaint(mid, StrokeCap.round))
      // The spine join: the last 20 degrees of the top ring in the bottom
      // colour with butt ends.
      ..drawPath(_arc(_topY, 70, 90), _strokePaint(mid, StrokeCap.butt))
      ..drawPath(_hubPath(_bottomY), Paint()..color = mid);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlateS old) => true;
}

/// Draws [child] centred at [factor] of the box, on transparent.
class _Inset extends CustomPainter {
  const _Inset(this.child, {required this.factor});

  final CustomPainter child;
  final double factor;

  @override
  void paint(Canvas canvas, Size size) {
    final double inner = size.width * factor;
    final double edge = (size.width - inner) / 2;
    canvas
      ..save()
      ..translate(edge, edge);
    child.paint(canvas, Size(inner, inner));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Inset old) => true;
}

/// Draws [child] clipped to a circle, which is how a launcher shows it.
class _Clipped extends CustomPainter {
  const _Clipped(this.child);

  final CustomPainter child;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..clipPath(Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height)));
    child.paint(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Clipped old) => true;
}
