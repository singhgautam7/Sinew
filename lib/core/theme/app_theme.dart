import 'package:flutter/material.dart';

import 'accents.dart';
import 'palette.dart';
import 'theme_families.dart';
import 'tokens.dart';
import 'typography.dart';

export 'accents.dart' show PhaseColor, PlateColor, SinewAccents, SinewPhase;
export 'palette.dart' show SinewBrand, SinewColors, Tone;
export 'theme_families.dart' show MullFamily, kThemeFamilies, familyById;
export 'tokens.dart';
export 'typography.dart' show SinewType;

/// Builds, and caches, one [ThemeData] per (family or wallpaper seed, tone).
///
/// `ThemeData` and `ColorScheme` construction is not free and a theme is
/// stable for the life of a setting, so each is built once and handed out on
/// every rebuild after that. A family and a wallpaper seed go through the same
/// path (`MullFamily.fromSeed` is a family), so the two can never diverge.
abstract final class AppTheme {
  static final Map<String, ThemeData> _cache = <String, ThemeData>{};

  /// The theme for [tone]. [seed] is the wallpaper seed when dynamic colour is
  /// on; otherwise [familyId] picks the family (Sinew by default, and for any
  /// id that no longer exists).
  static ThemeData of(Tone tone, {String familyId = 'sinew', Color? seed}) {
    final String key = seed != null
        ? 'seed:${seed.toARGB32()}:${tone.name}'
        : 'family:${familyById(familyId).id}:${tone.name}';
    return _cache.putIfAbsent(
      key,
      () => _build(
        tone,
        seed != null ? MullFamily.fromSeed(seed) : familyById(familyId),
      ),
    );
  }

  /// A family's palette without building a [ThemeData] (theme previews).
  static SinewPalette paletteOf(MullFamily family, Tone tone) =>
      tone == Tone.amoled
      ? family.amoled()
      : family.palette(dark: tone == Tone.dark);

  /// Number of themes built so far. Tests use it to prove the cache holds.
  @visibleForTesting
  static int get cachedCount => _cache.length;

  @visibleForTesting
  static void clearCache() => _cache.clear();

