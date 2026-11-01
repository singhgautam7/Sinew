import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/library/library_db.dart';
import 'db/library/library_installer.dart';
import 'db/repositories/exercise_repository.dart';
import 'db/repositories/exercise_search_service.dart';
import 'db/repositories/library_upgrade.dart';
import 'db/repositories/measurement_repository.dart';
import 'db/repositories/plate_inventory_repository.dart';
import 'db/repositories/profile_repository.dart';
import 'db/repositories/routine_repository.dart';
import 'db/repositories/runtime_state_repository.dart';
import 'db/repositories/session_repository.dart';
import 'db/repositories/timer_preset_repository.dart';
import 'db/user/user_db.dart';
import 'settings/app_settings.dart';

/// Riverpod 3 retries a failed provider with backoff by default. Sinew has
/// no network, so every failure is deterministic: a retry only keeps a screen
/// in its loading state instead of showing the error. Set on the root scope.
Duration? noRetry(int retryCount, Object error) => null;

/// The provider graph for data access. Widgets never touch a database: they
/// read a repository from here (Riverpod is the DI).

/// Overridden in `main` with the instance opened during bootstrap, and in
/// tests with `UserDatabase.forTesting(NativeDatabase.memory())`.
final Provider<UserDatabase> userDatabaseProvider = Provider<UserDatabase>(
  (Ref ref) =>
      throw UnimplementedError('userDatabaseProvider must be overridden'),
);

final FutureProvider<LibraryInstaller> libraryInstallerProvider =
    FutureProvider<LibraryInstaller>(
      (Ref ref) => LibraryInstaller.forApp(ref.watch(prefsProvider)),
    );

/// The read-only exercise library, installed on first use. Errors with
/// [LibraryAssetMissing] until Phase 2 ships the asset; screens show their
/// error state rather than crash.
final FutureProvider<LibraryDatabase> libraryDatabaseProvider =
    FutureProvider<LibraryDatabase>((Ref ref) async {
      final LibraryInstaller installer = await ref.watch(
        libraryInstallerProvider.future,
      );
      // A library update may drop exercises the user already logged: keep
      // their names as tombstones so history never goes blank.
      final LibraryUpgrade upgrade = LibraryUpgrade(
        custom: ref.watch(customExerciseRepositoryProvider),
      );
      final File file = await installer.ensureInstalled(
        beforeReplace: upgrade.snapshot,
      );
      await upgrade.complete(file);
      final LibraryDatabase db = LibraryDatabase.openReadOnly(file);
      ref.onDispose(db.close);
      return db;
    });

final FutureProvider<LibraryRepository> libraryRepositoryProvider =
    FutureProvider<LibraryRepository>(
      (Ref ref) async =>
          LibraryRepository(await ref.watch(libraryDatabaseProvider.future)),
    );

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>(
      (Ref ref) => ProfileRepository(ref.watch(userDatabaseProvider)),
    );

final Provider<CustomExerciseRepository> customExerciseRepositoryProvider =
    Provider<CustomExerciseRepository>(
      (Ref ref) => CustomExerciseRepository(ref.watch(userDatabaseProvider)),
    );

final Provider<RoutineRepository> routineRepositoryProvider =
    Provider<RoutineRepository>(
      (Ref ref) => RoutineRepository(ref.watch(userDatabaseProvider)),
    );

final Provider<SessionRepository> sessionRepositoryProvider =
    Provider<SessionRepository>(
      (Ref ref) => SessionRepository(ref.watch(userDatabaseProvider)),
    );

final Provider<MeasurementRepository> measurementRepositoryProvider =
    Provider<MeasurementRepository>(
      (Ref ref) => MeasurementRepository(ref.watch(userDatabaseProvider)),
    );

final Provider<TimerPresetRepository> timerPresetRepositoryProvider =
    Provider<TimerPresetRepository>(
      (Ref ref) => TimerPresetRepository(ref.watch(userDatabaseProvider)),
    );

final Provider<PlateInventoryRepository> plateInventoryRepositoryProvider =
    Provider<PlateInventoryRepository>(
      (Ref ref) => PlateInventoryRepository(ref.watch(userDatabaseProvider)),
    );

final Provider<RuntimeStateRepository> runtimeStateRepositoryProvider =
    Provider<RuntimeStateRepository>(
      (Ref ref) => RuntimeStateRepository(ref.watch(userDatabaseProvider)),
    );

final FutureProvider<ExerciseResolver> exerciseResolverProvider =
    FutureProvider<ExerciseResolver>(
      (Ref ref) async => ExerciseResolver(
        custom: ref.watch(customExerciseRepositoryProvider),
        library: await ref.watch(libraryRepositoryProvider.future),
      ),
    );

/// Library plus the user's own exercises in one search.
final FutureProvider<ExerciseSearchService> exerciseSearchServiceProvider =
    FutureProvider<ExerciseSearchService>(
      (Ref ref) async => ExerciseSearchService(
        library: await ref.watch(libraryRepositoryProvider.future),
        custom: ref.watch(customExerciseRepositoryProvider),
      ),
    );
