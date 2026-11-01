import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/routine_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/repositories/measurement_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/widgets/domain/stat_card.dart';
import 'package:sinew/features/today/today_providers.dart';

import '../../helpers/backup_fixtures.dart';
import '../../helpers/phase8_finders.dart';
import '../../helpers/phase8_harness.dart';

/// Tuesday 6 January 2026, 10:00 local.
DateTime _now() => DateTime(2026, 1, 6, 10);

Routine _routine(String id, String name, int position) => Routine(
  id: id,
  name: name,
  position: position,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  items: <RoutineItem>[
    RoutineItem(id: '$id-1', exerciseId: 'bench-press', position: 0),
    RoutineItem(id: '$id-2', exerciseId: 'plank', position: 1),
  ],
);

Future<void> _finished(
  UserDatabase db,
  String name,
  DateTime at, {
  String? routineId,
}) async {
  final SessionRepository repo = SessionRepository(db);
  final WorkoutSession s = await repo.start(
    name: name,
    startedAt: at,
    routineId: routineId,
  );
  await repo.finish(
    s.id,
    endedAt: at.add(const Duration(minutes: 52)),
    durationSec: 52 * 60,
    volumeKg: 6240,
    caloriesKcal: 410,
  );
}

void main() {
  group('pure helpers', () {
    test('weekCounts puts sessions on the right days, Monday first', () {
      final ({List<int> counts, int todayIndex}) w = weekCounts(
        <DateTime>[
          DateTime(2026, 1, 5, 8), // Monday
          DateTime(2026, 1, 5, 18), // Monday again
          DateTime(2026, 1, 6, 7), // Tuesday (today)
          DateTime(2026, 1, 4, 7), // last Sunday: outside the week
        ],
        _now(),
        mondayFirst: true,
      );
      expect(w.counts, <int>[2, 1, 0, 0, 0, 0, 0]);
      expect(w.todayIndex, 1);
    });

    test('weekCounts can start the week on Sunday', () {
      final ({List<int> counts, int todayIndex}) w = weekCounts(
        <DateTime>[DateTime(2026, 1, 4, 8), DateTime(2026, 1, 6, 8)],
        _now(),
        mondayFirst: false,
      );
      expect(w.counts, <int>[1, 0, 1, 0, 0, 0, 0]);
      expect(w.todayIndex, 2);
    });

    test('nextRoutine follows the last performed one and wraps', () {
      final List<Routine> routines = <Routine>[
        _routine('a', 'Upper A', 0),
        _routine('b', 'Lower', 1),
        _routine('c', 'Upper B', 2),
      ];
      WorkoutSession s(String? routineId) => WorkoutSession(
        id: 'x',
        startedAt: DateTime(2026),
        routineId: routineId,
        updatedAt: DateTime(2026),
      );
      expect(nextRoutine(routines, <WorkoutSession>[]), routines.first);
      expect(nextRoutine(routines, <WorkoutSession>[s('a')])!.id, 'b');
      expect(
        nextRoutine(routines, <WorkoutSession>[s(null), s('c')])!.id,
        'a',
      );
      expect(nextRoutine(const <Routine>[], <WorkoutSession>[s('a')]), isNull);
    });
  });

  testWidgets('a new user sees the first-workout card and a body nudge', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(tester, clock: _now);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Log your first workout'), findsOneWidget);
    expect(find.text('Start empty workout'), findsOneWidget);
    expect(find.text('Add height and weight to see BMI.'), findsOneWidget);
    expect(find.text('Last session'.toUpperCase()), findsNothing);
    await closeApp(tester);
  });

  testWidgets('populated: next routine, quick timers, last session, week', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      clock: _now,
      seed: (UserDatabase db) async {
        await populate(db, sessions: 3);
        await RoutineRepository(db).save(_routine('routine-pull', 'Pull day', 2));
        // The routine Push day was last used on 3 January: Pull is next.
        await _finished(
          db,
          'Push day',
          DateTime(2026, 1, 5, 10, 30),
          routineId: 'routine-push',
        );
      },
    );
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Tuesday, 6 January'), findsOneWidget);
    expect(find.text('PLANNED TODAY'), findsOneWidget);
    expect(find.text('Pull day'), findsOneWidget);
    expect(find.text('2 exercises'), findsOneWidget);
    expect(find.text('Start workout'), findsOneWidget);
    expect(find.text('QUICK TIMERS'), findsOneWidget);
    expect(find.text('Tabata'), findsOneWidget);
    // The last workout is Push day on 5 January, the day before.
    await tester.scrollUntilVisible(find.text('LAST SESSION'), 200);
    expect(find.text('Push day'), findsOneWidget);
    expect(find.textContaining('Yesterday'), findsOneWidget);
    expect(find.textContaining('52 min'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('THIS WEEK'), 200);
    expect(find.textContaining('THIS WEEK · '), findsOneWidget);
    expect(tester.takeException(), isNull);
    await closeApp(tester);
  });

  testWidgets('starting the planned routine opens it', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      clock: _now,
      seed: (UserDatabase db) async {
        await RoutineRepository(db).save(_routine('routine-a', 'Upper A', 0));
      },
    );
    await tapText(tester, 'Start workout');
    expect(currentPath(tester), Routes.routine('routine-a'));
    // Train registers this route; until it does the router shows its own
    // error page, which is not what this test is about.
    tester.takeException();
    await closeApp(tester);
  });

  testWidgets('rest day: trained already today', (WidgetTester tester) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      clock: _now,
      seed: (UserDatabase db) async {
        await RoutineRepository(db).save(_routine('routine-a', 'Upper A', 0));
        await RoutineRepository(db).save(_routine('routine-b', 'Lower', 1));
        await _finished(
          db,
          'Upper A',
          DateTime(2026, 1, 6, 7),
          routineId: 'routine-a',
        );
      },
    );
    expect(find.text('Done for today'), findsOneWidget);
    expect(find.text('Nice work. Next up is Lower.'), findsOneWidget);
    expect(find.text('Start a workout'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('a running workout shows the resume banner', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      clock: _now,
      seed: (UserDatabase db) async {
        await SessionRepository(db).start(name: 'Running');
      },
    );
    expect(find.text('Workout in progress'), findsOneWidget);
    await tapText(tester, 'Workout in progress');
    expect(currentPath(tester), Routes.workout);
    await closeApp(tester);
  });

  testWidgets('latest body stats come from the engine, locked ones link', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      clock: _now,
      seed: (UserDatabase db) async {
        await MeasurementRepository(db).saveEntry(
          MeasurementEntry(
            id: 'e1',
            date: DateTime(2026, 1, 5),
            values: const <String, double>{'weight': 80},
            updatedAt: DateTime(2026, 1, 5),
          ),
        );
      },
    );
    await tester.scrollUntilVisible(find.text('Body · latest'.toUpperCase()), 200);
    expect(find.byType(StatCard<double>), findsNWidgets(2));
    expect(find.text('80'), findsOneWidget);
    // BMI needs a height: its card offers to add one on the profile.
    expect(find.text('Needs height'), findsOneWidget);
    await tapText(tester, 'Needs height');
    expect(currentPath(tester), Routes.profile);
    await closeApp(tester);
  });

  testWidgets('the backup reminder appears after ten finished workouts', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      clock: _now,
      seed: (UserDatabase db) async {
        for (int i = 0; i < 10; i++) {
          await _finished(db, 'W$i', DateTime(2025, 12, 1 + i, 9));
        }
      },
    );
    expect(find.text('Back up your workouts'), findsOneWidget);
    await tapText(tester, 'Back up your workouts');
    expect(currentPath(tester), Routes.backup);
    await closeApp(tester);
  });

  testWidgets('the search button opens global search', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(tester, clock: _now);
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    expect(currentPath(tester), Routes.search);
    await closeApp(tester);
  });

  testWidgets('Today lays out at 200% text on a 360dp phone', (
    WidgetTester tester,
  ) async {
    usePhone(tester, textScale: 2);
    await pumpSinew(
      tester,
      clock: _now,
      seed: (UserDatabase db) async {
        await populate(db, sessions: 3);
        await RoutineRepository(db).save(_routine('routine-pull', 'Pull day', 2));
      },
    );
    expect(tester.takeException(), isNull);
    for (int i = 0; i < 6; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    await closeApp(tester);
  });
}
