import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/accents.dart';
import 'package:sinew/core/theme/oklch.dart';
import 'package:sinew/core/theme/palette.dart';
import 'package:sinew/core/theme/theme_families.dart';

import 'reference_values.dart';

/// Largest per-channel difference (8-bit steps) the formula may have from the
/// handoff's reference values. 1 is rounding of the OKLCh to sRGB conversion.
const int kTolerance = 1;

/// AMOLED has no formula in the handoff, only values; the fitted one lands
/// within the same bound.
const int kAmoledTolerance = 1;

void _expectScheme(
  ColorScheme scheme,
  Map<String, Color> reference,
  int tolerance,
) {
  final List<String> misses = <String>[];
  reference.forEach((String role, Color want) {
    final Color got = roleOf(scheme, role);
    final int d = channelDelta(got, want);
    if (d > tolerance) {
      misses.add(
        '$role: got #${got.toARGB32().toRadixString(16)} '
        'want #${want.toARGB32().toRadixString(16)} (off by $d)',
      );
    }
  });
  expect(misses, isEmpty, reason: misses.join('\n'));
}

void main() {
  const MullFamily sinew = MullFamily.sinew;

  group('Sinew scheme reproduces the handoff reference values', () {
    test('light, within $kTolerance per channel', () {
      _expectScheme(sinew.palette(dark: false).scheme, kSinewLight, kTolerance);
    });

    test('dark, within $kTolerance per channel', () {
      _expectScheme(sinew.palette(dark: true).scheme, kSinewDark, kTolerance);
    });

    test('AMOLED, within $kAmoledTolerance per channel', () {
      _expectScheme(sinew.amoled().scheme, kSinewAmoled, kAmoledTolerance);
    });

    test('guardedLightness steps the light primary from .55 down to .53', () {
      expect(sinew.guardedLightness, closeTo(0.53, 1e-9));
    });
  });

  group('AMOLED', () {
    test('surface is #000000 for every family', () {
      for (final MullFamily f in kThemeFamilies) {
        final ColorScheme s = f.amoled().scheme;
        expect(s.surface, const Color(0xFF000000), reason: f.id);
        expect(s.surfaceContainerLowest, const Color(0xFF000000));
        expect(s.brightness, Brightness.dark);
      }
    });

    test('containers step up from black and the text roles read on it', () {
      final ColorScheme s = sinew.amoled().scheme;
      double l(Color c) => c.computeLuminance();
      expect(l(s.surfaceContainerLow), greaterThan(l(s.surface)));
      expect(l(s.surfaceContainer), greaterThan(l(s.surfaceContainerLow)));
      expect(l(s.surfaceContainerHigh), greaterThan(l(s.surfaceContainer)));
      expect(
        contrastRatio(s.onSurface, s.surface),
        greaterThan(10),
        reason: 'onSurface on black',
      );
      // The handoff says both text roles clear 10:1; its own reference value
      // for onSurfaceVariant (#A9B98A) measures 9.99:1.
      expect(
        contrastRatio(s.onSurfaceVariant, s.surface),
        greaterThan(9.9),
        reason: 'onSurfaceVariant on black',
      );
    });
  });

  group('wallpaper (dynamic) family', () {
    test('derives every role from one seed, hue taken from the seed', () {
      const Color blue = Color(0xFF4567A8);
      final MullFamily f = MullFamily.fromSeed(blue);
      expect(f.primaryHue, closeTo(Oklch.hueOf(blue), 1e-9));
      final ColorScheme light = f.palette(dark: false).scheme;
      expect(Oklch.of(light.primary).h, closeTo(f.primaryHue, 4));
    });
  });

  group('heat ramp', () {
    test('matches the handoff heat ramp for Sinew', () {
      final List<Color> light = sinew.palette(dark: false).ramp;
      final List<Color> dark = sinew.palette(dark: true).ramp;
      final List<Color> lightRef = SinewAccents.reference(Tone.light).heat;
      final List<Color> darkRef = SinewAccents.reference(Tone.dark).heat;
      for (int i = 0; i < 5; i++) {
        expect(
          channelDelta(light[i], lightRef[i]),
          lessThanOrEqualTo(kTolerance),
          reason: 'light heat $i',
        );
        expect(
          channelDelta(dark[i], darkRef[i]),
          lessThanOrEqualTo(kTolerance),
          reason: 'dark heat $i',
        );
      }
    });
  });
}
