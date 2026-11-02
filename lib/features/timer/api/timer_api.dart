import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/timer_preset.dart';
import '../../../core/settings/haptics.dart';
import '../../../engines/timer/timer_engine.dart';
import '../services/cue_player_impl.dart';
import '../services/foreground_host.dart';
import '../services/screen_wake_impl.dart';

/// CONTRACT between the Timer feature and everything that runs a timer (the
/// Train rest timer reuses the same engine). Owned and implemented by the
/// Timer feature; the interfaces are fixed, the providers below hold the real
/// implementations. Tests override the providers with fakes.

/// Keeps a running [TimerRun] alive while the app is in the background: an
/// Android foreground service with a persistent notification (phase,
/// remaining time, pause/skip controls) and cues scheduled ahead.
abstract interface class BackgroundTimerHost {
  /// Starts or updates the foreground service for [run]. [title] is the
  /// notification title, e.g. "Rest" or "Tabata".
  Future<void> show(TimerRun run, TimerCues cues, {required String title});

  /// Stops the service and removes the notification.
  Future<void> clear();
}

/// Plays one cue: sound, haptic and/or voice, respecting the cue toggles and
/// the ringer mode (silent mutes sound and voice, vibrate keeps haptics).
abstract interface class CuePlayer {
  Future<void> play(CueEvent event, TimerCues cues);
}

/// Keeps the screen on while a workout or timer is in front of the user.
abstract interface class ScreenWake {
  Future<void> keepOn({required bool on});
}

final Provider<BackgroundTimerHost> backgroundTimerHostProvider =
    Provider<BackgroundTimerHost>((Ref ref) => ForegroundTimerHost());

final Provider<CuePlayer> cuePlayerProvider = Provider<CuePlayer>(
  (Ref ref) =>
      PlatformCuePlayer(hapticsEnabled: () => ref.read(hapticsEnabledProvider)),
);

final Provider<ScreenWake> screenWakeProvider = Provider<ScreenWake>(
  (Ref ref) => const WakelockScreenWake(),
);

/// What the app hears from the background service. Overridden in tests.
final Provider<TimerServiceLink> timerServiceLinkProvider =
    Provider<TimerServiceLink>((Ref ref) {
      final ForegroundTaskLink link = ForegroundTaskLink();
      ref.onDispose(link.dispose);
      return link;
    });
