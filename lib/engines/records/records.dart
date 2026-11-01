import '../../core/models/training.dart';

// PURE DART. Personal records from session history. Only completed,
// non-warm-up sets count. Everything is recomputed from the sessions, so
// editing a past set and recomputing gives the new truth.

/// Epley is only trusted up to this many reps.
const int kEpleyMaxReps = 10;

/// Tolerance when deciding that a value strictly beats the previous best.
const double _kEps = 1e-9;

/// One record: the value, where it came from and when.
class RecordEntry {
  const RecordEntry({
    required this.value,
    required this.sessionId,
    required this.date,
    this.setId,
  });

  final double value;

  /// Null for per-session records (volume).
  final String? setId;
  final String sessionId;
  final DateTime date;

  @override
  String toString() => 'RecordEntry($value, set: $setId, session: $sessionId)';
}

/// All records for one exercise. Null / empty when nothing qualifies.
class ExerciseRecords {
  const ExerciseRecords({
    required this.exerciseId,
    this.heaviestWeight,
    this.repsAtWeight = const <double, RecordEntry>{},
    this.bestE1rm,
    this.mostVolumeInSession,
    this.longestHold,
    this.longestDistance,
    this.longestDuration,
  });

  final String exerciseId;

  /// Heaviest weight lifted, kg.
  final RecordEntry? heaviestWeight;

  /// Weight (kg, rounded to the gram) to the most reps done at it.
  final Map<double, RecordEntry> repsAtWeight;

  /// Best Epley estimate, kg.
  final RecordEntry? bestE1rm;

  /// Most weight x reps in one session, kg. [RecordEntry.setId] is null.
  final RecordEntry? mostVolumeInSession;

  /// Longest hold, seconds.
  final RecordEntry? longestHold;

  /// Longest distance in one set, metres.
  final RecordEntry? longestDistance;

  /// Longest timed set, seconds.
  final RecordEntry? longestDuration;
}

class RecordBook {
  const RecordBook(this.byExercise);

  final Map<String, ExerciseRecords> byExercise;

  ExerciseRecords? operator [](String exerciseId) => byExercise[exerciseId];
}

abstract final class Records {
  /// Epley one-rep-max estimate. Null for reps above [kEpleyMaxReps], reps
  /// <= 0 or a non-positive weight. One rep is the weight itself.
  static double? epley1rm(double weightKg, int reps) {
    if (reps <= 0 || reps > kEpleyMaxReps || weightKg <= 0) return null;
    if (reps == 1) return weightKg;
    return weightKg * (1 + reps / 30);
  }

  /// Sum of weight x reps over every counted set in the session.
  static double sessionVolumeKg(WorkoutSession session) {
    double total = 0;
    for (final SessionExercise e in session.exercises) {
      total += _exerciseVolume(e);
    }
    return total;
  }

  /// Records for every exercise. [sessions] may be in any order.
  static RecordBook computeRecords(List<WorkoutSession> sessions) {
    final Map<String, _Builder> builders = <String, _Builder>{};
    for (final WorkoutSession s in _chronological(sessions)) {
      final Map<String, double> volume = <String, double>{};
      for (final SessionExercise e in _orderedExercises(s)) {
        final _Builder b = builders.putIfAbsent(
          e.exerciseId,
          () => _Builder(e.exerciseId),
        );
        volume[e.exerciseId] = (volume[e.exerciseId] ?? 0) + _exerciseVolume(e);
        for (final SetEntry set in _orderedSets(e)) {
          if (!_counts(set)) continue;
          b.add(set, s);
        }
      }
      volume.forEach((String id, double v) {
        if (v > 0) builders[id]!.offerVolume(v, s);
      });
    }
    return RecordBook(<String, ExerciseRecords>{
      for (final MapEntry<String, _Builder> e in builders.entries)
        e.key: e.value.build(),
    });
  }

