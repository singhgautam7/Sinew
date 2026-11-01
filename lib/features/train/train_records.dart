import '../../core/db/repositories/session_repository.dart';
import '../../core/models/training.dart';
import '../../engines/records/records.dart';

// Glue between sessions and the records engine. The maths is the engine's
// (`Records`); this only applies its answer to the stored `isPR` flags.

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

/// Recomputes PR flags over every session and writes the ones that changed.
///
/// [replace] is a session just edited (it is saved too, with its volume
/// refreshed if it is finished). Used after editing or deleting a past
/// session, and at finish.
Future<void> recomputePrFlags(
  SessionRepository repo, {
  WorkoutSession? replace,
}) async {
  final List<WorkoutSession> stored = await repo.allWithTree();
  final List<WorkoutSession> all = <WorkoutSession>[
    for (final WorkoutSession s in stored)
      if (replace != null && s.id == replace.id) replace else s,
  ];
  if (replace != null && !all.any((WorkoutSession s) => s.id == replace.id)) {
    all.add(replace);
  }
  final Set<String> pr = Records.prSetIds(all);
  for (final WorkoutSession s in all) {
    WorkoutSession next = withPrFlags(s, pr);
    final bool edited = replace != null && s.id == replace.id;
    if (edited && next.endedAt != null) {
      next = next.copyWith(volumeKg: Records.sessionVolumeKg(next));
    }
    if (edited || !identical(next, s)) await repo.saveTree(next);
  }
}
