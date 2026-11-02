import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';

/// Whether the user wants haptic feedback (Settings > Haptics). Every widget
/// that takes a `haptics` flag is given this value; nothing vibrates on its
/// own.
final Provider<bool> hapticsEnabledProvider = Provider<bool>(
  (Ref ref) => ref.watch(settingsProvider.select((AppSettings s) => s.haptics)),
);

/// The app's haptic vocabulary, each gated on [enabled] (pass
/// `ref.watch(hapticsEnabledProvider)` or the widget's `haptics` flag).
abstract final class SinewHaptics {
  static Future<void> selection({required bool enabled}) =>
      enabled ? HapticFeedback.selectionClick() : Future<void>.value();

  static Future<void> light({required bool enabled}) =>
      enabled ? HapticFeedback.lightImpact() : Future<void>.value();

  static Future<void> medium({required bool enabled}) =>
      enabled ? HapticFeedback.mediumImpact() : Future<void>.value();

  static Future<void> heavy({required bool enabled}) =>
      enabled ? HapticFeedback.heavyImpact() : Future<void>.value();
}
