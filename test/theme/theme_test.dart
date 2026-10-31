import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/theme/palette.dart';
import 'package:sinew/core/theme/wallpaper_seed.dart';

Future<ProviderContainer> _container({
  Map<String, Object> prefs = const <String, Object>{},
  Color? platformSeed,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final SharedPreferences p = await SharedPreferences.getInstance();
  final ProviderContainer c = ProviderContainer(
    overrides: <Override>[
      prefsProvider.overrideWithValue(p),
      seedSourceProvider.overrideWithValue(() async => platformSeed),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('AppTheme', () {
    setUp(AppTheme.clearCache);

    test('builds each (seed, tone) once and hands out the same instance', () {
      final ThemeData a = AppTheme.of(Tone.light);
      final ThemeData b = AppTheme.of(Tone.light);
      expect(identical(a, b), isTrue);
      expect(identical(a.colorScheme, b.colorScheme), isTrue);
      expect(AppTheme.cachedCount, 1);

      AppTheme.of(Tone.dark);
      AppTheme.of(Tone.amoled);
      AppTheme.of(Tone.light, seed: const Color(0xFF3366CC));
      expect(AppTheme.cachedCount, 4);
      // Null seed is the brand seed: same cache entry.
      expect(
        identical(AppTheme.of(Tone.light, seed: SinewSeeds.brand), a),
        isTrue,
      );
    });

    test('carries the role map and matching brightness', () {
      for (final Tone t in Tone.values) {
        final ThemeData theme = AppTheme.of(t);
        final SinewColors c = theme.extension<SinewColors>()!;
        expect(c.tone, t);
        expect(
          theme.brightness,
          t == Tone.light ? Brightness.light : Brightness.dark,
        );
        expect(theme.colorScheme.primary, c.primary);
        expect(theme.scaffoldBackgroundColor, c.surface);
      }
    });

    test('AMOLED is true black; dark is not', () {
      expect(
        SinewColors.derive(SinewSeeds.brand, Tone.amoled).surface,
        SinewSeeds.black,
      );
      expect(
        SinewColors.derive(SinewSeeds.brand, Tone.dark).surface,
        isNot(SinewSeeds.black),
      );
    });

    test('the brand seed drives a green primary', () {
      final Color p = SinewColors.derive(SinewSeeds.brand, Tone.light).primary;
      final HSLColor hsl = HSLColor.fromColor(p);
      expect(hsl.hue, inInclusiveRange(60, 110));
    });
  });

  group('AppSettings', () {
    test('defaults before anything is stored', () async {
      final ProviderContainer c = await _container();
      final AppSettings s = c.read(settingsProvider);
      expect(s, const AppSettings());
      expect(s.dynamicColor, isTrue);
      expect(s.toneFor(Brightness.dark), Tone.dark);
      expect(s.toneFor(Brightness.light), Tone.light);
    });

    test('writes through to prefs and reads back synchronously', () async {
      final ProviderContainer c = await _container();
      final SettingsController ctrl = c.read(settingsProvider.notifier);
      await ctrl.setThemeMode(ThemeMode.dark);
      await ctrl.setAmoled(value: true);
      await ctrl.setTextScale(5);

      final SharedPreferences prefs = c.read(prefsProvider);
      final AppSettings reread = AppSettings.read(prefs);
      expect(reread.themeMode, ThemeMode.dark);
      expect(reread.amoled, isTrue);
      expect(reread.textScale, AppSettings.maxTextScale);
      expect(reread.toneFor(Brightness.light), Tone.amoled);
    });
  });

  group('wallpaper seed cache', () {
    test('the cached seed is there on the first read (no flash)', () async {
      final ProviderContainer c = await _container(
        prefs: <String, Object>{WallpaperSeedController.kSeed: 0xFF112233},
        platformSeed: const Color(0xFF112233),
      );
      expect(c.read(wallpaperSeedProvider), const Color(0xFF112233));
      expect(c.read(activeSeedProvider), const Color(0xFF112233));
    });

    test('a changed wallpaper replaces the cache', () async {
      final ProviderContainer c = await _container(
        prefs: <String, Object>{WallpaperSeedController.kSeed: 0xFF112233},
        platformSeed: const Color(0xFF445566),
      );
      c.read(wallpaperSeedProvider);
      await c.read(wallpaperSeedProvider.notifier).refresh();
      expect(c.read(wallpaperSeedProvider), const Color(0xFF445566));
      expect(
        c.read(prefsProvider).getInt(WallpaperSeedController.kSeed),
        0xFF445566,
      );
    });

    test('dynamic colour off means the brand seed', () async {
      final ProviderContainer c = await _container(
        prefs: <String, Object>{
          WallpaperSeedController.kSeed: 0xFF112233,
          AppSettings.kDynamic: false,
        },
      );
      expect(c.read(activeSeedProvider), isNull);
    });
  });
}
