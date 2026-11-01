import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/chart_card.dart';
import 'package:sinew/core/widgets/sinew_states.dart';

import '../harness.dart';

List<ChartPoint> _points([int n = 6, double start = 92]) => <ChartPoint>[
  for (int i = 0; i < n; i++)
    ChartPoint(DateTime(2026, 5 + i, 12), start - i * 1.6),
];

ChartCard _card({
  List<ChartPoint>? points,
  ChartSeries? secondary,
  ChartRange? range = ChartRange.month6,
  ValueChanged<ChartRange>? onRange,
  ChartReference? reference,
  String? delta = '-8.0 cm since 12 May',
}) => ChartCard(
  title: 'Waist',
  subtitle: 'Last 6 months',
  primary: ChartSeries(label: 'Waist', points: points ?? _points()),
  secondary: secondary,
  latestLabel: '84.0 cm',
  deltaLabel: delta,
  range: range,
  onRangeChanged: onRange ?? (ChartRange _) {},
  reference: reference,
);

LineChartData _data(WidgetTester tester) =>
    tester.widget<LineChart>(find.byType(LineChart)).data;

void main() {
  group('ChartCard', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets(
        'renders the header and one point per entry in ${tone.name}',
        (WidgetTester tester) async {
          await pumpThemed(
            tester,
            SizedBox(width: 328, child: _card()),
            tone: tone,
          );
          expect(find.text('Waist'), findsOneWidget);
          expect(find.text('Last 6 months'), findsOneWidget);
          expect(find.text('84.0 cm'), findsOneWidget);
          expect(find.text('-8.0 cm since 12 May'), findsOneWidget);
          final LineChartData d = _data(tester);
          expect(d.lineBarsData, hasLength(1));
          expect(d.lineBarsData.first.spots, hasLength(6));
          expect(d.lineBarsData.first.spots.first.y, 92);
        },
      );
    }

    testWidgets('without a latest label it formats the last point', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: ChartCard(
            title: 'Weight',
            primary: ChartSeries(label: 'Weight', points: _points(3, 80)),
            valueFormat: (double v) => '${v.toStringAsFixed(1)} kg',
          ),
        ),
      );
      expect(find.text('76.8 kg'), findsOneWidget);
    });

    testWidgets('points are sorted by date', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        SizedBox(width: 328, child: _card(points: _points().reversed.toList())),
      );
      final List<FlSpot> spots = _data(tester).lineBarsData.first.spots;
      for (int i = 1; i < spots.length; i++) {
        expect(spots[i].x, greaterThan(spots[i - 1].x));
      }
    });

    testWidgets('a second series is a second line with a legend', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: _card(
            secondary: ChartSeries(label: 'Hips', points: _points(6, 100)),
          ),
        ),
      );
      final LineChartData d = _data(tester);
      expect(d.lineBarsData, hasLength(2));
      expect(d.lineBarsData[1].color, isNot(d.lineBarsData[0].color));
      expect(find.text('Hips'), findsOneWidget);
    });

    testWidgets(
      'a reference line is drawn and widens the range to include it',
      (WidgetTester tester) async {
        await pumpThemed(
          tester,
          SizedBox(
            width: 328,
            child: _card(
              points: <ChartPoint>[
                ChartPoint(DateTime(2026, 5), 0.52),
                ChartPoint(DateTime(2026, 6), 0.55),
              ],
              reference: const ChartReference(value: 0.5, label: '0.5'),
            ),
          ),
        );
        final LineChartData d = _data(tester);
        expect(d.extraLinesData.horizontalLines, hasLength(1));
        expect(d.extraLinesData.horizontalLines.first.y, 0.5);
        expect(d.minY, lessThan(0.5));
      },
    );

    testWidgets('a single point still draws', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        SizedBox(width: 328, child: _card(points: _points(1))),
      );
      expect(_data(tester).lineBarsData.first.spots, hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('many points draw only the last dot', (
      WidgetTester tester,
    ) async {
      final List<ChartPoint> many = <ChartPoint>[
        for (int i = 0; i < 100; i++)
          ChartPoint(DateTime(2026, 1, 1).add(Duration(days: i)), 80 + i % 7),
      ];
      await pumpThemed(
        tester,
        SizedBox(width: 328, child: _card(points: many)),
      );
      final LineChartBarData bar = _data(tester).lineBarsData.first;
      expect(bar.spots, hasLength(100));
      expect(bar.dotData.checkToShowDot(bar.spots.first, bar), isFalse);
      expect(bar.dotData.checkToShowDot(bar.spots.last, bar), isTrue);
    });
  });

  group('range selector', () {
    testWidgets('lists the five ranges and reports a pick', (
      WidgetTester tester,
    ) async {
      ChartRange? picked;
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: _card(onRange: (ChartRange r) => picked = r),
        ),
      );
      for (final String l in <String>['1M', '3M', '6M', '1Y', 'All']) {
        expect(find.text(l), findsOneWidget);
      }
      await tester.tap(find.text('3M'));
      await tester.pump();
      expect(picked, ChartRange.month3);
      await tester.tap(find.text('All'));
      await tester.pump();
      expect(picked, ChartRange.all);
    });

    testWidgets('no range hides the selector', (WidgetTester tester) async {
      await pumpThemed(tester, SizedBox(width: 328, child: _card(range: null)));
      expect(find.text('3M'), findsNothing);
    });
  });

  group('empty and loading', () {
    testWidgets('empty shows the message and no chart', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: _card(points: const <ChartPoint>[], delta: null),
        ),
      );
      expect(find.text('No entries yet'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
      // The selector stays so a longer range can be tried.
      expect(find.text('1Y'), findsOneWidget);
    });

    testWidgets('loading is a skeleton', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        const SizedBox(width: 328, child: ChartCard.loading(title: 'Waist')),
      );
      expect(find.byType(SinewSkeleton), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });
  });

  group('accessibility', () {
    testWidgets('the plot is summarised in text', (WidgetTester tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(tester, SizedBox(width: 328, child: _card()));
      expect(
        find.bySemanticsLabel(
          RegExp(
            r'Waist chart\. Latest 84\.0 cm, -8\.0 cm since 12 May\. '
            r'6 entries from 12 May to 12 Oct\. Showing six months',
          ),
        ),
        findsOneWidget,
      );
      h.dispose();
    });

    test('the summary of an empty chart says so', () {
      expect(
        _card(points: const <ChartPoint>[]).summary(),
        'Waist chart. No entries yet',
      );
    });

    testWidgets('200% text on a 360dp phone does not overflow', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _card(
                secondary: ChartSeries(label: 'Hips', points: _points()),
              ),
              _card(points: const <ChartPoint>[]),
            ],
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion draws without animation', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(width: 328, child: _card()),
        disableAnimations: true,
      );
      expect(
        tester.widget<LineChart>(find.byType(LineChart)).duration,
        Duration.zero,
      );
    });
  });
}
