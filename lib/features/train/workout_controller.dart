import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/ids.dart';
import '../../core/db/repositories/exercise_repository.dart';
import '../../core/db/repositories/session_repository.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../engines/body_stats/body_stats.dart';
import '../../engines/records/records.dart';
import 'rest_timer.dart';
import 'train_providers.dart';
import 'train_records.dart';

/// Everything the active workout screen shows, loaded once and then edited in
/// memory and in the database together (every change is written at once).
class WorkoutState {
  const WorkoutState({
    required this.session,
    required this.exercises,
    required this.previous,
    required this.routineItems,
  });

  final WorkoutSession session;

  /// By exercise id.
  final Map<String, Exercise> exercises;

  /// The sets of each exercise in its last finished session (the hints).
  final Map<String, List<SetEntry>> previous;

  /// The routine's items by exercise id (targets, rest), if started from one.
  final Map<String, RoutineItem> routineItems;

  WorkoutState copyWith({
    WorkoutSession? session,
    Map<String, Exercise>? exercises,
    Map<String, List<SetEntry>>? previous,
  }) => WorkoutState(
    session: session ?? this.session,
    exercises: exercises ?? this.exercises,
    previous: previous ?? this.previous,
    routineItems: routineItems,
  );

  /// The exercise, or a stand-in reading as reps when it cannot be resolved
  /// (the library is unavailable), so the workout still works.
  Exercise exerciseOf(String id) =>
      exercises[id] ??
      Exercise(
        id: id,
        name: id.replaceAll('-', ' '),
        category: 'unknown',
        trackingType: TrackingType.reps,
      );

  /// Rest after a set of [exerciseId]: the routine's, else the exercise's
  /// default, else 90 s.
  int restSecFor(String exerciseId) =>
      routineItems[exerciseId]?.restSec ??
      exercises[exerciseId]?.defaultRestSec ??
      TrainSpec.defaultRestSec;

  SessionExercise? exerciseById(String sessionExerciseId) {
    for (final SessionExercise e in session.exercises) {
      if (e.id == sessionExerciseId) return e;
    }
    return null;
  }

  int get completedSets => session.exercises.fold<int>(
    0,
    (int n, SessionExercise e) =>
        n + e.sets.where((SetEntry s) => s.completed).length,
  );

  int get totalSets => session.exercises.fold<int>(
    0,
    (int n, SessionExercise e) => n + e.sets.length,
  );
}

/// What finishing a workout produced.
class FinishOutcome {
  const FinishOutcome({
    required this.sessionId,
    required this.caloriesSkipped,
    required this.prCount,
  });

  final String sessionId;

  /// True when there was no body weight to estimate calories from.
  final bool caloriesSkipped;
  final int prCount;
}

/// A set filled from a routine item's targets, shaped by the tracking type.
SetEntry setFromTarget(
  TrackingType type,
  int position,
  RoutineItem? item, {
  SetEntry? like,
}) {
  final SetEntry base = SetEntry(id: newId(), position: position);
  if (item != null) {
    return switch (type) {
      TrackingType.weightReps => base.copyWith(
        weightKg: item.targetWeightKg,
        reps: item.targetReps,
      ),
      TrackingType.reps ||
      TrackingType.unknown => base.copyWith(reps: item.targetReps),
      TrackingType.time => base.copyWith(durationSec: item.targetDurationSec),
      TrackingType.distanceTime => base.copyWith(
        distanceM: item.targetDistanceM,
        durationSec: item.targetDurationSec,
      ),
      TrackingType.rounds || TrackingType.flow => base.copyWith(
        rounds: item.targetReps,
        durationSec: item.targetDurationSec,
      ),
      TrackingType.hold => base.copyWith(holdSec: item.targetDurationSec),
    };
  }
  if (like != null) {
    return base.copyWith(
      weightKg: like.weightKg,
      reps: like.reps,
      durationSec: like.durationSec,
      distanceM: like.distanceM,
      rounds: like.rounds,
      holdSec: like.holdSec,
    );
  }
  return base;
}

/// How many sets a new exercise starts with.
int defaultSetCount(TrackingType type, int previousCount) {
  if (previousCount > 0) return previousCount.clamp(1, TrainSpec.maxSets);
  return switch (type) {
    TrackingType.weightReps ||
    TrackingType.reps ||
    TrackingType.unknown => TrainSpec.defaultSetCount,
    _ => 1,
  };
}

