import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

/// Plays the bundled wavs through `audioplayers` in low-latency mode.
///
/// The audio context uses the "assistance sonification" usage with no audio
/// focus: a cue never pauses the user's music, and Android itself mutes it in
/// silent and vibrate mode, in the background service as well as here.
class AudioplayersSoundOutput implements SoundOutput {
  final Map<CueSound, Future<AudioPlayer?>> _players =
      <CueSound, Future<AudioPlayer?>>{};

  static final AudioContext _context = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  Future<AudioPlayer?> _player(CueSound sound) =>
      _players.putIfAbsent(sound, () async {
        try {
          final AudioPlayer p = AudioPlayer(playerId: 'sinew-${sound.name}');
          await p.setPlayerMode(PlayerMode.lowLatency);
          await p.setReleaseMode(ReleaseMode.stop);
          await p.setAudioContext(_context);
          await p.setSource(AssetSource('audio/${sound.name}.wav'));
          return p;
        } on Object catch (e) {
          debugPrint('Sinew cue sound ${sound.name} unavailable: $e');
          return null;
        }
      });

  /// Loads every sound so the first cue is not late.
  Future<void> preload() async {
    for (final CueSound s in CueSound.values) {
      await _player(s);
    }
  }

  @override
  Future<void> play(CueSound sound) async {
    try {
      final AudioPlayer? p = await _player(sound);
      if (p == null) return;
      await p.stop();
      await p.resume();
    } on Object catch (e) {
      debugPrint('Sinew cue sound ${sound.name} failed: $e');
    }
  }
}

/// Sound, haptic and voice for one cue, respecting the cue toggles and the
/// ringer mode: silent mutes sound and voice, vibrate leaves haptics only.
class PlatformCuePlayer implements PhaseCuePlayer {
  PlatformCuePlayer({
    SoundOutput? sound,
    Future<RingerMode> Function()? ringerMode,
    Future<void> Function(String text)? speak,
    Future<void> Function(CueKind kind)? haptic,
    int Function()? nowMs,
  }) : _sound = sound ?? AudioplayersSoundOutput(),
       _ringer = ringerMode ?? SinewPlatform.ringerMode,
       _speak = speak ?? ((String t) => SinewPlatform.speak(t)),
       _haptic = haptic ?? _systemHaptic,
       _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final SoundOutput _sound;
  final Future<RingerMode> Function() _ringer;
  final Future<void> Function(String text) _speak;
  final Future<void> Function(CueKind kind) _haptic;
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
    if (event.haptic && cues.haptic) work.add(_haptic(event.kind));
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

Future<void> _systemHaptic(CueKind kind) async {
  switch (kind) {
    case CueKind.countdown:
      await HapticFeedback.selectionClick();
    case CueKind.phaseStart:
      await HapticFeedback.mediumImpact();
    case CueKind.warning:
      await HapticFeedback.heavyImpact();
    case CueKind.finish:
      await HapticFeedback.vibrate();
  }
}
