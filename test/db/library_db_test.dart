import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/db/library/library_installer.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';

import '../helpers/test_db.dart';

ExercisesCompanion _exercise(String id, String name, String tracking) =>
    ExercisesCompanion.insert(
      id: id,
      name: name,
      nameNorm: name.toLowerCase(),
      aliases: const <String>[],
      category: 'strength',
      trackingType: tracking,
      primaryMuscles: const <String>['chest'],
      secondaryMuscles: const <String>[],
      equipment: const <String>['barbell'],
      unilateral: false,
      steps: const <String>[],
      tips: const <String>[],
      commonMistakes: const <String>[],
      safetyNotes: const <String>[],
      contraindications: const <String>[],
      tags: const <String>[],
      metValue: const Value<double?>(5),
    );

Future<LibraryDatabase> _filled(QueryExecutor executor) async {
  final LibraryDatabase db = LibraryDatabase.forBuild(executor);
  await db.batch((Batch b) {
    b.insertAll(db.exercises, <ExercisesCompanion>[
      _exercise('bench-press', 'Bench Press', 'weightReps'),
      _exercise('future-move', 'Future Move', 'teleport'),
    ]);
    b.insert(
      db.libraryMeta,
      LibraryMetaCompanion.insert(key: 'libraryVersion', value: '1.0.0'),
    );
  });
  await db.customStatement(
    'INSERT INTO ${LibraryDatabase.ftsTable}(rowid, name, aliases, muscles) '
    "SELECT seq, name, '', 'chest' FROM exercises",
  );
  return db;
}

void main() {
  test('schema, FTS5 prefix search and lookups', () async {
    final LibraryDatabase db = await _filled(NativeDatabase.memory());
    addTearDown(db.close);
    final LibraryRepository repo = LibraryRepository(db);

    expect(await repo.count(), 2);
    expect(await repo.libraryVersion(), '1.0.0');
    final Exercise bench = (await repo.byId('bench-press'))!;
    expect(bench.trackingType, TrackingType.weightReps);
    expect(bench.metValue, 5);
    // An unknown tracking type from a newer library never throws.
    expect(
      (await repo.byId('future-move'))!.trackingType,
      TrackingType.unknown,
    );
    expect((await repo.byIds(<String>['bench-press', 'nope'])).keys, <String>[
      'bench-press',
    ]);

    final List<QueryRow> hits = await db
        .customSelect(
          'SELECT e.id FROM ${LibraryDatabase.ftsTable} f '
          'JOIN exercises e ON e.seq = f.rowid '
          "WHERE ${LibraryDatabase.ftsTable} MATCH '\"ben\"*'",
        )
        .get();
    expect(hits.map((QueryRow r) => r.read<String>('id')), <String>[
      'bench-press',
    ]);
  });

  test('the installed file opens read-only: any write throws', () async {
    final Directory dir = await Directory.systemTemp.createTemp('sinew_lib');
    addTearDown(() => dir.delete(recursive: true));
    final File file = File('${dir.path}/library.sqlite');
    final LibraryDatabase build = await _filled(NativeDatabase(file));
    await build.close();

    final LibraryDatabase db = LibraryDatabase.openReadOnly(file);
    addTearDown(db.close);
    expect(await LibraryRepository(db).count(), 2);
    await expectLater(
      db.customStatement("DELETE FROM exercises WHERE id = 'bench-press'"),
      throwsA(anything),
    );
  });

  test('the resolver finds custom, then library, then tombstone', () async {
    final LibraryDatabase lib = await _filled(NativeDatabase.memory());
    final UserDatabase user = memoryUserDb();
    addTearDown(lib.close);
    addTearDown(user.close);
    final CustomExerciseRepository custom = CustomExerciseRepository(user);
    final Exercise mine = await custom.save(
      const Exercise(
        id: '',
        name: 'My curl',
        category: 'strength',
        trackingType: TrackingType.weightReps,
      ),
    );
    await custom.addTombstones(const <ExerciseTombstone>[
      ExerciseTombstone(
        exerciseId: 'old-move',
        name: 'Old Move',
        trackingType: TrackingType.hold,
        removedInLibraryVersion: '1.1.0',
      ),
    ]);
    final Map<String, Exercise> got = await ExerciseResolver(
      custom: custom,
      library: LibraryRepository(lib),
    ).resolve(<String>[mine.id, 'bench-press', 'old-move', 'never-existed']);

    expect(got[mine.id]!.isCustom, isTrue);
    expect(got['bench-press']!.name, 'Bench Press');
    expect(got['old-move']!.name, 'Old Move');
    expect(got['old-move']!.trackingType, TrackingType.hold);
    expect(got.containsKey('never-existed'), isFalse);
  });

  group('LibraryInstaller', () {
    late Directory dir;
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('sinew_install');
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });
    tearDown(() => dir.delete(recursive: true));

    test('copies once, reinstalls only for a newer bundled version', () async {
      final _FakeBundle bundle = _FakeBundle('1.0.0', <int>[1, 2, 3]);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final LibraryInstaller installer = LibraryInstaller(
        prefs: prefs,
        directory: dir,
        bundle: bundle,
      );
      expect(installer.installedVersion, isNull);
      final File f = await installer.ensureInstalled();
      expect(await f.readAsBytes(), <int>[1, 2, 3]);
      expect(installer.installedVersion, '1.0.0');

      bundle.loads = 0;
      await installer.ensureInstalled();
      expect(bundle.loads, 0, reason: 'same version must not copy again');

      String? replacedFrom;
      final LibraryInstaller next = LibraryInstaller(
        prefs: prefs,
        directory: dir,
        bundle: _FakeBundle('1.1.0', <int>[9]),
      );
      await next.ensureInstalled(
        beforeReplace: (File old, String v) async {
          replacedFrom = '${(await old.readAsBytes()).first}->$v';
        },
      );
      expect(replacedFrom, '1->1.1.0');
      expect(await File(next.dbPath).readAsBytes(), <int>[9]);
      expect(
        dir.listSync().where((FileSystemEntity e) => e.path.endsWith('.part')),
        isEmpty,
      );
    });

    test('a missing asset is a typed error, not a crash', () async {
      final LibraryInstaller installer = LibraryInstaller(
        prefs: await SharedPreferences.getInstance(),
        directory: dir,
        bundle: _FakeBundle(null, null),
      );
      await expectLater(
        installer.ensureInstalled(),
        throwsA(isA<LibraryAssetMissing>()),
      );
    });
  });
}

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.version, this.bytes);

  final String? version;
  final List<int>? bytes;
  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    if (key == LibraryInstaller.assetVersion && version != null) {
      return ByteData.sublistView(Uint8List.fromList(version!.codeUnits));
    }
    if (key == LibraryInstaller.assetDb && bytes != null) {
      loads++;
      return ByteData.sublistView(Uint8List.fromList(bytes!));
    }
    throw FlutterError('Unable to load asset: $key');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      String.fromCharCodes((await load(key)).buffer.asUint8List());
}