/// Owns the one active workout. Not auto-disposed, so a minimised workout
/// keeps its state; a cold start rebuilds it from `SessionRepository.active()`.
class WorkoutController extends AsyncNotifier<WorkoutState?> {
  /// Finished sessions, for live PR detection.
  List<WorkoutSession> _history = const <WorkoutSession>[];

  SessionRepository get _repo => ref.read(sessionRepositoryProvider);

  @override
  Future<WorkoutState?> build() async {
    final WorkoutSession? session = await _repo.active();
    if (session == null) return null;
    final List<WorkoutSession> all = await _repo.allWithTree();
    _history = <WorkoutSession>[
      for (final WorkoutSession s in all)
        if (s.endedAt != null) s,
    ];
    final Set<String> ids = <String>{
      for (final SessionExercise e in session.exercises) e.exerciseId,
    };
    final Map<String, Exercise> exercises = await _resolve(ids);
    final Map<String, List<SetEntry>> previous = <String, List<SetEntry>>{
      for (final String id in ids)
        id: await _repo.previousSets(id, excludeSessionId: session.id),
    };
    final Map<String, RoutineItem> items = <String, RoutineItem>{};
    final String? routineId = session.routineId;
    if (routineId != null) {
      final routine = await ref.read(routineRepositoryProvider).byId(routineId);
      for (final RoutineItem i in routine?.items ?? const <RoutineItem>[]) {
        items.putIfAbsent(i.exerciseId, () => i);
      }
    }
    return WorkoutState(
      session: session,
      exercises: exercises,
      previous: previous,
      routineItems: items,
    );
  }

  Future<Map<String, Exercise>> _resolve(Iterable<String> ids) async {
    if (ids.isEmpty) return <String, Exercise>{};
    try {
      final ExerciseResolver resolver = await ref.read(
        exerciseResolverProvider.future,
      );
      return await resolver.resolve(ids);
    } on Object {
      // No library (not installed yet): the workout still runs, with ids as
      // names and reps as the tracking type.
      return <String, Exercise>{};
    }
  }

  WorkoutState get _s => state.requireValue!;

  DateTime _now() => ref.read(trainNowProvider)();

  void _replaceSession(WorkoutSession s) {
    state = AsyncData<WorkoutState?>(_s.copyWith(session: s));
  }

  WorkoutSession _mapSets(
    WorkoutSession s,
    String seId,
    List<SetEntry> Function(List<SetEntry>) f,
  ) => s.copyWith(
    exercises: <SessionExercise>[
      for (final SessionExercise e in s.exercises)
        if (e.id == seId) e.copyWith(sets: f(e.sets)) else e,
    ],
  );

  // ── Sets ──────────────────────────────────────────────────────────────────

  /// Edits one set (typed values, set type): in memory first, then written.
  Future<void> updateSet(String seId, SetEntry entry) {
    final WorkoutSession next = _mapSets(
      _s.session,
      seId,
      (List<SetEntry> sets) => <SetEntry>[
        for (final SetEntry x in sets) x.id == entry.id ? entry : x,
      ],
    );
    _replaceSession(next);
    return _repo.upsertSet(next.id, seId, entry);
  }

  /// Marks a set done (or open again) and recomputes PR flags against the
  /// history. Written at once, so the workout survives an app kill.
  Future<void> setCompleted(String seId, String setId, {required bool done}) {
    final DateTime now = _now();
    final WorkoutSession before = _s.session;
    WorkoutSession next = _mapSets(
      before,
      seId,
      (List<SetEntry> sets) => <SetEntry>[
        for (final SetEntry x in sets)
          if (x.id == setId)
            x.copyWith(
              completed: done,
              completedAt: done ? now : null,
              isPR: false,
            )
          else
            x,
      ],
    );
    final Set<String> pr = Records.prSetIds(<WorkoutSession>[
      ..._history,
      next,
    ]);
    next = withPrFlags(next, pr);
    _replaceSession(next);
    return _writeChanged(before, next);
  }

  Future<void> _writeChanged(
    WorkoutSession before,
    WorkoutSession after,
  ) async {
    final Map<String, SetEntry> old = <String, SetEntry>{
      for (final SessionExercise e in before.exercises)
        for (final SetEntry s in e.sets) s.id: s,
    };
    for (final SessionExercise e in after.exercises) {
      for (final SetEntry s in e.sets) {
        if (old[s.id] != s) await _repo.upsertSet(after.id, e.id, s);
      }
    }
  }

