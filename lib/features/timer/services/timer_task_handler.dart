import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../../core/models/enums.dart';
import '../../../core/platform/platform_channel.dart';
import '../../../core/theme/tokens.dart';
import '../../../engines/timer/timer_engine.dart';
import '../data/active_timer.dart';
import 'cue_player_impl.dart';
import 'service_protocol.dart';

/// Entry point of the foreground service's isolate. Must stay top level and
/// annotated, or the engine cannot find it in a release build.
@pragma('vm:entry-point')
void timerTaskCallback() {
  FlutterForegroundTask.setTaskHandler(TimerTaskHandler());
}

/// The service's options for a repeat every [tick]. The plugin's own wake
/// lock is off: the cue channel holds one only while a run is counting (see
/// `CueChannel.kt`), so a paused run lets the CPU sleep. Restarting after the
/// system killed the service is off too: a timer must not come back by itself.
ForegroundTaskOptions timerServiceOptions(Duration tick) =>
    ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(tick.inMilliseconds),
      allowWakeLock: false,
      allowAutoRestart: false,
    );

/// What the handler asks of the platform, behind a seam so the handler can be
/// driven without a service in tests.
abstract interface class TimerServiceOps {
  Future<void> wakeLock({required bool on});

  /// Rewrites the notification and, when [tick] is given, the repeat interval.
  Future<void> updateNotification(NotificationContent c, {Duration? tick});

  Future<void> saveState(String json);

  Future<void> sendStateToApp(String json);

  void sendFinishedToApp();

  /// Stops the service. Drops the saved copy of the run unless [keepState].
  Future<void> stop({required bool keepState});
}

class PluginServiceOps implements TimerServiceOps {
  const PluginServiceOps();

  @override
  Future<void> wakeLock({required bool on}) => SinewCues.wakeLock(on: on);

  @override
  Future<void> updateNotification(
    NotificationContent c, {
    Duration? tick,
  }) async {
    await FlutterForegroundTask.updateService(
      foregroundTaskOptions: tick == null ? null : timerServiceOptions(tick),
      notificationTitle: c.title,
      notificationText: c.text,
      notificationButtons: <NotificationButton>[
        for (final (String id, String label) in c.buttons)
          NotificationButton(id: id, text: label),
      ],
    );
  }

  @override
  Future<void> saveState(String json) =>
      FlutterForegroundTask.saveData(key: kServiceStateKey, value: json);

  @override
  Future<void> sendStateToApp(String json) async =>
      FlutterForegroundTask.sendDataToMain(stateMessage(json));

  @override
  void sendFinishedToApp() =>
      FlutterForegroundTask.sendDataToMain(<String, Object?>{'t': msgFinished});

  @override
  Future<void> stop({required bool keepState}) async {
    if (!keepState) {
      await FlutterForegroundTask.removeData(key: kServiceStateKey);
    }
    await FlutterForegroundTask.stopService();
  }
}

