import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The app mark: a rounded tile in the primary container with the barbell
/// glyph. Decorative; the name next to it is what a screen reader hears.
class SinewBrandMark extends StatelessWidget {
  const SinewBrandMark({super.key, this.size = Sizes.buttonLarge});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.cs.primaryContainer,
          borderRadius: BorderRadius.circular(
            size * TodaySpec.brandRadiusRatio,
          ),
        ),
        child: Icon(
          Icons.fitness_center_rounded,
          size: size * TodaySpec.brandGlyphRatio,
          color: context.cs.onPrimaryContainer,
        ),
      ),
    );
  }
}
