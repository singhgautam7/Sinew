import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The device's ringer state. Cues respect it: silent mutes sounds and voice,
/// vibrate keeps haptics only.
enum RingerMode { normal, vibrate, silent }

/// The one method channel to Android (`MainActivity.kt`). No plugin is used
/// for these: TTS through `flutter_tts` would apply the Kotlin Gradle Plugin
/// Flutter is deprecating (Mull's finding), and the version and ringer mode
/// are one call each.
///
/// Every call degrades quietly where there is no platform (tests, a missing
/// handler): it returns a neutral value instead of throwing.
abstract final class SinewPlatform {
  static const MethodChannel _channel = MethodChannel('com.grs.sinew/platform');

  /// Overridable in tests.
  @visibleForTesting
  static MethodChannel get channel => _channel;

  /// `versionName+versionCode` from the package, e.g. `0.1.0+1`. Never a
  /// string in Dart: bump `pubspec.yaml` only.
  static Future<String?> appVersion() => _call<String>('appVersion');

  /// Speaks [text] with the phone's own TTS engine, flushing anything queued.
  /// Returns false if no engine is available.
  static Future<bool> speak(String text, {double rate = 1.0}) async =>
      await _call<bool>('speak', <String, Object>{
        'text': text,
        'rate': rate,
      }) ??
      false;

  static Future<void> stopSpeaking() => _call<void>('stopSpeaking');

  static Future<RingerMode> ringerMode() async {
    final String? mode = await _call<String>('ringerMode');
    return switch (mode) {
      'silent' => RingerMode.silent,
      'vibrate' => RingerMode.vibrate,
      _ => RingerMode.normal,
    };
  }

  static Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('Sinew platform $method failed: $e');
      return null;
    }
  }
}
