import '../../core/models/enums.dart';
import '../../core/models/timer_preset.dart';
import '../../core/models/training.dart';
import 'timer_run.dart';

// PURE DART.

/// Turns a finished (or stopped) run into a workout session for "Log as
/// workout". [end] is the snapshot at the end of the run.
///
/// Rule:
/// - A step is *completed* when the run finished naturally, or its index is
///   below the step the run stopped in (skipped steps count as completed;
///   the step a stop interrupted does not).
/// - One [SessionExercise] per distinct `exerciseId` among completed work
///   steps, in order of first appearance. Each completed work step becomes a
///   set: `holdSec` for yoga flows (poses are holds), otherwise `durationSec`.
///   Durations are the step's effective length.
/// - If no step carries an exercise id at all, a single generic entry with
///   exerciseId `timer-<mode>` holds one set: `durationSec` is the active
///   elapsed time and `rounds` is the user's AMRAP count for AMRAP, else the
///   number of completed work steps (omitted when zero).
/// - startedAt/endedAt come from the run, `durationSec` is active elapsed
///   time (pauses excluded), `source` is [SessionSource.timer].
WorkoutSession sessionFromRun(
  TimerRun run,
  TimerSnapshot end, {
  String? name,
  required String Function() newId,
}) {
  final DateTime startedAt = DateTime.fromMillisecondsSinceEpoch(
    run.startedAtMs,
    isUtc: true,
  );
  final DateTime endedAt = DateTime.fromMillisecondsSinceEpoch(
    end.endedAtMs ?? end.atMs,
    isUtc: true,
  );
  final int durationSec = (end.totalElapsedMs / 1000).round();
  final bool natural = end.finished && !end.stopped;
  final int completed = natural ? run.steps.length : end.stepIndex;

  final bool anyExercise = run.steps.any(
    (TimerStepSpec s) => s.exerciseId != null,
  );
  final List<String> order = <String>[];
  final Map<String, List<SetEntry>> byExercise = <String, List<SetEntry>>{};
  int completedWork = 0;
  for (int i = 0; i < completed && i < run.steps.length; i++) {
    final TimerStepSpec s = run.steps[i];
    if (s.phase != TimerPhase.work) continue;
    completedWork++;
    final String? ex = s.exerciseId;
    if (ex == null) continue;
    final int sec = ((run.effectiveDurationMs(i) ?? 0) / 1000).round();
    final List<SetEntry> sets = byExercise.putIfAbsent(ex, () {
      order.add(ex);
      return <SetEntry>[];
    });
    final bool hold = run.mode == TimerMode.yogaFlow;
    sets.add(
      SetEntry(
        id: newId(),
        position: sets.length,
        completed: true,
        durationSec: hold ? null : sec,
        holdSec: hold ? sec : null,
      ),
    );
  }

  final List<SessionExercise> exercises = <SessionExercise>[];
  if (anyExercise) {
    for (int i = 0; i < order.length; i++) {
      exercises.add(
        SessionExercise(
          id: newId(),
          exerciseId: order[i],
          position: i,
          sets: byExercise[order[i]]!,
        ),
      );
    }
  } else {
    final int rounds = run.mode == TimerMode.amrap
        ? end.amrapRounds
        : completedWork;
    exercises.add(
      SessionExercise(
        id: newId(),
        exerciseId: 'timer-${run.mode.name}',
        position: 0,
        sets: <SetEntry>[
          SetEntry(
            id: newId(),
            position: 0,
            completed: true,
            durationSec: durationSec,
            rounds: rounds > 0 ? rounds : null,
          ),
        ],
      ),
    );
  }

  return WorkoutSession(
    id: newId(),
    name: name,
    startedAt: startedAt,
    endedAt: endedAt,
    source: SessionSource.timer,
    durationSec: durationSec,
    exercises: exercises,
    updatedAt: endedAt,
  );
}
