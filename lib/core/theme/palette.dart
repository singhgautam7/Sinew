import 'package:flutter/material.dart';

/// The only place in the app that names a raw colour.
///
/// PLACEHOLDER DERIVATION (Phase 1): every role is derived from a seed through
/// Material's tonal-spot scheme. Phase 3 replaces [SinewColors.derive] with the
/// full palette from the design handoff; the role names are the contract that
/// widgets code against, so the swap is one file.
abstract final class SinewSeeds {
  /// Sinew's brand seed, used when dynamic colour is off or unavailable.
  static const Color brand = Color(0xFF6E8A16);

  /// Fixed status hues, harmonised into each scheme by re-seeding.
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB26A00);

  /// True black and pure white for the AMOLED tone and the inverse ground.
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
}

/// Which variant of a scheme is being rendered.
enum Tone { light, dark, amoled }

/// The role tokens. Nothing in a screen names a raw colour; it reads
/// `context.colors.<role>`. A theme swap is a single map replacement.
@immutable
class SinewColors extends ThemeExtension<SinewColors> {
  const SinewColors({
    required this.tone,
    required this.surface,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.outline,
    required this.divider,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onSurfaceMuted,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.shadow,
    required this.scrim,
  });

  final Tone tone;

  /// Page background.
  final Color surface;
  final Color surfaceContainerLow;

  /// Cards, rows, sheets.
  final Color surfaceContainer;

  /// Nav pill, chips, fields.
  final Color surfaceContainerHigh;

  /// 1px borders. Depth lives here.
  final Color outline;

  /// Hairline between rows inside one container.
  final Color divider;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color onSurfaceMuted;

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  /// Personal records, completed sets.
  final Color success;
  final Color successContainer;

  /// Estimated values, approaching limits.
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color onDangerContainer;
  final Color inverseSurface;
  final Color onInverseSurface;

  /// Only the nav pill casts one.
  final Color shadow;
  final Color scrim;

  bool get isDark => tone != Tone.light;

  /// Derives every role from one seed. Memoised by `AppTheme`, never called
  /// per frame.
  factory SinewColors.derive(Color seed, Tone tone) {
    final Brightness b = tone == Tone.light
        ? Brightness.light
        : Brightness.dark;
    final ColorScheme s = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    final ColorScheme ok = ColorScheme.fromSeed(
      seedColor: SinewSeeds.success,
      brightness: b,
    );
    final ColorScheme warn = ColorScheme.fromSeed(
      seedColor: SinewSeeds.warning,
      brightness: b,
    );
    final bool amoled = tone == Tone.amoled;
    return SinewColors(
      tone: tone,
      surface: amoled ? SinewSeeds.black : s.surface,
      surfaceContainerLow: amoled
          ? s.surfaceContainerLowest
          : s.surfaceContainerLow,
      surfaceContainer: amoled ? s.surfaceContainerLow : s.surfaceContainer,
      surfaceContainerHigh: amoled
          ? s.surfaceContainer
          : s.surfaceContainerHigh,
      outline: s.outlineVariant,
      divider: s.outlineVariant.withValues(alpha: 0.6),
      onSurface: s.onSurface,
      onSurfaceVariant: s.onSurfaceVariant,
      onSurfaceMuted: s.onSurface.withValues(alpha: 0.38),
      primary: s.primary,
      onPrimary: s.onPrimary,
      primaryContainer: s.primaryContainer,
      onPrimaryContainer: s.onPrimaryContainer,
      secondaryContainer: s.secondaryContainer,
      onSecondaryContainer: s.onSecondaryContainer,
      tertiary: s.tertiary,
      tertiaryContainer: s.tertiaryContainer,
      onTertiaryContainer: s.onTertiaryContainer,
      success: ok.primary,
      successContainer: ok.primaryContainer,
      warning: warn.primary,
      warningContainer: warn.primaryContainer,
      danger: s.error,
      dangerContainer: s.errorContainer,
      onDangerContainer: s.onErrorContainer,
      inverseSurface: s.inverseSurface,
      onInverseSurface: s.onInverseSurface,
      shadow: s.shadow,
      scrim: s.scrim,
    );
  }

  /// The Material [ColorScheme] filled from these roles, so any stock widget
  /// lands on the same colours as the rest of the app.
  ColorScheme toColorScheme(Color seed) {
    final ColorScheme base = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
    return base.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: divider,
      error: danger,
      errorContainer: dangerContainer,
      onErrorContainer: onDangerContainer,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      shadow: shadow,
      scrim: scrim,
    );
  }

  /// Roles are derived from a seed, never edited one by one: a different
  /// palette is a new [SinewColors.derive].
  @override
  SinewColors copyWith() => this;

  @override
  SinewColors lerp(ThemeExtension<SinewColors>? other, double t) {
    if (other is! SinewColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SinewColors(
      tone: t < 0.5 ? tone : other.tone,
      surface: l(surface, other.surface),
      surfaceContainerLow: l(surfaceContainerLow, other.surfaceContainerLow),
      surfaceContainer: l(surfaceContainer, other.surfaceContainer),
      surfaceContainerHigh: l(surfaceContainerHigh, other.surfaceContainerHigh),
      outline: l(outline, other.outline),
      divider: l(divider, other.divider),
      onSurface: l(onSurface, other.onSurface),
      onSurfaceVariant: l(onSurfaceVariant, other.onSurfaceVariant),
      onSurfaceMuted: l(onSurfaceMuted, other.onSurfaceMuted),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primaryContainer: l(primaryContainer, other.primaryContainer),
      onPrimaryContainer: l(onPrimaryContainer, other.onPrimaryContainer),
      secondaryContainer: l(secondaryContainer, other.secondaryContainer),
      onSecondaryContainer: l(onSecondaryContainer, other.onSecondaryContainer),
      tertiary: l(tertiary, other.tertiary),
      tertiaryContainer: l(tertiaryContainer, other.tertiaryContainer),
      onTertiaryContainer: l(onTertiaryContainer, other.onTertiaryContainer),
      success: l(success, other.success),
      successContainer: l(successContainer, other.successContainer),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      danger: l(danger, other.danger),
      dangerContainer: l(dangerContainer, other.dangerContainer),
      onDangerContainer: l(onDangerContainer, other.onDangerContainer),
      inverseSurface: l(inverseSurface, other.inverseSurface),
      onInverseSurface: l(onInverseSurface, other.onInverseSurface),
      shadow: l(shadow, other.shadow),
      scrim: l(scrim, other.scrim),
    );
  }
}
