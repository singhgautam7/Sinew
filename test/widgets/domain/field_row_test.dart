import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/field_row.dart';
import 'package:sinew/core/widgets/sinew_menu.dart';

import '../harness.dart';

Finder get _field => find.byType(TextField);

String _text(WidgetTester tester) =>
    tester.widget<TextField>(_field.first).controller!.text;

void main() {
  group('FieldUnit', () {
    test('length converts both ways at the edge', () {
      final FieldUnit inch = FieldUnit.length(LengthUnit.inch);
      expect(inch.label, 'in');
      expect(inch.toDisplay(25.4), closeTo(10, 1e-9));
      expect(inch.toMetric(10), closeTo(25.4, 1e-9));
      expect(inch.format(25.4), '10');
      final FieldUnit cm = FieldUnit.length(LengthUnit.cm);
      expect(cm.format(84), '84');
      expect(cm.format(84.25), '84.3');
    });

    test('weight and plain', () {
      final FieldUnit lb = FieldUnit.weight(WeightUnit.lb);
      expect(lb.toMetric(100), closeTo(45.359237, 1e-9));
      expect(FieldUnit.plain('%').toMetric(18.5), 18.5);
      expect(FieldUnit.plain('%').label, '%');
    });
  });

  group('FieldRow', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets('shows name, unit and the value in ${tone.name}', (
        WidgetTester tester,
      ) async {
        await pumpThemed(
          tester,
          FieldRow(
            name: 'Waist',
            unit: FieldUnit.length(LengthUnit.cm),
            valueMetric: 84,
            previousMetric: 85,
            previousLabel: '24 Oct',
            deltaText: '-1.0',
            onChanged: (double? _) {},
          ),
          tone: tone,
        );
        expect(find.text('Waist'), findsOneWidget);
        expect(find.textContaining('cm'), findsWidgets);
        expect(_text(tester), '84');
        expect(find.textContaining('last 85, 24 Oct'), findsOneWidget);
        expect(find.text('-1.0'), findsOneWidget);
      });
    }

    testWidgets('typing in inches reports centimetres', (
      WidgetTester tester,
    ) async {
      final List<double?> got = <double?>[];
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Waist',
          unit: FieldUnit.length(LengthUnit.inch),
          onChanged: got.add,
        ),
      );
      await tester.enterText(_field, '10');
      expect(got.last, closeTo(25.4, 1e-9));
      await tester.enterText(_field, '33.5');
      expect(got.last, closeTo(85.09, 1e-9));
    });

    testWidgets('shows a stored value in the display unit', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Weight',
          unit: FieldUnit.weight(WeightUnit.lb),
          valueMetric: 45.359237,
          onChanged: (double? _) {},
        ),
      );
      expect(_text(tester), '100');
    });

    testWidgets('clearing the box reports null; a comma counts as a point', (
      WidgetTester tester,
    ) async {
      final List<double?> got = <double?>[];
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Waist',
          unit: FieldUnit.length(LengthUnit.cm),
          valueMetric: 84,
          onChanged: got.add,
        ),
      );
      await tester.enterText(_field, '');
      expect(got.last, isNull);
      await tester.enterText(_field, '84,5');
      expect(got.last, 84.5);
    });

    testWidgets('letters are not accepted', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Waist',
          unit: FieldUnit.length(LengthUnit.cm),
          onChanged: (double? _) {},
        ),
      );
      await tester.enterText(_field, 'ab12');
      expect(_text(tester), '12');
    });

    testWidgets('the previous value is the hint when the box is empty', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Neck',
          unit: FieldUnit.length(LengthUnit.cm),
          previousMetric: 39,
          onChanged: (double? _) {},
        ),
      );
      expect(_text(tester), '');
      expect(find.text('39'), findsOneWidget);
    });

    testWidgets('a new value from the parent replaces the text', (
      WidgetTester tester,
    ) async {
      Widget row(double? v) => FieldRow(
        name: 'Waist',
        unit: FieldUnit.length(LengthUnit.cm),
        valueMetric: v,
        onChanged: (double? _) {},
      );
      await pumpThemed(tester, row(84));
      expect(_text(tester), '84');
      await pumpThemed(tester, row(80.5));
      expect(_text(tester), '80.5');
      await pumpThemed(tester, row(null));
      expect(_text(tester), '');
    });

    testWidgets('switching unit rewrites the text in the new unit', (
      WidgetTester tester,
    ) async {
      Widget row(LengthUnit u) => FieldRow(
        name: 'Waist',
        unit: FieldUnit.length(u),
        valueMetric: 25.4,
        onChanged: (double? _) {},
      );
      await pumpThemed(tester, row(LengthUnit.cm));
      expect(_text(tester), '25.4');
      await pumpThemed(tester, row(LengthUnit.inch));
      expect(_text(tester), '10');
    });

    testWidgets('echoing back what was typed does not disturb the box', (
      WidgetTester tester,
    ) async {
      late StateSetter set;
      double? value;
      await pumpThemed(
        tester,
        StatefulBuilder(
          builder: (BuildContext c, StateSetter s) {
            set = s;
            return FieldRow(
              name: 'Waist',
              unit: FieldUnit.length(LengthUnit.inch),
              valueMetric: value,
              onChanged: (double? v) => set(() => value = v),
            );
          },
        ),
      );
      await tester.enterText(_field, '13.');
      await tester.pump();
      expect(_text(tester), '13.');
      await tester.enterText(_field, '13.6');
      await tester.pump();
      expect(_text(tester), '13.6');
    });

    testWidgets('the side tag reads L or R and is spoken in the label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Bicep',
          unit: FieldUnit.length(LengthUnit.cm),
          side: BodySide.left,
          onChanged: (double? _) {},
        ),
      );
      expect(find.text('L'), findsOneWidget);
      expect(find.text('R'), findsNothing);
      expect(find.bySemanticsLabel('Bicep left, cm'), findsOneWidget);
      h.dispose();
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Bicep',
          unit: FieldUnit.length(LengthUnit.cm),
          side: BodySide.right,
          onChanged: (double? _) {},
        ),
      );
      expect(find.text('R'), findsOneWidget);
    });

    testWidgets('estimated shows a pill and muted text', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Neck',
          unit: FieldUnit.length(LengthUnit.cm),
          valueMetric: 39,
          estimated: true,
          onChanged: (double? _) {},
        ),
      );
      expect(find.text('Estimated'), findsOneWidget);
    });

    testWidgets('disabled ignores input', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Neck',
          unit: FieldUnit.length(LengthUnit.cm),
          enabled: false,
          onChanged: (double? _) {},
        ),
      );
      expect(tester.widget<TextField>(_field).enabled, isFalse);
    });

    testWidgets('the box is at least 48dp tall', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        FieldRow(
          name: 'Neck',
          unit: FieldUnit.length(LengthUnit.cm),
          onChanged: (double? _) {},
        ),
      );
      expect(tester.getSize(_field).height, greaterThanOrEqualTo(48));
    });

    testWidgets('200% text drops the box under the name, no overflow', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FieldRow(
                name: 'Upper arm circumference',
                unit: FieldUnit.length(LengthUnit.cm),
                valueMetric: 102.5,
                previousMetric: 101.5,
                previousLabel: '24 Oct',
                deltaText: '+1.0',
                side: BodySide.left,
                estimated: true,
                onChanged: (double? _) {},
              ),
              FieldPairRow(
                name: 'Thigh',
                unit: FieldUnit.length(LengthUnit.cm),
                leftMetric: 57,
                rightMetric: 57.5,
                onLeftChanged: (double? _) {},
                onRightChanged: (double? _) {},
              ),
            ],
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsNWidgets(3));
    });
  });

  group('FieldPairRow', () {
    testWidgets('has a box per side and reports each in metric', (
      WidgetTester tester,
    ) async {
      double? left;
      double? right;
      await pumpThemed(
        tester,
        FieldPairRow(
          name: 'Bicep',
          unit: FieldUnit.length(LengthUnit.inch),
          onLeftChanged: (double? v) => left = v,
          onRightChanged: (double? v) => right = v,
        ),
      );
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('left · in'), findsOneWidget);
      expect(find.text('right · in'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '10');
      await tester.enterText(find.byType(TextField).last, '20');
      expect(left, closeTo(25.4, 1e-9));
      expect(right, closeTo(50.8, 1e-9));
    });
  });

  group('FieldManagerRow', () {
    Widget row({
      bool enabled = true,
      bool paired = false,
      ValueChanged<bool>? onEnabled,
      List<SinewMenuEntry<String>> overflow = const <SinewMenuEntry<String>>[],
      ValueChanged<String>? onOverflow,
      Widget? handle,
    }) => FieldManagerRow(
      name: 'Bicep',
      meta: 'cm · Silhouette: upper arm',
      fieldEnabled: enabled,
      paired: paired,
      onEnabledChanged: onEnabled ?? (bool _) {},
      overflow: overflow,
      onOverflow: onOverflow,
      dragHandle: handle,
    );

    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets('shows name, meta, tag, handle and switch in ${tone.name}', (
        WidgetTester tester,
      ) async {
        await pumpThemed(tester, row(paired: true), tone: tone);
        expect(find.text('Bicep'), findsOneWidget);
        expect(find.text('cm · Silhouette: upper arm'), findsOneWidget);
        expect(find.text('L / R'), findsOneWidget);
        expect(find.byIcon(Icons.drag_indicator_rounded), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
      });
    }

    testWidgets('the switch reports the new state', (
      WidgetTester tester,
    ) async {
      bool? got;
      await pumpThemed(tester, row(onEnabled: (bool v) => got = v));
      await tester.tap(find.byType(Switch));
      expect(got, isFalse);
    });

    testWidgets('the switch is named for TalkBack', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(tester, row());
      expect(
        find.bySemanticsLabel('Show Bicep on new entries'),
        findsOneWidget,
      );
      h.dispose();
    });

    testWidgets('a custom drag handle takes the slot', (
      WidgetTester tester,
    ) async {
      await pumpThemed(tester, row(handle: const Icon(Icons.menu)));
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.drag_indicator_rounded), findsNothing);
    });

    testWidgets('the overflow menu reports the picked entry', (
      WidgetTester tester,
    ) async {
      String? picked;
      await pumpThemed(
        tester,
        row(
          overflow: const <SinewMenuEntry<String>>[
            SinewMenuEntry<String>(value: 'edit', label: 'Edit'),
            SinewMenuEntry<String>(value: 'hide', label: 'Hide field'),
          ],
          onOverflow: (String v) => picked = v,
        ),
      );
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide field'));
      await tester.pumpAndSettle();
      expect(picked, 'hide');
    });

    testWidgets('no overflow entries means no overflow button', (
      WidgetTester tester,
    ) async {
      await pumpThemed(tester, row());
      expect(find.byIcon(Icons.more_vert_rounded), findsNothing);
    });

    testWidgets('200% text on a 360dp phone does not overflow', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SingleChildScrollView(
          child: row(
            paired: true,
            overflow: const <SinewMenuEntry<String>>[
              SinewMenuEntry<String>(value: 'edit', label: 'Edit'),
            ],
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