  /// Ids of sets that strictly beat the previous best for their exercise, at
  /// the time they were done, in any of: heaviest weight, best e1RM, reps at
  /// that weight, longest hold, longest distance. The first set ever done of
  /// an exercise is never a PR, and a category with no earlier value has
  /// nothing to beat.
  static Set<String> prSetIds(List<WorkoutSession> sessions) {
    final Set<String> result = <String>{};
    final Map<String, _Bests> bests = <String, _Bests>{};
    for (final WorkoutSession s in _chronological(sessions)) {
      for (final SessionExercise e in _orderedExercises(s)) {
        final _Bests b = bests.putIfAbsent(e.exerciseId, _Bests.new);
        for (final SetEntry set in _orderedSets(e)) {
          if (!_counts(set)) continue;
          if (b.update(set)) result.add(set.id);
        }
      }
    }
    return result;
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  static bool _counts(SetEntry s) => s.completed && !s.isWarmup;

  static double _setVolume(SetEntry s) {
    final double? w = s.weightKg;
    final int? r = s.reps;
    if (w == null || r == null || w <= 0 || r <= 0) return 0;
    return w * r;
  }

  static double _exerciseVolume(SessionExercise e) {
    double total = 0;
    for (final SetEntry s in e.sets) {
      if (_counts(s)) total += _setVolume(s);
    }
    return total;
  }

  static List<WorkoutSession> _chronological(List<WorkoutSession> sessions) {
    final List<WorkoutSession> sorted = List<WorkoutSession>.of(sessions)
      ..sort((WorkoutSession a, WorkoutSession b) {
        final int c = a.startedAt.compareTo(b.startedAt);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    return sorted;
  }

  static List<SessionExercise> _orderedExercises(WorkoutSession s) {
    return List<SessionExercise>.of(s.exercises)..sort(
      (SessionExercise a, SessionExercise b) =>
          a.position.compareTo(b.position),
    );
  }

  static List<SetEntry> _orderedSets(SessionExercise e) {
    return List<SetEntry>.of(e.sets)
      ..sort((SetEntry a, SetEntry b) => a.position.compareTo(b.position));
  }

  static double _key(double kg) => (kg * 1000).round() / 1000;
}

/// Running bests used by [Records.prSetIds].
class _Bests {
  double? weight;
  double? e1rm;
  double? hold;
  double? distance;
  final Map<double, int> repsAt = <double, int>{};

  /// Folds [s] in and returns whether it beat a previous best.
  bool update(SetEntry s) {
    bool pr = false;
    final double? w = s.weightKg;
    final int? r = s.reps;
    if (w != null && w > 0) {
      final double? prevW = weight;
      if (prevW != null && w > prevW + _kEps) pr = true;
      if (prevW == null || w > prevW) weight = w;

      if (r != null && r > 0) {
        final double? e = Records.epley1rm(w, r);
        if (e != null) {
          final double? prevE = e1rm;
          if (prevE != null && e > prevE + _kEps) pr = true;
          if (prevE == null || e > prevE) e1rm = e;
        }
        final double k = Records._key(w);
        final int? prevR = repsAt[k];
        if (prevR != null && r > prevR) pr = true;
        if (prevR == null || r > prevR) repsAt[k] = r;
      }
    }
    final int? h = s.holdSec;
    if (h != null && h > 0) {
      final double? prev = hold;
      if (prev != null && h > prev + _kEps) pr = true;
      if (prev == null || h > prev) hold = h.toDouble();
    }
    final double? d = s.distanceM;
    if (d != null && d > 0) {
      final double? prev = distance;
      if (prev != null && d > prev + _kEps) pr = true;
      if (prev == null || d > prev) distance = d;
    }
    return pr;
  }
}

class _Builder {
  _Builder(this.exerciseId);

  final String exerciseId;
  RecordEntry? heaviest;
  RecordEntry? e1rm;
  RecordEntry? volume;
  RecordEntry? hold;
  RecordEntry? distance;
  RecordEntry? duration;
  final Map<double, RecordEntry> repsAt = <double, RecordEntry>{};

  RecordEntry _entry(double value, SetEntry s, WorkoutSession session) {
    return RecordEntry(
      value: value,
      setId: s.id,
      sessionId: session.id,
      date: s.completedAt ?? session.startedAt,
    );
  }

  bool _beats(double v, RecordEntry? prev) =>
      prev == null || v > prev.value + _kEps;

  void add(SetEntry s, WorkoutSession session) {
    final double? w = s.weightKg;
    final int? r = s.reps;
    if (w != null && w > 0) {
      if (_beats(w, heaviest)) heaviest = _entry(w, s, session);
      if (r != null && r > 0) {
        final double? e = Records.epley1rm(w, r);
        if (e != null && _beats(e, e1rm)) e1rm = _entry(e, s, session);
        final double k = Records._key(w);
        if (_beats(r.toDouble(), repsAt[k])) {
          repsAt[k] = _entry(r.toDouble(), s, session);
        }
      }
    }
    final int? h = s.holdSec;
    if (h != null && h > 0 && _beats(h.toDouble(), hold)) {
      hold = _entry(h.toDouble(), s, session);
    }
    final double? d = s.distanceM;
    if (d != null && d > 0 && _beats(d, distance)) {
      distance = _entry(d, s, session);
    }
    final int? t = s.durationSec;
    if (t != null && t > 0 && _beats(t.toDouble(), duration)) {
      duration = _entry(t.toDouble(), s, session);
    }
  }

  void offerVolume(double v, WorkoutSession session) {
    if (_beats(v, volume)) {
      volume = RecordEntry(
        value: v,
        sessionId: session.id,
        date: session.startedAt,
      );
    }
  }

  ExerciseRecords build() => ExerciseRecords(
    exerciseId: exerciseId,
    heaviestWeight: heaviest,
    repsAtWeight: Map<double, RecordEntry>.unmodifiable(repsAt),
    bestE1rm: e1rm,
    mostVolumeInSession: volume,
    longestHold: hold,
    longestDistance: distance,
    longestDuration: duration,
  );
}
