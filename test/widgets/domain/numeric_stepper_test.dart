import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/numeric_stepper.dart';

import '../harness.dart';

class _Host extends StatefulWidget {
  const _Host({
    required this.initial,
    this.step = 2.5,
    this.min = 0,
    this.max = 100,
    this.glove = false,
    this.log,
  });

  final double initial;
  final double step;
  final double min;
  final double max;
  final bool glove;
  final List<double>? log;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late double value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return NumericStepper(
      value: value,
      step: widget.step,
      min: widget.min,
      max: widget.max,
      unit: 'kg',
      glove: widget.glove,
      semanticLabel: 'Weight',
      haptics: false,
      onChanged: (double v) {
        widget.log?.add(v);
        setState(() => value = v);
      },
    );
  }
}

Finder get _plus => find.byKey(const ValueKey<String>('stepper-plus'));
Finder get _minus => find.byKey(const ValueKey<String>('stepper-minus'));

void main() {
  group('NumericStepper', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets('renders ${tone.name}', (WidgetTester tester) async {
        await pumpThemed(tester, const _Host(initial: 60), tone: tone);
        expect(find.text('60'), findsOneWidget);
        expect(find.text('kg'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tapping plus and minus steps by the step size', (
      WidgetTester tester,
    ) async {
      final List<double> log = <double>[];
      await pumpThemed(tester, _Host(initial: 60, log: log));
      await tester.tap(_plus);
      await tester.pump();
      expect(find.text('62.5'), findsOneWidget);
      await tester.tap(_minus);
      await tester.tap(_minus);
      await tester.pump();
      expect(find.text('57.5'), findsOneWidget);
      expect(log, <double>[62.5, 60, 57.5]);
    });

    testWidgets('stops at min and max', (WidgetTester tester) async {
      final List<double> log = <double>[];
      await pumpThemed(
        tester,
        _Host(initial: 1, step: 2.5, min: 0, max: 2.5, log: log),
      );
      await tester.tap(_plus);
      await tester.pump();
      expect(find.text('2.5'), findsOneWidget);
      await tester.tap(_plus);
      await tester.pump();
      expect(find.text('2.5'), findsOneWidget);
      await tester.tap(_minus);
      await tester.tap(_minus);
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      await tester.tap(_minus);
      await tester.pump();
      expect(log, <double>[2.5, 0]);
    });

    testWidgets('holding a button repeats, and releasing stops', (
      WidgetTester tester,
    ) async {
      final List<double> log = <double>[];
      await pumpThemed(tester, _Host(initial: 10, step: 1, log: log));
      final TestGesture g = await tester.startGesture(tester.getCenter(_plus));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      final int first = log.length;
      expect(first, 1);
      await tester.pump(const Duration(milliseconds: 600));
      expect(log.length, greaterThan(first + 3));
      await g.up();
      await tester.pump();
      final int atRelease = log.length;
      await tester.pump(const Duration(seconds: 1));
      expect(log.length, atRelease);
    });

    testWidgets('holding stops at the bound', (WidgetTester tester) async {
      final List<double> log = <double>[];
      await pumpThemed(tester, _Host(initial: 98, step: 1, max: 100, log: log));
      final TestGesture g = await tester.startGesture(tester.getCenter(_plus));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pump(const Duration(seconds: 2));
      await g.up();
      await tester.pump();
      expect(log, <double>[99, 100]);
    });

    testWidgets('tap the value to type it, clamped to the bounds', (
      WidgetTester tester,
    ) async {
      final List<double> log = <double>[];
      await pumpThemed(tester, _Host(initial: 60, log: log));
      await tester.tap(find.text('60'));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), '82,5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('82.5'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.text('82.5'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '999');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('100'), findsOneWidget);
      expect(log, <double>[82.5, 100]);
    });

    testWidgets('exposes increase and decrease to a screen reader', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final List<double> log = <double>[];
      await pumpThemed(tester, _Host(initial: 60, log: log));
      final Finder node = find.bySemanticsLabel('Weight');
      expect(node, findsOneWidget);
      final SemanticsNode n = tester.getSemantics(node);
      expect(n.value, '60 kg');
      expect(n.increasedValue, '62.5');
      expect(n.decreasedValue, '57.5');
      tester.semantics.performAction(
        find.semantics.byLabel('Weight'),
        SemanticsAction.increase,
      );
      await tester.pump();
      tester.semantics.performAction(
        find.semantics.byLabel('Weight'),
        SemanticsAction.decrease,
      );
      await tester.pump();
      expect(log, <double>[62.5, 60]);
      handle.dispose();
    });

    testWidgets('glove targets are 64dp, normal ones 48dp', (
      WidgetTester tester,
    ) async {
      await pumpThemed(tester, const _Host(initial: 5, glove: true));
      expect(tester.getSize(_plus), const Size(64, 64));
      await pumpThemed(tester, const _Host(initial: 5));
      expect(tester.getSize(_plus), const Size(48, 48));
    });

    for (final bool glove in <bool>[false, true]) {
      testWidgets('survives 200% text at 360dp (glove: $glove)', (
        WidgetTester tester,
      ) async {
        await pumpThemed(
          tester,
          _Host(initial: 1234.5, glove: glove),
          textScale: 2,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
