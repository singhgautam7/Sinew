import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart' show noRetry;
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/engines/records/train_stats.dart';
import 'package:sinew/features/train/workout_controller.dart';

import 'train_env.dart';

String get _workout => '${Routes.workout}?routine=r1';

Future<T> _until<T>(T? Function() read) async {
  for (int i = 0; i < 200; i++) {
    final T? v = read();
    if (v != null) return v;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError('never became available');
}

void main() {
  late TrainEnv env;

  setUp(() async {
    env = await TrainEnv.create();
    await env.seedRoutine();
  });

  tearDown(() => env.dispose());

  group('the workout controller', () {
    late ProviderContainer c;

    setUp(() {
      c = ProviderContainer(retry: noRetry, overrides: env.overrides());
      c.listen(workoutProvider, (_, _) {});
    });
    tearDown(() => c.dispose());

    Future<WorkoutState> started({bool routine = true}) async {
      await c
          .read(workoutLauncherProvider)
          .start(routine: routine ? await env.routines.byId('r1') : null);
      return _until(() => c.read(workoutProvider).value);
    }

    test('follows the active session however it was started', () async {
      expect(await c.read(workoutProvider.future), isNull);
      final WorkoutState first = await started();
      expect(first.session.exercises.single.sets, hasLength(3));

      // Finish, then start again from "elsewhere": it must load, not stay
      // on the "no workout" answer it cached.
      final WorkoutController ctrl = c.read(workoutProvider.notifier);
      final SetEntry s = first.session.exercises.single.sets.first;
      await ctrl.setCompleted(
        first.session.exercises.single.id,
        s.id,
        done: true,
      );
      final FinishOutcome? out = await ctrl.finish();
      expect(out, isNotNull);
      expect(c.read(workoutProvider).value, isNull);

      final WorkoutState second = await started(routine: false);
      expect(second.session.id, isNot(first.session.id));
      expect(second.session.exercises, isEmpty);
    });

    test('a second start resumes instead of creating another', () async {
      final WorkoutState first = await started();
      final r = await c.read(workoutLauncherProvider).start();
      expect(r.resumed, isTrue);
      expect(r.id, first.session.id);
      expect(
        await env.sessions.sessionHeaders(finishedOnly: false),
        hasLength(1),
      );
    });

    test('finish is one write: tree, summary and records together', () async {
      await env.seedSession(
        name: 'Before',
        start: DateTime(2026, 2, 1),
        sets: <(double, int)>[(60, 8)],
        id: 'before',
      );
      final WorkoutState ws = await started();
      final WorkoutController ctrl = c.read(workoutProvider.notifier);
      final SessionExercise e = ws.session.exercises.single;
      env.clock.advance(const Duration(minutes: 30));
      // Set 1 beats 60 x 8; set 2 is left open and is dropped.
      await ctrl.updateSet(e.id, e.sets[0].copyWith(weightKg: 70, reps: 8));
      await ctrl.setCompleted(e.id, e.sets[0].id, done: true);
      final FinishOutcome out = (await ctrl.finish())!;

      expect(out.prCount, 1);
      expect(
        out.prs.single.e1rmDeltaKg,
        closeTo(70 * (1 + 8 / 30) - 60 * (1 + 8 / 30), 1e-9),
      );
      expect(c.read(lastFinishedPrsProvider)!.sessionId, out.sessionId);
      final WorkoutSession done = (await env.sessions.byId(out.sessionId))!;
      expect(done.endedAt, isNotNull);
      expect(done.durationSec, 1800);
      expect(done.volumeKg, 560);
      expect(done.exercises.single.sets, hasLength(1));
      expect(done.exercises.single.sets.single.isPR, isTrue);
      expect(await env.sessions.active(), isNull);
    });

    test('finishing twice or editing afterwards is harmless', () async {
      final WorkoutState ws = await started();
      final WorkoutController ctrl = c.read(workoutProvider.notifier);
      final SessionExercise e = ws.session.exercises.single;
      await ctrl.setCompleted(e.id, e.sets[0].id, done: true);
      await ctrl.finish();
      expect(await ctrl.finish(), isNull);
      await ctrl.updateSet(e.id, e.sets[0].copyWith(reps: 1));
      await ctrl.addSet(e.id);
      await ctrl.removeSet(e.id, e.sets[0].id);
      await ctrl.discard();
      expect(c.read(workoutProvider).value, isNull);
    });

    test('editing a completed set recomputes its record flag', () async {
      await env.seedSession(
        name: 'Before',
        start: DateTime(2026, 2, 1),
        sets: <(double, int)>[(60, 8)],
      );
      final WorkoutState ws = await started();
      final WorkoutController ctrl = c.read(workoutProvider.notifier);
      final SessionExercise e = ws.session.exercises.single;
      final String id = e.sets[0].id;

      Future<bool> flag() async => (await env.sessions.active())!
          .exercises
          .single
          .sets
          .firstWhere((SetEntry s) => s.id == id)
          .isPR;

      await ctrl.updateSet(e.id, e.sets[0].copyWith(weightKg: 50, reps: 8));
      await ctrl.setCompleted(e.id, id, done: true);
      expect(await flag(), isFalse);
      final SetEntry done = c
          .read(workoutProvider)
          .value!
          .session
          .exercises
          .single
          .sets[0];
      await ctrl.updateSet(e.id, done.copyWith(weightKg: 80));
      expect(await flag(), isTrue);
      expect(
        c.read(workoutProvider).value!.session.exercises.single.sets[0].isPR,
        isTrue,
      );
      await ctrl.updateSet(e.id, done.copyWith(weightKg: 40));
      expect(await flag(), isFalse);
    });

    test('writes land in the order they were made', () async {
      final WorkoutState ws = await started();
      final WorkoutController ctrl = c.read(workoutProvider.notifier);
      final SessionExercise e = ws.session.exercises.single;
      final SetEntry s = e.sets[0];
      // Fired without awaiting, as typing does.
      final List<Future<void>> pending = <Future<void>>[
        for (int w = 1; w <= 8; w++)
          ctrl.updateSet(e.id, s.copyWith(weightKg: w * 10.0)),
      ];
      await Future.wait(pending);
      expect(
        (await env.sessions.active())!.exercises.single.sets[0].weightKg,
        80,
      );
    });

    test('Undo helpers put a set and an exercise back', () async {
      final WorkoutState ws = await started();
      final WorkoutController ctrl = c.read(workoutProvider.notifier);
      final SessionExercise e = ws.session.exercises.single;
      final SetEntry middle = e.sets[1];
      await ctrl.removeSet(e.id, middle.id);
      expect(
        (await env.sessions.active())!.exercises.single.sets,
        hasLength(2),
      );
      await ctrl.restoreSet(e.id, middle, 1);
      final List<SetEntry> back =
          (await env.sessions.active())!.exercises.single.sets;
      expect(back.map((SetEntry s) => s.id), e.sets.map((SetEntry s) => s.id));
      expect(back.map((SetEntry s) => s.position), <int>[0, 1, 2]);

      await ctrl.removeExercise(e.id);
      expect((await env.sessions.active())!.exercises, isEmpty);
      await ctrl.restoreExercise(e, 0);
      expect(
        (await env.sessions.active())!.exercises.single.sets,
        hasLength(3),
      );
    });
  });

  test('rest falls back to the given default, not a fixed 90', () {
    final WorkoutState ws = WorkoutState(
      session: WorkoutSession(
        id: 's',
        startedAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      exercises: const {},
      previous: const {},
      routineItems: const {},
    );
    expect(ws.restSecFor('x', 120), 120);
    expect(ws.restSecFor('x', 45), 45);
  });

  group('the workout screen', () {
    testWidgets('honours the keep screen on setting', (
      WidgetTester tester,
    ) async {
      await env.pump(tester, _workout);
      expect(env.timerServices.screenOn, isTrue);
      await env.unmount(tester);

      await env.prefs.setBool('app.keepScreenOn', false);
      final TrainEnv off = env;
      off.timerServices.screenOn = false;
      await off.pump(tester, _workout);
      expect(off.timerServices.screenOn, isFalse);
      await off.unmount(tester);
    });

    testWidgets('reopening a set offers Undo, which completes it again', (
      WidgetTester tester,
    ) async {
      await env.pump(tester, _workout);
      await tester.tap(find.text('Complete set 1'));
      await env.settle(tester);
      await tester.tap(find.text('60 kg × 8').first);
      await env.settle(tester);
      expect(find.text('Set 1 reopened'), findsOneWidget);
      expect(
        (await env.sessions.active())!.exercises.single.sets[0].completed,
        isFalse,
      );

      await tester.tap(find.text('Undo'));
      await env.settle(tester);
      expect(
        (await env.sessions.active())!.exercises.single.sets[0].completed,
        isTrue,
      );
      await env.unmount(tester);
    });

    testWidgets('deleting a set offers Undo', (WidgetTester tester) async {
      await env.pump(tester, _workout);
      await tester.longPress(find.text('60 kg × 8').last);
      await env.settle(tester);
      await tester.tap(find.text('Delete set'));
      await env.settle(tester);
      expect(
        (await env.sessions.active())!.exercises.single.sets,
        hasLength(2),
      );
      expect(find.text('Set 3 deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await env.settle(tester);
      expect(
        (await env.sessions.active())!.exercises.single.sets,
        hasLength(3),
      );
      await env.unmount(tester);
    });

    testWidgets('removing an exercise offers Undo', (
      WidgetTester tester,
    ) async {
      await env.pump(tester, _workout);
      await tester.tap(find.bySemanticsLabel('More for Bench press'));
      await env.settle(tester);
      await tester.tap(find.text('Remove exercise'));
      await env.settle(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Remove'),
        ),
      );
      await env.settle(tester, 12);
      expect((await env.sessions.active())!.exercises, isEmpty);
      expect(find.text('Bench press removed'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await env.settle(tester, 12);
      expect(
        (await env.sessions.active())!.exercises.single.sets,
        hasLength(3),
      );
      await env.unmount(tester);
    });

    testWidgets('a workout started from elsewhere opens, never "No workout"', (
      WidgetTester tester,
    ) async {
      await env.pump(tester, Routes.train);
      await tester.tap(find.text('Start an empty workout'));
      await env.settle(tester, 12);
      expect(find.text('No workout in progress'), findsNothing);
      expect(find.text('Add your first exercise'), findsOneWidget);
      await env.unmount(tester);
    });
  });

  group('the Train tab', () {
    testWidgets('has the Routines, History and Library control and Search', (
      WidgetTester tester,
    ) async {
      await env.pump(tester, Routes.train);
      expect(find.text('Routines'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Search'));
      await env.settle(tester);
      expect(find.text('Search stub'), findsOneWidget);
      await env.unmount(tester);

      await env.pump(tester, Routes.train);
      await tester.tap(find.text('Library'));
      await env.settle(tester);
      expect(find.text('Library stub'), findsOneWidget);
      await env.unmount(tester);
    });

    testWidgets('History shows the month, totals, muscles and PR pills', (
      WidgetTester tester,
    ) async {
      final DateTime now = DateTime.now();
      await env.seedSession(
        name: 'Push A',
        start: now.subtract(const Duration(minutes: 90)),
        id: 'pa',
      );
      await env.seedSession(
        name: 'Push B',
        start: now.subtract(const Duration(minutes: 5)),
        id: 'pb',
      );
      await env.sessions.setPrFlags(<String, bool>{'set-pb-0': true});
      await env.pump(tester, Routes.train, height: 1600);
      await tester.tap(find.text('History'));
      await env.settle(tester, 12);

      expect(find.textContaining('${now.year}'), findsWidgets);
      expect(find.text('Muscles this week'), findsOneWidget);
      expect(find.text('2 sessions · 1 h 30 min'), findsWidgets);
      expect(find.text('Push B'), findsOneWidget);
      expect(find.text('PR'), findsOneWidget);
      expect(find.textContaining('Most sets: chest'), findsOneWidget);
      expect(find.text('less'), findsOneWidget);
      await env.unmount(tester);
    });

    testWidgets('deleting a routine offers Undo', (WidgetTester tester) async {
      await env.pump(tester, Routes.train);
      await tester.longPress(find.text('Push'));
      await env.settle(tester);
      await tester.tap(find.text('Delete'));
      await env.settle(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await env.settle(tester, 12);
      expect(await env.routines.byId('r1'), isNull);
      expect(find.text('Routine deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await env.settle(tester, 12);
      final Routine? back = await env.routines.byId('r1');
      expect(back, isNotNull);
      expect(back!.items, hasLength(1));
      await env.unmount(tester);
    });

    testWidgets('routine length uses the rest default from Settings', (
      WidgetTester tester,
    ) async {
      // 3 sets with a 2:00 rest on the item: unaffected by the default.
      await env.pump(tester, Routes.train);
      expect(find.textContaining('1 exercise · about'), findsOneWidget);
      await env.unmount(tester);
      expect(
        estimateRoutineMinutes(const <RoutineItem>[
          RoutineItem(id: 'a', exerciseId: 'x', position: 0, targetSets: 6),
        ], defaultRestSec: 120),
        15,
      );
    });
  });
}
