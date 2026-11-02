import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/nav_visibility.dart';
import 'package:sinew/core/routing/router.dart';

import 'train_env.dart';

void main() {
  late TrainEnv env;

  setUp(() async {
    env = await TrainEnv.create();
  });

  tearDown(() => env.dispose());

  testWidgets('empty routines, create one with the picker, it appears', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, Routes.train);
    expect(find.text('No routines yet'), findsOneWidget);

    await tester.tap(find.text('New routine').first);
    await env.settle(tester);
    expect(find.text('New routine'), findsWidgets);
    // The editor hides the nav.
    expect(
      env.container(tester).read(navHideReasonsProvider),
      contains(NavHideReason.fullScreen),
    );

    await tester.enterText(find.byType(TextField).first, 'Upper A');
    env.pick = <String>['custom-bench', 'custom-pullup'];
    await tester.tap(find.text('Add exercise'));
    await env.settle(tester);
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Pull-up'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await env.settle(tester);
    expect(find.text('Upper A'), findsOneWidget);
    expect(find.textContaining('2 exercises'), findsOneWidget);
    expect(
      env.container(tester).read(navHideReasonsProvider),
      isNot(contains(NavHideReason.fullScreen)),
    );

    final List<Routine> saved = await env
        .container(tester)
        .read(routineRepositoryProvider)
        .allWithItems();
    expect(saved.single.name, 'Upper A');
    expect(saved.single.items.map((RoutineItem i) => i.exerciseId), <String>[
      'custom-bench',
      'custom-pullup',
    ]);
    await env.unmount(tester);
  });

  testWidgets('a routine needs a name', (WidgetTester tester) async {
    await env.pump(tester, Routes.newRoutine);
    await tester.tap(find.text('Save'));
    await env.settle(tester);
    expect(find.text('Give the routine a name'), findsOneWidget);
    await env.unmount(tester);
  });

  testWidgets('targets, superset and removing items in the editor', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, Routes.newRoutine, height: 1600);
    await tester.enterText(find.byType(TextField).first, 'Push');
    env.pick = <String>['custom-bench', 'custom-pullup'];
    await tester.tap(find.text('Add exercise'));
    await env.settle(tester);

    // Open the first item and link it with the next.
    await tester.tap(find.text('Bench press'));
    await env.settle(tester);
    await tester.tap(find.text('Superset with next'));
    await env.settle(tester);
    expect(find.text('Unlink superset'), findsOneWidget);
    expect(find.text('Superset'), findsNWidgets(2));

    // Add a set: the stepper plus button.
    final Finder plus = find.byKey(const ValueKey<String>('stepper-plus'));
    await tester.ensureVisible(plus.first);
    await tester.tap(plus.first);
    await env.settle(tester);
    expect(find.textContaining('4 ×'), findsOneWidget);

    await tester.tap(find.text('Remove'));
    await env.settle(tester);
    expect(find.text('Bench press'), findsNothing);
    // The lone partner is no longer in a superset.
    expect(find.text('Superset'), findsNothing);
    await env.unmount(tester);
  });

  testWidgets('a running workout shows a resume banner on Train', (
    WidgetTester tester,
  ) async {
    await env.sessions.start(name: 'Leg day');
    await env.pump(tester, Routes.train);
    expect(find.text('Workout in progress'), findsOneWidget);
    expect(find.text('Leg day'), findsOneWidget);
    await env.unmount(tester);
  });
}
