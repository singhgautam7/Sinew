import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/core/platform/platform_channel.dart';
import 'package:sinew/engines/timer/timer_engine.dart';
import 'package:sinew/features/timer/services/cue_player_impl.dart';

class _Sounds implements SoundOutput {
  final List<CueSound> played = <CueSound>[];

  @override
  Future<void> play(CueSound sound) async => played.add(sound);
}

CueEvent _event(
  CueKind kind, {
  String text = 'Rest',
  bool sound = true,
  bool haptic = true,
  bool voice = true,
}) => CueEvent(
  kind: kind,
  atMs: 0,
  stepIndex: 0,
  text: text,
  sound: sound,
  haptic: haptic,
  voice: voice,
);

void main() {
  late _Sounds sounds;
  late List<String> spoken;
  late List<CueKind> haptics;
  late int now;
  late int ringerReads;
  RingerMode ringer = RingerMode.normal;

  PlatformCuePlayer build() => PlatformCuePlayer(
    sound: sounds,
    ringerMode: () async {
      ringerReads++;
      return ringer;
    },
    speak: (String t) async => spoken.add(t),
    haptic: (CueKind k) async => haptics.add(k),
    nowMs: () => now,
  );

  setUp(() {
    sounds = _Sounds();
    spoken = <String>[];
    haptics = <CueKind>[];
    now = 0;
    ringerReads = 0;
    ringer = RingerMode.normal;
  });

  const TimerCues all = TimerCues(voice: true);

  test('normal ringer plays sound, haptic and voice', () async {
    await build().playForPhase(
      _event(CueKind.phaseStart),
      all,
      TimerPhase.rest,
    );
    expect(sounds.played, <CueSound>[CueSound.rest]);
    expect(haptics, <CueKind>[CueKind.phaseStart]);
    expect(spoken, <String>['Rest']);
  });

  test('silent mutes sound and voice but keeps the haptic', () async {
    ringer = RingerMode.silent;
    await build().play(_event(CueKind.countdown, text: '3'), all);
    expect(sounds.played, isEmpty);
    expect(spoken, isEmpty);
    expect(haptics, <CueKind>[CueKind.countdown]);
  });

  test('vibrate gives haptics only', () async {
    ringer = RingerMode.vibrate;
    await build().play(_event(CueKind.warning, text: '10 seconds'), all);
    expect(sounds.played, isEmpty);
    expect(spoken, isEmpty);
    expect(haptics, <CueKind>[CueKind.warning]);
  });

  test('the cue toggles are respected', () async {
    await build().play(
      _event(CueKind.phaseStart),
      const TimerCues(sound: false, haptic: false, voice: false),
    );
    expect(sounds.played, isEmpty);
    expect(haptics, isEmpty);
    expect(spoken, isEmpty);
  });

  test('an event the engine marked silent stays silent', () async {
    await build().play(
      _event(CueKind.phaseStart, sound: false, haptic: false, voice: false),
      all,
    );
    expect(sounds.played, isEmpty);
    expect(haptics, isEmpty);
    expect(spoken, isEmpty);
  });

  test('the ringer mode is cached for a moment', () async {
    final PlatformCuePlayer p = build();
    await p.play(_event(CueKind.countdown, text: '3'), all);
    now = 500;
    await p.play(_event(CueKind.countdown, text: '2'), all);
    expect(ringerReads, 1);
    now = 5000;
    await p.play(_event(CueKind.countdown, text: '1'), all);
    expect(ringerReads, 2);
  });

  test('sounds by kind and phase', () {
    expect(soundFor(CueKind.countdown, null), CueSound.tick);
    expect(soundFor(CueKind.warning, null), CueSound.warning);
    expect(soundFor(CueKind.finish, null), CueSound.finish);
    expect(soundFor(CueKind.phaseStart, TimerPhase.work), CueSound.go);
    expect(soundFor(CueKind.phaseStart, TimerPhase.rest), CueSound.rest);
    expect(soundFor(CueKind.phaseStart, TimerPhase.roundRest), CueSound.rest);
    expect(soundFor(CueKind.phaseStart, TimerPhase.open), CueSound.go);
  });
}
