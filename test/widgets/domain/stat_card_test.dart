import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/app_icon_button.dart';
import 'package:sinew/core/widgets/domain/stat_card.dart';
import 'package:sinew/core/widgets/sinew_list.dart';
import 'package:sinew/core/widgets/sinew_states.dart';
import 'package:sinew/engines/body_stats/stat_result.dart';

import '../harness.dart';

String _f(double v) => v.toStringAsFixed(1);

StatCard<double> _bmi({
  StatResult<double> result = const StatValue<double>(23.4),
  VoidCallback? onInfo,
  VoidCallback? onTap,
  VoidCallback? onAction,
  bool compact = false,
  StatDelta? delta,
}) => StatCard<double>(
  label: 'BMI',
  result: result,
  format: _f,
  unit: 'kg/m2',
  category: 'Normal',
  delta: delta,
  caption: 'WHO cut-offs',
  onInfo: onInfo,
  onTap: onTap,
  onLockedAction: onAction,
  compact: compact,
);

void main() {
  group('input words', () {
    test('every input has plain words', () {
      expect(statInputLabel(StatInput.activityLevel), 'activity level');
      expect(statInputLabel(StatInput.bodyFat), 'body fat');
      for (final StatInput i in StatInput.values) {
        expect(statInputLabel(i), isNotEmpty);
      }
    });

    test('lists read as sentences', () {
      expect(describeStatInputs(<StatInput>[StatInput.waist]), 'waist');
      expect(
        describeStatInputs(<StatInput>[StatInput.waist, StatInput.neck]),
        'waist and neck',
      );
      expect(
        describeStatInputs(<StatInput>[
          StatInput.weight,
          StatInput.height,
          StatInput.age,
        ]),
        'weight, height and age',
      );
      expect(
        lockedStatMessage(<StatInput>[StatInput.waist, StatInput.neck]),
        'Add your waist and neck to see this.',
      );
    });
  });

  group('StatCard', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets(
        'shows the value, unit, category and caption in ${tone.name}',
        (WidgetTester tester) async {
          await pumpThemed(
            tester,
            SizedBox(width: 328, child: _bmi(onInfo: () {})),
            tone: tone,
          );
          expect(find.text('BMI'), findsOneWidget);
          expect(find.text('23.4'), findsOneWidget);
          expect(find.text('kg/m2'), findsOneWidget);
          expect(find.text('Normal'), findsOneWidget);
          expect(find.text('WHO cut-offs'), findsOneWidget);
          expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
        },
      );
    }

    testWidgets('the info button reports a tap and is labelled', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(
        tester,
        SizedBox(width: 328, child: _bmi(onInfo: () => taps++)),
      );
      expect(find.bySemanticsLabel(RegExp('About BMI')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      expect(taps, 1);
      h.dispose();
    });

    testWidgets('the info button is a 48dp target', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(width: 328, child: _bmi(onInfo: () {})),
      );
      final Size s = tester.getSize(find.byType(AppIconButton));
      expect(s.width, greaterThanOrEqualTo(48));
      expect(s.height, greaterThanOrEqualTo(48));
    });

    testWidgets('approximate and estimated values wear badges', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: StatCard<double>(
            label: 'Maintenance',
            result: const StatValue<double>(
              2690,
              approximate: true,
              estimated: true,
            ),
            format: (double v) => v.toStringAsFixed(0),
            unit: 'kcal/day',
          ),
        ),
      );
      expect(find.text('Approximate'), findsOneWidget);
      expect(find.text('Estimate'), findsOneWidget);
      expect(find.byType(SinewPill), findsNWidgets(2));
    });

    testWidgets('a delta shows its text', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: _bmi(
            delta: const StatDelta('-0.6 vs last entry', trend: StatTrend.down),
          ),
        ),
      );
      expect(find.text('-0.6 vs last entry'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });

    testWidgets('tapping the card calls onTap', (WidgetTester tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        SizedBox(width: 328, child: _bmi(onTap: () => taps++)),
      );
      await tester.tap(find.text('23.4'));
      expect(taps, 1);
    });

    testWidgets('a footer slot sits under the value', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 328,
          child: StatCard<double>(
            label: 'BMI',
            result: StatValue<double>(23.4),
            format: _f,
            footer: Text('band'),
          ),
        ),
      );
      expect(find.text('band'), findsOneWidget);
    });
  });

  group('locked and invalid', () {
    testWidgets('lists exactly what is missing, in words', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: StatCard<double>(
            label: 'Body fat %',
            result: const MissingInputs<double>(<StatInput>[
              StatInput.waist,
              StatInput.neck,
            ]),
            format: _f,
            onLockedAction: () {},
          ),
        ),
      );
      expect(find.text('Add your waist and neck to see this.'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('Add measurements'), findsOneWidget);
    });

    testWidgets('three inputs read as a list', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 328,
          child: StatCard<double>(
            label: 'Maintenance',
            result: MissingInputs<double>(<StatInput>[
              StatInput.weight,
              StatInput.height,
              StatInput.activityLevel,
            ]),
            format: _f,
          ),
        ),
      );
      expect(
        find.text('Add your weight, height and activity level to see this.'),
        findsOneWidget,
      );
      // No action given: no button.
      expect(find.byType(TextButton), findsNothing);
      expect(find.text('Add measurements'), findsNothing);
    });

    testWidgets('the action callback fires', (WidgetTester tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: _bmi(
            result: const MissingInputs<double>(<StatInput>[
              StatInput.weight,
              StatInput.height,
            ]),
            onAction: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('Add measurements'));
      expect(taps, 1);
    });

    testWidgets('a locked card is announced as locked', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: _bmi(
            result: const MissingInputs<double>(<StatInput>[StatInput.height]),
          ),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Locked')), findsOneWidget);
      h.dispose();
    });

    testWidgets('invalid inputs name what to check', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 328,
          child: _bmi(
            result: const InvalidInputs<double>(<StatInput>[
              StatInput.waist,
              StatInput.neck,
            ]),
            onAction: () {},
          ),
        ),
      );
      expect(find.textContaining('Check your waist and neck'), findsOneWidget);
      expect(find.text('Review measurements'), findsOneWidget);
    });

    testWidgets('compact locked card says what it needs, in one line', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        SizedBox(
          width: StatSpec.compactMinWidth,
          child: _bmi(
            result: const MissingInputs<double>(<StatInput>[
              StatInput.weight,
              StatInput.height,
            ]),
            compact: true,
            onAction: () => taps++,
          ),
        ),
      );
      expect(find.text('Needs weight and height'), findsOneWidget);
      await tester.tap(find.text('Needs weight and height'));
      expect(taps, 1);
    });
  });

  group('compact and loading', () {
    testWidgets('compact shows only label, value and unit', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(width: StatSpec.compactMinWidth, child: _bmi(compact: true)),
      );
      expect(find.text('23.4'), findsOneWidget);
      expect(find.text('Normal'), findsNothing);
      expect(find.text('WHO cut-offs'), findsNothing);
    });

    testWidgets('the loading card is a skeleton', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 328,
          child: StatCard<double>.loading(label: 'BMI'),
        ),
      );
      expect(find.byType(SinewSkeleton), findsNWidgets(2));
      expect(find.text('23.4'), findsNothing);
      await pumpThemed(
        tester,
        const SizedBox(
          width: 140,
          child: StatCard<double>.loading(label: 'BMI', compact: true),
        ),
        disableAnimations: true,
      );
      expect(find.byType(SinewSkeleton), findsNWidgets(2));
    });
  });

  group('text scale', () {
    for (final StatResult<double> r in <StatResult<double>>[
      const StatValue<double>(1234567.5, approximate: true, estimated: true),
      const MissingInputs<double>(<StatInput>[
        StatInput.weight,
        StatInput.height,
        StatInput.age,
        StatInput.sex,
        StatInput.activityLevel,
      ]),
    ]) {
      testWidgets('${r.runtimeType} at 200% on a 360dp phone', (
        WidgetTester tester,
      ) async {
        await pumpThemed(
          tester,
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                _bmi(
                  result: r,
                  onInfo: () {},
                  onAction: () {},
                  delta: const StatDelta('-0.6 kg since 24 Oct'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(child: _bmi(result: r, compact: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _bmi(result: r, compact: true)),
                  ],
                ),
              ],
            ),
          ),
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