  /// Adds a set after the last one, with the last one's numbers.
  Future<void> addSet(String seId) {
    final SessionExercise e = _s.exerciseById(seId)!;
    if (e.sets.length >= TrainSpec.maxSets) return Future<void>.value();
    final TrackingType type = _s.exerciseOf(e.exerciseId).trackingType;
    final SetEntry fresh = setFromTarget(
      type,
      e.sets.length,
      null,
      like: e.sets.isEmpty ? null : e.sets.last,
    );
    final WorkoutSession next = _mapSets(
      _s.session,
      seId,
      (List<SetEntry> sets) => <SetEntry>[...sets, fresh],
    );
    _replaceSession(next);
    return _repo.upsertSet(next.id, seId, fresh);
  }

  /// Removes a set and renumbers the ones after it.
  Future<void> removeSet(String seId, String setId) async {
    final WorkoutSession before = _s.session;
    final WorkoutSession next = _mapSets(before, seId, (List<SetEntry> sets) {
      final List<SetEntry> kept = <SetEntry>[
        for (final SetEntry x in sets)
          if (x.id != setId) x,
      ];
      return <SetEntry>[
        for (int i = 0; i < kept.length; i++) kept[i].copyWith(position: i),
      ];
    });
    _replaceSession(next);
    await _repo.deleteSet(next.id, setId);
    await _writeChanged(before, next);
  }

  // ── Exercises ─────────────────────────────────────────────────────────────

  /// Adds exercises to the end of the workout, each with its starting sets.
  Future<void> addExercises(List<String> ids) async {
    final Map<String, Exercise> resolved = await _resolve(ids);
    final Map<String, List<SetEntry>> previous = <String, List<SetEntry>>{};
    final List<SessionExercise> added = <SessionExercise>[];
    for (final String id in ids) {
      final String sessionId = _s.session.id;
      final SessionExercise se = await _repo.addExercise(sessionId, id);
      final List<SetEntry> prev = await _repo.previousSets(
        id,
        excludeSessionId: sessionId,
      );
      previous[id] = prev;
      final TrackingType type =
          (resolved[id] ?? _s.exercises[id])?.trackingType ?? TrackingType.reps;
      final List<SetEntry> sets = <SetEntry>[
        for (int i = 0; i < defaultSetCount(type, prev.length); i++)
          setFromTarget(type, i, null),
      ];
      for (final SetEntry set in sets) {
        await _repo.upsertSet(sessionId, se.id, set);
      }
      added.add(se.copyWith(sets: sets));
    }
    final WorkoutState cur = _s;
    state = AsyncData<WorkoutState?>(
      cur.copyWith(
        session: cur.session.copyWith(
          exercises: <SessionExercise>[...cur.session.exercises, ...added],
        ),
        exercises: <String, Exercise>{...cur.exercises, ...resolved},
        previous: <String, List<SetEntry>>{...cur.previous, ...previous},
      ),
    );
  }

  /// Swaps an exercise for another. Sets already done stay logged under the
  /// old exercise; the open ones move to the new one, targets kept.
  Future<void> swapExercise(String seId, String newExerciseId) async {
    final SessionExercise? old = _s.exerciseById(seId);
    if (old == null || old.exerciseId == newExerciseId) return;
    final Map<String, Exercise> resolved = await _resolve(<String>[
      newExerciseId,
    ]);
    final List<SetEntry> prev = await _repo.previousSets(
      newExerciseId,
      excludeSessionId: _s.session.id,
    );
    final List<SetEntry> done = <SetEntry>[
      for (final SetEntry s in old.sets)
        if (s.completed) s,
    ];
    final List<SetEntry> open = <SetEntry>[
      for (final SetEntry s in old.sets)
        if (!s.completed) s,
    ];
    final TrackingType type =
        (resolved[newExerciseId] ?? _s.exercises[newExerciseId])
            ?.trackingType ??
        TrackingType.reps;
    final SessionExercise replacement = SessionExercise(
      id: newId(),
      exerciseId: newExerciseId,
      position: old.position,
      supersetGroup: old.supersetGroup,
      notes: old.notes,
      sets: open.isEmpty
          ? <SetEntry>[
              for (int i = 0; i < defaultSetCount(type, prev.length); i++)
                setFromTarget(type, i, null),
            ]
          : <SetEntry>[
              for (int i = 0; i < open.length; i++)
                open[i].copyWith(position: i),
            ],
    );
    final List<SessionExercise> list = <SessionExercise>[];
    for (final SessionExercise e in _s.session.exercises) {
      if (e.id != seId) {
        list.add(e);
        continue;
      }
      if (done.isEmpty) {
        list.add(replacement);
      } else {
        list
          ..add(
            e.copyWith(
              sets: <SetEntry>[
                for (int i = 0; i < done.length; i++)
                  done[i].copyWith(position: i),
              ],
            ),
          )
          ..add(replacement);
      }
    }
    await _saveStructure(
      list,
      exercises: <String, Exercise>{..._s.exercises, ...resolved},
      previous: <String, List<SetEntry>>{..._s.previous, newExerciseId: prev},
    );
  }

