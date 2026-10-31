import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/training.dart';
import '../ids.dart';
import '../user/user_db.dart';

/// Starting a session while another is active.
class ActiveSessionExists implements Exception {
  const ActiveSessionExists(this.activeId);

  final String activeId;

  @override
  String toString() => 'ActiveSessionExists($activeId)';
}

/// Workout sessions, their exercises and sets.
///
/// The active workout survives app kill: every set change is written
/// immediately with [upsertSet], never batched in memory.
class SessionRepository {
  SessionRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  // ── Active session ────────────────────────────────────────────────────────

  Future<WorkoutSession?> active() async {
    final WorkoutSessionRow? row = await _activeQuery().getSingleOrNull();
    return row == null ? null : _loadTree(row);
  }

  Stream<String?> watchActiveId() =>
      _activeQuery().watchSingleOrNull().map((WorkoutSessionRow? r) => r?.id);

  /// Starts a session. Throws [ActiveSessionExists] if one is running.
  Future<WorkoutSession> start({
    String? name,
    String? routineId,
    SessionSource source = SessionSource.manual,
    DateTime? startedAt,
  }) => _db.transaction(() async {
    final WorkoutSessionRow? running = await _activeQuery().getSingleOrNull();
    if (running != null) throw ActiveSessionExists(running.id);
    final DateTime now = _clock();
    final WorkoutSession s = WorkoutSession(
      id: newId(),
      name: name,
      startedAt: startedAt ?? now,
      routineId: routineId,
      source: source,
      updatedAt: now,
    );
    await _db.into(_db.workoutSessions).insert(_sessionRow(s));
    return s;
  });

  /// Ends the session and stores its cached summary.
  Future<void> finish(
    String id, {
    required DateTime endedAt,
    int? durationSec,
    double? volumeKg,
    double? caloriesKcal,
    int? perceivedEffort,
    String? notes,
  }) =>
      (_db.update(
        _db.workoutSessions,
      )..where(($WorkoutSessionsTable t) => t.id.equals(id))).write(
        WorkoutSessionsCompanion(
          endedAt: Value<DateTime?>(endedAt),
          durationSec: Value<int?>(durationSec),
          volumeKg: Value<double?>(volumeKg),
          caloriesKcal: Value<double?>(caloriesKcal),
          perceivedEffort: Value<int?>(perceivedEffort),
          notes: notes == null
              ? const Value<String?>.absent()
              : Value<String?>(notes),
          updatedAt: Value<DateTime>(_clock()),
        ),
      );

  // ── Writes during a workout ───────────────────────────────────────────────

  Future<SessionExercise> addExercise(
    String sessionId,
    String exerciseId, {
    int? position,
    int? supersetGroup,
  }) async {
    final int pos = position ?? await _nextExercisePosition(sessionId);
    final SessionExercise se = SessionExercise(
      id: newId(),
      exerciseId: exerciseId,
      position: pos,
      supersetGroup: supersetGroup,
    );
    await _db.transaction(() async {
      await _db.into(_db.sessionExercises).insert(_exerciseRow(sessionId, se));
      await _touch(sessionId);
    });
    return se;
  }

  Future<void> removeExercise(String sessionId, String sessionExerciseId) =>
      _db.transaction(() async {
        await (_db.delete(_db.sessionExercises)..where(
              ($SessionExercisesTable t) => t.id.equals(sessionExerciseId),
            ))
            .go();
        await _touch(sessionId);
      });

  /// Insert or update one set and bump the session's `updatedAt`.
  Future<void> upsertSet(
    String sessionId,
    String sessionExerciseId,
    SetEntry set,
  ) => _db.transaction(() async {
    await _db
        .into(_db.setEntries)
        .insertOnConflictUpdate(_setRow(sessionExerciseId, set));
    await _touch(sessionId);
  });

  Future<void> deleteSet(String sessionId, String setId) =>
      _db.transaction(() async {
        await (_db.delete(
          _db.setEntries,
        )..where(($SetEntriesTable t) => t.id.equals(setId))).go();
        await _touch(sessionId);
      });

  // ── Reads ─────────────────────────────────────────────────────────────────