/// The part of the timer that keeps working when the app's isolate is gone
/// (screen off, app swiped away from the foreground, activity destroyed).
///
/// It holds the last run the app gave it and does these things:
/// - keeps the ongoing notification current (phase, round, time left, next);
/// - answers the notification buttons (pause or resume, skip, +10 s), saving
///   the new run and telling the app if it is listening;
/// - plays due cues (sound, vibration and voice, through the native cue
///   channel), but only while the app is silent: the app sends a heartbeat
///   every second and, while it is alive, it plays the cues itself;
/// - sleeps while the run is paused: a slow repeat, no wake lock, and after
///   [TimerTiming.pausedServiceTimeout] it stops the service altogether (the
///   run stays saved and restores the next time the app opens).
///
/// Time comes from the run's timestamps; the repeating event only decides
/// how often we look.
class TimerTaskHandler extends TaskHandler {
  TimerTaskHandler({
    PhaseCuePlayer? player,
    TimerServiceOps? ops,
    int Function()? nowMs,
  }) : _sound = player == null ? ChannelSoundOutput() : null,
       _ops = ops ?? const PluginServiceOps(),
       _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch) {
    _player = player ?? PlatformCuePlayer(sound: _sound);
  }

  final ChannelSoundOutput? _sound;
  late final PhaseCuePlayer _player;
  final TimerServiceOps _ops;
  final int Function() _nowMs;

  ActiveTimer? _state;
  int _lastCueMs = 0;
  int _lastHeartbeatMs = 0;
  NotificationContent? _shown;
  int? _finishedAtMs;

  /// Whether the run is counting (so the wake lock is held and the repeat is
  /// fast). Null before the first look.
  bool? _counting;

  @visibleForTesting
  ActiveTimer? get state => _state;

  @visibleForTesting
  bool? get counting => _counting;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final int now = _nowMs();
    _lastCueMs = now;
    _lastHeartbeatMs = now;
    final Object? saved = await FlutterForegroundTask.getData<String>(
      key: kServiceStateKey,
    );
    _state = decodeState(saved);
    final ChannelSoundOutput? s = _sound;
    if (s != null) unawaited(s.preload());
    await _refreshNotification(force: true);
  }

  @override
  void onReceiveData(Object data) {
    if (data is! Map<Object?, Object?>) return;
    final int now = _nowMs();
    switch (data['t']) {
      case msgHeartbeat:
        _lastHeartbeatMs = now;
      case msgState:
        _lastHeartbeatMs = now;
        final ActiveTimer? next = decodeState(data['json']);
        if (next == null) return;
        _state = next;
        _finishedAtMs = null;
        unawaited(_refreshNotification(force: true));
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) => tick();

  /// One look at the run. Public so tests can drive it.
  @visibleForTesting
  void tick() {
    final ActiveTimer? a = _state;
    if (a == null) return;
    final int now = _nowMs();
    final TimerSnapshot snap = a.run.snapshotAt(now);

    if (_finishedAtMs != null) {
      if (now - _finishedAtMs! >= TimerTiming.finishLinger.inMilliseconds) {
        unawaited(_stop(keepState: false));
      }
      return;
    }

    // A run that has been paused for a long time does not keep a service,
    // a notification and a wake lock alive. It stays saved for a restore.
    final int? pausedAt = a.run.pausedAtMs;
    if (pausedAt != null &&
        now - pausedAt >= TimerTiming.pausedServiceTimeout.inMilliseconds) {
      unawaited(_stop(keepState: true));
      return;
    }

    final bool appAlive = now - _lastHeartbeatMs < TimerTiming.heartbeatLapseMs;
    if (!appAlive && !a.run.isPaused && a.run.endedAtMs == null) {
      for (final CueEvent e in dueCues(
        a.run,
        a.cues,
        lastCueMs: _lastCueMs,
        nowMs: now,
      )) {
        final TimerPhase phase = e.stepIndex < a.run.steps.length
            ? a.run.steps[e.stepIndex].phase
            : TimerPhase.work;
        unawaited(_player.playForPhase(e, a.cues, phase));
      }
    }
    _lastCueMs = now + 1;

    if (snap.finished) {
      _finishedAtMs = now;
      _ops.sendFinishedToApp();
    }
    unawaited(_refreshNotification());
  }

  @override
  void onNotificationButtonPressed(String id) {
    final ActiveTimer? a = _state;
    if (a == null) return;
    final int now = _nowMs();
    final ActiveTimer? next = applyButton(a, id, now);
    if (next == null) return;
    if (a.run.isPaused && !next.run.isPaused) _lastCueMs = now;
    _state = next;
    final String json = encodeState(next);
    unawaited(_ops.saveState(json));
    unawaited(_ops.sendStateToApp(json));
    unawaited(_refreshNotification(force: true));
  }

  @override
  void onNotificationPressed() {
    // The notification's own intent opens the app on the running timer
    // (`notificationInitialRoute`); nothing to do here.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _state = null;
    _counting = null;
    await _ops.wakeLock(on: false);
  }

  Future<void> _stop({required bool keepState}) async {
    _state = null;
    await _ops.wakeLock(on: false);
    await _ops.stop(keepState: keepState);
  }

  /// Rewrites the notification when its text changed (once a second while
  /// running), or always when [force]d. Also switches between the fast and
  /// the sleeping repeat, and takes or drops the wake lock, whenever the run
  /// starts or stops counting.
  Future<void> _refreshNotification({bool force = false}) async {
    final ActiveTimer? a = _state;
    if (a == null) return;
    final int now = _nowMs();
    final bool counting =
        !a.run.isPaused &&
        a.run.endedAtMs == null &&
        !a.run.snapshotAt(now).finished;
    Duration? tick;
    if (counting != _counting) {
      _counting = counting;
      tick = counting ? TimerTiming.serviceTick : TimerTiming.pausedServiceTick;
      await _ops.wakeLock(on: counting);
    }
    final NotificationContent c = notificationContent(a, now);
    if (!force && tick == null && c == _shown) return;
    _shown = c;
    await _ops.updateNotification(c, tick: tick);
  }
}
