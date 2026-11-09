// ThemeExtension holding the 9 color roles from figure_style.json.
// Shared between the FigurePainter and MuscleMap to guarantee perfect visual harmony.

import 'package:flutter/material.dart';

import 'accents.dart';

@immutable
class FigureColors extends ThemeExtension<FigureColors> {
  const FigureColors({
    required this.bodyBase,
    required this.bodyMuscle,
    required this.bodyFar,
    required this.musclePrimary,
    required this.muscleSecondary,
    required this.prop,
    required this.propDetail,
    required this.ground,
    required this.shadow,
  });

  /// Torso base, head, neck, feet, joint dots.
  final Color bodyBase;

  /// Default untargeted muscle shapes.
  final Color bodyMuscle;

  /// Far-side limbs for depth separation.
  final Color bodyFar;

  /// Primary targeted muscle highlight.
  final Color musclePrimary;

  /// Secondary targeted muscle highlight.
  final Color muscleSecondary;

  /// Equipment frames, bars, handles, bench structure.
  final Color prop;

  /// Plates, collars, bench pad.
  final Color propDetail;

  /// Ground reference plane.
  final Color ground;

  /// Soft contact shadow.
  final Color shadow;

  static FigureColors derive({
    required ColorScheme cs,
    required SinewAccents accents,
    required bool isDark,
  }) {
    final Color bodyFar = Color.lerp(
      accents.muscleIdle,
      isDark ? cs.surface : cs.surfaceContainerHighest,
      0.35,
    )!;

    return FigureColors(
      bodyBase: accents.muscleBody,
      bodyMuscle: accents.muscleIdle,
      bodyFar: bodyFar,
      musclePrimary: accents.musclePrimary,
      muscleSecondary: accents.muscleSecondary,
      prop: cs.inverseSurface,
      propDetail: isDark ? cs.outline : cs.onSurfaceVariant,
      ground: cs.outlineVariant,
      shadow: cs.onSurface.withValues(alpha: 0.12),
    );
  }

  @override
  FigureColors copyWith({
    Color? bodyBase,
    Color? bodyMuscle,
    Color? bodyFar,
    Color? musclePrimary,
    Color? muscleSecondary,
    Color? prop,
    Color? propDetail,
    Color? ground,
    Color? shadow,
  }) {
    return FigureColors(
      bodyBase: bodyBase ?? this.bodyBase,
      bodyMuscle: bodyMuscle ?? this.bodyMuscle,
      bodyFar: bodyFar ?? this.bodyFar,
      musclePrimary: musclePrimary ?? this.musclePrimary,
      muscleSecondary: muscleSecondary ?? this.muscleSecondary,
      prop: prop ?? this.prop,
      propDetail: propDetail ?? this.propDetail,
      ground: ground ?? this.ground,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  FigureColors lerp(ThemeExtension<FigureColors>? other, double t) {
    if (other is! FigureColors) return this;
    return FigureColors(
      bodyBase: Color.lerp(bodyBase, other.bodyBase, t)!,
      bodyMuscle: Color.lerp(bodyMuscle, other.bodyMuscle, t)!,
      bodyFar: Color.lerp(bodyFar, other.bodyFar, t)!,
      musclePrimary: Color.lerp(musclePrimary, other.musclePrimary, t)!,
      muscleSecondary: Color.lerp(muscleSecondary, other.muscleSecondary, t)!,
      prop: Color.lerp(prop, other.prop, t)!,
      propDetail: Color.lerp(propDetail, other.propDetail, t)!,
      ground: Color.lerp(ground, other.ground, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension FigureColorsBuildContext on BuildContext {
  FigureColors get figureColors =>
      Theme.of(this).extension<FigureColors>() ??
      FigureColors(
        bodyBase: Colors.grey.shade300,
        bodyMuscle: Colors.grey.shade500,
        bodyFar: Colors.grey.shade600,
        musclePrimary: Colors.green,
        muscleSecondary: Colors.lightGreen,
        prop: Colors.black87,
        propDetail: Colors.grey,
        ground: Colors.grey.shade400,
        shadow: Colors.black26,
      );
}
