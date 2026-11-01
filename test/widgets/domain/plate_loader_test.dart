import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/plate_inventory.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/_painters/plate_bar_painter.dart';
import 'package:sinew/core/widgets/domain/plate_loader.dart';
import 'package:sinew/engines/plates/plates.dart';

import '../harness.dart';

const Bar _olympic = Bar(name: 'Olympic bar', weightKg: 20);
const Bar _handle = Bar(name: 'Dumbbell handle', weightKg: 2, isDumbbell: true);
const PlateInventory _inv = PlateInventory.metricDefault;

Widget _loader(
  ValueNotifier<double> target, {
  Bar bar = _olympic,
  WeightUnit unit = WeightUnit.kg,
  bool haptics = false,
  ValueChanged<double>? onPick,
}) {
  return ValueListenableBuilder<double>(
    valueListenable: target,
    builder: (BuildContext context, double kg, Widget? _) => PlateLoader(
      result: PlateEngine.solve(targetKg: kg, bar: bar, inventory: _inv),
      targetKg: kg,
      bar: bar,
      unit: unit,
      haptics: haptics,
      onPickNearest: onPick,
    ),
  );
}

/// The plate outlines (design space) the loader would paint right now.
List<Rect> _plateRects(WidgetTester tester) {
  final PlateBarPainter painter = tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((CustomPaint p) => p.painter)
      .whereType<PlateBarPainter>()
      .first;
  final PlateGeometry g = PlateGeometry(painter.kind);
  final TestRecordingCanvas canvas = TestRecordingCanvas();
  painter.paint(canvas, Size(g.width, g.height));
  final List<Rect> out = <Rect>[];
  for (final RecordedInvocation r in canvas.invocations) {
    if (r.invocation.memberName != #drawRRect) continue;
    final Paint paint = r.invocation.positionalArguments[1] as Paint;
    if (paint.style != PaintingStyle.stroke) continue;
    out.add((r.invocation.positionalArguments[0] as RRect).outerRect);
  }
  return out;
}

List<String> _recordHaptics(WidgetTester tester) {
  final List<String> calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall c) async {
      if (c.method == 'HapticFeedback.vibrate') {
        calls.add(c.arguments as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

void main() {
  group('PlateLoader', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets('renders ${tone.name} with caption and a label', (
        WidgetTester tester,
      ) async {
        final ValueNotifier<double> t = ValueNotifier<double>(100);
        await pumpThemed(tester, _loader(t), tone: tone);
        expect(tester.takeException(), isNull);
        expect(
          find.text('Bar 20 kg · 40 kg per side: 25 + 15'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('100 kilograms: 25, 15 per side'),
          findsOneWidget,
        );
        // Two plates per side, drawn on both sides.
        expect(_plateRects(tester), hasLength(4));
      });
    }

    testWidgets('empty bar and handle only say so', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<double> t = ValueNotifier<double>(20);
      await pumpThemed(tester, _loader(t));
      expect(find.text('Empty bar · 20 kg'), findsOneWidget);
      expect(_plateRects(tester), isEmpty);
      final ValueNotifier<double> d = ValueNotifier<double>(2);
      await pumpThemed(tester, _loader(d, bar: _handle));
      await tester.pumpAndSettle();
      expect(find.text('Handle only · 2 kg'), findsOneWidget);
    });

    testWidgets('a dumbbell draws plates on its handle', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<double> t = ValueNotifier<double>(7);
      await pumpThemed(tester, _loader(t, bar: _handle));
      expect(find.text('Handle 2 kg · 2.5 kg per side: 2.5'), findsOneWidget);
      expect(_plateRects(tester), hasLength(2));
    });

    testWidgets('pounds: caption and label use the user unit', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<double> t = ValueNotifier<double>(100);
      await pumpThemed(tester, _loader(t, unit: WeightUnit.lb));
      expect(find.textContaining('lb per side'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('pounds')), findsOneWidget);
    });

    testWidgets('a change ends with the right plates after settling', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<double> t = ValueNotifier<double>(60);
      await pumpThemed(tester, _loader(t));
      expect(_plateRects(tester), hasLength(2));
      t.value = 100;
      await tester.pump();
      await tester.pumpAndSettle();
      expect(_plateRects(tester), hasLength(4));
      t.value = 20;
      await tester.pump();
      await tester.pumpAndSettle();
      expect(_plateRects(tester), isEmpty);
    });

    testWidgets('plates that stay do not move while others slide', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<double> t = ValueNotifier<double>(100);
      await pumpThemed(tester, _loader(t));
      final List<Rect> before = _plateRects(tester);
      expect(before, hasLength(4));
      // 110 kg: 45 per side = 25 + 20, so the 25 stays and the 15 swaps.
      t.value = 110;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final List<Rect> mid = _plateRects(tester);
      // Painted order per side: kept first. The 25 is the first plate drawn.
      expect(mid.first, before.first);
      await tester.pumpAndSettle();
      final List<Rect> after = _plateRects(tester);
      expect(after.first, before.first);
      expect(after, hasLength(4));
      // The entering plate does not sit where the old one did.
      expect(after[1].width, isNot(before[1].width));
    });

    testWidgets('entering plates slide in from outside and settle', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<double> t = ValueNotifier<double>(20);
      await pumpThemed(tester, _loader(t));
      t.value = 60;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      final Rect early = _plateRects(tester).first;
      await tester.pumpAndSettle();
      final Rect end = _plateRects(tester).first;
      // First plate on the left side: it starts further left than it ends.
      expect(early.left, lessThan(end.left));
    });

    testWidgets('reduced motion jumps straight to the end state', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<double> t = ValueNotifier<double>(60);
      await pumpThemed(tester, _loader(t), disableAnimations: true);
      t.value = 100;
      await tester.pump();
      expect(_plateRects(tester), hasLength(4));
    });

    testWidgets('a selection click per entering plate, none when off', (
      WidgetTester tester,
    ) async {
      final List<String> calls = _recordHaptics(tester);
      final ValueNotifier<double> t = ValueNotifier<double>(20);
      await pumpThemed(tester, _loader(t, haptics: true));
      t.value = 100;
      await tester.pump();
      await tester.pumpAndSettle();
      expect(
        calls.where((String c) => c == 'HapticFeedbackType.selectionClick'),
        hasLength(2),
      );
      calls.clear();
      await pumpThemed(tester, _loader(t));
      t.value = 20;
      await tester.pump();
      t.value = 100;
      await tester.pump();
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });

    group('edge states', () {
      testWidgets('not achievable shows the nearest weights as chips', (
        WidgetTester tester,
      ) async {
        final List<double> picked = <double>[];
        final ValueNotifier<double> t = ValueNotifier<double>(101);
        await pumpThemed(tester, _loader(t, onPick: picked.add));
        expect(
          find.textContaining("isn't possible with your plates"),
          findsOne,
        );
        expect(find.text('100 kg'), findsOneWidget);
        expect(find.text('102.5 kg'), findsOneWidget);
        await tester.tap(find.text('102.5 kg'));
        expect(picked, <double>[102.5]);
      });

      testWidgets('lighter than the bar', (WidgetTester tester) async {
        final ValueNotifier<double> t = ValueNotifier<double>(10);
        await pumpThemed(tester, _loader(t));
        expect(find.text('Lighter than the 20 kg bar'), findsOneWidget);
        expect(find.text('20 kg'), findsOneWidget);
      });

      testWidgets('over the most the plates can load', (
        WidgetTester tester,
      ) async {
        final ValueNotifier<double> t = ValueNotifier<double>(900);
        await pumpThemed(tester, _loader(t));
        expect(find.textContaining('More than your plates can load'), findsOne);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('a machine stack puts the pin at the target', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const PlateLoader.stack(targetKg: 45, stepKg: 5),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pin at 45 kg · plate 9 of 16'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Pin at 45 kilograms, plate 9 of 16'),
        findsOneWidget,
      );
    });

    testWidgets('a stack target between steps offers both neighbours', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const PlateLoader.stack(targetKg: 47, stepKg: 5),
      );
      expect(find.text('45 kg'), findsOneWidget);
      expect(find.text('50 kg'), findsOneWidget);
    });

    for (final Bar bar in <Bar>[_olympic, _handle]) {
      testWidgets('survives 200% text at 360dp (${bar.name})', (
        WidgetTester tester,
      ) async {
        final ValueNotifier<double> t = ValueNotifier<double>(
          bar.isDumbbell ? 8.5 : 101,
        );
        await pumpThemed(tester, _loader(t, bar: bar), textScale: 2);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('stack survives 200% text at 360dp', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const PlateLoader.stack(targetKg: 47, stepKg: 5),
        textScale: 2,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
