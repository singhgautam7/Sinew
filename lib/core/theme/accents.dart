// The reference tables below hold `double` keys, which a const map cannot, so
// the accents are built at class initialisation and the lints that ask for
// `const` on every colour literal are off for this file.
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'oklch.dart';
import 'palette.dart';
import 'theme_families.dart';

/// A weight plate: the face and the deeper edge it always carries, so white
/// and chrome plates hold up on light surfaces.
typedef PlateColor = ({Color fill, Color edge});

enum SinewPhase { work, rest, warmup, cooldown }

/// A timer phase: the full-screen [field], the [on] colour for numerals on it
/// and the progress [ring].
typedef PhaseColor = ({Color field, Color on, Color ring});

/// Harmonising a fixed hue toward the theme: half the distance, at most
/// [maxShift] degrees (the idea of Kuber's `color_harmonizer`).
abstract final class HueHarmony {
  static const double maxShift = 15;

  /// The hue every reference accent was harmonised toward (Sinew primary).
  static const double referenceHue = 121;

  static double _signedDiff(double from, double to) =>
      ((to - from + 540) % 360) - 180;

  /// [hue] pulled toward [target].
  static double toward(double hue, double target) {
    final double d = _signedDiff(hue, target);
    final double shift = math.min(maxShift, d.abs() / 2) * d.sign;
    return (hue + shift + 360) % 360;
  }

  /// The inverse of [toward] for a hue that was pulled toward [target]:
  /// recovers the hue before harmonising, exactly (the shift is either the
  /// 15 degree cap or half the distance, and the two ranges do not overlap).
  static double original(double harmonised, double target) {
    final double e = _signedDiff(target, harmonised);
    final double a = e.abs();
    final double d = a >= maxShift ? a + maxShift : a * 2;
    return (target + e.sign * d + 360) % 360;
  }

  /// A reference accent re-harmonised toward [target]. Lightness and chroma
  /// are kept, so contrast survives. Near-neutral colours (below
  /// [neutralChroma]) have no hue to move and are returned as they are.
  static Color retarget(Color reference, double target) {
    if ((target - referenceHue).abs() < 1e-9) return reference;
    final Oklch o = Oklch.of(reference);
    if (o.c < neutralChroma) return reference;
    final double hue = toward(original(o.h, referenceHue), target);
    return Oklch(o.l, o.c, hue).toColor();
  }

  /// Chroma under which a colour counts as a neutral.
  static const double neutralChroma = 0.02;
}

/// Fixed accents that are not part of the Material scheme: weight plates,
/// timer phases, muscle map, heat ramp and chart series. Light, dark and
/// AMOLED; in dynamic colour each hue is rotated toward the wallpaper hue
/// (half the distance, at most 15 degrees), as the handoff says.
///
/// Read as `context.accents`.
@immutable
class SinewAccents extends ThemeExtension<SinewAccents> {
  const SinewAccents({
    required this.plates,
    required this.bar,
    required this.barCollar,
    required this.phases,
    required this.musclePrimary,
    required this.muscleSecondary,
    required this.muscleIdle,
    required this.muscleBody,
    required this.heat,
    required this.series,
  });

  /// Keyed by kg size (25, 20, 15, 10, 5, 2.5, 1.25). Pounds map through
  /// [plateLb].
  final Map<double, PlateColor> plates;
  final Color bar;
  final Color barCollar;
  final Map<SinewPhase, PhaseColor> phases;
  final Color musclePrimary;
  final Color muscleSecondary;
  final Color muscleIdle;
  final Color muscleBody;

  /// Five steps, weakest to strongest on the surface (calendar, muscles this
  /// week).
  final List<Color> heat;

  /// Eight chart series.
  final List<Color> series;

  /// The pound plate that stands in for a kilogram size (45 lb for 20 kg...).
  /// Keyed by the pound value the plate is labelled with.
  static final Map<double, double> plateLb = <double, double>{
    55: 25,
    45: 20,
    35: 15,
    25: 10,
    10: 5,
    5: 2.5,
    2.5: 1.25,
  };

