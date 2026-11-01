import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/repositories/routine_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/features/backup/backup_io.dart';

import '../../helpers/phase8_finders.dart';
import '../../helpers/phase8_harness.dart';

class _NoResolver implements ExerciseResolver {
  @override
  Future<Map<String, Exercise>> resolve(Iterable<String> ids) async =>
      <String, Exercise>{};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final Override _fakeResolver = exerciseResolverProvider.overrideWith(
  (Ref ref) async => _NoResolver(),
);

Future<int> _sessionCount(UserDatabase db) =>
    SessionRepository(db).finishedCount();

Future<List<String>> _routineNames(UserDatabase db) async => <String>[
  for (final Routine r in await RoutineRepository(db).allWithItems()) r.name,
];

Future<void> _localRoutine(UserDatabase db) => RoutineRepository(db).save(
  Routine(
    id: 'local-routine',
    name: 'Local routine',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  ),
);

void main() {
  testWidgets('export JSON saves a sinew-backup file and records the date', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final Harness h = await pumpSinew(
      tester,
      location: Routes.backup,
      extra: <Override>[_fakeResolver],
      seed: _localRoutine,
    );
    expect(find.text('No backup yet'), findsOneWidget);

    await tapText(tester, 'Export backup (JSON)');
    expect(
      find.text('You pick where the file goes. Sinew never uploads it.'),
      findsOneWidget,
    );
    await tapText(tester, 'Save');

    expect(h.io.saved.keys, hasLength(1));
    final String name = h.io.saved.keys.single;
    expect(RegExp(r'^sinew-backup-\d{8}-\d{4}\.json$').hasMatch(name), isTrue);
    final Map<String, dynamic> json =
        jsonDecode(utf8.decode(h.io.saved[name]!)) as Map<String, dynamic>;
    expect(json['app'], 'sinew');
    expect(find.text('No backup yet'), findsNothing);
    expect(find.textContaining('Last backup'), findsOneWidget);
    expect(h.prefs.getString('backup.lastAt'), isNotNull);
    await closeApp(tester);
  });

  testWidgets('a cancelled save does not count as a backup', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final Harness h = await pumpSinew(tester, location: Routes.backup);
    h.io.saveResult = false;
    await tapText(tester, 'Export backup (JSON)');
    await tapText(tester, 'Save');
    expect(h.prefs.getString('backup.lastAt'), isNull);
    expect(find.text('No backup yet'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('export CSV offers both files and saves them', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final Harness h = await pumpSinew(
      tester,
      location: Routes.backup,
      extra: <Override>[_fakeResolver],
    );
    await tapText(tester, 'Export CSV');
    expect(find.text('measurements.csv'), findsOneWidget);
    expect(find.text('sets.csv'), findsOneWidget);
    await tapText(tester, 'Save');
    expect(h.io.saved.keys.toSet(), <String>{'measurements.csv', 'sets.csv'});
    expect(utf8.decode(h.io.saved['sets.csv']!), startsWith('date,'));
    // A CSV is not a backup.
    expect(h.prefs.getString('backup.lastAt'), isNull);
    await closeApp(tester);
  });

  testWidgets('restore of a newer backup shows the error and changes nothing', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final String json = await makeBackupJson();
    final Map<String, dynamic> future = jsonDecode(json) as Map<String, dynamic>
      ..['schemaVersion'] = 999;
    final Harness h = await pumpSinew(
      tester,
      location: Routes.backup,
      seed: _localRoutine,
    );
    h.io.toPick = PickedTextFile(name: 'future.json', text: jsonEncode(future));

    await tapText(tester, 'Import a backup');
    await tapText(tester, 'Choose a backup file');
    expect(find.text('Made by a newer Sinew'), findsOneWidget);
    expect(find.textContaining('newer version of Sinew'), findsOneWidget);
    expect(find.text('Nothing on this phone was changed.'), findsOneWidget);
    expect(await _routineNames(h.db), <String>['Local routine']);
    expect(await _sessionCount(h.db), 0);
    await closeApp(tester);
  });

  testWidgets('a damaged file is reported as damaged', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final Harness h = await pumpSinew(tester, location: Routes.backup);
    h.io.toPick = const PickedTextFile(
      name: 'broken.json',
      text: '{"app": "sin',
    );
    await tapText(tester, 'Import a backup');
    await tapText(tester, 'Choose a backup file');
    expect(find.text('This backup is damaged'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('preview then merge keeps local data and adds the backup', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final String json = await makeBackupJson(sessions: 3);
    final Harness h = await pumpSinew(
      tester,
      location: Routes.backup,
      seed: _localRoutine,
    );
    h.io.toPick = PickedTextFile(
      name: 'sinew-backup-test.json',
      text: json,
      size: json.length,
    );

    await tapText(tester, 'Import a backup');
    await tapText(tester, 'Choose a backup file');

    // Counts per type and both ways to restore are explained.
    expect(find.text('sinew-backup-test.json'), findsOneWidget);
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Routines'), findsOneWidget);
    expect(find.textContaining('Workouts from '), findsOneWidget);
    expect(find.textContaining('Add what is new'), findsOneWidget);
    expect(
      find.textContaining('Delete everything on this phone'),
      findsOneWidget,
    );
    // Nothing is written before the person confirms.
    expect(await _sessionCount(h.db), 0);

    await tapButton(tester, 'Merge');
    expect(find.text('Merge this backup?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Merge'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Backup merged'), findsOneWidget);
    expect(await _sessionCount(h.db), 3);
    final List<String> names = await _routineNames(h.db);
    expect(names, containsAll(<String>['Local routine', 'Push day']));
    await closeApp(tester);
  });

  testWidgets('replace removes what was only on this phone', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final String json = await makeBackupJson(sessions: 2);
    final Harness h = await pumpSinew(
      tester,
      location: Routes.backup,
      seed: _localRoutine,
    );
    h.io.toPick = PickedTextFile(name: 'b.json', text: json);
    await tapText(tester, 'Import a backup');
    await tapText(tester, 'Choose a backup file');

    // Declining the confirmation changes nothing.
    await tapText(tester, 'Replace');
    await tapButton(tester, 'Replace');
    expect(find.text('Replace everything?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await _sessionCount(h.db), 0);

    await tapButton(tester, 'Replace');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Replace'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Backup restored'), findsOneWidget);
    expect(await _sessionCount(h.db), 2);
    expect(await _routineNames(h.db), <String>['Push day']);
    await closeApp(tester);
  });

  testWidgets('backup screens lay out at 200% text on a 360dp phone', (
    WidgetTester tester,
  ) async {
    usePhone(tester, textScale: 2);
    final String json = await makeBackupJson();
    final Harness h = await pumpSinew(tester, location: Routes.backup);
    expect(tester.takeException(), isNull);
    await tapText(tester, 'Export CSV');
    expect(tester.takeException(), isNull);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    h.io.toPick = PickedTextFile(name: 'b.json', text: json);
    await tapText(tester, 'Import a backup');
    await tapText(tester, 'Choose a backup file');
    expect(tester.takeException(), isNull);
    await closeApp(tester);
  });
}
