import 'package:flutter/material.dart';

import 'palette.dart';
import 'tokens.dart';
import 'typography.dart';

/// Builds, and caches, one [ThemeData] per (seed, tone).
///
/// `ThemeData` and `ColorScheme` construction is not free and a theme is
/// stable for the life of a setting, so each is built once and handed out on
/// every rebuild after that. The brand seed and a wallpaper seed go through
/// the same path, so the two can never diverge.
abstract final class AppTheme {
  static final Map<String, ThemeData> _cache = <String, ThemeData>{};

  /// [seed] is the wallpaper seed when dynamic colour is on, else null for
  /// Sinew's own [SinewSeeds.brand].
  static ThemeData of(Tone tone, {Color? seed}) {
    final Color s = seed ?? SinewSeeds.brand;
    return _cache.putIfAbsent(
      '${s.toARGB32()}:${tone.name}',
      () => _build(s, tone),
    );
  }

  /// Number of themes built so far. Tests use it to prove the cache holds.
  @visibleForTesting
  static int get cachedCount => _cache.length;

  @visibleForTesting
  static void clearCache() => _cache.clear();

  static ThemeData _build(Color seed, Tone tone) {
    final SinewColors c = SinewColors.derive(seed, tone);
    final ColorScheme scheme = c.toColorScheme(seed);
    final TextTheme text = SinewType.textTheme(c.onSurface, c.onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: c.surface,
      canvasColor: c.surface,
      textTheme: text,
      fontFamily: SinewType.family,
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: <ThemeExtension<dynamic>>[c],
      // Depth lives in 1px outlines. Material's tonal elevation is off.
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surfaceContainer,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardR,
          side: BorderSide(color: c.outline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.divider,
        thickness: Strokes.hairline,
        space: Strokes.hairline,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: Radii.sheetR),
        showDragHandle: false,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary,
        selectionColor: c.primaryContainer,
        selectionHandleColor: c.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
    );
  }
}

extension SinewThemeContext on BuildContext {
  /// The role token map for the active theme.
  SinewColors get colors => Theme.of(this).extension<SinewColors>()!;

  TextTheme get text => Theme.of(this).textTheme;
}
