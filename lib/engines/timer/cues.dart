// PURE DART.

enum CueKind { countdown, phaseStart, warning, finish }

/// One scheduled cue at an absolute time. The app schedules these ahead
/// (see `TimerRun.cuesBetween`) so they fire with the UI suspended.
class CueEvent {
  const CueEvent({
    required this.kind,
    required this.atMs,
    required this.stepIndex,
    required this.text,
    required this.sound,
    required this.haptic,
    required this.voice,
  });

  final CueKind kind;

  /// Epoch ms.
  final int atMs;
  final int stepIndex;

  /// What to speak ("3", "Rest", "10 seconds", "Done").
  final String text;
  final bool sound;
  final bool haptic;

  /// True when the voice cue is on and there is something to say.
  final bool voice;

  @override
  bool operator ==(Object other) =>
      other is CueEvent &&
      other.kind == kind &&
      other.atMs == atMs &&
      other.stepIndex == stepIndex &&
      other.text == text &&
      other.sound == sound &&
      other.haptic == haptic &&
      other.voice == voice;

  @override
  int get hashCode =>
      Object.hash(kind, atMs, stepIndex, text, sound, haptic, voice);

  @override
  String toString() => 'CueEvent(${kind.name} @$atMs step $stepIndex "$text")';
}
