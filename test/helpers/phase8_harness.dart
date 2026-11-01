import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/app.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/db/library/library_installer.dart';
import 'package:sinew/core/db/repositories/backup_repository.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/repositories/seed_repository.dart';
import 'package:sinew/core/db/seeds/measurement_seed.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/wallpaper_seed.dart';
import 'package:sinew/features/backup/backup_io.dart';
import 'package:sinew/features/backup/backup_service.dart';
import 'package:sinew/features/today/today_providers.dart';

import 'backup_fixtures.dart';
import 'test_db.dart';

/// A stand-in for the phone's file picker and share sheet.
class FakeBackupIo implements BackupFileIo {
  /// What the next [pickText] returns (null cancels).
  PickedTextFile? toPick;

  /// Every [save] call: file name to bytes.
  final Map<String, Uint8List> saved = <String, Uint8List>{};
  final List<List<String>> shared = <List<String>>[];
  bool saveResult = true;

  @override
  Future<PickedTextFile?> pickText() async => toPick;

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
    String mimeType = 'application/octet-stream',
  }) async {
    if (saveResult) saved[fileName] = bytes;
    return saveResult;
  }

  @override
  Future<void> share(
    List<({String name, Uint8List bytes, String mimeType})> files,
  ) async {
    shared.add(<String>[for (final f in files) f.name]);
  }
}

/// Everything a Phase 8 test needs, wired the way `main` wires the app.
class Harness {
  Harness({
    required this.db,
    required this.prefs,
    required this.io,
    required this.overrides,
  });

  final UserDatabase db;
  final SharedPreferences prefs;
  final FakeBackupIo io;
  final List<Override> overrides;

  ProviderContainer container(WidgetTester tester, Finder f) =>
      ProviderScope.containerOf(tester.element(f));
}

/// A phone-sized view (360 x 780 at 1x) and an optional text scale.
void usePhone(WidgetTester tester, {double textScale = 1}) {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Builds the overrides and database; [library] is an optional built library
/// file, otherwise the library reports itself missing.
Future<Harness> makeHarness({
  Map<String, Object> prefs = const <String, Object>{},
  bool onboarded = true,
  bool seedMeasurements = true,
  File? library,
  DateTime Function()? clock,
  List<Override> extra = const <Override>[],
  UserDatabase? database,
  Color? wallpaper,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AppSettings.kOnboarded: onboarded,
    ...prefs,
  });
  final SharedPreferences p = await SharedPreferences.getInstance();
  final UserDatabase db = database ?? memoryUserDb();
  addTearDown(db.close);
  if (seedMeasurements) {
    await MeasurementSeed.seed(SeedRepository(db));
  }
  final FakeBackupIo io = FakeBackupIo();
  LibraryDatabase? libDb;
  if (library != null) {
    libDb = LibraryDatabase.openReadOnly(library);
    addTearDown(libDb.close);
  }
  return Harness(
    db: db,
    prefs: p,
    io: io,
    overrides: <Override>[
      prefsProvider.overrideWithValue(p),
      userDatabaseProvider.overrideWithValue(db),
      seedSourceProvider.overrideWithValue(() async => wallpaper),
      backupFileIoProvider.overrideWithValue(io),
      if (clock != null) todayClockOverride(clock),
      if (libDb != null)
        libraryRepositoryProvider.overrideWith(
          (Ref ref) async => LibraryRepository(libDb!),
        )
      else
        libraryRepositoryProvider.overrideWith(
          (Ref ref) async =>
              throw const LibraryAssetMissing(LibraryInstaller.assetDb),
        ),
      ...extra,
    ],
  );
}

/// Overrides the Today clock without importing the feature in every test.
Override todayClockOverride(DateTime Function() clock) =>
    todayClockProvider.overrideWithValue(clock);

/// Pumps the whole app at [location] (or the default start route).
Future<Harness> pumpSinew(
  WidgetTester tester, {
  Map<String, Object> prefs = const <String, Object>{},
  bool onboarded = true,
  bool seedMeasurements = true,
  String? location,
  File? library,
  DateTime Function()? clock,
  Future<void> Function(UserDatabase db)? seed,
  List<Override> extra = const <Override>[],
  bool settle = true,
  Color? wallpaper,
}) async {
  final Harness h = await makeHarness(
    wallpaper: wallpaper,
    prefs: prefs,
    onboarded: onboarded,
    seedMeasurements: seedMeasurements,
    library: library,
    clock: clock,
    extra: extra,
  );
  if (seed != null) await seed(h.db);
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: h.overrides,
      child: SinewApp(initialLocation: location),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return h;
}

/// Unmounts the app and lets Drift's stream cleanup timers fire, so the test
/// ends with nothing pending. Call at the end of any test that read streams.
Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 10));
}

/// A real backup file's text, exported from a fully populated database.
Future<String> makeBackupJson({int sessions = 3}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final UserDatabase db = memoryUserDb();
  await populate(db, sessions: sessions);
  final BackupService service = BackupService(
    repository: BackupRepository(db),
    prefs: prefs,
  );
  final BackupFile file = await service.export(markBackedUp: false);
  await db.close();
  return file.contents;
}
