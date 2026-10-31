import 'package:flutter/material.dart';

/// The type scale.
///
/// PLACEHOLDER (Phase 1): Material 3's 2021 scale in the platform font, which
/// ships with the OS and is never fetched. Phase 3 bundles the handoff's
/// typeface under `assets/fonts/` and sets [family]; `google_fonts` is banned.
abstract final class SinewType {
  /// Null means the platform default (Roboto on Android).
  static const String? family = null;

  /// Tabular figures for every number that ticks or lines up in a column:
  /// timers, weights, reps, stats.
  static const List<FontFeature> tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    final TextTheme base = Typography.material2021().englishLike.apply(
      fontFamily: family,
      bodyColor: onSurface,
      displayColor: onSurface,
    );
    return base.copyWith(
      labelSmall: base.labelSmall?.copyWith(color: onSurfaceVariant),
      bodySmall: base.bodySmall?.copyWith(color: onSurfaceVariant),
    );
  }
}
