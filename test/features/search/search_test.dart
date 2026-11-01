import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/exercise_search_service.dart';
import 'package:sinew/core/db/repositories/library_types.dart';
import 'package:sinew/core/db/repositories/routine_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/features/search/search_providers.dart';

import '../../helpers/phase8_finders.dart';
import '../../helpers/phase8_harness.dart';

/// A search service over two fixed exercises: the real one needs the bundled
/// library file, which the widget tests do not open.
class _FakeSearch implements ExerciseSearchService {
  static const List<ExerciseSummary> all = <ExerciseSummary>[
    ExerciseSummary(
      id: 'bench-press',
      name: 'Bench press',
      category: 'strength',
      trackingType: TrackingType.weightReps,
      primaryMuscles: <String>['chest'],
      equipment: <String>['barbell'],
    ),
    ExerciseSummary(
      id: 'plank',
      name: 'Plank',
      category: 'strength',
      trackingType: TrackingType.hold,
      primaryMuscles: <String>['abs'],
      equipment: <String>['bodyweight'],
    ),
  ];

  @override
  Future<List<ExerciseSummary>> search({
    String query = '',
    LibraryFilters filters = const LibraryFilters(),
    int limit = 50,
    int offset = 0,
  }) async => all
      .where(
        (ExerciseSummary e) =>
            e.name.toLowerCase().contains(query.trim().toLowerCase()),
      )
      .toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final Override _fakeSearch = exerciseSearchServiceProvider.overrideWith(
  (Ref ref) async => _FakeSearch(),
);

Future<void> _seed(UserDatabase db) async {
  await RoutineRepository(db).save(
    Routine(
      id: 'routine-upper',
      name: 'Upper body A',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      items: const <RoutineItem>[
        RoutineItem(id: 'i1', exerciseId: 'bench-press', position: 0),
      ],
    ),
  );
  await RoutineRepository(db).save(
    Routine(
      id: 'routine-legs',
      name: 'Legs',
      position: 1,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      items: const <RoutineItem>[
        RoutineItem(id: 'i2', exerciseId: 'plank', position: 0),
      ],
    ),
  );
  final SessionRepository repo = SessionRepository(db);
  final WorkoutSession s = await repo.start(
    name: 'Upper body A',
    startedAt: DateTime(2026, 10, 28, 9),
    routineId: 'routine-upper',
  );
  await repo.addExercise(s.id, 'bench-press');
  await repo.finish(
    s.id,
    endedAt: DateTime(2026, 10, 28, 10),
    durationSec: 3600,
  );
}

void main() {
  test('matchesQuery needs every word, ignoring case', () {
    expect(matchesQuery('Bench PRESS', 'bench press'), isTrue);
    expect(matchesQuery('bench legs', 'bench press'), isFalse);
    expect(matchesQuery('', 'anything'), isTrue);
  });

  testWidgets('empty query lists recent searches and pages to jump to', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      location: Routes.search,
      prefs: <String, Object>{
        'search.recent': <String>['bench'],
      },
    );
    expect(find.text('bench'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('finds an exercise, a routine and a past workout', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      location: Routes.search,
      extra: <Override>[_fakeSearch],
      seed: _seed,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('search-field')),
      'bench',
    );
    // Past the debounce.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('EXERCISES · 1'), findsOneWidget);
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Chest · Barbell'), findsOneWidget);
    expect(find.text('ROUTINES · 1'), findsOneWidget);
    expect(find.text('Upper body A'), findsWidgets);
    expect(find.text('Includes Bench press'), findsWidgets);
    expect(find.text('WORKOUTS · 1'), findsOneWidget);
    expect(find.text('Upper body A · 28 Oct'), findsOneWidget);
    // Legs does not include a bench press.
    expect(find.text('Legs'), findsNothing);

    await tester.tap(find.text('Bench press'));
    await tester.pumpAndSettle();
    expect(currentPath(tester), Routes.exercise('bench-press'));
    // Library screens are Library's; the router's error page is not under test.
    tester.takeException();
    await closeApp(tester);
  });

  testWidgets('a routine result opens the routine, a page result its page', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      location: Routes.search,
      extra: <Override>[_fakeSearch],
      seed: _seed,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('search-field')),
      'legs',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Legs'));
    await tester.pumpAndSettle();
    expect(currentPath(tester), Routes.routine('routine-legs'));
    tester.takeException();
    await closeApp(tester);
  });

  testWidgets('More pages are searchable', (WidgetTester tester) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      location: Routes.search,
      extra: <Override>[_fakeSearch],
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('search-field')),
      'backup',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('PAGES · 1'), findsOneWidget);
    await tester.tap(find.text('Backup and restore'));
    await tester.pumpAndSettle();
    expect(currentPath(tester), Routes.backup);
    await closeApp(tester);
  });

  testWidgets('measurement fields lead to their progress page', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(
      tester,
      location: Routes.search,
      extra: <Override>[_fakeSearch],
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('search-field')),
      'waist',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('BODY · 1'), findsOneWidget);
    await tester.tap(find.text('Waist'));
    await tester.pumpAndSettle();
    expect(currentPath(tester), Routes.progress('waist'));
    tester.takeException();
    await closeApp(tester);
  });

  testWidgets('no match says so, and the search is remembered', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final Harness h = await pumpSinew(
      tester,
      location: Routes.search,
      extra: <Override>[_fakeSearch],
    );
    final Finder field = find.byKey(const ValueKey<String>('search-field'));
    await tester.enterText(field, 'zzzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('No results for "zzzz"'), findsOneWidget);

    // Submitting stores it for next time.
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(h.prefs.getStringList('search.recent'), <String>['zzzz']);
    await closeApp(tester);
  });

  testWidgets('works without the exercise library', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(tester, location: Routes.search, seed: _seed);
    await tester.enterText(
      find.byKey(const ValueKey<String>('search-field')),
      'upper',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(
      find.text('The exercise library is not available right now.'),
      findsOneWidget,
    );
    expect(find.text('ROUTINES · 1'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('search lays out at 200% text on a 360dp phone', (
    WidgetTester tester,
  ) async {
    usePhone(tester, textScale: 2);
    await pumpSinew(
      tester,
      location: Routes.search,
      extra: <Override>[_fakeSearch],
      seed: _seed,
    );
    expect(tester.takeException(), isNull);
    await tester.enterText(
      find.byKey(const ValueKey<String>('search-field')),
      'bench',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await closeApp(tester);
  });
}
