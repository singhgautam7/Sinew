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
    this.restSeconds = defaultRestSeconds,
    this.incrementKg = defaultIncrementKg,
    this.incrementLb = defaultIncrementLb,
    this.haptics = true,
    this.keepScreenOn = true,
    this.timerSound = true,
    this.timerHaptic = true,
    this.timerVoice = false,
    this.userName = '',
    this.weekStartsMonday = true,
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

  // ── Workout defaults (read by Train; stored here, wired by those screens) ─

  /// Rest between sets, in seconds.
  final int restSeconds;

  /// Step of the weight steppers: kilograms and pounds are separate because
  /// 2.5 kg and 5 lb are the usual plate pairs. Stored in the unit's own
  /// terms (kg value in [incrementKg], lb value in [incrementLb]).
  final double incrementKg;
  final double incrementLb;

  /// Haptics in the app (set done, plate settle).
  final bool haptics;

  /// Keep the screen awake during workouts and running timers.
  final bool keepScreenOn;

  // ── Timer defaults (read by Timer) ────────────────────────────────────────
  final bool timerSound;
  final bool timerHaptic;

  /// Spoken countdown before each phase.
  final bool timerVoice;

  // ── You ───────────────────────────────────────────────────────────────────

  /// Optional first name for the Today greeting. Never leaves the phone.
  final String userName;

  /// Weeks start on Monday (true) or Sunday (false).
  final bool weekStartsMonday;

  static const int defaultRestSeconds = 120;
  static const double defaultIncrementKg = 2.5;
  static const double defaultIncrementLb = 5;
  static const int minRestSeconds = 15;
  static const int maxRestSeconds = 600;

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
    int? restSeconds,
    double? incrementKg,
    double? incrementLb,
    bool? haptics,
    bool? keepScreenOn,
    bool? timerSound,
    bool? timerHaptic,
    bool? timerVoice,
    String? userName,
    bool? weekStartsMonday,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    familyId: familyId ?? this.familyId,
    dynamicColor: dynamicColor ?? this.dynamicColor,
    textScale: textScale ?? this.textScale,
    onboarded: onboarded ?? this.onboarded,
    restSeconds: restSeconds ?? this.restSeconds,
    incrementKg: incrementKg ?? this.incrementKg,
    incrementLb: incrementLb ?? this.incrementLb,
    haptics: haptics ?? this.haptics,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    timerSound: timerSound ?? this.timerSound,
    timerHaptic: timerHaptic ?? this.timerHaptic,
    timerVoice: timerVoice ?? this.timerVoice,
    userName: userName ?? this.userName,
    weekStartsMonday: weekStartsMonday ?? this.weekStartsMonday,
  );

  static const String kMode = 'theme.mode';

  /// Phase 1 stored true black as a bool next to the mode. It is read once to
  /// migrate (see [read]) and removed by [migrate].
  static const String kLegacyAmoled = 'theme.amoled';
  static const String kFamily = 'theme.family';
  static const String kDynamic = 'theme.dynamic';
  static const String kTextScale = 'text.scale';
  static const String kOnboarded = 'app.onboarded';

  // The `app.` prefix is backed up and restored with the rest of the settings.
  static const String kRestSeconds = 'app.restSeconds';
  static const String kIncrementKg = 'app.incrementKg';
  static const String kIncrementLb = 'app.incrementLb';
  static const String kHaptics = 'app.haptics';
  static const String kKeepScreenOn = 'app.keepScreenOn';
  static const String kTimerSound = 'app.timerSound';
  static const String kTimerHaptic = 'app.timerHaptic';
  static const String kTimerVoice = 'app.timerVoice';
  static const String kUserName = 'app.userName';
  static const String kWeekStartsMonday = 'app.weekStartsMonday';

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
      restSeconds: (prefs.getInt(kRestSeconds) ?? defaultRestSeconds).clamp(
        minRestSeconds,
        maxRestSeconds,
      ),
      incrementKg: _positive(prefs.getDouble(kIncrementKg), defaultIncrementKg),
      incrementLb: _positive(prefs.getDouble(kIncrementLb), defaultIncrementLb),
      haptics: prefs.getBool(kHaptics) ?? true,
      keepScreenOn: prefs.getBool(kKeepScreenOn) ?? true,
      timerSound: prefs.getBool(kTimerSound) ?? true,
      timerHaptic: prefs.getBool(kTimerHaptic) ?? true,
      timerVoice: prefs.getBool(kTimerVoice) ?? false,
      userName: prefs.getString(kUserName) ?? '',
      weekStartsMonday: prefs.getBool(kWeekStartsMonday) ?? true,
    );
  }

  static double _positive(double? v, double fallback) =>
      v != null && v > 0 ? v : fallback;

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
      other.onboarded == onboarded &&
      other.restSeconds == restSeconds &&
      other.incrementKg == incrementKg &&
      other.incrementLb == incrementLb &&
      other.haptics == haptics &&
      other.keepScreenOn == keepScreenOn &&
      other.timerSound == timerSound &&
      other.timerHaptic == timerHaptic &&
      other.timerVoice == timerVoice &&
      other.userName == userName &&
      other.weekStartsMonday == weekStartsMonday;

  @override
  int get hashCode => Object.hash(
    themeMode,
    familyId,
    dynamicColor,
    textScale,
    onboarded,
    restSeconds,
    incrementKg,
    incrementLb,
    haptics,
    keepScreenOn,
    timerSound,
    timerHaptic,
    timerVoice,
    userName,
    weekStartsMonday,
  );
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

  Future<void> setRestSeconds(int seconds) async {
    final int v = seconds.clamp(
      AppSettings.minRestSeconds,
      AppSettings.maxRestSeconds,
    );
    state = state.copyWith(restSeconds: v);
    await _prefs.setInt(AppSettings.kRestSeconds, v);
  }

  Future<void> setIncrementKg(double value) async {
    if (value <= 0) return;
    state = state.copyWith(incrementKg: value);
    await _prefs.setDouble(AppSettings.kIncrementKg, value);
  }

  Future<void> setIncrementLb(double value) async {
    if (value <= 0) return;
    state = state.copyWith(incrementLb: value);
    await _prefs.setDouble(AppSettings.kIncrementLb, value);
  }

  Future<void> setHaptics({required bool value}) async {
    state = state.copyWith(haptics: value);
    await _prefs.setBool(AppSettings.kHaptics, value);
  }

  Future<void> setKeepScreenOn({required bool value}) async {
    state = state.copyWith(keepScreenOn: value);
    await _prefs.setBool(AppSettings.kKeepScreenOn, value);
  }

  Future<void> setTimerSound({required bool value}) async {
    state = state.copyWith(timerSound: value);
    await _prefs.setBool(AppSettings.kTimerSound, value);
  }

  Future<void> setTimerHaptic({required bool value}) async {
    state = state.copyWith(timerHaptic: value);
    await _prefs.setBool(AppSettings.kTimerHaptic, value);
  }

  Future<void> setTimerVoice({required bool value}) async {
    state = state.copyWith(timerVoice: value);
    await _prefs.setBool(AppSettings.kTimerVoice, value);
  }

  Future<void> setUserName(String value) async {
    final String v = value.trim();
    state = state.copyWith(userName: v);
    if (v.isEmpty) {
      await _prefs.remove(AppSettings.kUserName);
    } else {
      await _prefs.setString(AppSettings.kUserName, v);
    }
  }

  Future<void> setWeekStartsMonday({required bool value}) async {
    state = state.copyWith(weekStartsMonday: value);
    await _prefs.setBool(AppSettings.kWeekStartsMonday, value);
  }
}

final NotifierProvider<SettingsController, AppSettings> settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
