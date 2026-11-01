import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/library_types.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/widgets/sinew_chips.dart';

import 'library_harness.dart';

/// The remove glyph of an active filter chip.
Finder _removeIcon(String label) => find.descendant(
  of: find.widgetWithText(SinewChip, label),
  matching: find.byIcon(Icons.close_rounded),
);

void main() {
  group('browse and search', () {
    libraryTest('browse shows categories with counts and flows', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.library);
      expect(find.text('Categories'.toUpperCase()), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Yoga'), findsOneWidget);
      expect(find.text('YOUR EXERCISES'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Create your own exercise'),
        300,
        scrollable: vScroll.last,
      );
      await tester.scrollUntilVisible(
        find.text('Arm Balance Flight Progression'),
        300,
        scrollable: vScroll.last,
      );
      expect(find.text('Arm Balance Flight Progression'), findsOneWidget);
    });

    libraryTest('search "bench" lists bench presses', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.library);
      await typeQuery(tester, 'bench');
      expect(find.textContaining('Bench Press'), findsWidgets);
      expect(find.textContaining('RESULTS'), findsOneWidget);
    });

    libraryTest('a category card and the filter sheet narrow the results', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.library);
      await tester.tap(find.text('Yoga'));
      await tester.pumpAndSettle();
      // The active filter shows as a removable chip.
      expect(_removeIcon('Yoga'), findsOneWidget);
      final Finder before = find.textContaining('RESULTS');
      final String beforeText = tester.widget<Text>(before).data!;

      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Glutes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Glutes'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Show '), findsOneWidget);
      await tester.tap(find.textContaining('Show '));
      await tester.pumpAndSettle();
      expect(_removeIcon('Glutes'), findsOneWidget);
      final String afterText = tester
          .widget<Text>(find.textContaining('RESULTS'))
          .data!;
      expect(afterText, isNot(beforeText));

      await tester.tap(_removeIcon('Yoga'));
      await tester.pumpAndSettle();
      await tester.tap(_removeIcon('Glutes'));
      await tester.pumpAndSettle();
      // Back to browse.
      expect(find.text('YOUR EXERCISES'), findsOneWidget);
    });

    libraryTest('no results offers to clear and to create', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.library);
      await typeQuery(tester, 'zzqqxx');
      expect(find.text('No matches for "zzqqxx"'), findsOneWidget);
      expect(find.text('Create exercise'), findsOneWidget);
    });

    libraryTest('long result lists page in as you scroll', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      const LibraryFilters strength = LibraryFilters(
        categories: <String>{'strength'},
      );
      final int total = await env.repo.count(filters: strength);
      expect(total, greaterThan(100));
      final String last = (await env.repo.search(
        filters: strength,
        limit: 1,
        offset: total - 1,
      )).single.name;
      await pumpLibraryRoute(tester, env, Routes.library);
      await tester.tap(find.text('Strength'));
      await tester.pumpAndSettle();
      expect(find.text(last), findsNothing);
      await tester.scrollUntilVisible(
        find.text(last),
        2000,
        scrollable: vScroll.last,
        maxScrolls: 400,
      );
      expect(find.text(last), findsOneWidget);
    });
  });

  group('exercise detail', () {
    Future<String> idOf(LibraryEnv env, String name) async {
      final List<ExerciseSummary> hits = await env.repo.search(
        query: name,
        limit: 1,
      );
      return hits.first.id;
    }

    libraryTest('shows the muscles, steps and a History action', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      final String id = await idOf(env, 'bench press');
      await pumpLibraryRoute(tester, env, Routes.exercise(id));
      expect(find.textContaining('Bench Press'), findsWidgets);
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Chest'), findsWidgets);
      expect(find.text('STEPS'), findsOneWidget);
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('history $id'), findsOneWidget);
    });

    libraryTest('a yoga pose uses the pose layout', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      final String id = await idOf(env, 'big toe pose');
      await pumpLibraryRoute(tester, env, Routes.exercise(id));
      expect(find.text('Hold'), findsWidgets);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Sides'), findsOneWidget);
    });

    libraryTest('a removed library exercise still opens', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await env.custom.addTombstones(<ExerciseTombstone>[
        const ExerciseTombstone(
          exerciseId: 'gone-forever',
          name: 'Gone Forever',
          trackingType: TrackingType.reps,
          removedInLibraryVersion: '2.0.0',
        ),
      ]);
      await pumpLibraryRoute(tester, env, Routes.exercise('gone-forever'));
      expect(find.text('Gone Forever'), findsOneWidget);
      expect(find.textContaining('removed from the library'), findsOneWidget);
    });

    libraryTest('an unknown id says so', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.exercise('nope'));
      expect(find.text('Exercise not found'), findsOneWidget);
    });

    libraryTest('viewing an exercise records it as recent', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      final String id = await idOf(env, 'bench press');
      await pumpLibraryRoute(tester, env, Routes.exercise(id));
      await tester.pumpAndSettle();
      expect(env.prefs.getStringList('library.recent'), <String>[id]);
    });
  });

  group('flow detail', () {
    libraryTest('lists the poses in order and starts the timer flow', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.flow('surya-namaskar-a'));
      expect(find.text('Sun Salutation A'), findsOneWidget);
      expect(find.text('POSES'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.textContaining('Hold'), findsWidgets);
      await tester.tap(find.text('Start flow'));
      await tester.pumpAndSettle();
      expect(find.text('timer yogaFlow surya-namaskar-a'), findsOneWidget);
    });
  });

  group('custom exercises', () {
    Future<void> createZercher(WidgetTester tester) async {
      await tester.ensureVisible(find.text('New'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      expect(find.text('New exercise'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Zercher lunge');
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(find.text('Save exercise'));
      await tester.pumpAndSettle();
    }

    libraryTest('name is required', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.newCustomExercise);
      await tester.tap(find.text('Save exercise'));
      await tester.pumpAndSettle();
      expect(find.text('Give it a name'), findsOneWidget);
      expect(await env.custom.allActive(), isEmpty);
    });

    libraryTest('create then find it in search, edit, archive', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.library);
      await createZercher(tester);

      final List<Exercise> saved = await env.custom.allActive();
      expect(saved, hasLength(1));
      expect(saved.single.name, 'Zercher lunge');
      expect(saved.single.id, startsWith(Exercise.customPrefix));
      expect(saved.single.metValue, 4.0);

      // Back on browse, listed under Your exercises and found by search.
      expect(find.text('Zercher lunge'), findsOneWidget);
      await typeQuery(tester, 'zercher');
      expect(find.text('Zercher lunge'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Open it, edit, archive.
      await tester.tap(find.text('Zercher lunge'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Edit exercise'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Archive exercise'),
        300,
        scrollable: vScroll.first,
      );
      await tester.tap(find.text('Archive exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive').last);
      await tester.pumpAndSettle();
      expect(await env.custom.allActive(), isEmpty);
      expect(
        (await env.custom.all()).single.archived,
        isTrue,
        reason: 'archived, not deleted',
      );
    });

    libraryTest('archived exercises are hidden from search', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      final Exercise e = await env.custom.save(
        const Exercise(
          id: '',
          name: 'Hidden lift',
          category: 'strength',
          trackingType: TrackingType.weightReps,
        ),
      );
      await env.custom.setArchived(e.id, archived: true);
      await pumpLibraryRoute(tester, env, Routes.library);
      await typeQuery(tester, 'hidden lift');
      expect(find.text('Hidden lift'), findsNothing);
      expect(find.textContaining('No matches'), findsOneWidget);
    });

    libraryTest('warns about a duplicate name but still saves', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.newCustomExercise);
      await tester.enterText(
        find.byType(TextField).first,
        'Bench Press with Chains',
      );
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(find.textContaining('already exists'), findsOneWidget);
    });

    libraryTest('tapping the muscle chips cycles primary and secondary', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.newCustomExercise);
      final Finder chest = find.widgetWithText(InkWell, 'Chest');
      await tester.scrollUntilVisible(chest, 200, scrollable: vScroll.first);
      await tester.tap(chest);
      await tester.pumpAndSettle();
      await tester.tap(chest);
      await tester.pumpAndSettle();
      expect(find.text('Secondary'), findsWidgets);
    });
  });

  group('200% text on a 360dp phone', () {
    libraryTest('browse, results, empty', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(tester, env, Routes.library, textScale: 2);
      expect(tester.takeException(), isNull);
      await typeQuery(tester, 'bench');
      expect(tester.takeException(), isNull);
      await typeQuery(tester, 'zzqqxx');
      expect(tester.takeException(), isNull);
    });

    libraryTest('filter sheet', (WidgetTester tester, LibraryEnv env) async {
      await pumpLibraryRoute(tester, env, Routes.library, textScale: 2);
      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    libraryTest('exercise detail and pose detail', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      final String id = (await env.repo.search(
        query: 'bench press',
        limit: 1,
      )).first.id;
      await pumpLibraryRoute(tester, env, Routes.exercise(id), textScale: 2);
      expect(tester.takeException(), isNull);
      await pumpLibraryRoute(
        tester,
        env,
        Routes.exercise('big-toe-pose'),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    libraryTest('flow detail', (WidgetTester tester, LibraryEnv env) async {
      await pumpLibraryRoute(
        tester,
        env,
        Routes.flow('surya-namaskar-a'),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    libraryTest('custom exercise form', (
      WidgetTester tester,
      LibraryEnv env,
    ) async {
      await pumpLibraryRoute(
        tester,
        env,
        Routes.newCustomExercise,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await tester.drag(vScroll.first, const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
