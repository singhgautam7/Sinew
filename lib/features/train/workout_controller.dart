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
import '../../engines/records/train_stats.dart';
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
  /// default, else [fallbackSec] (the user's default rest from Settings).
  int restSecFor(String exerciseId, int fallbackSec) =>
      routineItems[exerciseId]?.restSec ??
      exercises[exerciseId]?.defaultRestSec ??
      fallbackSec;

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
    this.prs = const <PrDetail>[],
  });

  final String sessionId;

  /// True when there was no body weight to estimate calories from.
  final bool caloriesSkipped;
  final int prCount;

  /// The record sets with their gains, for the summary.
  final List<PrDetail> prs;
}

/// The records of the workout just finished, handed to the summary so it
/// does not work them out again.
class FinishedPrs {
  const FinishedPrs(this.sessionId, this.prs);

  final String sessionId;
  final List<PrDetail> prs;
}

class LastFinishedPrs extends Notifier<FinishedPrs?> {
  @override
  FinishedPrs? build() => null;

  void put(FinishedPrs value) => state = value;
}

final NotifierProvider<LastFinishedPrs, FinishedPrs?> lastFinishedPrsProvider =
    NotifierProvider<LastFinishedPrs, FinishedPrs?>(LastFinishedPrs.new);

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
/// keeps its state; it follows the active session id, so a workout started
/// from anywhere (Train, Today) loads, and a finished one clears.
///
/// Every change updates the in-memory state at once and is written through a
/// single queue, so writes land in the order they were made and a failed one
/// surfaces to the caller instead of being lost.
class WorkoutController extends AsyncNotifier<WorkoutState?> {
  /// Finished sessions per exercise, each reduced to that exercise and oldest
  /// first: the hints and live PR detection read only these.
  final Map<String, List<WorkoutSession>> _history =
      <String, List<WorkoutSession>>{};

  Future<void> _writes = Future<void>.value();
  bool _closing = false;

  SessionRepository get _repo => ref.read(sessionRepositoryProvider);

