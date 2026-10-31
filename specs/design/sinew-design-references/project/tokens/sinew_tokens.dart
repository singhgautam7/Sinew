// Sinew token additions on top of the family system (Kuber theme_families.dart,
// app_theme.dart). Generated from tokens/sinew_tokens.json. Widgets never read these
// directly: AppTheme builds ThemeData + ThemeExtensions from them.
import 'package:flutter/material.dart';

/// Add to MullFamily (theme_families.dart) and to the ThemeVariant enum (append only).
/// Light primary resolves to L 0.53 via guardedLightness.
const sinewFamily = MullFamily(
  id: 'sinew', name: 'Sinew', blurb: 'chartreuse',
  neutralHue: 118, neutralChroma: 1.2,
  primaryHue: 121, primaryLightness: 0.55, primaryChroma: 0.13, primaryContainerChroma: 0.045,
);

/// Brand (icon, splash). Not part of the ColorScheme.
abstract final class SinewBrand {
  static const dark = Color(0xFF3B4707);
  static const mid = Color(0xFF6D8817);
  static const tint = Color(0xFFE4ECC7);
  static const splashDarkTint = Color(0xFF2A3310);
}

/// Reference values the family formula produces (for tests / golden checks).
abstract final class SinewSchemeLight {
  static const primary = Color(0xFF617600);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE0EAC9);
  static const onPrimaryContainer = Color(0xFF394B00);
  static const secondaryContainer = Color(0xFFE0EAC9);
  static const onSecondaryContainer = Color(0xFF394B00);
  static const inversePrimary = Color(0xFFA1B567);
  static const surface = Color(0xFFF9FBF4);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF4F7ED);
  static const surfaceContainer = Color(0xFFEFF2E5);
  static const surfaceContainerHigh = Color(0xFFE6EADB);
  static const surfaceContainerHighest = Color(0xFFDDE1D1);
  static const outlineVariant = Color(0xFFD4D8C7);
  static const outline = Color(0xFF858878);
  static const onSurface = Color(0xFF15180B);
  static const onSurfaceVariant = Color(0xFF626556);
  static const inverseSurface = Color(0xFF191C0F);
  static const onInverseSurface = Color(0xFFF5F6F2);
  static const error = Color(0xFFBD413F);
  static const errorContainer = Color(0xFFFFE7E4);
  static const onErrorContainer = Color(0xFFA92227);
}
abstract final class SinewSchemeDark {
  static const primary = Color(0xFFA1B567);
  static const onPrimary = Color(0xFF090A05);
  static const primaryContainer = Color(0xFF252C0F);
  static const onPrimaryContainer = Color(0xFFD9E3C0);
  static const secondaryContainer = Color(0xFF252C0F);
  static const onSecondaryContainer = Color(0xFFD9E3C0);
  static const inversePrimary = Color(0xFF677C06);
  static const surface = Color(0xFF161811);
  static const surfaceContainerLowest = Color(0xFF0F100A);
  static const surfaceContainerLow = Color(0xFF1C1E16);
  static const surfaceContainer = Color(0xFF22241B);
  static const surfaceContainerHigh = Color(0xFF2D2F24);
  static const surfaceContainerHighest = Color(0xFF35372C);
  static const outlineVariant = Color(0xFF3C3F33);
  static const outline = Color(0xFF7F8178);
  static const onSurface = Color(0xFFF1F2EE);
  static const onSurfaceVariant = Color(0xFFA3A69C);
  static const inverseSurface = Color(0xFFE7E9E2);
  static const onInverseSurface = Color(0xFF15180B);
  static const error = Color(0xFFF07F77);
  static const errorContainer = Color(0xFF391917);
  static const onErrorContainer = Color(0xFFFFA8A0);
}

typedef PlateColor = ({Color fill, Color edge});
enum SinewPhase { work, rest, warmup, cooldown }
typedef PhaseColor = ({Color field, Color on, Color ring});

/// Fixed accents. In dynamic colour, rotate each hue toward the wallpaper hue
/// with the same rule (half the distance, max 15deg) before use.
@immutable
class SinewAccents extends ThemeExtension<SinewAccents> {
  final Map<double, PlateColor> plates; // keyed by kg size; lb maps via plateLb
  final Color bar, barCollar;
  final Map<SinewPhase, PhaseColor> phases;
  final Color musclePrimary, muscleSecondary, muscleIdle, muscleBody;
  final List<Color> heat, series;
  const SinewAccents({required this.plates, required this.bar, required this.barCollar, required this.phases,
    required this.musclePrimary, required this.muscleSecondary, required this.muscleIdle, required this.muscleBody,
    required this.heat, required this.series});

  static const plateLb = {55.0: 25.0, 45.0: 20.0, 35.0: 15.0, 25.0: 10.0, 10.0: 5.0, 5.0: 2.5, 2.5: 1.25};

