import 'dart:io';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/db/library/library_installer.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/repositories/library_upgrade.dart';
import 'package:sinew/core/db/repositories/routine_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/models/training.dart';

import '../helpers/test_db.dart';
import '../helpers/test_library.dart';

class _FileBundle extends CachingAssetBundle {
  _FileBundle(this.version, this.file);

  final String version;
  final File file;

  @override
  Future<ByteData> load(String key) async {
    if (key == LibraryInstaller.assetVersion) {
      return ByteData.sublistView(Uint8List.fromList(version.codeUnits));
    }
    if (key == LibraryInstaller.assetDb) {
      return ByteData.sublistView(file.readAsBytesSync());
    }
    throw FlutterError('Unable to load asset: $key');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      String.fromCharCodes((await load(key)).buffer.asUint8List());
}

void main() {
  late Directory dir;
  late Directory installDir;
  late UserDatabase user;
  late CustomExerciseRepository custom;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('sinew_upg');
    installDir = Directory('${dir.path}/install');
    SharedPreferences.setMockInitialValues(<String, Object>{});
    user = memoryUserDb();
    custom = CustomExerciseRepository(user);
  });

  tearDown(() async {
    await user.close();
    await dir.delete(recursive: true);
  });

  test(
    'exercises removed by an update that user data uses get tombstones',
    () async {
      final File v1 = await buildTestLibrary(
        dir,
        fileName: 'v1.sqlite',
        version: '1.0.0',
        exercises: <Map<String, Object?>>[
          exerciseJson('keep', 'Keep Me'),
          exerciseJson('gone-logged', 'Gone Logged', trackingType: 'hold'),
          exerciseJson('gone-routine', 'Gone In Routine', trackingType: 'reps'),
          exerciseJson('gone-unused', 'Gone Unused'),
        ],
      );
      final File v2 = await buildTestLibrary(
        dir,
        fileName: 'v2.sqlite',
        version: '1.1.0',
        exercises: <Map<String, Object?>>[exerciseJson('keep', 'Keep Me')],
      );

      // User data referencing the old library.
      final SessionRepository sessions = SessionRepository(user);
      final WorkoutSession s = await sessions.start();
      await sessions.addExercise(s.id, 'keep');
      await sessions.addExercise(s.id, 'gone-logged');
      await sessions.addExercise(s.id, 'custom-abc');
      await sessions.addExercise(s.id, 'never-existed');
      await RoutineRepository(user).save(
        Routine(
          id: 'r1',
          name: 'R',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          items: const <RoutineItem>[
            RoutineItem(id: 'i1', exerciseId: 'gone-routine', position: 0),
          ],
        ),
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final LibraryUpgrade upgrade = LibraryUpgrade(custom: custom);

      // First install of v1: nothing to compare against.
      final LibraryInstaller first = LibraryInstaller(
        prefs: prefs,
        directory: installDir,
        bundle: _FileBundle('1.0.0', v1),
      );
      final File installed = await first.ensureInstalled(
        beforeReplace: upgrade.snapshot,
      );
      expect(await upgrade.complete(installed), 0);
      expect(await custom.tombstones(), isEmpty);
      expect(LibraryUpgrade.snapshotFor(installed).existsSync(), isFalse);

      // Update to v2.
      final LibraryInstaller second = LibraryInstaller(
        prefs: prefs,
        directory: installDir,
        bundle: _FileBundle('1.1.0', v2),
      );
      final File updated = await second.ensureInstalled(
        beforeReplace: upgrade.snapshot,
      );
      expect(
        LibraryUpgrade.snapshotFor(updated).existsSync(),
        isTrue,
        reason: 'copied aside before the replace',
      );
      expect(await upgrade.complete(updated), 2);
      expect(LibraryUpgrade.snapshotFor(updated).existsSync(), isFalse);

      final List<ExerciseTombstone> stones = await custom.tombstones()
        ..sort(
          (ExerciseTombstone a, ExerciseTombstone b) =>
              a.exerciseId.compareTo(b.exerciseId),
        );
      expect(stones.map((ExerciseTombstone t) => t.exerciseId), <String>[
        'gone-logged',
        'gone-routine',
      ]);
      expect(stones[0].name, 'Gone Logged');
      expect(stones[0].trackingType, TrackingType.hold);
      expect(stones[1].trackingType, TrackingType.reps);
      expect(
        stones.every(
          (ExerciseTombstone t) => t.removedInLibraryVersion == '1.1.0',
        ),
        isTrue,
      );

      // History resolves through the resolver, never blank.
      final LibraryDatabase lib = LibraryDatabase.openReadOnly(updated);
      addTearDown(lib.close);
      final Map<String, Exercise> got = await ExerciseResolver(
        custom: custom,
        library: LibraryRepository(lib),
      ).resolve(<String>['keep', 'gone-logged', 'gone-routine']);
      expect(got['keep']!.name, 'Keep Me');
      expect(got['gone-logged']!.name, 'Gone Logged');
      expect(got['gone-routine']!.name, 'Gone In Routine');

      // Running again is a no-op.
      expect(await upgrade.complete(updated), 0);
    },
  );

  test('an unchanged library or one without a snapshot does nothing', () async {
    final File v1 = await buildTestLibrary(
      dir,
      exercises: <Map<String, Object?>>[exerciseJson('a', 'A')],
    );
    final LibraryUpgrade upgrade = LibraryUpgrade(custom: custom);
    expect(await upgrade.complete(v1), 0);
    await upgrade.snapshot(v1, '1.0.1');
    expect(LibraryUpgrade.snapshotFor(v1).existsSync(), isTrue);
    expect(await upgrade.complete(v1), 0);
    expect(LibraryUpgrade.snapshotFor(v1).existsSync(), isFalse);
  });

  test('an unreadable snapshot never throws and is kept for a retry', () async {
    final File v1 = await buildTestLibrary(
      dir,
      exercises: <Map<String, Object?>>[exerciseJson('a', 'A')],
    );
    final SessionRepository sessions = SessionRepository(user);
    await sessions.addExercise((await sessions.start()).id, 'a');
    LibraryUpgrade.snapshotFor(v1).writeAsBytesSync(<int>[1, 2, 3]);
    expect(await LibraryUpgrade(custom: custom).complete(v1), 0);
    expect(LibraryUpgrade.snapshotFor(v1).existsSync(), isTrue);
  });
}
