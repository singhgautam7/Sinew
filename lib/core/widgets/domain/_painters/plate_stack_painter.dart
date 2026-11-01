import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Height of the stack art for [count] plates, in design units.
double plateStackHeight(int count) =>
    count * PlateSpec.stackPitch + PlateSpec.stackBottom + PlateSpec.stackTop;

/// A machine weight stack: a rod, [count] plates (the first [selected] are
/// lit) and a pin at plate [pin] (a fractional index while it slides).
class PlateStackPainter extends CustomPainter {
  const PlateStackPainter({
    required this.count,
    required this.selected,
    required this.pin,
    required this.stepLabel,
    required this.lit,
    required this.base,
    required this.rod,
    required this.pinColor,
    required this.labelStyle,
  });

  final int count;
  final int selected;
  final double pin;

  /// Text drawn beside every [PlateSpec.stackLabelEvery]th plate, by plate
  /// number (1-based).
  final String Function(int plateNumber) stepLabel;
  final Color lit;
  final Color base;
  final Color rod;
  final Color pinColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const double w = PlateSpec.stackWidth;
    final double h = plateStackHeight(count);
    canvas.save();
    canvas.scale(size.width / w);
    const double mid = w / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          mid - PlateSpec.stackRodHalf,
          0,
          PlateSpec.stackRodHalf * 2,
          h,
        ),
        const Radius.circular(PlateSpec.stackRodHalf),
      ),
      Paint()..color = rod,
    );
    for (int i = 0; i < count; i++) {
      final double y = PlateSpec.stackTop + i * PlateSpec.stackPitch;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            mid - PlateSpec.stackPlateHalf,
            y,
            PlateSpec.stackPlateHalf * 2,
            PlateSpec.stackPlateHeight,
          ),
          const Radius.circular(PlateSpec.stackPlateRadius),
        ),
        Paint()..color = i < selected ? lit : base,
      );
      if ((i + 1) % PlateSpec.stackLabelEvery == 0) {
        final TextPainter tp = TextPainter(
          text: TextSpan(text: stepLabel(i + 1), style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(
            mid + PlateSpec.stackLabelOffset,
            y + (PlateSpec.stackPlateHeight - tp.height) / 2,
          ),
        );
      }
    }

    final double py =
        PlateSpec.stackTop +
        (pin - 1) * PlateSpec.stackPitch +
        PlateSpec.stackPlateHeight / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          mid - PlateSpec.pinStart,
          py - PlateSpec.pinHeight / 2,
          PlateSpec.pinLength,
          PlateSpec.pinHeight,
        ),
        const Radius.circular(PlateSpec.pinHeight / 2),
      ),
      Paint()..color = pinColor,
    );
    canvas.drawCircle(
      Offset(mid - PlateSpec.pinKnobOffset, py),
      PlateSpec.pinKnobRadius,
      Paint()..color = pinColor,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(PlateStackPainter old) =>
      old.count != count ||
      old.selected != selected ||
      old.pin != pin ||
      old.lit != lit ||
      old.base != base ||
      old.rod != rod ||
      old.pinColor != pinColor ||
      old.labelStyle != labelStyle;
}
