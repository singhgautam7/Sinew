import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../api/timer_api.dart';

/// [ScreenWake] on `wakelock_plus`: a window flag that keeps the display on
/// while a timer or workout is in front of the user. A missing plugin (tests)
/// is not an error.
class WakelockScreenWake implements ScreenWake {
  const WakelockScreenWake();

  @override
  Future<void> keepOn({required bool on}) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } on Object catch (e) {
      debugPrint('Sinew screen wake unavailable: $e');
    }
  }
}
