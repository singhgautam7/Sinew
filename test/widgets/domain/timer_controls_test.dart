import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/timer_controls.dart';

import '../harness.dart';

class _Calls {
  int playPause = 0;
  int skip = 0;
  int add = 0;
  int lock = 0;
  int unlock = 0;
  int stop = 0;
}

Widget _controls(
  _Calls c, {
  bool paused = false,
  bool locked = false,
  SinewPhase phase = SinewPhase.work,
  bool stop = false,
  bool labels = false,
}) {
  return TimerControls(
    phase: phase,
    paused: paused,
    locked: locked,
    showLabels: labels,
    haptics: false,
    onPlayPause: () => c.playPause++,
    onSkip: () => c.skip++,
    onAddTime: () => c.add++,
    onLock: () => c.lock++,
    onUnlock: () => c.unlock++,
    onStop: stop ? () => c.stop++ : null,
  );
}

void main() {
  group('TimerControls', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      for (final SinewPhase phase in SinewPhase.values) {
        testWidgets('renders ${phase.name} in ${tone.name}', (
          WidgetTester tester,
        ) async {
          await pumpThemed(
            tester,
            _controls(_Calls(), phase: phase),
            tone: tone,
          );
          expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
          expect(find.text('+10s'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('every control has a label and the right size', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpThemed(tester, _controls(_Calls(), stop: true));
      for (final String label in <String>[
        'Lock',
        'Add 10 seconds',
        'Pause',
        'Skip',
        'Stop',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
      }
      expect(tester.getSize(find.bySemanticsLabel('Pause')).width, 96);
      expect(tester.getSize(find.bySemanticsLabel('Pause')).height, 96);
      for (final String label in <String>['Add 10 seconds', 'Skip', 'Stop']) {
        expect(
          tester.getSize(find.bySemanticsLabel(label)),
          const Size(64, 64),
        );
      }
      handle.dispose();
    });

    testWidgets('each button calls its callback', (WidgetTester tester) async {
      final _Calls c = _Calls();
      await pumpThemed(tester, _controls(c, stop: true));
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.tap(find.text('+10s'));
      await tester.tap(find.byIcon(Icons.lock_open_rounded));
      await tester.tap(find.byIcon(Icons.stop_rounded));
      expect(c.playPause, 1);
      expect(c.skip, 1);
      expect(c.add, 1);
      expect(c.lock, 1);
      expect(c.stop, 1);
    });

    testWidgets('the primary is a squircle that becomes a circle when paused', (
      WidgetTester tester,
    ) async {
      BorderRadius radius() {
        final AnimatedContainer ac = tester.widget<AnimatedContainer>(
          find.descendant(
            of: find.bySemanticsLabel(RegExp('Pause|Resume')),
            matching: find.byType(AnimatedContainer),
          ),
        );
        return (ac.decoration! as BoxDecoration).borderRadius! as BorderRadius;
      }

      await pumpThemed(tester, _controls(_Calls()));
      expect(radius(), BorderRadius.circular(32));
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

      await pumpThemed(tester, _controls(_Calls(), paused: true));
      await tester.pump(const Duration(milliseconds: 20));
      // Mid-morph: between the squircle and the circle.
      final double mid = radius().topLeft.x;
      expect(mid, inInclusiveRange(32, 48));
      await tester.pumpAndSettle();
      expect(radius(), BorderRadius.circular(48));
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.bySemanticsLabel('Resume'), findsOneWidget);
    });

    testWidgets('reduced motion shortens the morph to a fade', (
      WidgetTester tester,
    ) async {
      await pumpThemed(tester, _controls(_Calls()), disableAnimations: true);
      await pumpThemed(
        tester,
        _controls(_Calls(), paused: true),
        disableAnimations: true,
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    group('locked', () {
      testWidgets('everything but the lock is disabled', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final _Calls c = _Calls();
        await pumpThemed(tester, _controls(c, locked: true, stop: true));
        await tester.tap(find.byIcon(Icons.pause_rounded), warnIfMissed: false);
        await tester.tap(find.byIcon(Icons.skip_next_rounded));
        await tester.tap(find.text('+10s'));
        await tester.tap(find.byIcon(Icons.stop_rounded));
        await tester.tap(find.byIcon(Icons.lock_rounded));
        expect(c.playPause, 0);
        expect(c.skip, 0);
        expect(c.add, 0);
        expect(c.stop, 0);
        expect(c.lock, 0);
        expect(c.unlock, 0);
        expect(find.bySemanticsLabel('Unlock'), findsOneWidget);
        expect(
          tester.getSemantics(find.bySemanticsLabel('Skip')),
          matchesSemantics(
            label: 'Skip',
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
          ),
        );
        handle.dispose();
      });

      testWidgets('a short press does not unlock, a one second hold does', (
        WidgetTester tester,
      ) async {
        final _Calls c = _Calls();
        await pumpThemed(tester, _controls(c, locked: true));
        final Offset at = tester.getCenter(find.byIcon(Icons.lock_rounded));

        TestGesture g = await tester.startGesture(at);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        await g.up();
        await tester.pump();
        expect(c.unlock, 0);

        g = await tester.startGesture(at);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(c.unlock, 0);
        await tester.pump(const Duration(milliseconds: 600));
        await g.up();
        await tester.pump();
        expect(c.unlock, 1);
      });

      testWidgets('a screen reader can unlock with its long press action', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final _Calls c = _Calls();
        await pumpThemed(tester, _controls(c, locked: true));
        tester.semantics.performAction(
          find.semantics.byLabel('Unlock'),
          SemanticsAction.longPress,
        );
        expect(c.unlock, 1);
        handle.dispose();
      });
    });

    testWidgets('labels show under the controls when asked', (
      WidgetTester tester,
    ) async {
      await pumpThemed(tester, _controls(_Calls(), labels: true));
      for (final String l in <String>['Lock', 'Add', 'Pause', 'Skip']) {
        expect(find.text(l), findsOneWidget);
      }
    });

    testWidgets('five controls wrap at 360dp and survive 200% text', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        _controls(_Calls(), stop: true, labels: true),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await pumpThemed(
        tester,
        _controls(_Calls(), locked: true, stop: true),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AmrapCounter', () {
    testWidgets('tapping the surface adds a round, undo takes one back', (
      WidgetTester tester,
    ) async {
      int rounds = 5;
      late StateSetter set;
      await pumpThemed(
        tester,
        StatefulBuilder(
          builder: (BuildContext c, StateSetter s) {
            set = s;
            return AmrapCounter(
              phase: SinewPhase.work,
              rounds: rounds,
              haptics: false,
              onAdd: () => s(() => rounds++),
              onUndo: () => s(() => rounds--),
            );
          },
        ),
        tone: Tone.dark,
      );
      expect(set, isNotNull);
      expect(find.text('5'), findsOneWidget);
      await tester.tap(find.text('Tap anywhere here'));
      await tester.pump();
      expect(find.text('6'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('undo is disabled at zero; labels are spoken', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int undone = 0;
      await pumpThemed(
        tester,
        AmrapCounter(
          phase: SinewPhase.work,
          rounds: 0,
          haptics: false,
          onAdd: () {},
          onUndo: () => undone++,
        ),
      );
      await tester.tap(find.text('Undo'), warnIfMissed: false);
      expect(undone, 0);
      expect(find.bySemanticsLabel('Add a round'), findsOneWidget);
      expect(find.bySemanticsLabel('Undo last round'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('survives 200% text at 360dp', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        AmrapCounter(
          phase: SinewPhase.work,
          rounds: 12,
          haptics: false,
          onAdd: () {},
          onUndo: () {},
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
