import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A thin scale with a filled part up to [value] and a tick at [marker], such
/// as the waist-to-height bar with its 0.5 line. It shows position, not
/// alarm: one colour, no red zone.
class SinewMarkerBar extends StatelessWidget {
  const SinewMarkerBar({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.marker,
    required this.height,
    required this.markerWidth,
    required this.markerHeight,
    required this.semanticLabel,
  }) : assert(max > min, 'max must exceed min');

  final double value;
  final double min;
  final double max;
  final double marker;
  final double height;
  final double markerWidth;
  final double markerHeight;
  final String semanticLabel;

  double _at(double v) => ((v - min) / (max - min)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          height: markerHeight,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double w = c.maxWidth;
              final double top = (markerHeight - height) / 2;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: top,
                    height: height,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: Radii.fullR,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    width: w * _at(value),
                    top: top,
                    height: height,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: Radii.fullR,
                      ),
                    ),
                  ),
                  Positioned(
                    left: w * _at(marker) - markerWidth / 2,
                    width: markerWidth,
                    top: 0,
                    height: markerHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.onSurface,
                        borderRadius: Radii.fullR,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
