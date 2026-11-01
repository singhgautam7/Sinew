import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/accents.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/theme/oklch.dart';
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

/// Smallest angle between two hues, in degrees.
double _hueGap(double a, double b) {
  final double d = (a - b).abs() % 360;
  return d > 180 ? 360 - d : d;
}

void main() {
  group('AppTheme cache', () {
    setUp(AppTheme.clearCache);

    test('builds each (family, tone) once and hands out the same instance', () {
      final ThemeData a = AppTheme.of(Tone.light);
      final ThemeData b = AppTheme.of(Tone.light);
      expect(identical(a, b), isTrue);
      expect(identical(a.colorScheme, b.colorScheme), isTrue);
      expect(AppTheme.cachedCount, 1);

      AppTheme.of(Tone.dark);
      AppTheme.of(Tone.amoled);
      expect(AppTheme.cachedCount, 3);
      // Sinew is the default and the fallback for an unknown id.
      expect(identical(AppTheme.of(Tone.light, familyId: 'sinew'), a), isTrue);
      expect(identical(AppTheme.of(Tone.light, familyId: 'gone'), a), isTrue);
      expect(AppTheme.cachedCount, 3);

      final ThemeData other = AppTheme.of(Tone.light, familyId: 'perch');
      expect(identical(other, a), isFalse);
      expect(AppTheme.cachedCount, 4);
    });

    test('a wallpaper seed has its own entry per (seed, tone)', () {
      const Color seed = Color(0xFF3366CC);
      final ThemeData a = AppTheme.of(Tone.light, seed: seed);
      expect(identical(AppTheme.of(Tone.light, seed: seed), a), isTrue);
      AppTheme.of(Tone.dark, seed: seed);
      AppTheme.of(Tone.light, seed: const Color(0xFFCC6633));
      expect(AppTheme.cachedCount, 3);
      // The seed wins over the family.
      expect(
        identical(AppTheme.of(Tone.light, seed: seed, familyId: 'perch'), a),
        isTrue,
      );
    });

    test('carries the role map, the accents and matching brightness', () {
      for (final Tone t in Tone.values) {
        final ThemeData theme = AppTheme.of(t);
        final SinewColors c = theme.extension<SinewColors>()!;
        expect(c.tone, t);
        expect(theme.extension<SinewAccents>(), isNotNull);
        expect(
          theme.brightness,
          t == Tone.light ? Brightness.light : Brightness.dark,
        );
        expect(theme.colorScheme.primary, c.primary);
        expect(theme.scaffoldBackgroundColor, c.surface);
        expect(theme.textTheme.bodyMedium!.fontFamily, 'Inter');
      }
    });

    test('the role map keeps every role other code reads', () {
      final SinewColors c = AppTheme.of(Tone.light).extension<SinewColors>()!;
      final List<Color> roles = <Color>[
        c.primary,
        c.onPrimary,
        c.primaryContainer,
        c.onPrimaryContainer,
        c.secondaryContainer,
        c.onSecondaryContainer,
        c.tertiary,
        c.success,
        c.warning,
        c.danger,
        c.surface,
        c.surfaceContainer,
        c.surfaceContainerHigh,
        c.outline,
        c.divider,
        c.onSurface,
        c.onSurfaceVariant,
        c.onSurfaceMuted,
      ];
      expect(roles, hasLength(18));
    });

    test('AMOLED surface is #000000; dark and light are not', () {
      expect(
        AppTheme.of(Tone.amoled).colorScheme.surface,
        const Color(0xFF000000),
      );
      expect(
        AppTheme.of(Tone.amoled).scaffoldBackgroundColor,
        const Color(0xFF000000),
      );
      expect(
        AppTheme.of(Tone.dark).colorScheme.surface,
        isNot(const Color(0xFF000000)),
      );
      expect(
        AppTheme.of(Tone.light).colorScheme.surface,
        isNot(const Color(0xFF000000)),
      );
    });

    test('the Sinew family drives a chartreuse primary', () {
      final Color p = AppTheme.of(Tone.light).colorScheme.primary;
      expect(Oklch.of(p).h, closeTo(121, 4));
    });

    test('Sinew is first in the family list and every id is unique', () {
      expect(kThemeFamilies.first.id, 'sinew');
      expect(
        kThemeFamilies.map((MullFamily f) => f.id).toSet(),
        hasLength(kThemeFamilies.length),
      );
      expect(familyById(null).id, 'sinew');
      expect(familyById('neon').id, 'neon');
    });
  });

  group('SinewAccents', () {
    test('Sinew returns the reference values exactly, all three tones', () {
      for (final Tone t in Tone.values) {
        final SinewAccents derived = SinewAccents.derive(
          tone: t,
          palette: AppTheme.paletteOf(MullFamily.sinew, t),
          targetHue: MullFamily.sinew.primaryHue,
        );
        expect(identical(derived, SinewAccents.reference(t)), isTrue);
      }
    });

    test('plates are keyed by kg and have the IWF colours', () {
      final SinewAccents a = SinewAccents.reference(Tone.light);
      expect(a.plates.keys.toSet(), <double>{25, 20, 15, 10, 5, 2.5, 1.25});
      expect(a.plate(25)!.fill, const Color(0xFFC2460D));
      expect(a.plate(20)!.fill, const Color(0xFF0070B5));
      expect(a.plate(0.5), isNull);
      expect(SinewAccents.plateLb[45], 20);
    });

    test(
      'has the four phases, the muscle colours, five heat and eight series',
      () {
        for (final Tone t in Tone.values) {
          final SinewAccents a = SinewAccents.reference(t);
          for (final SinewPhase p in SinewPhase.values) {
            expect(a.phase(p).field, isA<Color>());
          }
          expect(a.heat, hasLength(5));
          expect(a.series, hasLength(8));
        }
      },
    );

    test('AMOLED phases keep a black field and colour numerals and ring', () {
      final SinewAccents amoled = SinewAccents.reference(Tone.amoled);
      final SinewAccents light = SinewAccents.reference(Tone.light);
      for (final SinewPhase p in SinewPhase.values) {
        expect(amoled.phase(p).field, const Color(0xFF000000));
        expect(amoled.phase(p).on, light.phase(p).field);
        expect(amoled.phase(p).ring, light.phase(p).field);
      }
    });

    test('HueHarmony.original undoes toward, exactly', () {
      for (int h = 0; h < 360; h += 5) {
        final double pulled = HueHarmony.toward(h.toDouble(), 121);
        expect(
          _hueGap(HueHarmony.original(pulled, 121), h.toDouble()),
          closeTo(0, 1e-9),
          reason: 'hue $h',
        );
      }
    });

    test('the reference series came from the documented Kuber hues', () {
      final List<double> documented = <double>[
        262,
        75,
        190,
        345,
        140,
        45,
        300,
        20,
      ];
      final List<Color> series = SinewAccents.reference(Tone.light).series;
      for (int i = 0; i < documented.length; i++) {
        final double original = HueHarmony.original(Oklch.of(series[i]).h, 121);
        expect(
          _hueGap(original, documented[i]),
          lessThan(3),
          reason: 'series $i',
        );
      }
    });

    test(
      'dynamic colour rotates each hue toward the wallpaper by at most 15',
      () {
        // A coral wallpaper, far from the reference hue of 121.
        const Color wallpaper = Color(0xFFDE958E);
        final MullFamily fam = MullFamily.fromSeed(wallpaper);
        for (final Tone t in <Tone>[Tone.light, Tone.dark]) {
          final SinewAccents ref = SinewAccents.reference(t);
          final SinewAccents dyn = SinewAccents.derive(
            tone: t,
            palette: AppTheme.paletteOf(fam, t),
            targetHue: fam.primaryHue,
          );
          // Plates, phases and series are re-harmonised from the hue they had
          // before Sinew's own harmonising: never more than 15 degrees from it.
          final List<(Color, Color)> pairs = <(Color, Color)>[
            for (int i = 0; i < ref.series.length; i++)
              (ref.series[i], dyn.series[i]),
            for (final double kg in ref.plates.keys) ...<(Color, Color)>[
              (ref.plates[kg]!.fill, dyn.plates[kg]!.fill),
              (ref.plates[kg]!.edge, dyn.plates[kg]!.edge),
            ],
            for (final SinewPhase p in SinewPhase.values) ...<(Color, Color)>[
              (ref.phase(p).field, dyn.phase(p).field),
              (ref.phase(p).ring, dyn.phase(p).ring),
            ],
          ];
          int moved = 0;
          for (final (Color r, Color d) in pairs) {
            final Oklch o = Oklch.of(r);
            if (o.c < HueHarmony.neutralChroma) {
              expect(d, r, reason: 'a neutral stays put');
              continue;
            }
            final double before = HueHarmony.original(o.h, 121);
            final double after = Oklch.of(d).h;
            // Allow 2 degrees for gamut clipping on the way back to sRGB.
            expect(_hueGap(before, after), lessThanOrEqualTo(15 + 2));
            // It moved toward the wallpaper hue, not away from it.
            expect(
              _hueGap(after, fam.primaryHue),
              lessThanOrEqualTo(_hueGap(before, fam.primaryHue) + 2),
            );
            if (_hueGap(o.h, after) > 1) moved++;
          }
          expect(
            moved,
            greaterThan(10),
            reason: 'dynamic colour must rotate hues',
          );
          // The muscle primary and the ramp come from the wallpaper scheme.
          expect(dyn.musclePrimary, AppTheme.paletteOf(fam, t).scheme.primary);
          expect(dyn.heat, AppTheme.paletteOf(fam, t).ramp);
        }
      },
    );

    test('rotation keeps lightness, so contrast survives', () {
      final MullFamily fam = MullFamily.fromSeed(const Color(0xFFDE958E));
      final SinewAccents ref = SinewAccents.reference(Tone.light);
      final SinewAccents dyn = SinewAccents.derive(
        tone: Tone.light,
        palette: AppTheme.paletteOf(fam, Tone.light),
        targetHue: fam.primaryHue,
      );
      for (int i = 0; i < ref.series.length; i++) {
        expect(
          Oklch.of(dyn.series[i]).l,
          closeTo(Oklch.of(ref.series[i]).l, 0.02),
          reason: 'series $i',
        );
      }
    });
  });

  group('AppSettings', () {
    test('defaults before anything is stored', () async {
      final ProviderContainer c = await _container();
      final AppSettings s = c.read(settingsProvider);
      expect(s, const AppSettings());
      expect(s.dynamicColor, isTrue);
      expect(s.familyId, 'sinew');
      expect(s.themeMode, AppThemeMode.system);
      expect(s.toneFor(Brightness.dark), Tone.dark);
      expect(s.toneFor(Brightness.light), Tone.light);
    });

    test('four modes map to tones and to the Material mode', () {
      expect(AppThemeMode.values, hasLength(4));
      expect(
        const AppSettings(themeMode: AppThemeMode.amoled)
            .toneFor(Brightness.light),
        Tone.amoled,
      );
      expect(
        const AppSettings(themeMode: AppThemeMode.light)
            .toneFor(Brightness.dark),
        Tone.light,
      );
      expect(AppThemeMode.amoled.materialMode, ThemeMode.dark);
      expect(AppThemeMode.dark.materialMode, ThemeMode.dark);
      expect(AppThemeMode.system.materialMode, ThemeMode.system);
    });

    test('writes through to prefs and reads back synchronously', () async {
      final ProviderContainer c = await _container();
      final SettingsController ctrl = c.read(settingsProvider.notifier);
      await ctrl.setThemeMode(AppThemeMode.amoled);
      await ctrl.setFamily('perch');
      await ctrl.setDynamicColor(value: false);
      await ctrl.setTextScale(5);

      final AppSettings reread = AppSettings.read(c.read(prefsProvider));
      expect(reread.themeMode, AppThemeMode.amoled);
      expect(reread.familyId, 'perch');
      expect(reread.dynamicColor, isFalse);
      expect(reread.textScale, AppSettings.maxTextScale);
      expect(reread.toneFor(Brightness.light), Tone.amoled);
    });

    test('an unknown stored mode falls back to system', () async {
      final ProviderContainer c = await _container(
        prefs: <String, Object>{AppSettings.kMode: 'sepia'},
      );
      expect(c.read(settingsProvider).themeMode, AppThemeMode.system);
    });
  });

  group('migration from the Phase 1 theme.amoled bool', () {
    test('dark + amoled true becomes the AMOLED mode', () async {
      final ProviderContainer c = await _container(
        prefs: <String, Object>{
          AppSettings.kMode: 'dark',
          AppSettings.kLegacyAmoled: true,
        },
      );
      expect(c.read(settingsProvider).themeMode, AppThemeMode.amoled);
      await Future<void>.delayed(Duration.zero);
      final SharedPreferences p = c.read(prefsProvider);
      expect(p.getString(AppSettings.kMode), 'amoled');
      expect(p.containsKey(AppSettings.kLegacyAmoled), isFalse);
    });

    test(
      'system + amoled true also becomes AMOLED (true black was wanted)',
      () {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AppSettings.kMode: 'system',
          AppSettings.kLegacyAmoled: true,
        });
        return SharedPreferences.getInstance().then((SharedPreferences p) {
          expect(AppSettings.read(p).themeMode, AppThemeMode.amoled);
        });
      },
    );

    test(
      'light + amoled true stays light (AMOLED never applied there)',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AppSettings.kMode: 'light',
          AppSettings.kLegacyAmoled: true,
        });
        final SharedPreferences p = await SharedPreferences.getInstance();
        expect(AppSettings.read(p).themeMode, AppThemeMode.light);
      },
    );

    test('amoled false leaves the mode alone', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppSettings.kMode: 'dark',
        AppSettings.kLegacyAmoled: false,
      });
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(AppSettings.read(p).themeMode, AppThemeMode.dark);
      await AppSettings.migrate(p);
      expect(p.containsKey(AppSettings.kLegacyAmoled), isFalse);
      expect(p.getString(AppSettings.kMode), 'dark');
    });

    test('choosing a mode settles a pending migration', () async {
      final ProviderContainer c = await _container(
        prefs: <String, Object>{
          AppSettings.kMode: 'dark',
          AppSettings.kLegacyAmoled: true,
        },
      );
      await c.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark);
      final SharedPreferences p = c.read(prefsProvider);
      expect(AppSettings.read(p).themeMode, AppThemeMode.dark);
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

    test('dynamic colour off means the chosen family', () async {
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
