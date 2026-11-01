import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/palette.dart';

/// The four theme modes (handoff departure 10). AMOLED is a mode of its own,
/// always dark, and replaces the Phase 1 "true black" toggle.
enum AppThemeMode {
  system,
  light,
  dark,
  amoled;

  /// What `MaterialApp.themeMode` is told: AMOLED is a dark theme.
  ThemeMode get materialMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark || AppThemeMode.amoled => ThemeMode.dark,
  };

  /// Label for the Theme screen.
  String get label => switch (this) {
    AppThemeMode.system => 'System',
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
    AppThemeMode.amoled => 'AMOLED',
  };
}

/// Device-level settings that must be known before the first frame, kept in
/// SharedPreferences and read synchronously at startup so the theme never
/// flashes. User data (profile, units, workouts, measurements) lives in the
/// user database, not here.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.familyId = defaultFamilyId,
    this.dynamicColor = true,
    this.textScale = 1.0,
    this.onboarded = false,
  });

  final AppThemeMode themeMode;

  /// The theme family (`MullFamily.id`); an unknown id resolves to Sinew.
  final String familyId;

  /// Take the seed from the wallpaper (Android 12+). Falls back to the chosen
  /// family when the platform has none.
  final bool dynamicColor;

  /// 0.85 to 1.3, applied on top of the OS text scale.
  final double textScale;
  final bool onboarded;

  static const String defaultFamilyId = 'sinew';
  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.3;

  /// The tone to render for a given platform brightness.
  Tone toneFor(Brightness platform) => switch (themeMode) {
    AppThemeMode.light => Tone.light,
    AppThemeMode.dark => Tone.dark,
    AppThemeMode.amoled => Tone.amoled,
    AppThemeMode.system => platform == Brightness.dark ? Tone.dark : Tone.light,
  };

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? familyId,
    bool? dynamicColor,
    double? textScale,
    bool? onboarded,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    familyId: familyId ?? this.familyId,
    dynamicColor: dynamicColor ?? this.dynamicColor,
    textScale: textScale ?? this.textScale,
    onboarded: onboarded ?? this.onboarded,
  );

  static const String kMode = 'theme.mode';

  /// Phase 1 stored true black as a bool next to the mode. It is read once to
  /// migrate (see [read]) and removed by [migrate].
  static const String kLegacyAmoled = 'theme.amoled';
  static const String kFamily = 'theme.family';
  static const String kDynamic = 'theme.dynamic';
  static const String kTextScale = 'text.scale';
  static const String kOnboarded = 'app.onboarded';

  /// Reads the settings. Pure: a Phase 1 install (`theme.amoled` true next to
  /// a `theme.mode` of dark or system) reads as [AppThemeMode.amoled] here,
  /// and [migrate] writes that back so the legacy key can go.
  static AppSettings read(SharedPreferences prefs) {
    final String? stored = prefs.getString(kMode);
    AppThemeMode mode = AppThemeMode.values.firstWhere(
      (AppThemeMode m) => m.name == stored,
      orElse: () => AppThemeMode.system,
    );
    if ((prefs.getBool(kLegacyAmoled) ?? false) && mode != AppThemeMode.light) {
      mode = AppThemeMode.amoled;
    }
    return AppSettings(
      themeMode: mode,
      familyId: prefs.getString(kFamily) ?? defaultFamilyId,
      dynamicColor: prefs.getBool(kDynamic) ?? true,
      textScale: (prefs.getDouble(kTextScale) ?? 1.0).clamp(
        minTextScale,
        maxTextScale,
      ),
      onboarded: prefs.getBool(kOnboarded) ?? false,
    );
  }

  /// Writes the migrated mode back and drops the Phase 1 `theme.amoled` key.
  /// Safe to call on every start; does nothing once migrated.
  static Future<void> migrate(SharedPreferences prefs) async {
    if (!prefs.containsKey(kLegacyAmoled)) return;
    final AppSettings s = read(prefs);
    await prefs.setString(kMode, s.themeMode.name);
    await prefs.remove(kLegacyAmoled);
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.familyId == familyId &&
      other.dynamicColor == dynamicColor &&
      other.textScale == textScale &&
      other.onboarded == onboarded;

  @override
  int get hashCode =>
      Object.hash(themeMode, familyId, dynamicColor, textScale, onboarded);
}

/// Overridden in `main` with the instance opened during bootstrap.
final Provider<SharedPreferences> prefsProvider = Provider<SharedPreferences>(
  (Ref ref) => throw UnimplementedError('prefsProvider must be overridden'),
);

/// Settings are held in memory and written through, so reading the theme is
/// synchronous and a change repaints exactly the widgets that selected on it.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final SharedPreferences prefs = ref.watch(prefsProvider);
    final AppSettings s = AppSettings.read(prefs);
    // Persist a Phase 1 migration without delaying the first frame.
    if (prefs.containsKey(AppSettings.kLegacyAmoled)) {
      AppSettings.migrate(prefs).ignore();
    }
    return s;
  }

  SharedPreferences get _prefs => ref.read(prefsProvider);

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(AppSettings.kMode, mode.name);
    // An explicit choice settles any pending Phase 1 migration.
    await _prefs.remove(AppSettings.kLegacyAmoled);
  }

  Future<void> setFamily(String id) async {
    state = state.copyWith(familyId: id);
    await _prefs.setString(AppSettings.kFamily, id);
  }

  Future<void> setDynamicColor({required bool value}) async {
    state = state.copyWith(dynamicColor: value);
    await _prefs.setBool(AppSettings.kDynamic, value);
  }

  Future<void> setTextScale(double value) async {
    final double v = value.clamp(
      AppSettings.minTextScale,
      AppSettings.maxTextScale,
    );
    state = state.copyWith(textScale: v);
    await _prefs.setDouble(AppSettings.kTextScale, v);
  }

  Future<void> setOnboarded({required bool value}) async {
    state = state.copyWith(onboarded: value);
    await _prefs.setBool(AppSettings.kOnboarded, value);
  }
}

final NotifierProvider<SettingsController, AppSettings> settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
