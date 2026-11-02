import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'oklch.dart';

/// One scheme family x brightness: the Material scheme, the status colours and
/// the five-step tonal ramp.
///
/// Ported from Kuber `theme_families.dart` (`KuberPalette`). The money list is
/// kept as Kuber's 12 colours (income, expense, warning, four each) because
/// the formula is Kuber's; Sinew reads income as success and warning as
/// warning (`SinewColors`).
@immutable
class SinewPalette {
  const SinewPalette(this.scheme, this.money, this.ramp);

  final ColorScheme scheme;

  /// success c/on/cont/onCont, expense x4, warning x4.
  final List<Color> money;

  /// 5 tonal steps of the accent, weakest to strongest on this surface.
  final List<Color> ramp;
}

/// 8-bit colour: the values the design tables list.
Color _q(Oklch o) => Color(o.toColor().toARGB32());

/// Per-channel 8-bit mix, rounded like the design's reference.
Color _mix(Color a, Color b, double t) {
  int c8(double v) => (v * 255).round();
  final int ar = c8(a.r), ag = c8(a.g), ab = c8(a.b);
  final int br = c8(b.r), bg = c8(b.g), bb = c8(b.b);
  return Color.fromARGB(
    255,
    (ar + (br - ar) * t).round(),
    (ag + (bg - ag) * t).round(),
    (ab + (bb - ab) * t).round(),
  );
}