  Future<void> removeExercise(String seId) async {
    final String sessionId = _s.session.id;
    final WorkoutSession next = _s.session.copyWith(
      exercises: <SessionExercise>[
        for (final SessionExercise e in _s.session.exercises)
          if (e.id != seId) e,
      ],
    );
    _replaceSession(next);
    await _repo.removeExercise(sessionId, seId);
  }

  Future<void> setNotes(String seId, String? notes) {
    final String? clean = (notes == null || notes.trim().isEmpty)
        ? null
        : notes.trim();
    return _saveStructure(<SessionExercise>[
      for (final SessionExercise e in _s.session.exercises)
        if (e.id == seId) e.copyWith(notes: clean) else e,
    ]);
  }

  /// Links the exercise to the next one as a superset, or unlinks it.
  Future<void> toggleSupersetWithNext(String seId) {
    final List<SessionExercise> list = _s.session.exercises;
    final int i = list.indexWhere((SessionExercise e) => e.id == seId);
    if (i < 0 || i + 1 >= list.length) return Future<void>.value();
    final SessionExercise a = list[i];
    final SessionExercise b = list[i + 1];
    final bool linked =
        a.supersetGroup != null && a.supersetGroup == b.supersetGroup;
    int maxGroup = 0;
    for (final SessionExercise e in list) {
      if ((e.supersetGroup ?? 0) > maxGroup) maxGroup = e.supersetGroup!;
    }
    final List<SessionExercise> next = <SessionExercise>[...list];
    if (linked) {
      next[i + 1] = b.copyWith(supersetGroup: null);
    } else {
      final int group = a.supersetGroup ?? maxGroup + 1;
      next[i] = a.copyWith(supersetGroup: group);
      next[i + 1] = b.copyWith(supersetGroup: group);
    }
    // A group of one is not a superset.
    final Map<int, int> sizes = <int, int>{};
    for (final SessionExercise e in next) {
      final int? g = e.supersetGroup;
      if (g != null) sizes[g] = (sizes[g] ?? 0) + 1;
    }
    return _saveStructure(<SessionExercise>[
      for (final SessionExercise e in next)
        if (e.supersetGroup != null && sizes[e.supersetGroup] == 1)
          e.copyWith(supersetGroup: null)
        else
          e,
    ]);
  }

  /// Writes the whole exercise list (positions renumbered) in one go.
  Future<void> _saveStructure(
    List<SessionExercise> list, {
    Map<String, Exercise>? exercises,
    Map<String, List<SetEntry>>? previous,
  }) async {
    final WorkoutSession next = _s.session.copyWith(
      exercises: <SessionExercise>[
        for (int i = 0; i < list.length; i++) list[i].copyWith(position: i),
      ],
      updatedAt: _now(),
    );
    state = AsyncData<WorkoutState?>(
      _s.copyWith(session: next, exercises: exercises, previous: previous),
    );
    await _repo.saveTree(next);
  }

  // ── Ending ────────────────────────────────────────────────────────────────

  /// Deletes the workout and everything in it.
  Future<void> discard() async {
    final String id = _s.session.id;
    await ref.read(trainRestProvider.notifier).end();
    await _repo.delete(id);
    state = const AsyncData<WorkoutState?>(null);
  }

