import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../../core/models/timer_preset.dart';
import '../../../core/routing/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../engines/timer/timer_engine.dart';
import '../api/timer_api.dart';
import '../data/active_timer.dart';
import 'service_protocol.dart';
import 'timer_task_handler.dart';

/// The app's side of the link to the background service: the run states the
/// service changed (a notification button was pressed while the app was
/// alive) and the copy it saved (read on a cold start).
abstract interface class TimerServiceLink {
  /// Run states the service changed, as the same payload the app persists.
  Stream<ActiveTimer> get changes;

  /// The service's saved copy of the run, if there is one.
  Future<ActiveTimer?> readSaved();
}

/// A link that never hears anything (tests, and platforms without the
/// service).
class NoServiceLink implements TimerServiceLink {
  const NoServiceLink();

  @override
  Stream<ActiveTimer> get changes => const Stream<ActiveTimer>.empty();

  @override
  Future<ActiveTimer?> readSaved() async => null;
}

class ForegroundTaskLink implements TimerServiceLink {
  ForegroundTaskLink() {
    FlutterForegroundTask.addTaskDataCallback(_onData);
  }

  final StreamController<ActiveTimer> _changes =
      StreamController<ActiveTimer>.broadcast();

  void _onData(Object data) {
    if (data is! Map<Object?, Object?> || data['t'] != msgState) return;
    final ActiveTimer? a = decodeState(data['json']);
    if (a != null) _changes.add(a);
  }

  @override
  Stream<ActiveTimer> get changes => _changes.stream;

  @override
  Future<ActiveTimer?> readSaved() async {
    try {
      return decodeState(
        await FlutterForegroundTask.getData<String>(key: kServiceStateKey),
      );
    } on Object {
      return null;
    }
  }

  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onData);
    unawaited(_changes.close());
  }
}

/// [BackgroundTimerHost] on `flutter_foreground_task`: an Android foreground
/// service with an ongoing notification, so the run, its cues and its
/// notification buttons keep working with the screen off or the app in the
/// background.
///
/// Every platform call is guarded: a missing plugin (tests, other Train
/// widgets that never start a service) leaves the timer running in the
/// foreground and never throws. A refused notification permission does not
/// stop the service either; only its notification is hidden.
class ForegroundTimerHost implements BackgroundTimerHost {
  ForegroundTimerHost({int Function()? nowMs})
    : _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final int Function() _nowMs;

  Future<void> _queue = Future<void>.value();
  Timer? _heartbeat;

  @override
  Future<void> show(
    TimerRun run,
    TimerCues cues, {
    required String title,
  }) => _enqueue(() async {
    final int now = _nowMs();
    if (run.snapshotAt(now).finished) {
      await _clear();
      return;
    }
    // The service runs without the notification permission (the notification
    // is just not shown), so the permission is asked for once and never
    // decides whether the timer keeps going with the screen off.
    await _askNotificationPermissionOnce();
    final String json = encodeState(
      ActiveTimer(run: run, cues: cues, title: title, updatedAtMs: now),
    );
    _init();
    await FlutterForegroundTask.saveData(key: kServiceStateKey, value: json);
    final bool paused = run.isPaused;
    if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.sendDataToTask(stateMessage(json));
    } else if (paused) {
      // A paused run does not need a service (it stopped after a long pause,
      // or the app was reopened on it). Resuming starts one.
      _stopHeartbeat();
      return;
    } else {
      final ServiceRequestResult r = await FlutterForegroundTask.startService(
        serviceId: kServiceId,
        serviceTypes: <ForegroundServiceTypes>[
          ForegroundServiceTypes.specialUse,
        ],
        notificationTitle: title,
        notificationText: 'Timer running',
        notificationIcon: const NotificationIcon(
          metaDataName: kNotificationIconMeta,
        ),
        notificationInitialRoute: Routes.timerRun,
        callback: timerTaskCallback,
      );
      if (r is ServiceRequestFailure) {
        debugPrint('Sinew timer service did not start: ${r.error}');
        return;
      }
    }
    if (paused) {
      _stopHeartbeat();
    } else {
      _startHeartbeat();
    }
  });

  @override
  Future<void> clear() => _enqueue(_clear);

  Future<void> _clear() async {
    _stopHeartbeat();
    await FlutterForegroundTask.removeData(key: kServiceStateKey);
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  /// Runs [job] after the previous call, swallowing any failure: the
  /// service is a convenience, never a reason for the timer to stop.
  Future<void> _enqueue(Future<void> Function() job) {
    _queue = _queue.then((_) => job()).catchError((Object e) {
      debugPrint('Sinew timer service call failed: $e');
    });
    return _queue;
  }

  void _init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'sinew_timer',
        channelName: 'Running timer',
        channelDescription: 'Shows the timer that is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: timerServiceOptions(TimerTiming.serviceTick),
    );
  }

  /// Android 13 and up need the notification permission to show the
  /// service's notification. It is asked for at the first timer start, once.
  Future<void> _askNotificationPermissionOnce() async {
    final NotificationPermission p =
        await FlutterForegroundTask.checkNotificationPermission();
    if (p == NotificationPermission.granted) return;
    final bool asked =
        await FlutterForegroundTask.getData<bool>(key: kNotificationAskedKey) ??
        false;
    if (asked) return;
    await FlutterForegroundTask.saveData(
      key: kNotificationAskedKey,
      value: true,
    );
    await FlutterForegroundTask.requestNotificationPermission();
  }

  void _stopHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(TimerTiming.heartbeat, (Timer _) {
      try {
        FlutterForegroundTask.sendDataToTask(heartbeatMessage);
      } on Object {
        // No service to hear it.
      }
    });
  }
}