/// WCAG contrast ratio.
double contrastRatio(Color a, Color b) {
  final double x = a.computeLuminance(), y = b.computeLuminance();
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

/// One accent family, from Mull `core/theme/palette.dart` (`ThemeFamily`) via
/// Kuber, with the theme-surfaces-v1 light ladder. [palette] maps the roles
/// onto a Material scheme; [amoled] is Sinew's fourth mode (handoff
/// departure 10).
@immutable
class MullFamily {
  const MullFamily({
    required this.id,
    required this.name,
    required this.blurb,
    required this.neutralHue,
    required this.neutralChroma,
    required this.primaryHue,
    required this.primaryLightness,
    required this.primaryChroma,
    required this.primaryContainerChroma,
    double? darkNeutralChroma,
  }) : darkNeutralChroma = darkNeutralChroma ?? neutralChroma;

  final String id;
  final String name;
  final String blurb;
  final double neutralHue;
  final double neutralChroma;
  final double primaryHue;
  final double primaryLightness;
  final double primaryChroma;
  final double primaryContainerChroma;
  final double darkNeutralChroma;

  /// Sinew: chartreuse. Neutral hue 118 at chroma 1.2, primary hue 121,
  /// L .55 (stepped down to .53 by [guardedLightness]), chroma .13.
  static const MullFamily sinew = MullFamily(
    id: 'sinew',
    name: 'Sinew',
    blurb: 'chartreuse',
    neutralHue: 118,
    neutralChroma: 1.2,
    primaryHue: 121,
    primaryLightness: 0.55,
    primaryChroma: 0.13,
    primaryContainerChroma: 0.045,
  );

  static const MullFamily mull = MullFamily(
    id: 'mull',
    name: 'Mull',
    blurb: 'default',
    neutralHue: 215,
    neutralChroma: 1,
    primaryHue: 215,
    primaryLightness: 0.52,
    primaryChroma: 0.11,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily vellum = MullFamily(
    id: 'vellum',
    name: 'Vellum',
    blurb: 'warm',
    neutralHue: 80,
    neutralChroma: 1.3,
    primaryHue: 70,
    primaryLightness: 0.58,
    primaryChroma: 0.10,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily foxglove = MullFamily(
    id: 'foxglove',
    name: 'Foxglove',
    blurb: 'soft',
    neutralHue: 330,
    neutralChroma: 1.05,
    primaryHue: 325,
    primaryLightness: 0.55,
    primaryChroma: 0.12,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily slate = MullFamily(
    id: 'slate',
    name: 'Slate',
    blurb: 'mono',
    neutralHue: 215,
    neutralChroma: 0.4,
    primaryHue: 215,
    primaryLightness: 0.42,
    primaryChroma: 0.012,
    primaryContainerChroma: 0.006,
  );
  static const MullFamily clay = MullFamily(
    id: 'clay',
    name: 'Clay',
    blurb: 'greige',
    neutralHue: 75,
    neutralChroma: 2.2,
    primaryHue: 45,
    primaryLightness: 0.50,
    primaryChroma: 0.055,
    primaryContainerChroma: 0.02,
    darkNeutralChroma: 1.2,
  );
  static const MullFamily perch = MullFamily(
    id: 'perch',
    name: 'Perch',
    blurb: 'violet',
    neutralHue: 265,
    neutralChroma: 1,
    primaryHue: 265,
    primaryLightness: 0.52,
    primaryChroma: 0.11,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily ember = MullFamily(
    id: 'ember',
    name: 'Ember',
    blurb: 'amber',
    neutralHue: 55,
    neutralChroma: 1.35,
    primaryHue: 45,
    primaryLightness: 0.58,
    primaryChroma: 0.11,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily fern = MullFamily(
    id: 'fern',
    name: 'Fern',
    blurb: 'cool green',
    neutralHue: 160,
    neutralChroma: 1.15,
    primaryHue: 162,
    primaryLightness: 0.54,
    primaryChroma: 0.10,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily tide = MullFamily(
    id: 'tide',
    name: 'Tide',
    blurb: 'teal',
    neutralHue: 189,
    neutralChroma: 1,
    primaryHue: 189,
    primaryLightness: 0.50,
    primaryChroma: 0.09,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily meadow = MullFamily(
    id: 'meadow',
    name: 'Meadow',
    blurb: 'green',
    neutralHue: 145,
    neutralChroma: 1.1,
    primaryHue: 145,
    primaryLightness: 0.52,
    primaryChroma: 0.10,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily blush = MullFamily(
    id: 'blush',
    name: 'Blush',
    blurb: 'rose',
    neutralHue: 359,
    neutralChroma: 1.05,
    primaryHue: 359,
    primaryLightness: 0.55,
    primaryChroma: 0.12,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily iris = MullFamily(
    id: 'iris',
    name: 'Iris',
    blurb: 'purple',
    neutralHue: 290,
    neutralChroma: 1,
    primaryHue: 290,
    primaryLightness: 0.55,
    primaryChroma: 0.12,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily coral = MullFamily(
    id: 'coral',
    name: 'Coral',
    blurb: 'red orange',
    neutralHue: 30,
    neutralChroma: 1.2,
    primaryHue: 30,
    primaryLightness: 0.56,
    primaryChroma: 0.12,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily citron = MullFamily(
    id: 'citron',
    name: 'Citron',
    blurb: 'yellow green',
    neutralHue: 113,
    neutralChroma: 1.2,
    primaryHue: 113,
    primaryLightness: 0.55,
    primaryChroma: 0.10,
    primaryContainerChroma: 0.04,
  );
  static const MullFamily neon = MullFamily(
    id: 'neon',
    name: 'Neon',
    blurb: 'vivid green',
    neutralHue: 147,
    neutralChroma: 0.8,
    primaryHue: 147,
    primaryLightness: 0.60,
    primaryChroma: 0.14,
    primaryContainerChroma: 0.05,
  );

  /// Android hands over one wallpaper seed; the rest is derived exactly as a
  /// bundled family's is (Mull `ThemeFamily.fromSeed`).
  factory MullFamily.fromSeed(Color seed) {
    final double hue = Oklch.hueOf(seed);
    return MullFamily(
      id: 'dynamic',
      name: 'Dynamic',
      blurb: 'wallpaper',
      neutralHue: hue,
      neutralChroma: 1,
      primaryHue: hue,
      primaryLightness: 0.52,
      primaryChroma: 0.11,
      primaryContainerChroma: 0.04,
    );
  }

  Color _n(double l, double c) => _q(Oklch(l, c * neutralChroma, neutralHue));
  Color _nd(double l, double c) =>
      _q(Oklch(l, c * darkNeutralChroma, neutralHue));
  Oklch _p(double l, double c) => Oklch(l, c, primaryHue);

  /// Contrast guard (Kuber theme-surfaces.md section 3c): the light primary
  /// steps down in 0.005 lightness until it reads at 4.5:1 as text on the
  /// deepest card fill and under white labels.
  double get guardedLightness {
    final List<Color> worst = <Color>[
      _n(.955, .014),
      _q(const Oklch(.965, 0, 0)),
    ];
    double l = primaryLightness;
    bool fails(double l) {
      final Color p = _q(_p(l, primaryChroma));
      return contrastRatio(const Color(0xFFFFFFFF), p) < 4.5 ||
          worst.any((Color w) => contrastRatio(p, w) < 4.5);
    }

    while (l > .3 && fails(l)) {
      l = ((l - .005) * 1000).round() / 1000;
    }
    return l;
  }

  /// The light or dark scheme (Kuber's formulas, verbatim).
  SinewPalette palette({required bool dark}) {
    final double pc = primaryChroma;
    if (!dark) {
      final Color surface = _n(.985, .008),
          container = _n(.955, .014),
          high = _n(.93, .017),
          border = _n(.875, .02);
      final Color primaryContainer = _p(0.92, primaryContainerChroma).toColor();
      final Color onPrimaryContainer = _p(0.38, pc).toColor();
      return SinewPalette(
        ColorScheme(
          brightness: Brightness.light,
          primary: _q(_p(guardedLightness, pc)),
          onPrimary: Colors.white,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          inversePrimary: _p(0.74, pc * 0.81).toColor(),
          secondary: _p(0.45, pc).toColor(),
          onSecondary: Colors.white,
          secondaryContainer: primaryContainer,
          onSecondaryContainer: onPrimaryContainer,
          tertiary: _p(0.45, pc).toColor(),
          onTertiary: Colors.white,
          tertiaryContainer: primaryContainer,
          onTertiaryContainer: onPrimaryContainer,
          error: const Oklch(0.55, 0.16, 25).toColor(),
          onError: Colors.white,
          errorContainer: const Oklch(0.95, 0.03, 25).toColor(),
          onErrorContainer: const Oklch(0.48, 0.17, 25).toColor(),
          surface: surface,
          surfaceDim: high,
          surfaceBright: surface,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: _mix(surface, container, 0.5),
          surfaceContainer: container,
          surfaceContainerHigh: high,
          surfaceContainerHighest: _mix(high, border, 0.5),
          onSurface: _n(0.20, 0.02),
          onSurfaceVariant: _n(0.50, 0.02),
          outline: _n(0.62, 0.02),
          outlineVariant: border,
          inverseSurface: _n(0.22, 0.02),
          onInverseSurface: _n(0.97, 0.004),
          shadow: Colors.black,
          scrim: Colors.black,
          surfaceTint: Colors.transparent,
        ),
        _money(dark: false),
        <Color>[
          for (final double l in <double>[0.95, 0.86, 0.73, 0.57, 0.44])
            _p(l, pc).toColor(),
        ],
      );
    }
    final double pcd = pc * 0.81;
    final Color surface = _nd(0.205, 0.012),
        container = _nd(0.255, 0.014),
        high = _nd(0.30, 0.016),
        border = _nd(0.36, 0.016);
    final Color primaryContainer = _p(0.28, pcd * 0.46).toColor();
    final Color onPrimaryContainer = _p(0.90, pcd * 0.46).toColor();
    return SinewPalette(
      ColorScheme(
        brightness: Brightness.dark,
        primary: _p(0.74, pcd).toColor(),
        onPrimary: _nd(0.14, 0.01),
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        inversePrimary: _p(primaryLightness, pc).toColor(),
        secondary: _p(0.85, pcd * 0.69).toColor(),
        onSecondary: _nd(0.14, 0.01),
        secondaryContainer: primaryContainer,
        onSecondaryContainer: onPrimaryContainer,
        tertiary: _p(0.85, pcd * 0.69).toColor(),
        onTertiary: _nd(0.14, 0.01),
        tertiaryContainer: primaryContainer,
        onTertiaryContainer: onPrimaryContainer,
        error: const Oklch(0.72, 0.14, 25).toColor(),
        onError: _nd(0.14, 0.01),
        errorContainer: const Oklch(0.26, 0.05, 25).toColor(),
        onErrorContainer: const Oklch(0.82, 0.11, 25).toColor(),
        surface: surface,
        surfaceDim: surface,
        surfaceBright: high,
        surfaceContainerLowest: _nd(0.17, 0.01),
        surfaceContainerLow: _mix(surface, container, 0.5),
        surfaceContainer: container,
        surfaceContainerHigh: high,
        surfaceContainerHighest: _mix(high, border, 0.5),
        onSurface: _nd(0.96, 0.005),
        onSurfaceVariant: _nd(0.72, 0.012),
        outline: _nd(0.60, 0.012),
        outlineVariant: border,
        inverseSurface: _nd(0.93, 0.008),
        onInverseSurface: _nd(0.20, 0.02),
        shadow: Colors.black,
        scrim: Colors.black,
        surfaceTint: Colors.transparent,
      ),
      _money(dark: true),
      <Color>[
        for (final double l in <double>[0.28, 0.38, 0.52, 0.68, 0.82])
          _p(l, pcd).toColor(),
      ],
    );
  }

  /// The AMOLED scheme (handoff departure 10): surface #000000, containers
  /// stepped up from black by tone only, and `onSurface` / `onSurfaceVariant`
  /// taken from the family tint and mid tones instead of grey.
  ///
  /// The handoff gives the Sinew values but not a formula, so this one is
  /// fitted to them: the dark scheme's accents are reused, the surface ladder
  /// is OKLCh at the primary hue (lightness .12, .155, .195, .23 with a small
  /// chroma that grows with it), and the text roles are the tint (`.927`) and
  /// mid (`.76`) tones. Chroma scales with the family (`neutralChroma / 1.2`
  /// for surfaces, `primaryChroma / .13` for text) so every family gets its
  /// own AMOLED, as the handoff asks. Reproduces Sinew's reference within a
  /// few 8-bit steps (see test/theme/theme_test.dart).
  SinewPalette amoled() {
    final SinewPalette d = palette(dark: true);
    final double ns = neutralChroma / 1.2;
    final double ts = primaryChroma / 0.13;
    Color a(double l, double c) => _q(Oklch(l, c * ns, primaryHue));
    final Color primaryContainer = _q(
      Oklch(0.23, primaryChroma * 0.81 * 0.44, primaryHue),
    );
    final Color tint = _q(Oklch(0.927, 0.0495 * ts, neutralHue));
    final Color mid = _q(Oklch(0.76, 0.0666 * ts, primaryHue + 2));
    return SinewPalette(
      d.scheme.copyWith(
        onPrimary: Colors.black,
        primaryContainer: primaryContainer,
        secondaryContainer: primaryContainer,
        tertiaryContainer: primaryContainer,
        errorContainer: _q(const Oklch(0.207, 0.047, 25)),
        surface: Colors.black,
        surfaceDim: Colors.black,
        surfaceBright: a(0.195, 0.022),
        surfaceContainerLowest: Colors.black,
        surfaceContainerLow: a(0.12, 0.0095),
        surfaceContainer: a(0.155, 0.0155),
        surfaceContainerHigh: a(0.195, 0.022),
        surfaceContainerHighest: a(0.23, 0.026),
        outlineVariant: a(0.311, 0.0258),
        outline: _q(Oklch(0.56, 0.06 * ts, primaryHue)),
        onSurface: tint,
        onSurfaceVariant: mid,
        inverseSurface: tint,
      ),
      d.money,
      d.ramp,
    );
  }

  /// Success / expense / warning in the same OKLCh register as the family.
  static List<Color> _money({required bool dark}) {
    List<Color> role(double hue, double chroma) => dark
        ? <Color>[
            Oklch(0.78, chroma, hue).toColor(),
            Oklch(0.25, chroma * 0.4, hue).toColor(),
            Oklch(0.32, chroma * 0.45, hue).toColor(),
            Oklch(0.90, chroma * 0.5, hue).toColor(),
          ]
        : <Color>[
            Oklch(0.52, chroma, hue).toColor(),
            Colors.white,
            Oklch(0.93, chroma * 0.4, hue).toColor(),
            Oklch(0.38, chroma, hue).toColor(),
          ];
    return <Color>[...role(145, 0.13), ...role(25, 0.15), ...role(70, 0.12)];
  }
}

/// The families offered on the Theme screen, in display order. Sinew is first
/// and the default; the rest are Mull's families with Kuber's real values.
///
/// Kuber's own "Signature" family (an M3 fidelity scheme seeded from the Kuber
/// icon) is deliberately not listed: it is Kuber's brand, not a Mull family.
const List<MullFamily> kThemeFamilies = <MullFamily>[
  MullFamily.sinew,
  MullFamily.mull,
  MullFamily.vellum,
  MullFamily.foxglove,
  MullFamily.slate,
  MullFamily.clay,
  MullFamily.perch,
  MullFamily.ember,
  MullFamily.fern,
  MullFamily.tide,
  MullFamily.meadow,
  MullFamily.blush,
  MullFamily.iris,
  MullFamily.coral,
  MullFamily.citron,
  MullFamily.neon,
];

/// The family with [id], else Sinew (a stored id that no longer exists must
/// never crash).
MullFamily familyById(String? id) => kThemeFamilies.firstWhere(
  (MullFamily f) => f.id == id,
  orElse: () => MullFamily.sinew,
);
