import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';

/// Reads the Material You seed Android derives from the wallpaper (Android
/// 12+), or null where there is none. Only the seed is taken; every role is
/// then derived exactly as Sinew's own seed is (see `AppTheme`).
typedef SeedSource = Future<Color?> Function();

Future<Color?> platformWallpaperSeed() async {
  try {
    // dynamic_color 2.x hands the palette back as the deprecated CorePalette;
    // only primary tone 40 is read, which is the seed Android used (Mull).
    // ignore: deprecated_member_use
    final palette = await DynamicColorPlugin.getCorePalette();
    return palette == null ? null : Color(palette.primary.get(40));
  } on PlatformException {
    return null;
  } on MissingPluginException {
    return null;
  }
}

/// Overridable in tests.
final Provider<SeedSource> seedSourceProvider = Provider<SeedSource>(
  (Ref ref) => platformWallpaperSeed,
);

/// The wallpaper seed, cached in prefs so the first frame of a cold start
/// already has it (no flash from the brand colour to the wallpaper colour).
/// The platform is asked once per launch, after the first frame, and the
/// cache is updated only if the wallpaper changed.
class WallpaperSeedController extends Notifier<Color?> {
  static const String kSeed = 'theme.wallpaperSeed';

  @override
  Color? build() {
    final int? cached = ref.read(prefsProvider).getInt(kSeed);
    unawaited(Future<void>.microtask(refresh));
    return cached == null ? null : Color(cached);
  }

  Future<void> refresh() async {
    final Color? fresh = await ref.read(seedSourceProvider)();
    if (!ref.mounted) return;
    if (fresh?.toARGB32() == state?.toARGB32()) return;
    state = fresh;
    if (fresh == null) {
      await ref.read(prefsProvider).remove(kSeed);
    } else {
      await ref.read(prefsProvider).setInt(kSeed, fresh.toARGB32());
    }
  }
}

final NotifierProvider<WallpaperSeedController, Color?> wallpaperSeedProvider =
    NotifierProvider<WallpaperSeedController, Color?>(
      WallpaperSeedController.new,
    );

/// The seed the theme is built from right now: the wallpaper's while dynamic
/// colour is on and the platform has one, otherwise null (Sinew's brand seed).
final Provider<Color?> activeSeedProvider = Provider<Color?>((Ref ref) {
  final bool dynamic = ref.watch(
    settingsProvider.select((AppSettings s) => s.dynamicColor),
  );
  return dynamic ? ref.watch(wallpaperSeedProvider) : null;
});
