import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/session_repository.dart';
import '../../core/models/exercise.dart';
import '../../core/models/plate_inventory.dart';
import '../../core/models/profile.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../library/exercise_picker.dart';

/// The exercise picker, behind a provider so tests can hand back ids without
/// opening the Library UI. Defaults to the Library feature's [pickExercises].
typedef ExercisePicker = Future<List<String>?> Function(
  BuildContext context, {
  bool multiple,
  Set<String> exclude,
  String? title,
});

final Provider<ExercisePicker> exercisePickerProvider =
    Provider<ExercisePicker>((Ref ref) => pickExercises);

/// Epoch milliseconds now. Everything time-based in Train (the rest timer,
/// the elapsed clock) reads this, so tests inject a fake clock.
typedef NowMs = int Function();

final Provider<NowMs> trainNowMsProvider = Provider<NowMs>(
  (Ref ref) =>
      () => DateTime.now().millisecondsSinceEpoch,
);

/// The wall-clock time for stamps (set completion, finish).
final Provider<DateTime Function()> trainNowProvider =
    Provider<DateTime Function()>((Ref ref) {
      final NowMs ms = ref.watch(trainNowMsProvider);
      return () => DateTime.fromMillisecondsSinceEpoch(ms());
    });

/// Routines in order, with their items (cards show counts and muscles).
final StreamProvider<List<Routine>> trainRoutinesProvider =
    StreamProvider.autoDispose<List<Routine>>((Ref ref) {
      final repo = ref.watch(routineRepositoryProvider);
      return repo.watchAll().asyncMap((List<Routine> _) async {
        final List<Routine> all = await repo.allWithItems();
        return all.where((Routine r) => !r.archived).toList()
          ..sort((Routine a, Routine b) {
            final int c = a.position.compareTo(b.position);
            return c != 0 ? c : a.name.compareTo(b.name);
          });
      });
    });

/// The id of the running workout, or null.
final StreamProvider<String?> trainActiveIdProvider =
    StreamProvider.autoDispose<String?>(
      (Ref ref) => ref.watch(sessionRepositoryProvider).watchActiveId(),
    );

final StreamProvider<Profile> trainProfileProvider =
    StreamProvider.autoDispose<Profile>(
      (Ref ref) => ref.watch(profileRepositoryProvider).watch(),
    );

final StreamProvider<PlateInventory> trainPlateInventoryProvider =
    StreamProvider.autoDispose<PlateInventory>(
      (Ref ref) => ref.watch(plateInventoryRepositoryProvider).watch(),
    );

/// A stable family key for a set of exercise ids.
String exerciseKey(Iterable<String> ids) =>
    (ids.toSet().toList()..sort()).join(',');

/// Exercises (library, custom or tombstone) by id, keyed by [exerciseKey].
final trainExercisesProvider = FutureProvider.autoDispose
    .family<Map<String, Exercise>, String>((Ref ref, String key) async {
      if (key.isEmpty) return <String, Exercise>{};
      final resolver = await ref.watch(exerciseResolverProvider.future);
      return resolver.resolve(key.split(','));
    });

/// One exercise's finished sessions (each reduced to that exercise), oldest
/// first, read through the exercise index. Refreshes when history changes.
final trainExerciseSessionsProvider = FutureProvider.autoDispose
    .family<List<WorkoutSession>, String>((Ref ref, String exerciseId) {
      ref.watch(trainHistoryTickProvider);
      return ref
          .watch(sessionRepositoryProvider)
          .sessionsForExercise(exerciseId);
    });

/// Personal-record counts of the sessions on screen (ids joined by commas),
/// keyed by session id.
final trainPrCountsProvider = FutureProvider.autoDispose
    .family<Map<String, int>, String>((Ref ref, String sessionKey) {
      ref.watch(trainHistoryTickProvider);
      return ref
          .watch(sessionRepositoryProvider)
          .prCounts(
            sessionKey.isEmpty ? const <String>[] : sessionKey.split(','),
          );
    });

/// Finished sessions of one calendar month, without their sets (the History
/// heatmap and its totals).
final trainMonthSessionsProvider = FutureProvider.autoDispose
    .family<List<SessionHeader>, DateTime>((Ref ref, DateTime month) {
      ref.watch(trainHistoryTickProvider);
      return ref
          .watch(sessionRepositoryProvider)
          .sessionHeaders(
            from: DateTime(month.year, month.month),
            to: DateTime(month.year, month.month + 1),
          );
    });

/// Completed sets per exercise in the week starting [weekStart].
final trainWeekSetCountsProvider = FutureProvider.autoDispose
    .family<Map<String, int>, DateTime>((Ref ref, DateTime weekStart) {
      ref.watch(trainHistoryTickProvider);
      return ref
          .watch(sessionRepositoryProvider)
          .completedSetCounts(
            from: weekStart,
            to: DateTime(weekStart.year, weekStart.month, weekStart.day + 7),
          );
    });

/// Counts every change to the sessions table, so cached reads refresh.
final StreamProvider<int> trainHistoryTickProvider =
    StreamProvider.autoDispose<int>((Ref ref) {
      int n = 0;
      return ref
          .watch(sessionRepositoryProvider)
          .watchHistory(limit: 1)
          .map((List<WorkoutSession> _) => ++n);
    });

/// One session with its tree (history detail, summary).
final trainSessionProvider = FutureProvider.autoDispose
    .family<WorkoutSession?, String>(
      (Ref ref, String id) => ref.watch(sessionRepositoryProvider).byId(id),
    );

/// The latest finished sessions (newest first, no exercises), for "last
/// done" lines.
final StreamProvider<List<WorkoutSession>> trainRecentSessionsProvider =
    StreamProvider.autoDispose<List<WorkoutSession>>(
      (Ref ref) =>
          ref.watch(sessionRepositoryProvider).watchHistory(limit: 100),
    );
