import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../../core/models/enums.dart';
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

/// The part of the timer that keeps working when the app's isolate is gone
/// (screen off, app swiped away from the foreground, activity destroyed).
///
/// It holds the last run the app gave it and does three things:
/// - keeps the ongoing notification current (phase, round, time left, next);
/// - answers the notification buttons (pause or resume, skip, +10 s), saving
///   the new run and telling the app if it is listening;
/// - plays due cues, but only while the app is silent: the app sends a
///   heartbeat every second and, while it is alive, it plays the cues itself
///   (it can also vibrate and speak, which this isolate cannot).
///
/// Time comes from the run's timestamps; the repeating event only decides
/// how often we look.
class TimerTaskHandler extends TaskHandler {
  TimerTaskHandler({SoundOutput? sound, int Function()? nowMs})
    : _sound = sound ?? AudioplayersSoundOutput(),
      _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final SoundOutput _sound;
  final int Function() _nowMs;

  ActiveTimer? _state;
  int _lastCueMs = 0;
  int _lastHeartbeatMs = 0;
  NotificationContent? _shown;
  int? _finishedAtMs;

  @visibleForTesting
  ActiveTimer? get state => _state;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final int now = _nowMs();
    _lastCueMs = now;
    _lastHeartbeatMs = now;
    final Object? saved = await FlutterForegroundTask.getData<String>(
      key: kServiceStateKey,
    );
    _state = decodeState(saved);
    final SoundOutput s = _sound;
    if (s is AudioplayersSoundOutput) unawaited(s.preload());
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
  void onRepeatEvent(DateTime timestamp) {
    final ActiveTimer? a = _state;
    if (a == null) return;
    final int now = _nowMs();
    final TimerSnapshot snap = a.run.snapshotAt(now);

    if (_finishedAtMs != null) {
      if (now - _finishedAtMs! >= TimerTiming.finishLinger.inMilliseconds) {
        unawaited(_stop());
      }
      return;
    }

    final bool appAlive = now - _lastHeartbeatMs < TimerTiming.heartbeatLapseMs;
    if (!appAlive && !a.run.isPaused && a.run.endedAtMs == null) {
      final int from = _lastCueMs < now - TimerTiming.staleCueMs
          ? now - TimerTiming.staleCueMs
          : _lastCueMs;
      for (final CueEvent e in a.run.cuesBetween(from, now + 1, a.cues)) {
        if (e.sound && a.cues.sound) {
          final TimerPhase? phase = e.stepIndex < a.run.steps.length
              ? a.run.steps[e.stepIndex].phase
              : null;
          unawaited(_sound.play(soundFor(e.kind, phase)));
        }
      }
    }
    _lastCueMs = now + 1;

    if (snap.finished) {
      _finishedAtMs = now;
      FlutterForegroundTask.sendDataToMain(<String, Object?>{'t': msgFinished});
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
    unawaited(
      FlutterForegroundTask.saveData(key: kServiceStateKey, value: json),
    );
    FlutterForegroundTask.sendDataToMain(stateMessage(json));
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
  }

  Future<void> _stop() async {
    _state = null;
    await FlutterForegroundTask.removeData(key: kServiceStateKey);
    await FlutterForegroundTask.stopService();
  }

  /// Rewrites the notification when its text changed (once a second while
  /// running), or always when [force]d.
  Future<void> _refreshNotification({bool force = false}) async {
    final ActiveTimer? a = _state;
    if (a == null) return;
    final NotificationContent c = notificationContent(a, _nowMs());
    if (!force && c == _shown) return;
    _shown = c;
    await FlutterForegroundTask.updateService(
      notificationTitle: c.title,
      notificationText: c.text,
      notificationButtons: <NotificationButton>[
        for (final (String id, String label) in c.buttons)
          NotificationButton(id: id, text: label),
      ],
    );
  }
}
