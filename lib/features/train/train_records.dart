import '../../core/db/repositories/session_repository.dart';
import '../../core/models/training.dart';
import '../../engines/records/records.dart';
import '../../engines/records/train_stats.dart';

// Glue between sessions and the records engine. The maths is the engine's
// (`Records`, `prFlagChanges`); this only applies its answer to the stored
// `isPR` flags.

/// [s] with every set's `isPR` set from [prSetIds]. Returns the same instance
/// when nothing changes.
WorkoutSession withPrFlags(WorkoutSession s, Set<String> prSetIds) {
  bool changed = false;
  final List<SessionExercise> exercises = <SessionExercise>[];
  for (final SessionExercise e in s.exercises) {
    bool exChanged = false;
    final List<SetEntry> sets = <SetEntry>[];
    for (final SetEntry set in e.sets) {
      final bool pr = set.completed && prSetIds.contains(set.id);
      if (pr != set.isPR) {
        exChanged = true;
        sets.add(set.copyWith(isPR: pr));
      } else {
        sets.add(set);
      }
    }
    if (exChanged) changed = true;
    exercises.add(exChanged ? e.copyWith(sets: sets) : e);
  }
  return changed ? s.copyWith(exercises: exercises) : s;
}

/// [s] with the flags in [changes] (set id to flag) applied. Same instance
/// when none of them is in [s].
WorkoutSession applyPrChanges(WorkoutSession s, Map<String, bool> changes) {
  if (changes.isEmpty) return s;
  bool changed = false;
  final List<SessionExercise> exercises = <SessionExercise>[];
  for (final SessionExercise e in s.exercises) {
    final List<SetEntry> sets = <SetEntry>[];
    bool exChanged = false;
    for (final SetEntry set in e.sets) {
      final bool? flag = changes[set.id];
      if (flag != null && flag != set.isPR) {
        exChanged = true;
        sets.add(set.copyWith(isPR: flag));
      } else {
        sets.add(set);
      }
    }
    if (exChanged) changed = true;
    exercises.add(exChanged ? e.copyWith(sets: sets) : e);
  }
  return changed ? s.copyWith(exercises: exercises) : s;
}

/// [s] reduced to the exercises in [ids].
WorkoutSession onlyExercises(WorkoutSession s, Set<String> ids) => s.copyWith(
  exercises: <SessionExercise>[
    for (final SessionExercise e in s.exercises)
      if (ids.contains(e.exerciseId)) e,
  ],
);

/// Recomputes record flags after a past session was edited or deleted and
/// writes only what changed (the `is_pr` column, in one batch).
///
/// Only the exercises involved can change: [exerciseIds] (and those of
/// [replace]) are re-read through the exercise index, never the whole
/// history. [replace] is the session as edited: it is saved too (volume
/// refreshed when finished). The running workout is never touched. With
/// neither argument every finished session is recomputed (after a restore).
Future<void> recomputePrFlags(
  SessionRepository repo, {
  WorkoutSession? replace,
  Iterable<String>? exerciseIds,
}) async {
  final Set<String> ids = <String>{
    ...?exerciseIds,
    if (replace != null)
      for (final SessionExercise e in replace.exercises) e.exerciseId,
  };
  final bool everything = replace == null && exerciseIds == null;
  if (!everything && ids.isEmpty && replace == null) return;

  final List<WorkoutSession> stored = everything
      ? <WorkoutSession>[
          for (final WorkoutSession s in await repo.allWithTree())
            if (s.endedAt != null) s,
        ]
      : await repo.sessionsForExercises(ids);
  final List<WorkoutSession> all = <WorkoutSession>[
    for (final WorkoutSession s in stored)
      if (replace == null || s.id != replace.id) s,
    if (replace != null) everything ? replace : onlyExercises(replace, ids),
  ];
  final Map<String, bool> changes = prFlagChanges(all);
  if (replace == null) {
    await repo.setPrFlags(changes);
    return;
  }
  WorkoutSession next = applyPrChanges(replace, changes);
  if (next.endedAt != null) {
    next = next.copyWith(volumeKg: Records.sessionVolumeKg(next));
  }
  final Set<String> own = <String>{
    for (final SessionExercise e in replace.exercises)
      for (final SetEntry s in e.sets) s.id,
  };
  await repo.saveTreeWithFlags(next, <String, bool>{
    for (final MapEntry<String, bool> e in changes.entries)
      if (!own.contains(e.key)) e.key: e.value,
  });
}
