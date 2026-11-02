import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/library_types.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/features/library/exercise_picker.dart';

import 'library_harness.dart';

void main() {
  List<String>? result;
  bool done = false;

  setUp(() {
    result = null;
    done = false;
  });

  Future<void> open(
    WidgetTester tester,
    LibraryEnv env, {
    bool multiple = true,
    Set<String> exclude = const <String>{},
    double textScale = 1,
  }) async {
    await pumpOpener(tester, env, (BuildContext context) async {
      result = await pickExercises(
        context,
        multiple: multiple,
        exclude: exclude,
      );
      done = true;
    }, textScale: textScale);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<List<ExerciseSummary>> find3(LibraryEnv env, String q) =>
      env.repo.search(query: q, limit: 3);

  libraryTest('multi-select returns the ids in pick order', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    final List<ExerciseSummary> hits = await find3(env, 'bench press');
    await open(tester, env);
    expect(find.text('Add exercises'), findsWidgets);
    await typeQuery(tester, 'bench press');
    // Pick the second row first, then the first.
    await tester.tap(find.text(hits[1].name));
    await tester.pumpAndSettle();
    await tester.tap(find.text(hits[0].name));
    await tester.pumpAndSettle();
    expect(find.text('Add 2'), findsOneWidget);
    expect(find.text('2 SELECTED'), findsOneWidget);
    await tester.tap(find.text('Add 2'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(result, <String>[hits[1].id, hits[0].id]);
  });

  libraryTest('the add button waits for a selection', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    await open(tester, env);
    final Finder add = find.widgetWithText(InkWell, 'Add exercises');
    expect(add, findsOneWidget);
    await tester.tap(find.text('Add exercises').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(done, isFalse);
  });

  libraryTest('single-select returns one id at once', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    final List<ExerciseSummary> hits = await find3(env, 'bench press');
    await open(tester, env, multiple: false);
    expect(find.text('Choose exercise'), findsOneWidget);
    expect(find.textContaining('Add '), findsNothing);
    await typeQuery(tester, 'bench press');
    await tester.tap(find.text(hits.first.name));
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(result, <String>[hits.first.id]);
  });

  libraryTest('dismissing returns null', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    await open(tester, env);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(result, isNull);
  });

  libraryTest('excluded ids are shown as already added and cannot be picked', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    final List<ExerciseSummary> hits = await find3(env, 'bench press');
    await open(tester, env, exclude: <String>{hits.first.id});
    await typeQuery(tester, 'bench press');
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    await tester.tap(find.text(hits.first.name));
    await tester.pumpAndSettle();
    expect(find.text('Add 1'), findsNothing);
  });

  libraryTest('creating a custom exercise adds it to the selection', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    await open(tester, env);
    await tester.tap(find.text('Create custom exercise'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Cossack squat');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Save exercise'));
    await tester.pumpAndSettle();

    final List<Exercise> mine = await env.custom.allActive();
    expect(mine.single.name, 'Cossack squat');
    expect(find.text('Add 1'), findsOneWidget);
    // It is listed under Your exercises and found by search.
    expect(find.text('Cossack squat'), findsWidgets);
    await tester.tap(find.text('Add 1'));
    await tester.pumpAndSettle();
    expect(result, <String>[mine.single.id]);
  });

  libraryTest('single-select create returns the new id', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    await open(tester, env, multiple: false);
    await tester.tap(find.text('Create custom exercise'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Jefferson curl');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Save exercise'));
    await tester.pumpAndSettle();
    final Exercise mine = (await env.custom.allActive()).single;
    expect(result, <String>[mine.id]);
  });

  libraryTest('custom and recent exercises lead the browse state', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    await env.custom.save(
      const Exercise(
        id: '',
        name: 'Atlas stone',
        category: 'strength',
        trackingType: TrackingType.weightReps,
      ),
    );
    final String recent = (await find3(env, 'squat')).first.id;
    await env.prefs.setStringList('library.recent', <String>[recent]);
    await open(tester, env);
    expect(find.text('RECENT'), findsOneWidget);
    expect(find.text('YOUR EXERCISES'), findsOneWidget);
    expect(find.text('Atlas stone'), findsOneWidget);
    expect(find.text('ALL EXERCISES'), findsOneWidget);
  });

  libraryTest('no results state in the picker', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    await open(tester, env);
    await typeQuery(tester, 'zzqqxx');
    expect(find.text('No matches'), findsOneWidget);
  });

  libraryTest('lays out at 200% text on a 360dp phone', (
    WidgetTester tester,
    LibraryEnv env,
  ) async {
    await open(tester, env, textScale: 2);
    expect(tester.takeException(), isNull);
    await typeQuery(tester, 'bench');
    expect(tester.takeException(), isNull);
  });
}
