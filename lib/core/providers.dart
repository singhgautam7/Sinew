import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/library/library_db.dart';
import 'db/library/library_installer.dart';
import 'db/repositories/exercise_repository.dart';
import 'db/repositories/backup_repository.dart';
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
import '../features/backup/backup_service.dart';
import '../features/backup/csv_export.dart';
import 'settings/app_settings.dart';
import 'models/plate_inventory.dart';
import 'models/training.dart';
import 'models/profile.dart';
import '../features/body/body_providers.dart';
import '../features/library/library_providers.dart';
import '../features/timer/controller/timer_presets_provider.dart';
import '../features/today/today_providers.dart';
import '../features/train/exercise_history_screen.dart';
import '../features/train/history_screen.dart';
import '../features/train/routine_style.dart';
import '../features/train/train_providers.dart';
import '../features/train/workout_controller.dart';
import '../features/train/workout_summary_screen.dart';

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

/// The profile, live. The one provider every feature watches (Today, Body,
/// More, Settings); defaults when none is saved.
final StreamProvider<Profile> currentProfileProvider =
    StreamProvider.autoDispose<Profile>(
      (Ref ref) => ref.watch(profileRepositoryProvider).watch(),
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

/// The plate inventory, live (defaults when none is saved).
final StreamProvider<PlateInventory> currentPlateInventoryProvider =
    StreamProvider.autoDispose<PlateInventory>(
      (Ref ref) => ref.watch(plateInventoryRepositoryProvider).watch(),
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

// ── Backup ──────────────────────────────────────────────────────────────────

final Provider<BackupRepository> backupRepositoryProvider =
    Provider<BackupRepository>(
      (Ref ref) => BackupRepository(ref.watch(userDatabaseProvider)),
    );

/// When the last export was made (`backup.lastAt`), or null if never.
class LastBackupAtNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => BackupService.readLastBackupAt(ref.watch(prefsProvider));

  /// Re-reads the preference after the service wrote it.
  void refresh() =>
      state = BackupService.readLastBackupAt(ref.read(prefsProvider));
}

final NotifierProvider<LastBackupAtNotifier, DateTime?> lastBackupAtProvider =
    NotifierProvider<LastBackupAtNotifier, DateTime?>(LastBackupAtNotifier.new);

final Provider<BackupService> backupServiceProvider = Provider<BackupService>(
  (Ref ref) => BackupService(
    repository: ref.watch(backupRepositoryProvider),
    prefs: ref.watch(prefsProvider),
    onBackedUp: () => ref.read(lastBackupAtProvider.notifier).refresh(),
    onSettingsRestored: () => ref.invalidate(settingsProvider),
    onDataRestored: () => onDataRestored(ref),
  ),
);

/// The single hook a restore calls once the database was rewritten: every
/// provider that caches what a restore can change is invalidated here, so no
/// screen keeps showing the data from before. Add a provider to this list when
/// it caches (or streams) user data.
void onDataRestored(Ref ref) {
  ref
    ..invalidate(currentProfileProvider)
    ..invalidate(currentPlateInventoryProvider)
    ..invalidate(shouldRemindBackupProvider)
    ..invalidate(sessionChangeProvider)
    ..invalidate(bodyFieldsProvider)
    ..invalidate(bodyEntriesProvider)
    ..invalidate(bodyOverviewProvider)
    ..invalidate(todayBodyProvider)
    ..invalidate(todaySummaryProvider)
    ..invalidate(activeSessionIdProvider)
    ..invalidate(timerPresetsProvider)
    ..invalidate(workoutProvider)
    ..invalidate(trainActiveIdProvider)
    ..invalidate(trainRoutinesProvider)
    ..invalidate(trainFinishedTreesProvider)
    ..invalidate(trainHistoryProvider)
    ..invalidate(trainRecentSessionsProvider)
    ..invalidate(exerciseHistoryProvider)
    ..invalidate(summaryProvider)
    ..invalidate(routineStyleProvider)
    ..invalidate(customExercisesProvider)
    ..invalidate(recentSummariesProvider);
}

final FutureProvider<CsvExportService> csvExportServiceProvider =
    FutureProvider<CsvExportService>(
      (Ref ref) async => CsvExportService(
        measurements: ref.watch(measurementRepositoryProvider),
        sessions: ref.watch(sessionRepositoryProvider),
        resolver: await ref.watch(exerciseResolverProvider.future),
      ),
    );

/// How many finished workouts without a backup before the reminder shows.
const int backupReminderSessions = 10;

/// Ticks whenever the sessions table changes (a workout starts, is saved,
/// finished or deleted), so anything derived from the history refreshes.
final StreamProvider<int> sessionChangeProvider = StreamProvider<int>((
  Ref ref,
) {
  int n = 0;
  return ref
      .watch(sessionRepositoryProvider)
      .watchHistory(limit: 1)
      .map((List<WorkoutSession> _) => ++n);
});

/// True when the user has never backed up and has logged at least
/// [backupReminderSessions] finished workouts. Refreshes when a workout
/// finishes.
final FutureProvider<bool> shouldRemindBackupProvider = FutureProvider<bool>((
  Ref ref,
) async {
  if (ref.watch(lastBackupAtProvider) != null) return false;
  ref.watch(sessionChangeProvider);
  final int finished = await ref
      .watch(sessionRepositoryProvider)
      .finishedCount();
  return finished >= backupReminderSessions;
});