  /// Ends the workout: drops unfinished sets, computes duration, volume, PR
  /// flags (over all sessions, writing the ones that changed) and calories,
  /// then closes the session.
  Future<FinishOutcome> finish() async {
    final WorkoutState cur = _s;
    final DateTime end = _now();
    // Only what was done is kept.
    final List<SessionExercise> kept = <SessionExercise>[];
    for (final SessionExercise e in cur.session.exercises) {
      final List<SetEntry> done = <SetEntry>[
        for (final SetEntry s in e.sets)
          if (s.completed) s,
      ];
      if (done.isEmpty) continue;
      kept.add(
        e.copyWith(
          position: kept.length,
          sets: <SetEntry>[
            for (int i = 0; i < done.length; i++) done[i].copyWith(position: i),
          ],
        ),
      );
    }
    final WorkoutSession cleaned = cur.session.copyWith(
      exercises: kept,
      endedAt: end,
    );

    // PR flags over every session including this one.
    final List<WorkoutSession> stored = await _repo.allWithTree();
    final List<WorkoutSession> all = <WorkoutSession>[
      for (final WorkoutSession s in stored)
        if (s.id != cleaned.id) s,
      cleaned,
    ];
    final Set<String> pr = Records.prSetIds(all);
    for (final WorkoutSession s in all) {
      if (s.id == cleaned.id) continue;
      final WorkoutSession flagged = withPrFlags(s, pr);
      if (!identical(flagged, s)) await _repo.saveTree(flagged);
    }
    final WorkoutSession flagged = withPrFlags(cleaned, pr);
    await _repo.saveTree(flagged);
    final int prCount = <SetEntry>[
      for (final SessionExercise e in flagged.exercises)
        for (final SetEntry s in e.sets)
          if (s.isPR) s,
    ].length;

    final double volume = Records.sessionVolumeKg(flagged);
    final int duration = end.difference(flagged.startedAt).inSeconds;

    // Calories need a body weight and MET values; without them skip.
    double? calories;
    final latest = await ref.read(measurementRepositoryProvider).latestValues();
    final double? weightKg = latest['weight']?.value;
    if (weightKg != null) {
      final Map<String, Exercise> resolved = await _resolve(<String>{
        for (final SessionExercise e in flagged.exercises) e.exerciseId,
      });
      final Map<String, double?> met = <String, double?>{
        for (final MapEntry<String, Exercise> e in resolved.entries)
          e.key: e.value.metValue,
      };
      final result = BodyStats.estimateSessionCalories(flagged, met, weightKg);
      if (result is StatValue<double>) calories = result.value;
    }

    await _repo.finish(
      flagged.id,
      endedAt: end,
      durationSec: duration < 0 ? 0 : duration,
      volumeKg: volume,
      caloriesKcal: calories,
    );
    await ref.read(trainRestProvider.notifier).end();
    state = const AsyncData<WorkoutState?>(null);
    return FinishOutcome(
      sessionId: flagged.id,
      caloriesSkipped: weightKg == null,
      prCount: prCount,
    );
  }
}

final AsyncNotifierProvider<WorkoutController, WorkoutState?> workoutProvider =
    AsyncNotifierProvider<WorkoutController, WorkoutState?>(
      WorkoutController.new,
    );

/// Starts (or resumes) workouts.
class WorkoutLauncher {
  WorkoutLauncher(this._ref);

  final Ref _ref;

  /// Starts an empty workout, or one from [routine]. When a workout is
  /// already running its id comes back with `resumed: true` and nothing is
  /// created.
  Future<({String id, bool resumed})> start({Routine? routine}) async {
    final SessionRepository repo = _ref.read(sessionRepositoryProvider);
    try {
      final WorkoutSession s = await repo.start(
        name: routine?.name,
        routineId: routine?.id,
        source: routine == null ? SessionSource.manual : SessionSource.routine,
        startedAt: _ref.read(trainNowProvider)(),
      );
      if (routine != null) await _seed(repo, s.id, routine);
      _ref.invalidate(workoutProvider);
      return (id: s.id, resumed: false);
    } on ActiveSessionExists catch (e) {
      return (id: e.activeId, resumed: true);
    }
  }

  Future<void> _seed(
    SessionRepository repo,
    String sessionId,
    Routine r,
  ) async {
    Map<String, Exercise> exercises = <String, Exercise>{};
    try {
      final ExerciseResolver resolver = await _ref.read(
        exerciseResolverProvider.future,
      );
      exercises = await resolver.resolve(<String>{
        for (final RoutineItem i in r.items) i.exerciseId,
      });
    } on Object {
      // Without a library every exercise reads as reps.
    }
    final List<RoutineItem> items = <RoutineItem>[...r.items]
      ..sort((RoutineItem a, RoutineItem b) => a.position - b.position);
    for (int p = 0; p < items.length; p++) {
      final RoutineItem item = items[p];
      final SessionExercise se = await repo.addExercise(
        sessionId,
        item.exerciseId,
        position: p,
        supersetGroup: item.supersetGroup,
      );
      final TrackingType type =
          exercises[item.exerciseId]?.trackingType ?? TrackingType.reps;
      for (int i = 0; i < item.targetSets.clamp(1, TrainSpec.maxSets); i++) {
        await repo.upsertSet(sessionId, se.id, setFromTarget(type, i, item));
      }
    }
  }
}

final Provider<WorkoutLauncher> workoutLauncherProvider =
    Provider<WorkoutLauncher>((Ref ref) => WorkoutLauncher(ref));
