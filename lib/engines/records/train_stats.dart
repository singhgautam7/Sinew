import '../../core/models/training.dart';
import 'records.dart';

// PURE DART. The sums behind the Train screens: routine length estimates,
// record deltas for the finish summary, the History calendar and the weekly
// muscle load. Widgets only format what these return.

/// Rough work time per set, in seconds, for "about N min" estimates.
const int kEstimatedWorkSecPerSet = 40;

/// Rest assumed when neither the routine nor the settings say otherwise.
const int kFallbackRestSec = 90;

/// Rough minutes for a routine: work plus rest for every set, rounded to
/// 5 minutes. Zero for an empty routine. [defaultRestSec] is the rest for
/// items without their own (the user's default rest).
int estimateRoutineMinutes(
  List<RoutineItem> items, {
  int defaultRestSec = kFallbackRestSec,
}) {
  if (items.isEmpty) return 0;
  int seconds = 0;
  for (final RoutineItem i in items) {
    seconds +=
        i.targetSets *
        (kEstimatedWorkSecPerSet + (i.restSec ?? defaultRestSec));
  }
  final int minutes = ((seconds / 60) / 5).round() * 5;
  return minutes < 5 ? 5 : minutes;
}

// ── Records at finish ───────────────────────────────────────────────────────

/// One personal-record set of a finished workout, with how much it beat the
/// previous best estimate by.
class PrDetail {
  const PrDetail({
    required this.exerciseId,
    required this.set,
    this.e1rmKg,
    this.e1rmDeltaKg,
  });

  final String exerciseId;
  final SetEntry set;

  /// Estimated one-rep max of the set, kg, when it has weight and reps.
  final double? e1rmKg;

  /// How much it beat the previous best estimate by, kg; null when there was
  /// no earlier estimate or it did not beat it.
  final double? e1rmDeltaKg;
}

/// The PR sets of [session] (those flagged `isPR`), each with its estimated
/// one-rep max and the gain over [before], the records of every earlier
/// session.
List<PrDetail> prDetails(WorkoutSession session, RecordBook before) {
  final List<PrDetail> out = <PrDetail>[];
  for (final SessionExercise e in session.exercises) {
    for (final SetEntry s in e.sets) {
      if (!s.isPR) continue;
      final double? w = s.weightKg;
      final int? r = s.reps;
      final double? e1 = (w != null && r != null)
          ? Records.epley1rm(w, r)
          : null;
      final double? prev = before[e.exerciseId]?.bestE1rm?.value;
      out.add(
        PrDetail(
          exerciseId: e.exerciseId,
          set: s,
          e1rmKg: e1,
          e1rmDeltaKg: (e1 != null && prev != null && e1 > prev)
              ? e1 - prev
              : null,
        ),
      );
    }
  }
  return out;
}

/// `isPR` flags that differ from what [Records.prSetIds] says over
/// [sessions], as set id to the new flag. Only completed sets can be PRs.
Map<String, bool> prFlagChanges(List<WorkoutSession> sessions) {
  final Set<String> pr = Records.prSetIds(sessions);
  final Map<String, bool> out = <String, bool>{};
  for (final WorkoutSession s in sessions) {
    for (final SessionExercise e in s.exercises) {
      for (final SetEntry set in e.sets) {
        final bool want = set.completed && pr.contains(set.id);
        if (want != set.isPR) out[set.id] = want;
      }
    }
  }
  return out;
}

// ── History calendar ────────────────────────────────────────────────────────

/// The local calendar day (midnight) of [d].
DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

/// Sessions per calendar day, keyed by [dayOf].
Map<DateTime, int> sessionsPerDay(Iterable<DateTime> starts) {
  final Map<DateTime, int> out = <DateTime, int>{};
  for (final DateTime s in starts) {
    final DateTime d = dayOf(s);
    out[d] = (out[d] ?? 0) + 1;
  }
  return out;
}

/// Heat step 0 (none) to 4 (four or more) for a day's session count.
int heatLevel(int sessions) =>
    sessions <= 0 ? 0 : (sessions > 4 ? 4 : sessions);

/// The weeks of [month] (Monday first), seven days each; days outside the
/// month are null.
List<List<DateTime?>> monthGrid(DateTime month) {
  final DateTime first = DateTime(month.year, month.month);
  final int days = DateTime(month.year, month.month + 1, 0).day;
  final int lead = first.weekday - 1;
  final List<DateTime?> cells = <DateTime?>[
    for (int i = 0; i < lead; i++) null,
    for (int d = 1; d <= days; d++) DateTime(month.year, month.month, d),
  ];
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return <List<DateTime?>>[
    for (int i = 0; i < cells.length; i += 7) cells.sublist(i, i + 7),
  ];
}

// ── Weekly muscle load ──────────────────────────────────────────────────────

/// Sets per muscle from sets per exercise: a set counts fully for each of the
/// exercise's primary muscles and half for each secondary one.
/// [musclesOf] maps an exercise id to its muscles.
Map<String, double> muscleLoad(
  Map<String, int> setsByExercise,
  Map<String, ({List<String> primary, List<String> secondary})> musclesOf,
) {
  final Map<String, double> out = <String, double>{};
  setsByExercise.forEach((String id, int sets) {
    final ({List<String> primary, List<String> secondary})? m = musclesOf[id];
    if (m == null || sets <= 0) return;
    for (final String p in m.primary) {
      out[p] = (out[p] ?? 0) + sets;
    }
    for (final String s in m.secondary) {
      out[s] = (out[s] ?? 0) + sets / 2;
    }
  });
  return out;
}

/// [load] scaled so the busiest muscle is 1 (the heat map's 0 to 1 range).
Map<String, double> muscleHeat(Map<String, double> load) {
  double top = 0;
  for (final double v in load.values) {
    if (v > top) top = v;
  }
  if (top <= 0) return const <String, double>{};
  return <String, double>{
    for (final MapEntry<String, double> e in load.entries)
      if (e.value > 0) e.key: e.value / top,
  };
}

/// The [count] most trained muscles, busiest first (ties by name).
List<String> topMuscles(Map<String, double> load, {int count = 2}) {
  final List<String> ids =
      <String>[
        for (final MapEntry<String, double> e in load.entries)
          if (e.value > 0) e.key,
      ]..sort((String a, String b) {
        final int c = load[b]!.compareTo(load[a]!);
        return c != 0 ? c : a.compareTo(b);
      });
  return ids.take(count).toList();
}
