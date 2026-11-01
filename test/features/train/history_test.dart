import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/widgets/domain/chart_card.dart';
import 'package:sinew/features/train/train_format.dart';

import 'train_env.dart';

void main() {
  late TrainEnv env;

  setUp(() async {
    env = await TrainEnv.create();
  });

  tearDown(() => env.dispose());

  testWidgets('history is empty at first', (WidgetTester tester) async {
    await env.pump(tester, Routes.history);
    expect(find.text('Nothing logged yet'), findsOneWidget);
    await env.unmount(tester);
  });

  testWidgets('history groups sessions by week and opens the detail', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.now();
    await env.seedSession(
      name: 'Push today',
      start: now.subtract(const Duration(minutes: 5)),
      sets: <(double, int)>[(60, 8), (60, 8)],
    );
    await env.seedSession(
      name: 'Old push',
      start: weekStart(now).subtract(const Duration(days: 3)),
      sets: <(double, int)>[(50, 8)],
    );
    await env.pump(tester, Routes.history, height: 1600);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('LAST WEEK'), findsOneWidget);
    expect(find.text('Push today'), findsOneWidget);
    expect(find.text('Old push'), findsOneWidget);

    await tester.tap(find.text('Push today'));
    await env.settle(tester);
    // Detail: summary stats and the sets.
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('60 kg × 8'), findsNWidgets(2));
    await env.unmount(tester);
  });

  testWidgets('history pages in as you scroll', (WidgetTester tester) async {
    final DateTime base = DateTime(2026, 1, 1, 9);
    for (int i = 0; i < 45; i++) {
      await env.seedSession(
        name: 'Session ${i.toString().padLeft(2, '0')}',
        start: base.add(Duration(days: i)),
      );
    }
    await env.pump(tester, Routes.history);
    // Newest first; the oldest is beyond the first page.
    expect(find.text('Session 44'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Session 00'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    expect(find.text('Session 00'), findsOneWidget);
    await env.unmount(tester);
  });

  testWidgets('editing a past set recomputes volume and records', (
    WidgetTester tester,
  ) async {
    await env.seedSession(
      name: 'First',
      start: DateTime(2026, 2, 1, 9),
      sets: <(double, int)>[(50, 8)],
      id: 'first',
    );
    await env.seedSession(
      name: 'Second',
      start: DateTime(2026, 2, 8, 9),
      sets: <(double, int)>[(60, 8)],
      id: 'second',
    );
    await env.pump(tester, Routes.session('second'));
    expect(find.text('60 kg × 8'), findsOneWidget);

    await tester.tap(find.text('60 kg × 8'));
    await env.settle(tester);
    expect(find.text('Edit set'), findsOneWidget);
    // Reps are the second stepper.
    await tester.tap(find.byKey(const ValueKey<String>('stepper-plus')).last);
    await env.settle(tester);
    await tester.tap(find.text('Save'));
    await env.settle(tester);

    expect(find.text('60 kg × 9'), findsOneWidget);
    final WorkoutSession second = (await env.sessions.byId('second'))!;
    expect(second.volumeKg, 60 * 9);
    // 60 kg beat 50 kg in the earlier session: it is a record.
    expect(second.exercises.single.sets.single.isPR, isTrue);
    await env.unmount(tester);
  });

  testWidgets('deleting a session asks first and can be undone', (
    WidgetTester tester,
  ) async {
    await env.seedSession(
      name: 'Doomed',
      start: DateTime.now().subtract(const Duration(minutes: 5)),
      id: 'doomed',
    );
    await env.pump(tester, Routes.history);
    await tester.tap(find.text('Doomed'));
    await env.settle(tester);
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await env.settle(tester);
    await tester.tap(find.text('Delete workout'));
    await env.settle(tester);
    expect(find.text('Delete this workout?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await env.settle(tester, 12);
    expect(await env.sessions.byId('doomed'), isNull);
    expect(find.text('Workout deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await env.settle(tester, 12);
    expect(await env.sessions.byId('doomed'), isNotNull);
    expect(find.text('Doomed'), findsOneWidget);
    await env.unmount(tester);
  });

  testWidgets('exercise history shows records, a chart and recent sessions', (
    WidgetTester tester,
  ) async {
    final List<(double, int)> loads = <(double, int)>[
      (60, 8),
      (65, 8),
      (70, 6),
      (72.5, 5),
    ];
    for (int i = 0; i < loads.length; i++) {
      await env.seedSession(
        name: 'Day $i',
        start: DateTime(2026, 1, 5 + i * 7, 9),
        sets: <(double, int)>[loads[i]],
        id: 'h$i',
      );
    }
    await env.pump(tester, Routes.exerciseHistory('custom-bench'));
    expect(find.text('Bench press'), findsWidgets);
    expect(find.byType(ChartCard), findsOneWidget);
    expect(find.text('Estimated 1RM'), findsOneWidget);
    expect(find.text('Heaviest'), findsOneWidget);
    expect(find.text('72.5 kg'), findsWidgets);
    expect(find.text('Sessions'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('RECORDS'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Heaviest weight'), findsOneWidget);
    expect(find.text('Best estimated 1RM'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('RECENT'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('RECENT'), findsOneWidget);

    // The range chips filter the chart without breaking it.
    await tester.dragUntilVisible(
      find.text('3M'),
      find.byType(ListView),
      const Offset(0, 200),
    );
    await tester.tap(find.text('3M'));
    await env.settle(tester);
    expect(tester.takeException(), isNull);
    await env.unmount(tester);
  });

  testWidgets('an exercise with no history says so', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, Routes.exerciseHistory('custom-pullup'));
    expect(find.text('No history yet'), findsOneWidget);
    await env.unmount(tester);
  });
}
