import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/timer_preset.dart';
import '../../../engines/timer/timer_engine.dart';

/// CONTRACT between the Timer feature and everything that runs a timer (the
/// Train rest timer reuses the same engine). Owned and implemented by the
/// Timer feature, which replaces the no-op defaults below with real
/// implementations; the interfaces are fixed.

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

class _NoopHost implements BackgroundTimerHost {
  const _NoopHost();

  @override
  Future<void> show(
    TimerRun run,
    TimerCues cues, {
    required String title,
  }) async {}

  @override
  Future<void> clear() async {}
}

class _NoopCues implements CuePlayer {
  const _NoopCues();

  @override
  Future<void> play(CueEvent event, TimerCues cues) async {}
}

class _NoopWake implements ScreenWake {
  const _NoopWake();

  @override
  Future<void> keepOn({required bool on}) async {}
}

final Provider<BackgroundTimerHost> backgroundTimerHostProvider =
    Provider<BackgroundTimerHost>((Ref ref) => const _NoopHost());

final Provider<CuePlayer> cuePlayerProvider = Provider<CuePlayer>(
  (Ref ref) => const _NoopCues(),
);

final Provider<ScreenWake> screenWakeProvider = Provider<ScreenWake>(
  (Ref ref) => const _NoopWake(),
);