  /// The plate colours for [kg], or null for a size without a colour.
  PlateColor? plate(double kg) => plates[kg];

  /// The phase colours; never null.
  PhaseColor phase(SinewPhase p) => phases[p]!;

  static final SinewAccents _light = SinewAccents(
    plates: <double, PlateColor>{
      5: (fill: Color(0xFFF1F2EF), edge: Color(0xFFCACBC7)), // white
      10: (fill: Color(0xFF5C913C), edge: Color(0xFF396D14)), // green
      15: (fill: Color(0xFFDBD856), edge: Color(0xFFB5B124)), // yellow
      20: (fill: Color(0xFF0070B5), edge: Color(0xFF004C8F)), // blue
      25: (fill: Color(0xFFC2460D), edge: Color(0xFF991B00)), // red
      2.5: (fill: Color(0xFF32342E), edge: Color(0xFF151712)), // graphite
      1.25: (fill: Color(0xFFB6B8B1), edge: Color(0xFF91938C)), // chrome
    },
    bar: Color(0xFFA4A5A2),
    barCollar: Color(0xFF7E807A),
    phases: <SinewPhase, PhaseColor>{
      SinewPhase.work: (
        field: Color(0xFFC6E36B),
        on: Color(0xFF1A2400),
        ring: Color(0xFF425700),
      ),
      SinewPhase.rest: (
        field: Color(0xFF95E2F5),
        on: Color(0xFF02242B),
        ring: Color(0xFF005768),
      ),
      SinewPhase.warmup: (
        field: Color(0xFFF5CF7D),
        on: Color(0xFF2B1C00),
        ring: Color(0xFF684600),
      ),
      SinewPhase.cooldown: (
        field: Color(0xFFC6D1FF),
        on: Color(0xFF1A1E30),
        ring: Color(0xFF424A73),
      ),
    },
    musclePrimary: Color(0xFF617600),
    muscleSecondary: Color(0xFFC4DE7A),
    muscleIdle: Color(0xFFACB09F),
    muscleBody: Color(0xFFDDDFD5),
    heat: <Color>[
      Color(0xFFE1FC97),
      Color(0xFFC4DE7A),
      Color(0xFF9CB450),
      Color(0xFF6C8213),
      Color(0xFF495C00),
    ],
    series: <Color>[
      Color(0xFF2E79B7),
      Color(0xFF907000),
      Color(0xFF008A70),
      Color(0xFFAC5371),
      Color(0xFF5C822F),
      Color(0xFFA7611B),
      Color(0xFF6E69B7),
      Color(0xFFAF5742),
    ],
  );

  static final SinewAccents _dark = SinewAccents(
    plates: <double, PlateColor>{
      5: (fill: Color(0xFFD0D1CE), edge: Color(0xFFBDBEBB)),
      10: (fill: Color(0xFF528435), edge: Color(0xFF2E6100)),
      15: (fill: Color(0xFFCDCB51), edge: Color(0xFFA8A405)),
      20: (fill: Color(0xFF0064A5), edge: Color(0xFF004082)),
      25: (fill: Color(0xFFB13D03), edge: Color(0xFF8C0400)),
      2.5: (fill: Color(0xFF282A24), edge: Color(0xFF0D0E09)),
      1.25: (fill: Color(0xFFAAACA5), edge: Color(0xFF858781)),
    },
    bar: Color(0xFF868783),
    barCollar: Color(0xFF62645E),
    phases: <SinewPhase, PhaseColor>{
      SinewPhase.work: (
        field: Color(0xFF2F3B00),
        on: Color(0xFFE0F0B8),
        ring: Color(0xFFB2CA6F),
      ),
      SinewPhase.rest: (
        field: Color(0xFF163B43),
        on: Color(0xFFCBEFF9),
        ring: Color(0xFF8EC9D8),
      ),
      SinewPhase.warmup: (
        field: Color(0xFF443309),
        on: Color(0xFFF9E6BF),
        ring: Color(0xFFD8BA7B),
      ),
      SinewPhase.cooldown: (
        field: Color(0xFF2F3449),
        on: Color(0xFFE1E7FF),
        ring: Color(0xFFB3BCE3),
      ),
    },
    musclePrimary: Color(0xFFA1B567),
    muscleSecondary: Color(0xFF3B4A00),
    muscleIdle: Color(0xFF54574B),
    muscleBody: Color(0xFF32342C),
    heat: <Color>[
      Color(0xFF222F00),
      Color(0xFF3B4A00),
      Color(0xFF607223),
      Color(0xFF8FA255),
      Color(0xFFBACF80),
    ],
    series: <Color>[
      Color(0xFF82C4FF),
      Color(0xFFD9BB66),
      Color(0xFF66D5BA),
      Color(0xFFF89FBB),
      Color(0xFFA6CC80),
      Color(0xFFF2AD73),
      Color(0xFFB6B4FF),
      Color(0xFFFCA48D),
    ],
  );

