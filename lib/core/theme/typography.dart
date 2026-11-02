import 'package:flutter/material.dart';

/// The type scale: Kuber's M3 scale in Inter (bundled under `assets/fonts/`,
/// never fetched), tabular figures everywhere so numbers line up, plus the
/// Sinew roles: a timer numeral, a JetBrains Mono readout and the Instrument
/// Serif italic accent used on About.
abstract final class SinewType {
  static const String family = 'Inter';
  static const String monoFamily = 'JetBrainsMono';
  static const String serifFamily = 'InstrumentSerif';

  /// Tabular figures for every number that ticks or lines up in a column:
  /// timers, weights, reps, stats.
  static const List<FontFeature> tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  /// Caps section headings and overlines.
  static const double sectionTracking = 0.8;

  /// The across-the-room timer numeral: 150/150 w700, tracking -6, display
  /// only. It scales down to fit the width (`FittedBox` at the call site).
  static const TextStyle timerNumeral = TextStyle(
    fontFamily: family,
    fontSize: 150,
    height: 1,
    fontWeight: FontWeight.w700,
    letterSpacing: -6,
    fontFeatures: tabular,
  );

  /// labelLarge at w700, for emphasis labels (replaces ad hoc weight
  /// overrides at call sites).
  static const TextStyle labelBold = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    fontFeatures: tabular,
  );

  /// Numeric readouts that want fixed-width glyphs (plate maths, set logs).
  static const TextStyle mono = TextStyle(
    fontFamily: monoFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    fontFeatures: tabular,
  );

  /// Editorial accent (About page): Instrument Serif italic. The family ships
  /// one weight, so no weight is set (no faux bold).
  static const TextStyle serifAccent = TextStyle(
    fontFamily: serifFamily,
    fontStyle: FontStyle.italic,
    fontSize: 28,
    height: 32 / 28,
  );

  /// Kuber's 15 roles. [onSurface] is the default colour, [onSurfaceVariant]
  /// the one `bodySmall` takes.
  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    TextStyle r(
      double size,
      double line,
      FontWeight w,
      double tracking, [
      Color? color,
    ]) => TextStyle(
      fontFamily: family,
      fontSize: size,
      height: line / size,
      fontWeight: w,
      letterSpacing: tracking,
      color: color ?? onSurface,
      fontFeatures: tabular,
    );
    return TextTheme(
      displayLarge: r(57, 64, FontWeight.w700, -0.25),
      displayMedium: r(45, 52, FontWeight.w700, 0),
      displaySmall: r(36, 44, FontWeight.w700, -0.5),
      headlineLarge: r(32, 40, FontWeight.w700, -0.5),
      headlineMedium: r(28, 36, FontWeight.w700, -0.25),
      headlineSmall: r(24, 32, FontWeight.w600, 0),
      titleLarge: r(22, 28, FontWeight.w600, -0.2),
      titleMedium: r(16, 24, FontWeight.w600, 0.1),
      titleSmall: r(14, 20, FontWeight.w600, 0.1),
      bodyLarge: r(16, 24, FontWeight.w400, 0),
      bodyMedium: r(14, 20, FontWeight.w400, 0),
      bodySmall: r(12, 16, FontWeight.w400, 0, onSurfaceVariant),
      labelLarge: r(14, 20, FontWeight.w600, 0.1),
      labelMedium: r(12, 16, FontWeight.w600, 0.5),
      labelSmall: r(11, 16, FontWeight.w500, 0.5),
    );
  }
}
