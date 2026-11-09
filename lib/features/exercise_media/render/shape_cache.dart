// Pre-baked unit Path shapes for the figure painter.
//
// Precomputes every primitive path once per body base and style version.
// Drawn per frame using canvas transforms (save, translate, rotate, scale, restore).
// NEVER rebuilds a Path during playback.

import 'dart:math' as math;
import 'dart:ui';

class ShapeCache {
  ShapeCache._() {
    _initPaths();
  }

  static ShapeCache? _instance;
  static ShapeCache get instance => _instance ??= ShapeCache._();

  /// Unit circle: center (0, 0), radius 1.0
  late final Path unitCircle;

  /// Unit ellipse: center (0, 0), rx 1.0, ry 1.0
  late final Path unitEllipse;

  /// Unit rounded rectangle: bounds (-1, -1, 1, 1), radius 0.35
  late final Path unitRoundedRect;

  /// Unit capsule: segment from (0, -1) to (0, 1) with hemispherical caps of radius 1.0
  late final Path unitCapsule;

  /// Chest plate: trapezoidal / rounded chest shield
  late final Path unitChestPlate;

  /// Flat foot: rounded contact sole
  late final Path unitFoot;

  void _initPaths() {
    // 1. Unit circle
    unitCircle = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 1.0));

    // 2. Unit ellipse
    unitEllipse = Path()
      ..addOval(const Rect.fromLTRB(-1.0, -1.0, 1.0, 1.0));

    // 3. Unit rounded rectangle
    unitRoundedRect = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(-1.0, -1.0, 1.0, 1.0),
          const Radius.circular(0.35),
        ),
      );

    // 4. Unit capsule along Y axis: (-1 to 1)
    unitCapsule = Path()
      ..moveTo(-1.0, -1.0)
      ..arcTo(
        const Rect.fromLTRB(-1.0, -2.0, 1.0, 0.0),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(1.0, 1.0)
      ..arcTo(
        const Rect.fromLTRB(-1.0, 0.0, 1.0, 2.0),
        0.0,
        math.pi,
        false,
      )
      ..close();

    // 5. Unit chest plate
    unitChestPlate = Path()
      ..moveTo(-0.9, -1.0)
      ..lineTo(0.9, -1.0)
      ..lineTo(0.7, 0.8)
      ..quadraticBezierTo(0.0, 1.1, -0.7, 0.8)
      ..close();

    // 6. Unit foot (flat bottom oval)
    unitFoot = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(-1.0, -0.6, 1.0, 0.6),
          const Radius.circular(0.6),
        ),
      );
  }
}
