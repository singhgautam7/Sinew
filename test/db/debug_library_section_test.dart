import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/features/more/debug_library_section.dart';

import '../helpers/test_library.dart';

void main() {
  testWidgets('lists version, total and counts per category', (
    WidgetTester tester,
  ) async {
    late Directory dir;
    late LibraryDatabase db;
    await tester.runAsync(() async {
      dir = await Directory.systemTemp.createTemp('sinew_dbg');
      db = openLibrary(
        await buildTestLibrary(
          dir,
          version: '2.3.4',
          exercises: <Map<String, Object?>>[
            exerciseJson('a', 'Alpha'),
            exerciseJson('b', 'Beta'),
            exerciseJson('c', 'Gamma', category: 'yoga'),
          ],
        ),
      );
    });
    addTearDown(() async {
      await tester.runAsync(() async {
        await db.close();
        await dir.delete(recursive: true);
      });
    });

    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        overrides: <Override>[
          libraryRepositoryProvider.overrideWith(
            (Ref ref) async => LibraryRepository(db),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: DebugLibrarySection()),
          ),
        ),
      ),
    );
    for (int i = 0; i < 40 && find.text('Version').evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }

    expect(find.text('Exercise library'), findsOneWidget);
    expect(find.text('2.3.4'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Yoga'), findsOneWidget);
  });
}
