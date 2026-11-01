import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/db/repositories/library_repository.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/features/train/starter_routines.dart';

import '../../helpers/test_library.dart';
import 'train_env.dart';

void main() {
  group('the bundled library', () {
    late Directory dir;
    late LibraryDatabase db;

    setUpAll(() async {
      dir = await Directory.systemTemp.createTemp('sinew_starters');
      final File copy = await File('assets/db/library.sqlite')
          .copy('${dir.path}/library.sqlite');
      db = openLibrary(copy);
    });

    tearDownAll(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    test('has every exercise the starter routines use', () async {
      final LibraryRepository repo = LibraryRepository(db);
      final Set<String> ids = <String>{
        for (final StarterRoutine r in kStarterRoutines)
          for (final StarterItem i in r.items) i.exerciseId,
      };
      final found = await repo.byIds(ids.toList());
      expect(
        ids.difference(found.keys.toSet()),
        isEmpty,
        reason: 'starter exercises missing from the library',
      );
    });
  });

  test('there are four starters, each with exercises and sensible targets', () {
    expect(kStarterRoutines.map((StarterRoutine r) => r.name), <String>[
      'Full body A',
      'Push',
      'Pull',
      'Legs',
    ]);
    for (final StarterRoutine r in kStarterRoutines) {
      expect(r.items, isNotEmpty);
      final Routine built = r.build(DateTime(2026), 3);
      expect(built.position, 3);
      expect(built.items, hasLength(r.items.length));
      expect(built.items.map((RoutineItem i) => i.position), <int>[
        for (int i = 0; i < r.items.length; i++) i,
      ]);
    }
  });

  testWidgets('an empty Train tab offers starters; adding one installs it', (
    WidgetTester tester,
  ) async {
    final TrainEnv env = await TrainEnv.create();
    addTearDown(env.dispose);
    await env.pump(tester, Routes.train);
    expect(find.text('No routines yet'), findsOneWidget);
    await tester.tap(find.text('Browse starter routines'));
    await env.settle(tester);
    expect(find.text('Full body A'), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);

    await tester.tap(find.text('Add').first);
    await env.settle(tester);
    final List<Routine> saved = await env.routines.allWithItems();
    expect(saved.single.name, 'Full body A');
    expect(saved.single.items, hasLength(5));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    // A second one lands after the first.
    await tester.tap(find.text('Add').first);
    await env.settle(tester);
    final List<Routine> two = await env.routines.allWithItems()
      ..sort((Routine a, Routine b) => a.position - b.position);
    expect(two.map((Routine r) => r.name), <String>['Full body A', 'Push']);
    await env.unmount(tester);
  });
}