  Future<WorkoutSession?> byId(String id) async {
    final WorkoutSessionRow? row = await (_db.select(
      _db.workoutSessions,
    )..where(($WorkoutSessionsTable t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _loadTree(row);
  }

  /// Finished sessions, newest first, without their exercises.
  Stream<List<WorkoutSession>> watchHistory({int limit = 50, int offset = 0}) =>
      (_db.select(_db.workoutSessions)
            ..where(($WorkoutSessionsTable t) => t.endedAt.isNotNull())
            ..orderBy(<OrderClauseGenerator<$WorkoutSessionsTable>>[
              ($WorkoutSessionsTable t) => OrderingTerm.desc(t.startedAt),
            ])
            ..limit(limit, offset: offset))
          .watch()
          .map(
            (List<WorkoutSessionRow> rows) => rows
                .map(
                  (WorkoutSessionRow r) => _map(r, const <SessionExercise>[]),
                )
                .toList(),
          );

  Future<int> finishedCount() async {
    final Expression<int> c = _db.workoutSessions.id.count();
    final TypedResult row =
        await (_db.selectOnly(_db.workoutSessions)
              ..addColumns(<Expression<Object>>[c])
              ..where(_db.workoutSessions.endedAt.isNotNull()))
            .getSingle();
    return row.read(c) ?? 0;
  }

  /// The sets of [exerciseId] in the most recent finished session that has
  /// it: what the next session prefills from.
  Future<List<SetEntry>> previousSets(
    String exerciseId, {
    String? excludeSessionId,
  }) async {
    final JoinedSelectStatement<HasResultSet, dynamic> q =
        _db.select(_db.sessionExercises).join(<Join<HasResultSet, dynamic>>[
            innerJoin(
              _db.workoutSessions,
              _db.workoutSessions.id.equalsExp(_db.sessionExercises.sessionId),
            ),
          ])
          ..where(
            _db.sessionExercises.exerciseId.equals(exerciseId) &
                _db.workoutSessions.endedAt.isNotNull() &
                (excludeSessionId == null
                    ? const Constant<bool>(true)
                    : _db.workoutSessions.id.equals(excludeSessionId).not()),
          )
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(_db.workoutSessions.startedAt),
            OrderingTerm.asc(_db.sessionExercises.position),
          ])
          ..limit(1);
    final TypedResult? hit = await q.getSingleOrNull();
    if (hit == null) return const <SetEntry>[];
    final String seId = hit.readTable(_db.sessionExercises).id;
    final List<SetEntryRow> sets =
        await (_db.select(_db.setEntries)
              ..where(($SetEntriesTable t) => t.sessionExerciseId.equals(seId))
              ..orderBy(<OrderClauseGenerator<$SetEntriesTable>>[
                ($SetEntriesTable t) => OrderingTerm.asc(t.position),
              ]))
            .get();
    return sets.map(_mapSet).toList();
  }

  /// Every session with its full tree, for backup and record recomputation.
  Future<List<WorkoutSession>> allWithTree() async {
    final List<WorkoutSessionRow> sessions = await _db
        .select(_db.workoutSessions)
        .get();
    final List<SessionExerciseRow> exercises = await _db
        .select(_db.sessionExercises)
        .get();
    final List<SetEntryRow> sets = await _db.select(_db.setEntries).get();
    final Map<String, List<SetEntry>> setsBy = <String, List<SetEntry>>{};
    for (final SetEntryRow s in sets) {
      (setsBy[s.sessionExerciseId] ??= <SetEntry>[]).add(_mapSet(s));
    }
    final Map<String, List<SessionExercise>> exBy =
        <String, List<SessionExercise>>{};
    for (final SessionExerciseRow e in exercises) {
      (exBy[e.sessionId] ??= <SessionExercise>[]).add(
        _mapExercise(e, _sorted(setsBy[e.id])),
      );
    }
    return <WorkoutSession>[
      for (final WorkoutSessionRow s in sessions)
        _map(
          s,
          (exBy[s.id] ?? <SessionExercise>[])..sort(
            (SessionExercise a, SessionExercise b) => a.position - b.position,
          ),
        ),
    ];
  }

  /// Writes a whole session tree, replacing what was there (restore, edit of
  /// a past session). One transaction.
  Future<void> saveTree(WorkoutSession s) => _db.transaction(() async {
    await _db.into(_db.workoutSessions).insertOnConflictUpdate(_sessionRow(s));
    await (_db.delete(
      _db.sessionExercises,
    )..where(($SessionExercisesTable t) => t.sessionId.equals(s.id))).go();
    await _db.batch((Batch b) {
      for (final SessionExercise e in s.exercises) {
        b.insert(_db.sessionExercises, _exerciseRow(s.id, e));
        b.insertAll(_db.setEntries, <SetEntriesCompanion>[
          for (final SetEntry set in e.sets) _setRow(e.id, set),
        ]);
      }
    });
  });

  Future<void> delete(String id) => (_db.delete(
    _db.workoutSessions,
  )..where(($WorkoutSessionsTable t) => t.id.equals(id))).go();

  // ── Internals ─────────────────────────────────────────────────────────────

  SimpleSelectStatement<$WorkoutSessionsTable, WorkoutSessionRow>
  _activeQuery() =>
      _db.select(_db.workoutSessions)
        ..where(($WorkoutSessionsTable t) => t.endedAt.isNull());

  Future<void> _touch(String sessionId) =>
      (_db.update(
        _db.workoutSessions,
      )..where(($WorkoutSessionsTable t) => t.id.equals(sessionId))).write(
        WorkoutSessionsCompanion(updatedAt: Value<DateTime>(_clock())),
      );

  Future<int> _nextExercisePosition(String sessionId) async {
    final Expression<int> maxPos = _db.sessionExercises.position.max();
    final TypedResult row =
        await (_db.selectOnly(_db.sessionExercises)
              ..addColumns(<Expression<Object>>[maxPos])
              ..where(_db.sessionExercises.sessionId.equals(sessionId)))
            .getSingle();
    final int? m = row.read(maxPos);
    return m == null ? 0 : m + 1;
  }

  Future<WorkoutSession> _loadTree(WorkoutSessionRow row) async {
    final List<SessionExerciseRow> exercises =
        await (_db.select(_db.sessionExercises)
              ..where(($SessionExercisesTable t) => t.sessionId.equals(row.id))
              ..orderBy(<OrderClauseGenerator<$SessionExercisesTable>>[
                ($SessionExercisesTable t) => OrderingTerm.asc(t.position),
              ]))
            .get();
    final List<String> ids = exercises
        .map((SessionExerciseRow e) => e.id)
        .toList();
    final List<SetEntryRow> sets = ids.isEmpty
        ? const <SetEntryRow>[]
        : await (_db.select(_db.setEntries)
                ..where(($SetEntriesTable t) => t.sessionExerciseId.isIn(ids)))
              .get();
    final Map<String, List<SetEntry>> by = <String, List<SetEntry>>{};
    for (final SetEntryRow s in sets) {
      (by[s.sessionExerciseId] ??= <SetEntry>[]).add(_mapSet(s));
    }
    return _map(row, <SessionExercise>[
      for (final SessionExerciseRow e in exercises)
        _mapExercise(e, _sorted(by[e.id])),
    ]);
  }

  static List<SetEntry> _sorted(List<SetEntry>? sets) =>
      (sets ?? <SetEntry>[])
        ..sort((SetEntry a, SetEntry b) => a.position - b.position);

  static WorkoutSessionsCompanion _sessionRow(WorkoutSession s) =>
      WorkoutSessionsCompanion.insert(
        id: s.id,
        name: Value<String?>(s.name),
        startedAt: s.startedAt,
        endedAt: Value<DateTime?>(s.endedAt),
        routineId: Value<String?>(s.routineId),
        notes: Value<String?>(s.notes),
        perceivedEffort: Value<int?>(s.perceivedEffort),
        source: Value<SessionSource>(s.source),
        durationSec: Value<int?>(s.durationSec),
        volumeKg: Value<double?>(s.volumeKg),
        caloriesKcal: Value<double?>(s.caloriesKcal),
        updatedAt: s.updatedAt,
      );

  static SessionExercisesCompanion _exerciseRow(
    String sessionId,
    SessionExercise e,
  ) => SessionExercisesCompanion.insert(
    id: e.id,
    sessionId: sessionId,
    exerciseId: e.exerciseId,
    position: e.position,
    supersetGroup: Value<int?>(e.supersetGroup),
    notes: Value<String?>(e.notes),
  );

  static SetEntriesCompanion _setRow(String sessionExerciseId, SetEntry s) =>
      SetEntriesCompanion.insert(
        id: s.id,
        sessionExerciseId: sessionExerciseId,
        position: s.position,
        type: Value<SetType>(s.type),
        weightKg: Value<double?>(s.weightKg),
        reps: Value<int?>(s.reps),
        durationSec: Value<int?>(s.durationSec),
        distanceM: Value<double?>(s.distanceM),
        rounds: Value<int?>(s.rounds),
        holdSec: Value<int?>(s.holdSec),
        completed: Value<bool>(s.completed),
        isWarmup: Value<bool>(s.isWarmup),
        isPr: Value<bool>(s.isPR),
        completedAt: Value<DateTime?>(s.completedAt),
      );

  static WorkoutSession _map(WorkoutSessionRow r, List<SessionExercise> ex) =>
      WorkoutSession(
        id: r.id,
        name: r.name,
        startedAt: r.startedAt,
        endedAt: r.endedAt,
        routineId: r.routineId,
        notes: r.notes,
        perceivedEffort: r.perceivedEffort,
        source: r.source,
        durationSec: r.durationSec,
        volumeKg: r.volumeKg,
        caloriesKcal: r.caloriesKcal,
        exercises: ex,
        updatedAt: r.updatedAt,
      );

  static SessionExercise _mapExercise(
    SessionExerciseRow e,
    List<SetEntry> sets,
  ) => SessionExercise(
    id: e.id,
    exerciseId: e.exerciseId,
    position: e.position,
    supersetGroup: e.supersetGroup,
    notes: e.notes,
    sets: sets,
  );

  static SetEntry _mapSet(SetEntryRow s) => SetEntry(
    id: s.id,
    position: s.position,
    type: s.type,
    weightKg: s.weightKg,
    reps: s.reps,
    durationSec: s.durationSec,
    distanceM: s.distanceM,
    rounds: s.rounds,
    holdSec: s.holdSec,
    completed: s.completed,
    isWarmup: s.isWarmup,
    isPR: s.isPr,
    completedAt: s.completedAt,
  );
}
