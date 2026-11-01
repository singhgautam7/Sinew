import 'dart:io';
import 'dart:isolate';

/// Runs heavy pure work (JSON encode and decode, CSV building) off the UI
/// isolate so a large history never drops frames.
///
/// The computation must capture only sendable values (plain data, models):
/// pass what it needs as locals and call a static function. Never capture
/// `this` of an object that holds a database or preferences.
abstract final class Background {
  /// Tests that exercise the real isolate hop set this.
  static bool forceIsolate = false;

  /// `flutter test` runs widget tests on a fake clock where a real isolate
  /// never completes, so the computation runs inline there.
  static bool get _inline =>
      !forceIsolate && Platform.environment.containsKey('FLUTTER_TEST');

  static Future<R> run<R>(R Function() computation) {
    if (_inline) return Future<R>.sync(computation);
    return Isolate.run<R>(computation);
  }
}
