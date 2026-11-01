import 'package:flutter/material.dart';

import 'theme_families.dart';
import 'tokens.dart';

/// Which variant of a scheme is being rendered.
enum Tone { light, dark, amoled }

/// Brand colours (icon, splash). Not part of the colour scheme.
abstract final class SinewBrand {
  static const Color dark = Color(0xFF3B4707);
  static const Color mid = Color(0xFF6D8817);
  static const Color tint = Color(0xFFE4ECC7);
  static const Color splashDarkTint = Color(0xFF2A3310);
}

/// The role map: the names screens code against. Built from the Material
/// scheme of the active family (or wallpaper seed), so a theme swap is a
/// single map replacement and nothing in a screen names a raw colour.
///
/// Read as `context.colors.<role>`. For anything a role does not cover, the
/// full Material scheme is `context.cs` and the fixed accents (plates, phases,
/// muscles, heat, series) are `context.accents`.
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
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
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

  /// Fields, chips, icon buttons.
  final Color surfaceContainerHigh;

  /// 1px borders. Depth lives here (the scheme's `outlineVariant`).
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
  final Color onSuccessContainer;

  /// Estimated values, approaching limits.
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color onDangerContainer;
  final Color inverseSurface;
  final Color onInverseSurface;

  /// Only the nav pill ever casts one.
  final Color shadow;
  final Color scrim;

  bool get isDark => tone != Tone.light;

  /// Maps a palette onto the role names.
  factory SinewColors.fromPalette(SinewPalette p, Tone tone) {
    final ColorScheme s = p.scheme;
    return SinewColors(
      tone: tone,
      surface: s.surface,
      surfaceContainerLow: s.surfaceContainerLow,
      surfaceContainer: s.surfaceContainer,
      surfaceContainerHigh: s.surfaceContainerHigh,
      outline: s.outlineVariant,
      divider: s.outlineVariant,
      onSurface: s.onSurface,
      onSurfaceVariant: s.onSurfaceVariant,
      onSurfaceMuted: s.onSurface.withValues(alpha: Opacities.disabled),
      primary: s.primary,
      onPrimary: s.onPrimary,
      primaryContainer: s.primaryContainer,
      onPrimaryContainer: s.onPrimaryContainer,
      secondaryContainer: s.secondaryContainer,
      onSecondaryContainer: s.onSecondaryContainer,
      tertiary: s.tertiary,
      tertiaryContainer: s.tertiaryContainer,
      onTertiaryContainer: s.onTertiaryContainer,
      success: p.money[0],
      successContainer: p.money[2],
      onSuccessContainer: p.money[3],
      warning: p.money[8],
      warningContainer: p.money[10],
      onWarningContainer: p.money[11],
      danger: s.error,
      dangerContainer: s.errorContainer,
      onDangerContainer: s.onErrorContainer,
      inverseSurface: s.inverseSurface,
      onInverseSurface: s.onInverseSurface,
      shadow: s.shadow,
      scrim: s.scrim,
    );
  }

  /// Roles are derived from a palette, never edited one by one.
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
      onSuccessContainer: l(onSuccessContainer, other.onSuccessContainer),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      onWarningContainer: l(onWarningContainer, other.onWarningContainer),
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
