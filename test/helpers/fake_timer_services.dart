import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/engines/timer/timer_engine.dart';
import 'package:sinew/features/timer/api/timer_api.dart';

/// Records what the app asked of the timer services instead of touching the
/// foreground service, audio or the wake lock (none exist in widget tests).
class FakeTimerServices implements BackgroundTimerHost, CuePlayer, ScreenWake {
  final List<String> hostCalls = <String>[];
  final List<CueEvent> cues = <CueEvent>[];
  bool screenOn = false;

  @override
  Future<void> show(
    TimerRun run,
    TimerCues cues, {
    required String title,
  }) async => hostCalls.add('show:$title');

  @override
  Future<void> clear() async => hostCalls.add('clear');

  @override
  Future<void> play(CueEvent event, TimerCues cues) async =>
      this.cues.add(event);

  @override
  Future<void> keepOn({required bool on}) async => screenOn = on;

  List<Override> overrides() => <Override>[
    backgroundTimerHostProvider.overrideWithValue(this),
    cuePlayerProvider.overrideWithValue(this),
    screenWakeProvider.overrideWithValue(this),
  ];
}
