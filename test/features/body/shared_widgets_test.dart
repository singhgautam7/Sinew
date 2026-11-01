import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/widgets/sinew_marker_bar.dart';
import 'package:sinew/core/widgets/sinew_scrubber.dart';

import '../../widgets/harness.dart';

void main() {
  testWidgets('scrubber reports drags and labels its ends', (
    WidgetTester tester,
  ) async {
    double value = 0;
    await pumpThemed(
      tester,
      StatefulBuilder(
        builder: (BuildContext c, StateSetter set) => SinewScrubber(
          value: value,
          max: 4,
          semanticLabel: 'Compare date',
          semanticValue: '12 Jan',
          startLabel: '12 Jan',
          endLabel: '31 Oct',
          onChanged: (double v) => set(() => value = v),
        ),
      ),
    );
    expect(find.text('12 Jan'), findsOneWidget);
    expect(find.text('31 Oct'), findsOneWidget);
    await tester.drag(find.byType(Slider), const Offset(400, 0));
    await tester.pump();
    expect(value, 4);
  });

  testWidgets('scrubber fits 200% text at 360dp', (WidgetTester tester) async {
    await pumpThemed(
      tester,
      SinewScrubber(
        value: 1,
        max: 4,
        semanticLabel: 'Compare date',
        startLabel: '12 January 2025',
        endLabel: '31 October 2026',
        onChanged: (double _) {},
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('marker bar places the fill and the marker', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      const SizedBox(
        width: 200,
        child: SinewMarkerBar(
          value: 0.4,
          min: 0.2,
          max: 0.6,
          marker: 0.5,
          height: 8,
          markerWidth: 4,
          markerHeight: 20,
          semanticLabel: 'Waist to height 0.40, marker at 0.5',
        ),
      ),
    );
    final Finder positioned = find.descendant(
      of: find.byType(SinewMarkerBar),
      matching: find.byType(Positioned),
    );
    final List<Positioned> parts = tester
        .widgetList<Positioned>(positioned)
        .toList();
    // Track, fill (half of 200), marker (three quarters, centred).
    expect(parts[1].width, closeTo(100, 1e-6));
    expect(parts[2].left, closeTo(148, 1e-6));
  });
}