  static final SinewAccents _amoled = _dark._asAmoled();

  /// The reference accents for [tone] (Sinew family, hue 121).
  static SinewAccents reference(Tone tone) => switch (tone) {
    Tone.light => _light,
    Tone.dark => _dark,
    Tone.amoled => _amoled,
  };

  /// AMOLED keeps a black field and colours the numerals and ring with the
  /// phase colour (handoff frame "AMOLED, black field, phase-coloured
  /// numerals and ring"). The phase colours are the light fields.
  SinewAccents _asAmoled() => SinewAccents(
    plates: plates,
    bar: bar,
    barCollar: barCollar,
    phases: <SinewPhase, PhaseColor>{
      for (final MapEntry<SinewPhase, PhaseColor> e in _light.phases.entries)
        e.key: (field: Colors.black, on: e.value.field, ring: e.value.field),
    },
    musclePrimary: musclePrimary,
    muscleSecondary: muscleSecondary,
    muscleIdle: muscleIdle,
    muscleBody: muscleBody,
    heat: heat,
    series: series,
  );

  /// The accents for [tone] in a theme whose hue is [targetHue].
  ///
  /// For Sinew (hue 121) these are the reference values exactly. For another
  /// family or the wallpaper, plates, phases and series are re-harmonised
  /// toward [targetHue], while the muscle primary, the heat ramp and the muscle
  /// secondary come from the family's own scheme and ramp ([palette]), as in
  /// the handoff ("primary = scheme primary, secondary = ramp[1]").
  factory SinewAccents.derive({
    required Tone tone,
    required SinewPalette palette,
    required double targetHue,
  }) {
    final SinewAccents ref = reference(tone);
    if ((targetHue - HueHarmony.referenceHue).abs() < 1e-9) return ref;
    Color re(Color c) => HueHarmony.retarget(c, targetHue);
    // Neutral tints (idle, body) take the theme's hue instead of rotating.
    Color tint(Color c) {
      final Oklch o = Oklch.of(c);
      return Oklch(o.l, o.c, targetHue).toColor();
    }

    return SinewAccents(
      plates: <double, PlateColor>{
        for (final MapEntry<double, PlateColor> e in ref.plates.entries)
          e.key: (fill: re(e.value.fill), edge: re(e.value.edge)),
      },
      bar: ref.bar,
      barCollar: ref.barCollar,
      phases: <SinewPhase, PhaseColor>{
        for (final MapEntry<SinewPhase, PhaseColor> e in ref.phases.entries)
          e.key: (
            field: re(e.value.field),
            on: re(e.value.on),
            ring: re(e.value.ring),
          ),
      },
      musclePrimary: palette.scheme.primary,
      muscleSecondary: palette.ramp[1],
      muscleIdle: tint(ref.muscleIdle),
      muscleBody: tint(ref.muscleBody),
      heat: palette.ramp,
      series: <Color>[for (final Color c in ref.series) re(c)],
    );
  }

  @override
  SinewAccents copyWith() => this;

  @override
  SinewAccents lerp(ThemeExtension<SinewAccents>? other, double t) =>
      t < .5 ? this : (other as SinewAccents? ?? this);
}
