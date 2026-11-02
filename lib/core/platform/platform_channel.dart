import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The device's ringer state. Cues respect it: silent mutes sounds and voice,
/// vibrate keeps haptics only.
enum RingerMode { normal, vibrate, silent }

/// The method channel for app-level facts (`MainActivity.kt`). No plugin is
/// used for these: the version is one call. Sound, vibration, speech and the
/// ringer mode are on [SinewCues], which the timer service's isolate can
/// reach too.
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
  static Future<String?> appVersion() => _call<String>(_channel, 'appVersion');

  /// Speaks [text]; see [SinewCues.speak].
  static Future<bool> speak(String text, {double rate = 1.0}) =>
      SinewCues.speak(text, rate: rate);

  static Future<void> stopSpeaking() => SinewCues.stopSpeaking();

  static Future<RingerMode> ringerMode() => SinewCues.ringerMode();
}

/// The cue channel (`CueChannel.kt`): the five timer sounds on a SoundPool,
/// vibration, spoken cues on the phone's own TextToSpeech, the ringer mode
/// and a wake lock for the running timer. Native code registers it on the
/// app's engine and on the foreground service's engine, so these calls work
/// in both isolates and a cue fired with the screen off behaves like one fired
/// in the app.
abstract final class SinewCues {
  static const MethodChannel _channel = MethodChannel('com.grs.sinew/cues');

  /// Overridable in tests.
  @visibleForTesting
  static MethodChannel get channel => _channel;

  /// Loads `assets/audio/<name>.wav` for each name. Idempotent.
  static Future<bool> load(List<String> names) async =>
      await _call<bool>(_channel, 'load', <String, Object>{'names': names}) ??
      false;

  static Future<bool> play(String name) async =>
      await _call<bool>(_channel, 'play', <String, Object>{'name': name}) ??
      false;

  /// Vibrates with [pattern] (`[wait, on, off, on, ...]`, milliseconds).
  static Future<void> vibrate(List<int> pattern) =>
      _call<void>(_channel, 'vibrate', <String, Object>{'pattern': pattern});

  /// Speaks [text] with the phone's own TTS engine, flushing anything queued.
  /// Returns false if no engine is available.
  static Future<bool> speak(String text, {double rate = 1.0}) async =>
      await _call<bool>(_channel, 'speak', <String, Object>{
        'text': text,
        'rate': rate,
      }) ??
      false;

  static Future<void> stopSpeaking() => _call<void>(_channel, 'stopSpeaking');

  static Future<RingerMode> ringerMode() async {
    final String? mode = await _call<String>(_channel, 'ringerMode');
    return switch (mode) {
      'silent' => RingerMode.silent,
      'vibrate' => RingerMode.vibrate,
      _ => RingerMode.normal,
    };
  }

  /// Holds or drops the partial wake lock that keeps the CPU awake for a
  /// counting timer with the screen off.
  static Future<void> wakeLock({required bool on}) =>
      _call<void>(_channel, 'wakeLock', <String, Object>{'on': on});
}

Future<T?> _call<T>(
  MethodChannel channel,
  String method, [
  Object? args,
]) async {
  try {
    return await channel.invokeMethod<T>(method, args);
  } on MissingPluginException {
    return null;
  } on PlatformException catch (e) {
    debugPrint('Sinew platform $method failed: $e');
    return null;
  }
}
