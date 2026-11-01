import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/timer_preset.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/timer_ring.dart';
import 'package:sinew/engines/timer/timer_engine.dart';

import '../harness.dart';

TimerSnapshot _snap({
  TimerPhase phase = TimerPhase.work,
  int elapsedMs = 6000,
  int? durationMs = 20000,
  bool paused = false,
  bool finished = false,
  int round = 3,
  int roundCount = 8,
}) {
  return TimerSnapshot(
    atMs: 0,
    stepIndex: 2,
    stepCount: 16,
    step: TimerStepSpec(label: 'Step', durationMs: durationMs, phase: phase),
    stepElapsedMs: elapsedMs,
    stepDurationMs: durationMs,
    totalElapsedMs: elapsedMs,
    totalDurationMs: 160000,
    finished: finished,
    stopped: false,
    paused: paused,
    round: round,
    roundCount: roundCount,
    amrapRounds: 0,
    endedAtMs: null,
  );
}

Widget _field(
  TimerSnapshot s, {
  int? warningSec,
  String? next = 'Next: Rest 0:10',
  Widget? controls,
}) {
  return SizedBox.expand(
    child: PhaseField(
      snapshot: s,
      title: 'Tabata, legs',
      trailing: 'Set 1 of 2',
      nextLabel: next,
      warningSec: warningSec,
      controls: controls,
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Tone tone = Tone.light,
  double textScale = 1,
  bool reduced = false,
}) => pumpThemed(
  tester,
  child,
  tone: tone,
  textScale: textScale,
  disableAnimations: reduced,
  scaffold: false,
);

void main() {
  group('ClockText', () {
    test('formats minutes, seconds and hours', () {
      expect(ClockText.format(0), '0:00');
      expect(ClockText.format(14), '0:14');
      expect(ClockText.format(74), '1:14');
      expect(ClockText.format(3723), '1:02:03');
      expect(ClockText.format(-5), '0:00');
    });

    test('parses what people type', () {
      expect(ClockText.parse('45'), 45);
      expect(ClockText.parse('1:30'), 90);
      expect(ClockText.parse('1:02:03'), 3723);
      expect(ClockText.parse(''), isNull);
      expect(ClockText.parse('a:b'), isNull);
    });

    test('speaks durations', () {
      expect(ClockText.spoken(14), '14 seconds');
      expect(ClockText.spoken(74), '1 minute 14 seconds');
      expect(ClockText.spoken(0), '0 seconds');
    });

    test('maps timer phases to accent phases', () {
      expect(sinewPhaseOf(TimerPhase.work), SinewPhase.work);
      expect(sinewPhaseOf(TimerPhase.rest), SinewPhase.rest);
      expect(sinewPhaseOf(TimerPhase.roundRest), SinewPhase.rest);
      expect(sinewPhaseOf(TimerPhase.prepare), SinewPhase.warmup);
      expect(sinewPhaseOf(TimerPhase.cooldown), SinewPhase.cooldown);
      expect(sinewPhaseOf(TimerPhase.open), SinewPhase.work);
    });
  });

  group('PhaseField', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets('shows the numeral, label and word (${tone.name})', (
        WidgetTester tester,
      ) async {
        await _pump(tester, _field(_snap()), tone: tone);
        expect(find.text('0:14'), findsOneWidget);
        expect(find.text('Round 3 of 8'), findsOneWidget);
        expect(find.text('WORK'), findsOneWidget);
        expect(find.text('Next: Rest 0:10'), findsOneWidget);
        expect(find.text('Tabata, legs'), findsOneWidget);
        expect(find.text('Set 1 of 2'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('counts down by rounding the remaining time up', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _field(_snap(elapsedMs: 5001)));
      expect(find.text('0:15'), findsOneWidget);
      await _pump(tester, _field(_snap(elapsedMs: 19900)));
      expect(find.text('0:01'), findsOneWidget);
    });

    testWidgets('an open-ended step counts up', (WidgetTester tester) async {
      await _pump(
        tester,
        _field(
          _snap(
            phase: TimerPhase.open,
            elapsedMs: 65000,
            durationMs: null,
            roundCount: 0,
            round: 0,
          ),
          next: null,
        ),
      );
      expect(find.text('1:05'), findsOneWidget);
      expect(find.text('WORK'), findsNothing);
    });

    testWidgets('rest, get ready and cool down have their own word', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _field(_snap(phase: TimerPhase.rest)));
      expect(find.text('REST'), findsOneWidget);
      await _pump(tester, _field(_snap(phase: TimerPhase.prepare)));
      await tester.pumpAndSettle();
      expect(find.text('GET READY'), findsOneWidget);
      await _pump(tester, _field(_snap(phase: TimerPhase.cooldown)));
      await tester.pumpAndSettle();
      expect(find.text('COOL DOWN'), findsOneWidget);
    });

    testWidgets('paused shows the PAUSED pill instead of the trailing text', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _field(_snap(paused: true)));
      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.text('Set 1 of 2'), findsNothing);
    });

    testWidgets('boxing warning replaces the ring with the warning face', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _field(_snap(elapsedMs: 12000), warningSec: 10),
        tone: Tone.dark,
      );
      expect(find.text('10 seconds left'), findsOneWidget);
      expect(find.text('0:08'), findsOneWidget);
      expect(find.text('WORK'), findsNothing);
      await _pump(
        tester,
        _field(_snap(elapsedMs: 5000), warningSec: 10),
        tone: Tone.dark,
      );
      expect(find.text('10 seconds left'), findsNothing);
    });

    testWidgets('finished shows the done face and the controls slot', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PhaseField(
          snapshot: _snap(finished: true),
          finishedSubtitle: 'Tabata, legs, 2 sets',
          controls: const Text('close'),
        ),
      );
      expect(find.text('Done. Nice work.'), findsOneWidget);
      expect(find.text('Tabata, legs, 2 sets'), findsOneWidget);
      expect(find.text('close'), findsOneWidget);
      expect(find.text('0:14'), findsNothing);
    });

    testWidgets('AMOLED draws coloured numerals on a black field', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.of(Tone.amoled), home: _field(_snap())),
      );
      final BuildContext ctx = tester.element(find.byType(PhaseField));
      final PhaseColor c = ctx.accents.phase(SinewPhase.work);
      expect(c.field, Colors.black);
      final Text numeral = tester.widget<Text>(find.text('0:14'));
      expect(numeral.style!.color, c.on);
      expect(c.on, isNot(Colors.black));
    });

    testWidgets('speaks the phase, time and round', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(tester, _field(_snap(paused: true)));
      expect(
        find.bySemanticsLabel('Work, 14 seconds, Round 3 of 8, Paused'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('a phase change sweeps for 360ms, or fades for 90ms', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _field(_snap()));
      await _pump(tester, _field(_snap(phase: TimerPhase.rest)));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.text('REST'), findsOneWidget);

      await _pump(tester, _field(_snap()), reduced: true);
      await tester.pumpAndSettle();
      await _pump(tester, _field(_snap(phase: TimerPhase.rest)), reduced: true);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('survives 200% text at 360dp in every state', (
      WidgetTester tester,
    ) async {
      final List<Widget> faces = <Widget>[
        _field(_snap()),
        _field(_snap(paused: true)),
        _field(_snap(elapsedMs: 12000), warningSec: 10),
        PhaseField(snapshot: _snap(finished: true)),
      ];
      for (final Widget f in faces) {
        await _pump(tester, f, textScale: 2);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('TimerRing', () {
    testWidgets('lays out at its size with its child inside', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const TimerRing(
          fraction: 0.5,
          ringColor: Colors.transparent,
          trackColor: Colors.transparent,
          size: 200,
          child: Text('0:30'),
        ),
      );
      expect(tester.getSize(find.byType(TimerRing)), const Size(200, 200));
      expect(find.text('0:30'), findsOneWidget);
    });
  });
}
