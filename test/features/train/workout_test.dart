import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/measurement_repository.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/nav_visibility.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/features/train/rest_timer.dart';

import 'train_env.dart';

String get _workoutWithRoutine => '${Routes.workout}?routine=r1';

Future<WorkoutSession> _active(TrainEnv env) async =>
    (await env.sessions.active())!;

void main() {
  late TrainEnv env;

  setUp(() async {
    env = await TrainEnv.create();
    await env.seedRoutine();
  });

  tearDown(() => env.dispose());

  testWidgets('starting a routine builds the session; a set persists at once', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, _workoutWithRoutine);
    expect(find.text('Bench press'), findsWidgets);
    expect(find.text('EXERCISE 1 OF 1'), findsOneWidget);

    WorkoutSession s = await _active(env);
    expect(s.routineId, 'r1');
    expect(s.exercises.single.sets, hasLength(3));
    expect(s.exercises.single.sets.first.completed, isFalse);

    // Typing a weight is written without completing anything.
    await tester.enterText(find.byType(TextField).first, '62.5');
    await env.settle(tester);
    s = await _active(env);
    expect(s.exercises.single.sets.first.weightKg, 62.5);

    // Completing a set is in the database straight away.
    await tester.tap(find.text('Complete set 1'));
    await env.settle(tester);
    s = await _active(env);
    final SetEntry first = s.exercises.single.sets.first;
    expect(first.completed, isTrue);
    expect(first.weightKg, 62.5);
    expect(first.reps, 8);
    expect(first.completedAt, isNotNull);
    expect(s.exercises.single.sets[1].completed, isFalse);
    expect(find.text('Complete set 2'), findsOneWidget);
    await env.unmount(tester);
  });

  testWidgets('the rest timer starts at the routine rest and clears at zero', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, _workoutWithRoutine);
    await tester.tap(find.text('Complete set 1'));
    await env.settle(tester);

    final container = env.container(tester);
    final RestState? rest = container.read(trainRestProvider);
    expect(rest, isNotNull);
    expect(rest!.totalSec, 120);
    expect(find.text('2:00'), findsOneWidget);
    expect(
      container.read(navHideReasonsProvider),
      contains(NavHideReason.restTimer),
    );
    // The rest survives a kill: it is saved under train.rest.
    expect(
      await container.read(runtimeStateRepositoryProvider).read('train.rest'),
      isNotNull,
    );

    // Time comes from the clock, not from counted ticks.
    env.clock.advance(const Duration(seconds: 45));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('1:15'), findsOneWidget);

    // +10 s and -10 s.
    await tester.tap(find.text('+10 s'));
    await env.settle(tester);
    expect(find.text('1:25'), findsOneWidget);
    await tester.tap(find.text('-10 s'));
    await env.settle(tester);
    expect(find.text('1:15'), findsOneWidget);

    env.clock.advance(const Duration(seconds: 80));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    expect(container.read(trainRestProvider), isNull);
    expect(
      await container.read(runtimeStateRepositoryProvider).read('train.rest'),
      isNull,
    );
    expect(
      container.read(navHideReasonsProvider),
      isNot(contains(NavHideReason.restTimer)),
    );
    await env.unmount(tester);
  });

  testWidgets('skipping the rest ends it', (WidgetTester tester) async {
    await env.pump(tester, _workoutWithRoutine);
    await tester.tap(find.text('Complete set 1'));
    await env.settle(tester);
    await tester.tap(find.text('Skip'));
    await env.settle(tester);
    expect(env.container(tester).read(trainRestProvider), isNull);
    expect(find.byKey(const ValueKey<String>('rest-remaining')), findsNothing);
    await env.unmount(tester);
  });

  testWidgets('a restart restores the workout and the running rest', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, _workoutWithRoutine);
    await tester.tap(find.text('Complete set 1'));
    await env.settle(tester);
    env.clock.advance(const Duration(seconds: 30));
    await env.unmount(tester);

    // A new process: new providers, same database.
    await env.pump(tester, Routes.workout);
    expect(find.text('Bench press'), findsWidgets);
    expect(find.text('Complete set 2'), findsOneWidget);
    final WorkoutSession s = await _active(env);
    expect(s.exercises.single.sets.first.completed, isTrue);
    expect(env.container(tester).read(trainRestProvider), isNotNull);
    expect(find.text('1:30'), findsOneWidget);
    await env.unmount(tester);
  });

  testWidgets('a set that beats history flashes PR; finishing saves it', (
    WidgetTester tester,
  ) async {
    await env.seedSession(
      name: 'Old push',
      start: DateTime(2026, 3, 1, 10),
      sets: <(double, int)>[(50, 8), (50, 8)],
    );
    // A body weight, so calories can be estimated.
    final MeasurementRepository m = MeasurementRepository(env.db);
    await m.saveField(
      MeasurementField(
        id: 'weight',
        name: 'Weight',
        unitType: MeasurementUnitType.mass,
        updatedAt: DateTime(2026),
      ),
    );
    await m.saveEntry(
      MeasurementEntry(
        id: 'm1',
        date: DateTime(2026, 3, 2),
        values: const <String, double>{'weight': 80},
        updatedAt: DateTime(2026, 3, 2),
      ),
    );

    await env.pump(tester, _workoutWithRoutine);
    await tester.tap(find.text('Complete set 1'));
    await env.settle(tester);
    expect(find.text('PR'), findsOneWidget);
    await tester.tap(find.text('Complete set 2'));
    await env.settle(tester);
    await tester.tap(find.text('Complete set 3'));
    await env.settle(tester);
    expect(find.text('Finish workout'), findsOneWidget);

    env.clock.advance(const Duration(minutes: 30));
    await tester.tap(find.text('Finish workout'));
    await env.settle(tester);
    expect(find.text('Finish workout?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Finish'),
      ),
    );
    await env.settle(tester, 20);

    // The summary.
    expect(find.text('Workout saved'), findsOneWidget);
    expect(find.text('Records'), findsOneWidget);
    expect(find.text('estimate'), findsOneWidget);

    expect(await env.sessions.active(), isNull);
    final List<WorkoutSession> all = await env.sessions.allWithTree();
    final WorkoutSession done = all.firstWhere(
      (WorkoutSession s) => s.routineId == 'r1',
    );
    expect(done.endedAt, isNotNull);
    expect(done.volumeKg, 60 * 8 * 3);
    expect(done.durationSec, greaterThanOrEqualTo(30 * 60));
    expect(done.caloriesKcal, isNotNull);
    expect(done.caloriesKcal, greaterThan(0));
    final List<SetEntry> sets = done.exercises.single.sets;
    expect(sets.where((SetEntry s) => s.isPR), hasLength(1));
    expect(sets.first.isPR, isTrue);

    // Effort and note are saved from the summary.
    await tester.dragUntilVisible(
      find.byKey(const ValueKey<String>('effort-7')),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.byKey(const ValueKey<String>('effort-7')));
    await env.settle(tester);
    expect((await env.sessions.byId(done.id))!.perceivedEffort, 7);
    await env.unmount(tester);
  });

  testWidgets('finishing without a body weight says calories need one', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, _workoutWithRoutine);
    await tester.tap(find.text('Complete set 1'));
    await env.settle(tester);
    await tester.tap(find.text('Finish'));
    await env.settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Finish'),
      ),
    );
    await env.settle(tester, 20);
    expect(find.text('Workout saved'), findsOneWidget);
    expect(find.text('needs body weight'), findsOneWidget);
    expect(find.text('Calories need a body weight'), findsOneWidget);
    final WorkoutSession done = (await env.sessions.allWithTree()).single;
    expect(done.caloriesKcal, isNull);
    // Unfinished sets are left out.
    expect(done.exercises.single.sets, hasLength(1));
    await env.unmount(tester);
  });

  testWidgets('discarding a workout deletes the session', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, _workoutWithRoutine);
    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await env.settle(tester);
    await tester.tap(find.text('Discard workout'));
    await env.settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Discard'),
      ),
    );
    await env.settle(tester);
    expect(await env.sessions.active(), isNull);
    expect(await env.sessions.allWithTree(), isEmpty);
    await env.unmount(tester);
  });

  testWidgets('the nav is hidden while the workout is open', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, Routes.train);
    final container = env.container(tester);
    expect(container.read(navHideReasonsProvider), isEmpty);

    await tester.tap(find.text('Start an empty workout').first);
    await env.settle(tester);
    expect(
      container.read(navHideReasonsProvider),
      contains(NavHideReason.activeWorkout),
    );
    expect(find.text('Add your first exercise'), findsOneWidget);

    await tester.tap(find.byTooltip('Minimise workout'));
    await env.settle(tester);
    expect(container.read(navHideReasonsProvider), isEmpty);
    // The workout is still running: Train offers to resume it.
    expect(find.text('Workout in progress'), findsOneWidget);
    await env.unmount(tester);
  });

  testWidgets('add and swap exercises mid-workout', (
    WidgetTester tester,
  ) async {
    await env.pump(tester, _workoutWithRoutine);
    env.pick = <String>['custom-pullup'];
    await tester.tap(find.widgetWithIcon(IconButton, Icons.add_rounded));
    await env.settle(tester);
    expect(find.text('EXERCISE 2 OF 2'), findsOneWidget);
    expect(find.text('Pull-up'), findsWidgets);
    expect((await _active(env)).exercises, hasLength(2));

    // Swap the pull-up for the cable row.
    env.pick = <String>['custom-row'];
    await tester.tap(find.byTooltip('Swap Pull-up'));
    await env.settle(tester);
    final WorkoutSession s = await _active(env);
    expect(s.exercises.map((SessionExercise e) => e.exerciseId), <String>[
      'custom-bench',
      'custom-row',
    ]);
    expect(find.text('Cable row'), findsWidgets);
    await env.unmount(tester);
  });
}
