import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/widgets/app_button.dart';
import 'package:sinew/core/widgets/domain/chart_card.dart';
import 'package:sinew/core/widgets/domain/silhouette_view.dart';
import 'package:sinew/core/widgets/sinew_scrubber.dart';

import 'body_harness.dart';

const Profile _male = Profile(sex: Sex.male, heightCm: 178);

Future<void> _seedHistory(WidgetTester tester, UserDatabase database) =>
    db(tester, () async {
      final repo = measurementsOf(database);
      await repo.saveEntry(
        entryOf('a', DateTime(2026, 1, 12), <String, double>{
          'waist': 92,
          'hips': 103,
          'chest': 101,
          'shoulders': 116,
          'neck': 40,
          'weight': 85,
        }),
      );
      await repo.saveEntry(
        entryOf('b', DateTime(2026, 8, 23), <String, double>{
          'waist': 86.5,
          'hips': 100,
          'chest': 102,
          'shoulders': 118,
          'neck': 39,
          'weight': 80,
        }),
      );
      await repo.saveEntry(
        entryOf('c', DateTime(2026, 10, 24), <String, double>{
          'waist': 85,
          'hips': 99,
        }),
      );
      await repo.saveEntry(
        entryOf('d', DateTime(2026, 10, 30), <String, double>{
          'waist': 84,
          'hips': 98,
        }),
      );
    });

ChartCard _chart(WidgetTester tester) =>
    tester.widget<ChartCard>(find.byType(ChartCard));

void main() {
  bodyTest('progress draws the points, latest value and change', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await _seedHistory(tester, database);
    final GoRouter router = await pumpBody(tester, database, profile: _male);
    await pushRoute(tester, router, Routes.progress('waist'));

    final ChartCard chart = _chart(tester);
    expect(chart.primary.points.map((ChartPoint p) => p.value), <double>[
      92,
      86.5,
      85,
      84,
    ]);
    expect(chart.latestLabel, '84 cm');
    expect(chart.deltaLabel, '−8 cm since 12 Jan');
    // The 0.5 of height line is the waist reference.
    expect(chart.reference!.value, 89);
    // Entries list newest first, with the change against the older value.
    expect(find.text('30 Oct'), findsOneWidget);
    expect(find.text('−1'), findsOneWidget);
  });

  bodyTest('range chips filter the points', (WidgetTester tester) async {
    final UserDatabase database = await seededDb(tester);
    await _seedHistory(tester, database);
    final GoRouter router = await pumpBody(tester, database, profile: _male);
    await pushRoute(tester, router, Routes.progress('waist'));

    await tester.tap(find.text('1M'));
    await settle(tester);
    expect(
      _chart(tester).primary.points.map((ChartPoint p) => p.value),
      <double>[85, 84],
    );
    expect(_chart(tester).deltaLabel, '−1 cm since 24 Oct');
    await tester.tap(find.text('All'));
    await settle(tester);
    expect(_chart(tester).primary.points, hasLength(4));
  });

  bodyTest('progress shows values in inches and an entry opens its editor', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await _seedHistory(tester, database);
    final GoRouter router = await pumpBody(
      tester,
      database,
      profile: _male.copyWith(lengthUnit: LengthUnit.inch),
    );
    await pushRoute(tester, router, Routes.progress('waist'));
    expect(_chart(tester).latestLabel, '33.1 in');
    expect(_chart(tester).primary.points.last.value, closeTo(84 / 2.54, 1e-9));

    await reveal(tester, find.text('30 Oct'));
    await tester.tap(find.text('30 Oct'));
    await settle(tester);
    expect(find.text('Edit entry'), findsOneWidget);
  });

  bodyTest('a field with no entries offers to add one', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.progress('calf-left'));
    expect(find.text('Add left calf'), findsOneWidget);
    expect(_chart(tester).primary.points, isEmpty);
  });

  bodyTest('progress lays out at 200% text', (WidgetTester tester) async {
    final UserDatabase database = await seededDb(tester);
    await _seedHistory(tester, database);
    final GoRouter router = await pumpBody(
      tester,
      database,
      textScale: 2,
      profile: _male,
    );
    await pushRoute(tester, router, Routes.progress('waist'));
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  bodyTest('compare morphs between dates and tabulates the change', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await _seedHistory(tester, database);
    final GoRouter router = await pumpBody(tester, database, profile: _male);
    await pushRoute(tester, router, Routes.compare);

    expect(find.text('Compare'), findsWidgets);
    SilhouetteView view() =>
        tester.widget<SilhouetteView>(find.byType(SilhouetteView));
    expect(view().compareGeometry, isNotNull);
    final double waistNow = view().geometry.level(BodyAnchor.waist)!.valueCm;
    final double waistThen = view().compareGeometry!
        .level(BodyAnchor.waist)!
        .valueCm;
    expect(waistThen, 92);
    expect(waistNow, 84);

    // Waist 92 to 84: the table shows both values and the change.
    expect(find.text('12 JAN'), findsOneWidget);
    expect(find.text('30 OCT'), findsOneWidget);
    expect(find.text('−8'), findsOneWidget);

    // Dragging the scrubber to the start morphs the "to" shape back.
    final Finder scrubber = find.byType(SinewScrubber);
    await tester.drag(scrubber, const Offset(-600, 0));
    await settle(tester);
    expect(view().geometry.level(BodyAnchor.waist)!.valueCm, 92);
    expect(find.text('+0'), findsNothing);
  });

  bodyTest('compare with fewer than two entries explains itself', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await db(
      tester,
      () => measurementsOf(database).saveEntry(
        entryOf('a', DateTime(2026, 10, 30), <String, double>{'waist': 84}),
      ),
    );
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.compare);
    expect(find.text('Two entries to compare'), findsOneWidget);
  });

  bodyTest('compare jumps under reduced motion and fits 200% text', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await _seedHistory(tester, database);
    final GoRouter router = await pumpBody(
      tester,
      database,
      textScale: 2,
      profile: _male,
      disableAnimations: true,
    );
    await pushRoute(tester, router, Routes.compare);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  bodyTest('compare lives in the header, not a button the FAB can cover', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await _seedHistory(tester, database);
    await pumpBody(tester, database, profile: _male);
    expect(find.bySemanticsLabel('Compare dates'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Compare dates'), findsNothing);
    await tester.tap(find.byIcon(Icons.compare_rounded));
    await settle(tester);
    // The Compare screen is open.
    expect(find.byType(SinewScrubber), findsOneWidget);
  });
}