  static const light = SinewAccents(
    plates: {
    5: (fill: Color(0xFFF1F2EF), edge: Color(0xFFCACBC7)), // white
    10: (fill: Color(0xFF5C913C), edge: Color(0xFF396D14)), // green
    15: (fill: Color(0xFFDBD856), edge: Color(0xFFB5B124)), // yellow
    20: (fill: Color(0xFF0070B5), edge: Color(0xFF004C8F)), // blue
    25: (fill: Color(0xFFC2460D), edge: Color(0xFF991B00)), // red
    2.5: (fill: Color(0xFF32342E), edge: Color(0xFF151712)), // graphite
    1.25: (fill: Color(0xFFB6B8B1), edge: Color(0xFF91938C)), // chrome
    },
    bar: Color(0xFFA4A5A2), barCollar: Color(0xFF7E807A),
    phases: {
    SinewPhase.work: (field: Color(0xFFC6E36B), on: Color(0xFF1A2400), ring: Color(0xFF425700)), // 11.26:1
    SinewPhase.rest: (field: Color(0xFF95E2F5), on: Color(0xFF02242B), ring: Color(0xFF005768)), // 11.22:1
    SinewPhase.warmup: (field: Color(0xFFF5CF7D), on: Color(0xFF2B1C00), ring: Color(0xFF684600)), // 11.12:1
    SinewPhase.cooldown: (field: Color(0xFFC6D1FF), on: Color(0xFF1A1E30), ring: Color(0xFF424A73)), // 10.98:1
    },
    musclePrimary: Color(0xFF617600), muscleSecondary: Color(0xFFC4DE7A),
    muscleIdle: Color(0xFFACB09F), muscleBody: Color(0xFFDDDFD5),
    heat: [Color(0xFFE1FC97), Color(0xFFC4DE7A), Color(0xFF9CB450), Color(0xFF6C8213), Color(0xFF495C00)],
    series: [Color(0xFF2E79B7), Color(0xFF907000), Color(0xFF008A70), Color(0xFFAC5371), Color(0xFF5C822F), Color(0xFFA7611B), Color(0xFF6E69B7), Color(0xFFAF5742)],
  );

  static const dark = SinewAccents(
    plates: {
    5: (fill: Color(0xFFD0D1CE), edge: Color(0xFFBDBEBB)), // white
    10: (fill: Color(0xFF528435), edge: Color(0xFF2E6100)), // green
    15: (fill: Color(0xFFCDCB51), edge: Color(0xFFA8A405)), // yellow
    20: (fill: Color(0xFF0064A5), edge: Color(0xFF004082)), // blue
    25: (fill: Color(0xFFB13D03), edge: Color(0xFF8C0400)), // red
    2.5: (fill: Color(0xFF282A24), edge: Color(0xFF0D0E09)), // graphite
    1.25: (fill: Color(0xFFAAACA5), edge: Color(0xFF858781)), // chrome
    },
    bar: Color(0xFF868783), barCollar: Color(0xFF62645E),
    phases: {
    SinewPhase.work: (field: Color(0xFF2F3B00), on: Color(0xFFE0F0B8), ring: Color(0xFFB2CA6F)), // 9.92:1
    SinewPhase.rest: (field: Color(0xFF163B43), on: Color(0xFFCBEFF9), ring: Color(0xFF8EC9D8)), // 9.91:1
    SinewPhase.warmup: (field: Color(0xFF443309), on: Color(0xFFF9E6BF), ring: Color(0xFFD8BA7B)), // 9.92:1
    SinewPhase.cooldown: (field: Color(0xFF2F3449), on: Color(0xFFE1E7FF), ring: Color(0xFFB3BCE3)), // 10.00:1
    },
    musclePrimary: Color(0xFFA1B567), muscleSecondary: Color(0xFF3B4A00),
    muscleIdle: Color(0xFF54574B), muscleBody: Color(0xFF32342C),
    heat: [Color(0xFF222F00), Color(0xFF3B4A00), Color(0xFF607223), Color(0xFF8FA255), Color(0xFFBACF80)],
    series: [Color(0xFF82C4FF), Color(0xFFD9BB66), Color(0xFF66D5BA), Color(0xFFF89FBB), Color(0xFFA6CC80), Color(0xFFF2AD73), Color(0xFFB6B4FF), Color(0xFFFCA48D)],
  );

  @override
  SinewAccents copyWith() => this;
  @override
  SinewAccents lerp(ThemeExtension<SinewAccents>? other, double t) => t < .5 ? this : (other as SinewAccents? ?? this);
}

/// Additions to KuberSpace / KuberShape.
abstract final class SinewSpace {
  static const double gloveTarget = 64; // active workout + timer secondary controls
  static const double timerControl = 96; // primary pause/play
  static const double setRowHeight = 64;
}
abstract final class SinewShape {
  static const double timerPrimary = 32; // squircle-ish pause; morphs to full when paused
}

/// Additions to KuberMotion.
abstract final class SinewMotion {
  static const plateEnter = Duration(milliseconds: 420);
  static const plateStagger = Duration(milliseconds: 45);
  static const plateExit = Duration(milliseconds: 220);
  static const plateSpring = SpringDescription(mass: 1, stiffness: 380, damping: 22);
  static const setComplete = Duration(milliseconds: 260);
  static const prFlash = Duration(milliseconds: 600);
  static const silhouetteMorph = Duration(milliseconds: 480);
  static const phaseSweep = Duration(milliseconds: 360);
}

/// The timer numeral role (not in the M3 scale).
const sinewTimerNumeral = TextStyle(fontSize: 150, height: 1, fontWeight: FontWeight.w700, letterSpacing: -6,
    fontFeatures: [FontFeature.tabularFigures()]);
