import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/theme/app_theme.dart';

import 'train_env.dart';

/// Every Train screen at 200% text on a 360dp phone, light and dark.
void main() {
  late TrainEnv env;

  setUp(() async {
    env = await TrainEnv.create();
    await env.seedRoutine();
    await env.seedSession(
      name: 'Push last week',
      start: DateTime.now().subtract(const Duration(days: 9)),
      sets: <(double, int)>[(50, 8), (55, 6)],
      id: 'old',
    );
    await env.seedSession(
      name: 'Push with a very long name that has to wrap somewhere',
      start: DateTime.now().subtract(const Duration(minutes: 5)),
      sets: <(double, int)>[(60, 8), (62.5, 8), (65, 5)],
      id: 'recent',
    );
  });

  tearDown(() => env.dispose());

  Future<void> check(
    WidgetTester tester,
    String location, {
    Tone tone = Tone.light,
    Future<void> Function()? then,
  }) async {
    await env.pump(tester, location, textScale: 2, tone: tone);
    expect(tester.takeException(), isNull, reason: location);
    if (then != null) {
      await then();
      expect(tester.takeException(), isNull, reason: '$location after');
    }
    await env.unmount(tester);
  }

  testWidgets('Train tab, empty and populated', (WidgetTester tester) async {
    await check(tester, Routes.train);
  });

  testWidgets('Train tab with a workout running, dark', (
    WidgetTester tester,
  ) async {
    await env.sessions.start(name: 'Leg day with a long name');
    await check(tester, Routes.train, tone: Tone.dark);
  });

  testWidgets('routine editor with targets open', (WidgetTester tester) async {
    await check(
      tester,
      Routes.routine('r1'),
      then: () async {
        await tester.tap(find.text('Bench press'));
        await env.settle(tester);
      },
    );
  });

  testWidgets('new routine editor', (WidgetTester tester) async {
    await check(tester, Routes.newRoutine);
  });

  testWidgets('active workout with a rest running, then expanded', (
    WidgetTester tester,
  ) async {
    await check(
      tester,
      '${Routes.workout}?routine=r1',
      then: () async {
        await tester.tap(find.text('Complete set 1'));
        await env.settle(tester);
        expect(
          find.byKey(const ValueKey<String>('rest-remaining')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey<String>('rest-remaining')));
        await env.settle(tester);
        expect(
          find.byKey(const ValueKey<String>('rest-expanded-remaining')),
          findsOneWidget,
        );
      },
    );
  });

  testWidgets('active workout with several exercise types, dark', (
    WidgetTester tester,
  ) async {
    final WorkoutSession s = await env.sessions.start(name: 'Mixed');
    final SessionRepositoryHelper h = SessionRepositoryHelper(env);
    await h.add(
      s.id,
      'custom-bench',
      const SetEntry(id: 'a', position: 0, weightKg: 82.5, reps: 8),
    );
    await h.add(
      s.id,
      'custom-row',
      const SetEntry(id: 'b', position: 0, weightKg: 45, reps: 12),
    );
    await h.add(
      s.id,
      'custom-plank',
      const SetEntry(id: 'c', position: 0, holdSec: 45),
    );
    await check(tester, Routes.workout, tone: Tone.dark);
  });

  testWidgets('workout summary', (WidgetTester tester) async {
    await check(tester, Routes.workoutSummary('recent'));
  });

  testWidgets('history', (WidgetTester tester) async {
    await check(tester, Routes.history);
  });

  testWidgets('Train History tab with the calendar and muscles card', (
    WidgetTester tester,
  ) async {
    await check(
      tester,
      Routes.train,
      then: () async {
        await tester.tap(find.text('History'));
        await env.settle(tester, 12);
        await tester.dragUntilVisible(
          find.text('Muscles this week'),
          find.byType(CustomScrollView),
          const Offset(0, -200),
        );
        expect(find.text('Muscles this week'), findsOneWidget);
      },
    );
  });

  testWidgets('Train History tab, dark', (WidgetTester tester) async {
    await check(
      tester,
      Routes.train,
      tone: Tone.dark,
      then: () async {
        await tester.tap(find.text('History'));
        await env.settle(tester, 12);
      },
    );
  });

  testWidgets('starter routines sheet and the empty Train tab', (
    WidgetTester tester,
  ) async {
    await env.routines.delete('r1');
    await check(
      tester,
      Routes.train,
      then: () async {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
        await env.settle(tester);
        await tester.tap(find.text('Browse starter routines'));
        await env.settle(tester);
        expect(find.text('Full body A'), findsOneWidget);
      },
    );
  });

  testWidgets('the last action row and header grow instead of clipping', (
    WidgetTester tester,
  ) async {
    await check(
      tester,
      '${Routes.workout}?routine=r1',
      then: () async {
        for (int i = 1; i <= 3; i++) {
          await tester.tap(find.text('Complete set $i'));
          await env.settle(tester);
        }
        expect(find.text('Finish workout'), findsOneWidget);
        // The button is at least the glove target, and taller when it wraps.
        expect(
          tester.getSize(find.byType(FilledButton).last).height,
          greaterThanOrEqualTo(64),
        );
        expect(find.text('Finish'), findsOneWidget);
      },
    );
  });

  testWidgets('session detail', (WidgetTester tester) async {
    await check(tester, Routes.session('recent'));
  });

  testWidgets('exercise history', (WidgetTester tester) async {
    await check(tester, Routes.exerciseHistory('custom-bench'));
  });
}

/// Adds an exercise with one set to a running session.
class SessionRepositoryHelper {
  SessionRepositoryHelper(this.env);

  final TrainEnv env;

  Future<void> add(String sessionId, String exerciseId, SetEntry set) async {
    final SessionExercise e = await env.sessions.addExercise(
      sessionId,
      exerciseId,
    );
    await env.sessions.upsertSet(sessionId, e.id, set);
  }
}
