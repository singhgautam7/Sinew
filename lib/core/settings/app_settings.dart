import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/palette.dart';

/// Device-level settings that must be known before the first frame, kept in
/// SharedPreferences and read synchronously at startup so the theme never
/// flashes. User data (profile, units, workouts, measurements) lives in the
/// user database, not here.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.amoled = false,
    this.dynamicColor = true,
    this.textScale = 1.0,
    this.onboarded = false,
  });

  final ThemeMode themeMode;

  /// True black. Only takes effect while dark is in effect.
  final bool amoled;

  /// Take the seed from the wallpaper (Android 12+). Falls back to Sinew's
  /// brand seed when the platform has none.
  final bool dynamicColor;

  /// 0.85 to 1.3, applied on top of the OS text scale.
  final double textScale;
  final bool onboarded;

  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.3;

  /// The tone to render for a given platform brightness.
  Tone toneFor(Brightness platform) {
    final bool dark = switch (themeMode) {
      ThemeMode.light => false,
      ThemeMode.dark => true,
      ThemeMode.system => platform == Brightness.dark,
    };
    if (!dark) return Tone.light;
    return amoled ? Tone.amoled : Tone.dark;
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? amoled,
    bool? dynamicColor,
    double? textScale,
    bool? onboarded,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    amoled: amoled ?? this.amoled,
    dynamicColor: dynamicColor ?? this.dynamicColor,
    textScale: textScale ?? this.textScale,
    onboarded: onboarded ?? this.onboarded,
  );

  static const String kMode = 'theme.mode';
  static const String kAmoled = 'theme.amoled';
  static const String kDynamic = 'theme.dynamic';
  static const String kTextScale = 'text.scale';
  static const String kOnboarded = 'app.onboarded';

  static AppSettings read(SharedPreferences prefs) => AppSettings(
    themeMode: ThemeMode.values.firstWhere(
      (ThemeMode m) => m.name == prefs.getString(kMode),
      orElse: () => ThemeMode.system,
    ),
    amoled: prefs.getBool(kAmoled) ?? false,
    dynamicColor: prefs.getBool(kDynamic) ?? true,
    textScale: (prefs.getDouble(kTextScale) ?? 1.0).clamp(
      minTextScale,
      maxTextScale,
    ),
    onboarded: prefs.getBool(kOnboarded) ?? false,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.amoled == amoled &&
      other.dynamicColor == dynamicColor &&
      other.textScale == textScale &&
      other.onboarded == onboarded;

  @override
  int get hashCode =>
      Object.hash(themeMode, amoled, dynamicColor, textScale, onboarded);
}

/// Overridden in `main` with the instance opened during bootstrap.
final Provider<SharedPreferences> prefsProvider = Provider<SharedPreferences>(
  (Ref ref) => throw UnimplementedError('prefsProvider must be overridden'),
);

/// Settings are held in memory and written through, so reading the theme is
/// synchronous and a change repaints exactly the widgets that selected on it.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => AppSettings.read(ref.watch(prefsProvider));

  SharedPreferences get _prefs => ref.read(prefsProvider);

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(AppSettings.kMode, mode.name);
  }

  Future<void> setAmoled({required bool value}) async {
    state = state.copyWith(amoled: value);
    await _prefs.setBool(AppSettings.kAmoled, value);
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