  @override
  Future<WorkoutState?> build() async {
    _history.clear();
    _closing = false;
    // The active id drives this provider: starting a workout anywhere makes
    // it load, finishing or discarding one clears it.
    final String? id = await ref.watch(
      trainActiveIdProvider.selectAsync((String? v) => v),
    );
    if (id == null) return null;
    final WorkoutSession? session = await _repo.byId(id);
    if (session == null || session.endedAt != null) return null;
    final Set<String> ids = <String>{
      for (final SessionExercise e in session.exercises) e.exerciseId,
    };
    await _loadHistory(ids, session.id);
    final Map<String, Exercise> exercises = await _resolve(ids);
    final Map<String, List<SetEntry>> previous = <String, List<SetEntry>>{
      for (final String id in ids) id: _previousOf(id),
    };
    final Map<String, RoutineItem> items = <String, RoutineItem>{};
    final String? routineId = session.routineId;
    if (routineId != null) {
      final Routine? routine = await ref
          .read(routineRepositoryProvider)
          .byId(routineId);
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

  /// Reads the finished sessions of [ids] not loaded yet, through the
  /// exercise index (never the whole history).
  Future<void> _loadHistory(Iterable<String> ids, String sessionId) async {
    final List<String> missing = <String>[
      for (final String id in ids)
        if (!_history.containsKey(id)) id,
    ];
    if (missing.isEmpty) return;
    final List<WorkoutSession> found = await _repo.sessionsForExercises(
      missing,
      excludeSessionId: sessionId,
    );
    for (final String id in missing) {
      _history[id] = <WorkoutSession>[
        for (final WorkoutSession s in found)
          if (s.exercises.any((SessionExercise e) => e.exerciseId == id))
            onlyExercises(s, <String>{id}),
      ];
    }
  }

  /// The sets of [exerciseId] in its latest finished session (the hints).
  List<SetEntry> _previousOf(String exerciseId) {
    final List<WorkoutSession>? list = _history[exerciseId];
    if (list == null || list.isEmpty || list.last.exercises.isEmpty) {
      return const <SetEntry>[];
    }
    return list.last.exercises.first.sets;
  }

  WorkoutState? get _cur => state.value;

  DateTime _now() => ref.read(trainNowProvider)();

  /// Runs [job] after every write queued before it. The queue survives a
  /// failed job; the failure goes to the caller.
  Future<void> _enqueue(Future<void> Function() job) {
    if (_closing) return Future<void>.value();
    final Future<void> run = _writes.then((_) => job());
    _writes = run.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return run;
  }

  void _setSession(WorkoutState cur, WorkoutSession s) {
    state = AsyncData<WorkoutState?>(cur.copyWith(session: s));
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

  /// [s] with the record flags of [exerciseIds] recomputed against their
  /// finished history.
  WorkoutSession _flag(WorkoutSession s, Iterable<String> exerciseIds) {
    WorkoutSession out = s;
    for (final String id in exerciseIds.toSet()) {
      final WorkoutSession reduced = onlyExercises(out, <String>{id});
      final Set<String> own = <String>{
        for (final SessionExercise e in reduced.exercises)
          for (final SetEntry set in e.sets) set.id,
      };
      final Map<String, bool> changes = prFlagChanges(<WorkoutSession>[
        ...?_history[id],
        reduced,
      ])..removeWhere((String k, bool _) => !own.contains(k));
      out = applyPrChanges(out, changes);
    }
    return out;
  }

  /// Queues the write of every set that differs between [before] and
  /// [after], in one transaction.
  Future<void> _writeChanged(WorkoutSession before, WorkoutSession after) {
    final Map<String, SetEntry> old = <String, SetEntry>{
      for (final SessionExercise e in before.exercises)
        for (final SetEntry s in e.sets) s.id: s,
    };
    final List<(String, SetEntry)> changed = <(String, SetEntry)>[
      for (final SessionExercise e in after.exercises)
        for (final SetEntry s in e.sets)
          if (old[s.id] != s) (e.id, s),
    ];
    if (changed.isEmpty) return Future<void>.value();
    return _enqueue(() => _repo.upsertSets(after.id, changed));
  }

  // ── Sets ──────────────────────────────────────────────────────────────────

  /// Edits one set (typed values, set type): in memory first, then written.
  /// A completed set's record flags are worked out again.
  Future<void> updateSet(String seId, SetEntry entry) {
    final WorkoutState? cur = _cur;
    final SessionExercise? e = cur?.exerciseById(seId);
    if (cur == null || e == null) return Future<void>.value();
    final WorkoutSession before = cur.session;
    WorkoutSession next = _mapSets(
      before,
      seId,
      (List<SetEntry> sets) => <SetEntry>[
        for (final SetEntry x in sets) x.id == entry.id ? entry : x,
      ],
    );
    if (entry.completed) next = _flag(next, <String>[e.exerciseId]);
    _setSession(cur, next);
    return _writeChanged(before, next);
  }

  /// Marks a set done (or open again) and recomputes PR flags against the
  /// history. Written at once, so the workout survives an app kill.
  Future<void> setCompleted(String seId, String setId, {required bool done}) {
    final WorkoutState? cur = _cur;
    final SessionExercise? e = cur?.exerciseById(seId);
    if (cur == null || e == null) return Future<void>.value();
    final DateTime now = _now();
    final WorkoutSession before = cur.session;
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
    next = _flag(next, <String>[e.exerciseId]);
    _setSession(cur, next);
    return _writeChanged(before, next);
  }

  /// Adds a set after the last one, with the last one's numbers.
  Future<void> addSet(String seId) {
    final WorkoutState? cur = _cur;
    final SessionExercise? e = cur?.exerciseById(seId);
    if (cur == null || e == null || e.sets.length >= TrainSpec.maxSets) {
      return Future<void>.value();
    }
    final TrackingType type = cur.exerciseOf(e.exerciseId).trackingType;
    final SetEntry fresh = setFromTarget(
      type,
      e.sets.length,
      null,
      like: e.sets.isEmpty ? null : e.sets.last,
    );
    final WorkoutSession next = _mapSets(
      cur.session,
      seId,
      (List<SetEntry> sets) => <SetEntry>[...sets, fresh],
    );
    _setSession(cur, next);
    return _enqueue(() => _repo.upsertSet(next.id, seId, fresh));
  }

  /// Removes a set and renumbers the ones after it.
  Future<void> removeSet(String seId, String setId) {
    final WorkoutState? cur = _cur;
    final SessionExercise? e = cur?.exerciseById(seId);
    if (cur == null || e == null) return Future<void>.value();
    final WorkoutSession before = cur.session;
    WorkoutSession next = _mapSets(before, seId, (List<SetEntry> sets) {
      final List<SetEntry> kept = <SetEntry>[
        for (final SetEntry x in sets)
          if (x.id != setId) x,
      ];
      return <SetEntry>[
        for (int i = 0; i < kept.length; i++) kept[i].copyWith(position: i),
      ];
    });
    next = _flag(next, <String>[e.exerciseId]);
    _setSession(cur, next);
    return _enqueue(
      () => _repo.deleteSetWith(
        next.id,
        setId,
        _changedSets(before, next, except: setId),
      ),
    );
  }

  /// Puts a removed set back at [index] (Undo), renumbering the others.
  Future<void> restoreSet(String seId, SetEntry set, int index) {
    final WorkoutState? cur = _cur;
    final SessionExercise? e = cur?.exerciseById(seId);
    if (cur == null ||
        e == null ||
        e.sets.any((SetEntry s) => s.id == set.id)) {
      return Future<void>.value();
    }
    final WorkoutSession before = cur.session;
    WorkoutSession next = _mapSets(before, seId, (List<SetEntry> sets) {
      final List<SetEntry> list = <SetEntry>[...sets]
        ..insert(index.clamp(0, sets.length), set);
      return <SetEntry>[
        for (int i = 0; i < list.length; i++) list[i].copyWith(position: i),
      ];
    });
    next = _flag(next, <String>[e.exerciseId]);
    _setSession(cur, next);
    return _writeChanged(before, next);
  }

  List<(String, SetEntry)> _changedSets(
    WorkoutSession before,
    WorkoutSession after, {
    String? except,
  }) {
    final Map<String, SetEntry> old = <String, SetEntry>{
      for (final SessionExercise e in before.exercises)
        for (final SetEntry s in e.sets) s.id: s,
    };
    return <(String, SetEntry)>[
      for (final SessionExercise e in after.exercises)
        for (final SetEntry s in e.sets)
          if (s.id != except && old[s.id] != s) (e.id, s),
    ];
  }

  // ── Exercises ─────────────────────────────────────────────────────────────

  /// Adds exercises to the end of the workout, each with its starting sets,
  /// in one write.
  Future<void> addExercises(List<String> ids) async {
    final WorkoutState? start = _cur;
    if (start == null) return;
    final Map<String, Exercise> resolved = await _resolve(ids);
    await _loadHistory(ids, start.session.id);
    final WorkoutState? cur = _cur;
    if (cur == null) return;
    final Map<String, List<SetEntry>> previous = <String, List<SetEntry>>{
      for (final String id in ids) id: _previousOf(id),
    };
    final List<SessionExercise> added = <SessionExercise>[];
    for (final String id in ids) {
      final TrackingType type =
          (resolved[id] ?? cur.exercises[id])?.trackingType ??
          TrackingType.reps;
      final int count = defaultSetCount(type, previous[id]!.length);
      added.add(
        SessionExercise(
          id: newId(),
          exerciseId: id,
          position: cur.session.exercises.length + added.length,
          sets: <SetEntry>[
            for (int i = 0; i < count; i++) setFromTarget(type, i, null),
          ],
        ),
      );
    }
    await _saveStructure(
      <SessionExercise>[...cur.session.exercises, ...added],
      exercises: <String, Exercise>{...cur.exercises, ...resolved},
      previous: <String, List<SetEntry>>{...cur.previous, ...previous},
    );
  }

  /// Swaps an exercise for another. Sets already done stay logged under the
  /// old exercise; the open ones move to the new one, targets kept.
  Future<void> swapExercise(String seId, String newExerciseId) async {
    final WorkoutState? start = _cur;
    final SessionExercise? old = start?.exerciseById(seId);
    if (start == null || old == null || old.exerciseId == newExerciseId) {
      return;
    }
    final Map<String, Exercise> resolved = await _resolve(<String>[
      newExerciseId,
    ]);
    await _loadHistory(<String>[newExerciseId], start.session.id);
    final WorkoutState? cur = _cur;
    final SessionExercise? now = cur?.exerciseById(seId);
    if (cur == null || now == null) return;
    final List<SetEntry> prev = _previousOf(newExerciseId);
    final List<SetEntry> done = <SetEntry>[
      for (final SetEntry s in now.sets)
        if (s.completed) s,
    ];
    final List<SetEntry> open = <SetEntry>[
      for (final SetEntry s in now.sets)
        if (!s.completed) s,
    ];
    final TrackingType type =
        (resolved[newExerciseId] ?? cur.exercises[newExerciseId])
            ?.trackingType ??
        TrackingType.reps;
    final SessionExercise replacement = SessionExercise(
      id: newId(),
      exerciseId: newExerciseId,
      position: now.position,
      supersetGroup: now.supersetGroup,
      notes: now.notes,
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
    for (final SessionExercise e in cur.session.exercises) {
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
      exercises: <String, Exercise>{...cur.exercises, ...resolved},
      previous: <String, List<SetEntry>>{...cur.previous, newExerciseId: prev},
    );
  }

  Future<void> removeExercise(String seId) {
    final WorkoutState? cur = _cur;
    if (cur == null || cur.exerciseById(seId) == null) {
      return Future<void>.value();
    }
    final String sessionId = cur.session.id;
    _setSession(
      cur,
      cur.session.copyWith(
        exercises: <SessionExercise>[
          for (final SessionExercise e in cur.session.exercises)
            if (e.id != seId) e,
        ],
      ),
    );
    return _enqueue(() => _repo.removeExercise(sessionId, seId));
  }

  /// Puts a removed exercise (with its sets) back at [index] (Undo).
  Future<void> restoreExercise(SessionExercise exercise, int index) {
    final WorkoutState? cur = _cur;
    if (cur == null || cur.exerciseById(exercise.id) != null) {
      return Future<void>.value();
    }
    final List<SessionExercise> list = <SessionExercise>[
      ...cur.session.exercises,
    ]..insert(index.clamp(0, cur.session.exercises.length), exercise);
    return _saveStructure(list);
  }

  Future<void> setNotes(String seId, String? notes) {
    final WorkoutState? cur = _cur;
    if (cur == null) return Future<void>.value();
    final String? clean = (notes == null || notes.trim().isEmpty)
        ? null
        : notes.trim();
    return _saveStructure(<SessionExercise>[
      for (final SessionExercise e in cur.session.exercises)
        if (e.id == seId) e.copyWith(notes: clean) else e,
    ]);
  }

  /// Links the exercise to the next one as a superset, or unlinks it.
  Future<void> toggleSupersetWithNext(String seId) {
    final WorkoutState? cur = _cur;
    if (cur == null) return Future<void>.value();
    final List<SessionExercise> list = cur.session.exercises;
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

  /// Writes the whole exercise list (positions renumbered) in one go. The
  /// in-memory state changes at once; the write is queued.
  Future<void> _saveStructure(
    List<SessionExercise> list, {
    Map<String, Exercise>? exercises,
    Map<String, List<SetEntry>>? previous,
  }) {
    final WorkoutState? cur = _cur;
    if (cur == null) return Future<void>.value();
    final WorkoutSession next = cur.session.copyWith(
      exercises: <SessionExercise>[
        for (int i = 0; i < list.length; i++) list[i].copyWith(position: i),
      ],
      updatedAt: _now(),
    );
    state = AsyncData<WorkoutState?>(
      cur.copyWith(session: next, exercises: exercises, previous: previous),
    );
    return _enqueue(() => _repo.saveTree(next));
  }

  // ── Ending ────────────────────────────────────────────────────────────────

  /// Deletes the workout and everything in it. A no-op when none is running.
  Future<void> discard() async {
    final WorkoutState? cur = _cur;
    if (cur == null) return;
    await _writes;
    _closing = true;
    try {
      await ref.read(trainRestProvider.notifier).end();
      await _repo.delete(cur.session.id);
    } on Object {
      _closing = false;
      rethrow;
    }
    state = const AsyncData<WorkoutState?>(null);
  }

  /// Ends the workout: drops unfinished sets, computes duration, volume,
  /// calories and PR flags (from the history of the exercises done only), and
  /// closes the session in one transaction. Null when no workout is running.
  Future<FinishOutcome?> finish() async {
    final WorkoutState? cur = _cur;
    if (cur == null) return null;
    await _writes; // everything typed so far is stored
    _closing = true;
    try {
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
              for (int i = 0; i < done.length; i++)
                done[i].copyWith(position: i),
            ],
          ),
        );
      }
      final WorkoutSession cleaned = cur.session.copyWith(
        exercises: kept,
        endedAt: end,
      );

      // Record flags over the history of the exercises done: this workout's
      // own, and any other session they move (a backdated one).
      final Set<String> ids = <String>{
        for (final SessionExercise e in kept) e.exerciseId,
      };
      await _loadHistory(ids, cleaned.id);
      final List<WorkoutSession> history = <WorkoutSession>[
        for (final String id in ids) ...?_history[id],
      ];
      final Map<String, bool> changes = prFlagChanges(<WorkoutSession>[
        ...history,
        cleaned,
      ]);
      final WorkoutSession flagged = applyPrChanges(cleaned, changes);
      final Set<String> own = <String>{
        for (final SessionExercise e in flagged.exercises)
          for (final SetEntry s in e.sets) s.id,
      };
      final Map<String, bool> others = <String, bool>{
        for (final MapEntry<String, bool> c in changes.entries)
          if (!own.contains(c.key)) c.key: c.value,
      };

      final double volume = Records.sessionVolumeKg(flagged);
      final int duration = end.difference(flagged.startedAt).inSeconds;

      // Calories need a body weight and MET values; without them skip. All
      // computed before anything is written.
      double? calories;
      final latest = await ref
          .read(measurementRepositoryProvider)
          .latestValues();
      final double? weightKg = latest['weight']?.value;
      if (weightKg != null) {
        final Map<String, Exercise> resolved = <String, Exercise>{
          ...await _resolve(<String>[
            for (final String id in ids)
              if (!cur.exercises.containsKey(id)) id,
          ]),
          for (final MapEntry<String, Exercise> e in cur.exercises.entries)
            if (ids.contains(e.key)) e.key: e.value,
        };
        final Map<String, double?> met = <String, double?>{
          for (final MapEntry<String, Exercise> e in resolved.entries)
            e.key: e.value.metValue,
        };
        final result = BodyStats.estimateSessionCalories(
          flagged,
          met,
          weightKg,
        );
        if (result is StatValue<double>) calories = result.value;
      }

      final WorkoutSession finished = flagged.copyWith(
        durationSec: duration < 0 ? 0 : duration,
        volumeKg: volume,
        caloriesKcal: calories,
      );
      await _repo.finishWithFlags(finished, prChanges: others);

      // The records before this workout, for the gains on the summary.
      final List<PrDetail> prs = prDetails(
        finished,
        Records.computeRecords(history),
      );
      ref
          .read(lastFinishedPrsProvider.notifier)
          .put(FinishedPrs(finished.id, prs));
      await ref.read(trainRestProvider.notifier).end();
      state = const AsyncData<WorkoutState?>(null);
      return FinishOutcome(
        sessionId: finished.id,
        caloriesSkipped: weightKg == null,
        prCount: prs.length,
        prs: prs,
      );
    } on Object {
      _closing = false;
      rethrow;
    }
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
  /// created. A routine's exercises and sets are written with the session in
  /// one transaction. The workout screen follows the active session id, so
  /// nothing else needs refreshing.
  Future<({String id, bool resumed})> start({Routine? routine}) async {
    final SessionRepository repo = _ref.read(sessionRepositoryProvider);
    final List<SessionExercise> exercises = routine == null
        ? const <SessionExercise>[]
        : await _seed(routine);
    try {
      final WorkoutSession s = await repo.start(
        name: routine?.name,
        routineId: routine?.id,
        source: routine == null ? SessionSource.manual : SessionSource.routine,
        startedAt: _ref.read(trainNowProvider)(),
        exercises: exercises,
      );
      return (id: s.id, resumed: false);
    } on ActiveSessionExists catch (e) {
      return (id: e.activeId, resumed: true);
    }
  }

  /// The routine's items as session exercises with their target sets.
  Future<List<SessionExercise>> _seed(Routine r) async {
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
    return <SessionExercise>[
      for (int p = 0; p < items.length; p++)
        SessionExercise(
          id: newId(),
          exerciseId: items[p].exerciseId,
          position: p,
          supersetGroup: items[p].supersetGroup,
          sets: <SetEntry>[
            for (
              int i = 0;
              i < items[p].targetSets.clamp(1, TrainSpec.maxSets);
              i++
            )
              setFromTarget(
                exercises[items[p].exerciseId]?.trackingType ??
                    TrackingType.reps,
                i,
                items[p],
              ),
          ],
        ),
    ];
  }
}

final Provider<WorkoutLauncher> workoutLauncherProvider =
    Provider<WorkoutLauncher>((Ref ref) => WorkoutLauncher(ref));
