import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/timer_preset.dart';
import '../../../core/platform/platform_channel.dart';
import '../../../core/theme/tokens.dart';
import '../../../engines/timer/timer_engine.dart';
import '../api/timer_api.dart';

/// A [CuePlayer] that also knows which phase a cue belongs to, so a phase
/// start can sound different for work and rest. The engine's [CueEvent]
/// carries the step index and label but not the phase, so the caller (which
/// holds the run) passes it. A plain [CuePlayer] still works: it just uses
/// the generic sound.
abstract interface class PhaseCuePlayer implements CuePlayer {
  Future<void> playForPhase(CueEvent event, TimerCues cues, TimerPhase phase);
}

/// The five bundled cue sounds (`assets/audio/<name>.wav`).
enum CueSound { tick, go, rest, warning, finish }

/// The sound a cue plays.
CueSound soundFor(CueKind kind, TimerPhase? phase) => switch (kind) {
  CueKind.countdown => CueSound.tick,
  CueKind.warning => CueSound.warning,
  CueKind.finish => CueSound.finish,
  CueKind.phaseStart => switch (phase) {
    TimerPhase.rest ||
    TimerPhase.roundRest ||
    TimerPhase.prepare ||
    TimerPhase.cooldown => CueSound.rest,
    _ => CueSound.go,
  },
};

/// Where the five sounds come out. A seam so tests record instead of play.
abstract interface class SoundOutput {
  Future<void> play(CueSound sound);
}

/// Plays the bundled wavs on the native cue channel (a `SoundPool`, see
/// `CueChannel.kt`). The channel exists in the app's isolate and in the
/// service's, so both use this one class.
///
/// The sounds use the media usage with sonification content and no audio
/// focus: a cue never pauses the user's music, and the silent and vibrate
/// ringer modes are honoured by [PlatformCuePlayer] before it gets here.
class ChannelSoundOutput implements SoundOutput {
  Future<bool>? _loaded;

  /// Loads every sound so the first cue is not late.
  Future<bool> preload() => _loaded ??= SinewCues.load(<String>[
    for (final CueSound s in CueSound.values) s.name,
  ]);

  @override
  Future<void> play(CueSound sound) async {
    try {
      if (!await preload()) {
        // Not loaded (no platform yet): try again at the next cue.
        _loaded = null;
        return;
      }
      await SinewCues.play(sound.name);
    } on Object catch (e) {
      debugPrint('Sinew cue sound ${sound.name} failed: $e');
    }
  }
}

/// How late a cue may still be played. A countdown tick or a warning that is
/// a second old is noise; a phase start or the finish is still news.
int staleLimitMs(CueKind kind) => switch (kind) {
  CueKind.phaseStart || CueKind.finish => TimerTiming.staleLongCueMs,
  CueKind.countdown || CueKind.warning => TimerTiming.staleCueMs,
};

/// The cues of [run] due in `[lastCueMs, nowMs]` that are not stale. Shared by
/// the app's ticker and the service, so both drop the same ones.
List<CueEvent> dueCues(
  TimerRun run,
  TimerCues cues, {
  required int lastCueMs,
  required int nowMs,
}) {
  final int from = math.max(lastCueMs, nowMs - TimerTiming.staleLongCueMs);
  return <CueEvent>[
    for (final CueEvent e in run.cuesBetween(from, nowMs + 1, cues))
      if (nowMs - e.atMs <= staleLimitMs(e.kind)) e,
  ];
}

/// Sound, haptic and voice for one cue, respecting the cue toggles and the
/// ringer mode: silent mutes sound and voice, vibrate leaves haptics only.
class PlatformCuePlayer implements PhaseCuePlayer {
  PlatformCuePlayer({
    SoundOutput? sound,
    Future<RingerMode> Function()? ringerMode,
    Future<void> Function(String text)? speak,
    Future<void> Function(CueKind kind)? haptic,
    bool Function()? hapticsEnabled,
    int Function()? nowMs,
  }) : _sound = sound ?? ChannelSoundOutput(),
       _ringer = ringerMode ?? SinewCues.ringerMode,
       _speak = speak ?? ((String t) => SinewCues.speak(t)),
       _haptic = haptic ?? _channelHaptic,
       _hapticsEnabled = hapticsEnabled ?? (() => true),
       _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final SoundOutput _sound;
  final Future<RingerMode> Function() _ringer;
  final Future<void> Function(String text) _speak;
  final Future<void> Function(CueKind kind) _haptic;

  /// The app-wide Settings > Haptics switch. The service cannot read
  /// settings, so there the cues it was given already carry it.
  final bool Function() _hapticsEnabled;
  final int Function() _nowMs;

  RingerMode _cachedRinger = RingerMode.normal;
  int _ringerAtMs = -1 << 40;

  Future<RingerMode> _ringerNow() async {
    final int now = _nowMs();
    if (now - _ringerAtMs < TimerTiming.ringerCache.inMilliseconds) {
      return _cachedRinger;
    }
    try {
      _cachedRinger = await _ringer();
    } on Object {
      _cachedRinger = RingerMode.normal;
    }
    _ringerAtMs = now;
    return _cachedRinger;
  }

  @override
  Future<void> play(CueEvent event, TimerCues cues) =>
      playForPhase(event, cues, TimerPhase.work);

  @override
  Future<void> playForPhase(
    CueEvent event,
    TimerCues cues,
    TimerPhase phase,
  ) async {
    final RingerMode ringer = await _ringerNow();
    final bool audible = ringer == RingerMode.normal;
    final List<Future<void>> work = <Future<void>>[];
    if (event.haptic && cues.haptic && _hapticsEnabled()) {
      work.add(_haptic(event.kind));
    }
    if (audible && event.sound && cues.sound) {
      work.add(_sound.play(soundFor(event.kind, phase)));
    }
    if (audible && event.voice && cues.voice && event.text.isNotEmpty) {
      work.add(_speak(event.text));
    }
    try {
      await Future.wait(work);
    } on Object catch (e) {
      debugPrint('Sinew cue failed: $e');
    }
  }
}

Future<void> _channelHaptic(CueKind kind) => SinewCues.vibrate(switch (kind) {
  CueKind.countdown => CueHaptics.countdown,
  CueKind.phaseStart => CueHaptics.phaseStart,
  CueKind.warning => CueHaptics.warning,
  CueKind.finish => CueHaptics.finish,
});