  static ThemeData _build(Tone tone, MullFamily family) {
    final SinewPalette p = paletteOf(family, tone);
    final ColorScheme cs = p.scheme;
    final SinewColors roles = SinewColors.fromPalette(p, tone);
    final SinewAccents accents = SinewAccents.derive(
      tone: tone,
      palette: p,
      targetHue: family.primaryHue,
    );
    final TextTheme text = SinewType.textTheme(
      cs.onSurface,
      cs.onSurfaceVariant,
    );
    const StadiumBorder stadium = StadiumBorder();
    final TextStyle labelLarge = text.labelLarge!;
    const Size buttonMin = Size(Sizes.buttonMinWidth, Sizes.buttonSmall);
    const EdgeInsets buttonPad = EdgeInsets.symmetric(
      horizontal: Sizes.buttonPadSmall,
    );
    const BorderRadius fieldR = Radii.largeR;

    OutlineInputBorder field(BorderSide side) =>
        OutlineInputBorder(borderRadius: fieldR, borderSide: side);
    final BorderSide focusSide = BorderSide(
      color: cs.primary,
      width: Sizes.fieldBorder,
    );
    final BorderSide errorSide = BorderSide(
      color: cs.error,
      width: Sizes.fieldBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: cs.brightness,
      colorScheme: cs,
      extensions: <ThemeExtension<dynamic>>[roles, accents],
      textTheme: text,
      fontFamily: SinewType.family,
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: cs.surface,
      canvasColor: cs.surface,
      // Depth lives in 1px outlines. Material's tonal elevation is off.
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: Elevations.none,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardR,
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: Elevations.none,
        scrolledUnderElevation: Elevations.none,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: Elevations.none,
        indicatorColor: cs.secondaryContainer,
        indicatorShape: stadium,
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? cs.onSecondaryContainer
                : cs.onSurfaceVariant,
            size: IconSpec.size,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => text.labelMedium!.copyWith(
            color: s.contains(WidgetState.selected)
                ? cs.onSurface
                : cs.onSurfaceVariant,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Sizes.fieldPadV,
        ),
        border: field(BorderSide.none),
        enabledBorder: field(BorderSide.none),
        disabledBorder: field(BorderSide.none),
        focusedBorder: field(focusSide),
        errorBorder: field(errorSide),
        focusedErrorBorder: field(errorSide),
        hintStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
        labelStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
        floatingLabelStyle: text.bodySmall!.copyWith(color: cs.primary),
        helperStyle: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        counterStyle: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        errorStyle: text.bodySmall!.copyWith(color: cs.error),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cs.primary,
        selectionColor: cs.primary.withValues(alpha: Opacities.selection),
        selectionHandleColor: cs.primary,
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: Strokes.hairline,
        space: Strokes.hairline,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: text.bodyMedium!.copyWith(color: cs.onInverseSurface),
        actionTextColor: cs.inversePrimary,
        shape: const RoundedRectangleBorder(borderRadius: Radii.largeR),
        behavior: SnackBarBehavior.floating,
        elevation: Elevations.none,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: cs.secondaryContainer,
        disabledColor: cs.onSurface.withValues(alpha: Opacities.disabledFill),
        side: WidgetStateBorderSide.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected)
              ? BorderSide.none
              : BorderSide(color: cs.outline),
        ),
        checkmarkColor: cs.onSecondaryContainer,
        labelStyle: labelLarge.copyWith(color: cs.onSurfaceVariant),
        secondaryLabelStyle: labelLarge.copyWith(
          color: cs.onSecondaryContainer,
        ),
        iconTheme: IconThemeData(color: cs.primary, size: IconSpec.small),
        shape: const RoundedRectangleBorder(borderRadius: Radii.chipR),
        padding: const EdgeInsets.symmetric(horizontal: Space.sm),
        labelPadding: const EdgeInsets.symmetric(horizontal: Space.sm),
        elevation: Elevations.none,
        pressElevation: Elevations.none,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLow,
        modalBackgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: Elevations.none,
        modalElevation: Elevations.none,
        modalBarrierColor: cs.scrim.withValues(alpha: Opacities.scrim),
        shape: const RoundedRectangleBorder(borderRadius: Radii.sheetR),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: Elevations.none,
        barrierColor: cs.scrim.withValues(alpha: Opacities.scrim),
        shape: const RoundedRectangleBorder(borderRadius: Radii.dialogR),
        titleTextStyle: text.headlineSmall!.copyWith(color: cs.onSurface),
        contentTextStyle: text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        actionsPadding: const EdgeInsets.fromLTRB(
          Space.xl,
          0,
          Space.xl,
          Space.xl,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: stadium,
          minimumSize: buttonMin,
          padding: buttonPad,
          textStyle: labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: Elevations.none,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          shape: stadium,
          minimumSize: buttonMin,
          padding: buttonPad,
          textStyle: labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(color: cs.outline),
          shape: stadium,
          minimumSize: buttonMin,
          padding: buttonPad,
          textStyle: labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          shape: stadium,
          minimumSize: const Size(IconSpec.tapTarget, Sizes.buttonSmall),
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          textStyle: labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: const CircleBorder()),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: Elevations.none,
        focusElevation: Elevations.none,
        hoverElevation: Elevations.none,
        highlightElevation: Elevations.none,
        shape: const CircleBorder(),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(Sizes.segmentedMinWidth, Sizes.segmented),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(stadium),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: cs.outline),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle>(labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith(
            (Set<WidgetState> s) => s.contains(WidgetState.selected)
                ? cs.secondaryContainer
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (Set<WidgetState> s) => s.contains(WidgetState.selected)
                ? cs.onSecondaryContainer
                : cs.onSurface,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected)
              ? Icon(
                  Icons.check_rounded,
                  size: IconSpec.tiny,
                  color: cs.primary,
                )
              : null,
        ),
      ),
      checkboxTheme: const CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Space.xxs)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.secondaryContainer,
        circularTrackColor: Colors.transparent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.secondaryContainer,
        thumbColor: cs.primary,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        minVerticalPadding: Space.listRowPadV,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.listRowPadH,
        ),
        horizontalTitleGap: Space.lg,
        titleTextStyle: text.titleMedium!.copyWith(color: cs.onSurface),
        subtitleTextStyle: text.bodyMedium!.copyWith(
          color: cs.onSurfaceVariant,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.mediumR),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: Elevations.none,
        menuPadding: const EdgeInsets.all(Space.sm),
        textStyle: labelLarge.copyWith(color: cs.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardR,
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(cs.surfaceContainer),
          surfaceTintColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          elevation: const WidgetStatePropertyAll<double>(Elevations.none),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.all(Space.sm),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: Radii.cardR,
              side: BorderSide(color: cs.outlineVariant),
            ),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cs.inverseSurface,
          borderRadius: Radii.extraSmallR,
        ),
        textStyle: text.bodySmall!.copyWith(color: cs.onInverseSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.sm,
          vertical: Space.xs,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: Elevations.none,
        shape: const RoundedRectangleBorder(borderRadius: Radii.dialogR),
        rangeSelectionBackgroundColor: cs.secondaryContainer,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        elevation: Elevations.none,
        shape: const RoundedRectangleBorder(borderRadius: Radii.dialogR),
      ),
    );
  }
}

/// The accessors every widget uses.
///
/// - `context.cs`: the Material [ColorScheme] (full role set).
/// - `context.colors`: the Sinew role map ([SinewColors]).
/// - `context.accents`: plates, phases, muscles, heat, series.
/// - `context.text`: the [TextTheme] (Inter, tabular figures).
extension SinewThemeContext on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  /// The role token map for the active theme.
  SinewColors get colors => Theme.of(this).extension<SinewColors>()!;

  SinewAccents get accents => Theme.of(this).extension<SinewAccents>()!;

  TextTheme get text => Theme.of(this).textTheme;

  /// Caps section heading style: labelMedium, 0.8 tracking, onSurfaceVariant.
  TextStyle get sectionHeader => Theme.of(this).textTheme.labelMedium!.copyWith(
    letterSpacing: SinewType.sectionTracking,
    color: Theme.of(this).colorScheme.onSurfaceVariant,
  );

  /// labelLarge at w700, in the on-surface colour.
  TextStyle get labelBold =>
      SinewType.labelBold.copyWith(color: Theme.of(this).colorScheme.onSurface);

  /// Numeric readout (JetBrains Mono), in the on-surface colour.
  TextStyle get mono =>
      SinewType.mono.copyWith(color: Theme.of(this).colorScheme.onSurface);

  /// The across-the-room timer numeral, in the on-surface colour.
  TextStyle get timerNumeral => SinewType.timerNumeral.copyWith(
    color: Theme.of(this).colorScheme.onSurface,
  );

  /// Instrument Serif italic accent (About).
  TextStyle get serifAccent => SinewType.serifAccent.copyWith(
    color: Theme.of(this).colorScheme.onSurface,
  );
}
