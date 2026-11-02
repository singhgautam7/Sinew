import '../models/enums.dart';

// PURE DART. Every stored value is metric (kg, cm, metres, seconds); these
// convert only at the edges, for display and for input. Never store a
// converted value.

/// Exact by definition (international yard and pound agreement, 1959).
abstract final class UnitFactors {
  static const double kgPerLb = 0.45359237;
  static const double cmPerInch = 2.54;
  static const double metresPerMile = 1609.344;
  static const double metresPerKm = 1000;
}

abstract final class Units {
  // ── Mass ──────────────────────────────────────────────────────────────────

  static double toKg(double value, WeightUnit from) => switch (from) {
    WeightUnit.kg => value,
    WeightUnit.lb => value * UnitFactors.kgPerLb,
  };

  static double fromKg(double kg, WeightUnit to) => switch (to) {
    WeightUnit.kg => kg,
    WeightUnit.lb => kg / UnitFactors.kgPerLb,
  };

  // ── Length (body measurements, height) ─────────────────────────────────────

  static double toCm(double value, LengthUnit from) => switch (from) {
    LengthUnit.cm => value,
    LengthUnit.inch => value * UnitFactors.cmPerInch,
  };

  static double fromCm(double cm, LengthUnit to) => switch (to) {
    LengthUnit.cm => cm,
    LengthUnit.inch => cm / UnitFactors.cmPerInch,
  };

  // ── Distance (cardio) ─────────────────────────────────────────────────────

  static double toMetres(double value, DistanceUnit from) => switch (from) {
    DistanceUnit.km => value * UnitFactors.metresPerKm,
    DistanceUnit.mi => value * UnitFactors.metresPerMile,
  };

  static double fromMetres(double metres, DistanceUnit to) => switch (to) {
    DistanceUnit.km => metres / UnitFactors.metresPerKm,
    DistanceUnit.mi => metres / UnitFactors.metresPerMile,
  };

  // ── Rounding for display ──────────────────────────────────────────────────

  /// Rounds to the nearest multiple of [step] (for example 0.5 kg, 1 lb).
  static double roundTo(double value, double step) {
    assert(step > 0, 'step must be positive');
    return (value / step).round() * step;
  }

  /// A short, trimmed number: `80`, `82.5`, `82.25`. Never `82.50`.
  static String trim(double value, {int maxDecimals = 2}) {
    final String fixed = value.toStringAsFixed(maxDecimals);
    if (!fixed.contains('.')) return fixed;
    final String stripped = fixed.replaceFirst(RegExp(r'0+$'), '');
    return stripped.endsWith('.')
        ? stripped.substring(0, stripped.length - 1)
        : stripped;
  }

  static String weightLabel(WeightUnit u) => switch (u) {
    WeightUnit.kg => 'kg',
    WeightUnit.lb => 'lb',
  };

  static String lengthLabel(LengthUnit u) => switch (u) {
    LengthUnit.cm => 'cm',
    LengthUnit.inch => 'in',
  };

  static String distanceLabel(DistanceUnit u) => switch (u) {
    DistanceUnit.km => 'km',
    DistanceUnit.mi => 'mi',
  };

  /// `80 kg` / `176.4 lb` from a stored kilogram value.
  static String formatWeight(
    double kg,
    WeightUnit unit, {
    int maxDecimals = 1,
  }) =>
      '${trim(fromKg(kg, unit), maxDecimals: maxDecimals)} ${weightLabel(unit)}';

  static String formatLength(
    double cm,
    LengthUnit unit, {
    int maxDecimals = 1,
  }) =>
      '${trim(fromCm(cm, unit), maxDecimals: maxDecimals)} ${lengthLabel(unit)}';

  static String formatDistance(
    double metres,
    DistanceUnit unit, {
    int maxDecimals = 2,
  }) =>
      '${trim(fromMetres(metres, unit), maxDecimals: maxDecimals)} '
      '${distanceLabel(unit)}';
}
