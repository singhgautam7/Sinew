import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/profile.dart';
import '../../core/models/timer_preset.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../engines/body_stats/body_stats.dart';
import '../body/body_model.dart';
import '../../core/format/date_text.dart';

/// "Now", overridable in tests so a seeded week is the same on any day.
final Provider<DateTime Function()> todayClockProvider =
    Provider<DateTime Function()>((Ref ref) => DateTime.now);

/// The id of the running workout, or null. Live.
final StreamProvider<String?> activeSessionIdProvider =
    StreamProvider.autoDispose<String?>(
      (Ref ref) => ref.watch(sessionRepositoryProvider).watchActiveId(),
    );

/// What Today shows besides the body card. Computed from live streams, so a
/// finished workout or a new routine updates the screen without a refresh.
class TodaySummary {
  const TodaySummary({
    required this.now,
    required this.routines,
    required this.next,
    required this.trainedToday,
    required this.finishedCount,
    required this.quickTimers,
    required this.last,
    required this.week,
    required this.weekSessions,
    required this.todayIndex,
    required this.weekStartsMonday,
    required this.profile,
  });

  final DateTime now;
  final Profile profile;
  final List<Routine> routines;

  /// The routine after the one performed most recently, in routine order.
  final Routine? next;
  final bool trainedToday;
  final int finishedCount;
  final List<TimerPreset> quickTimers;

  /// The most recent finished workout, with its exercises and sets.
  final WorkoutSession? last;

  /// Sessions per day of the current week, first day first (seven entries).
  final List<int> week;
  final int weekSessions;

  /// Index of today in [week].
  final int todayIndex;
  final bool weekStartsMonday;

  /// No finished workout and no routine: the first-run version of Today.
  bool get isNewUser => finishedCount == 0 && routines.isEmpty;
}

/// Per-day counts for the week containing [now]. Pure, for tests.
({List<int> counts, int todayIndex}) weekCounts(
  Iterable<DateTime> sessionStarts,
  DateTime now, {
  required bool mondayFirst,
}) {
  final DateTime today = DateText.dayOf(now);
  final int offset = mondayFirst ? now.weekday - 1 : now.weekday % 7;
  final DateTime start = DateTime(today.year, today.month, today.day - offset);
  final List<int> counts = List<int>.filled(7, 0);
  for (final DateTime s in sessionStarts) {
    final int d = DateText.daysBetween(start, s.toLocal());
    if (d >= 0 && d < 7) counts[d]++;
  }
  return (counts: counts, todayIndex: offset);
}

/// The routine after the most recently performed one (routine order wraps).
/// With nothing performed yet, the first routine. Pure, for tests.
Routine? nextRoutine(List<Routine> routines, List<WorkoutSession> newestFirst) {
  if (routines.isEmpty) return null;
  for (final WorkoutSession s in newestFirst) {
    final int i = routines.indexOfId(s.routineId);
    if (i >= 0) return routines[(i + 1) % routines.length];
  }
  return routines.first;
}

extension on List<Routine> {
  int indexOfId(String? id) =>
      id == null ? -1 : indexWhere((Routine r) => r.id == id);
}

final StreamProvider<List<WorkoutSession>> _historyProvider =
    StreamProvider.autoDispose<List<WorkoutSession>>(
      (Ref ref) =>
          ref.watch(sessionRepositoryProvider).watchHistory(limit: 120),
    );

final StreamProvider<List<Routine>> _routinesProvider =
    StreamProvider.autoDispose<List<Routine>>(
      (Ref ref) => ref.watch(routineRepositoryProvider).watchAll(),
    );

final StreamProvider<List<TimerPreset>> _presetsProvider =
    StreamProvider.autoDispose<List<TimerPreset>>(
      (Ref ref) => ref.watch(timerPresetRepositoryProvider).watchAll(),
    );

final FutureProvider<TodaySummary>
todaySummaryProvider = FutureProvider.autoDispose<TodaySummary>((
  Ref ref,
) async {
  final DateTime now = ref.watch(todayClockProvider)();
  final bool mondayFirst = ref.watch(
    settingsProvider.select((AppSettings s) => s.weekStartsMonday),
  );
  final List<WorkoutSession> history = await ref.watch(_historyProvider.future);
  final List<Routine> routines = await ref.watch(_routinesProvider.future);
  final List<TimerPreset> presets = await ref.watch(_presetsProvider.future);
  final Profile profile = await ref.watch(currentProfileProvider.future);
  final int finished = await ref
      .watch(sessionRepositoryProvider)
      .finishedCount();

  WorkoutSession? last;
  if (history.isNotEmpty) {
    last = await ref.watch(sessionRepositoryProvider).byId(history.first.id);
  }
  final ({List<int> counts, int todayIndex}) week = weekCounts(
    history.map((WorkoutSession s) => s.startedAt),
    now,
    mondayFirst: mondayFirst,
  );
  Routine? next = nextRoutine(routines, history);
  if (next != null) {
    next = await ref.watch(routineRepositoryProvider).byId(next.id) ?? next;
  }
  return TodaySummary(
    now: now,
    routines: routines,
    next: next,
    trainedToday: history.any(
      (WorkoutSession s) => DateText.sameDay(s.startedAt.toLocal(), now),
    ),
    finishedCount: finished,
    quickTimers: presets.take(3).toList(),
    last: last,
    week: week.counts,
    weekSessions: week.counts.fold(0, (int a, int b) => a + b),
    todayIndex: week.todayIndex,
    weekStartsMonday: mondayFirst,
    profile: profile,
  );
});

/// The newest body numbers for Today's card, computed by the engine.
class TodayBody {
  const TodayBody({
    required this.profile,
    required this.weightKg,
    required this.weightDate,
    required this.bmi,
    required this.bodyFat,
    required this.hasAny,
    required this.heightCm,
  });

  final Profile profile;
  final double? weightKg;
  final DateTime? weightDate;
  final StatResult<double> bmi;
  final StatResult<BodyFat> bodyFat;

  /// The height the stats used (profile or logged, whichever is newer).
  final double? heightCm;

  /// Any weight, height or body measurement at all.
  final bool hasAny;

  StatResult<double> get weight => weightKg == null
      ? const MissingInputs<double>(<StatInput>[StatInput.weight])
      : StatValue<double>(weightKg!);
}

final FutureProvider<TodayBody> todayBodyProvider =
    FutureProvider.autoDispose<TodayBody>((Ref ref) async {
      final DateTime now = ref.watch(todayClockProvider)();
      final Profile profile = await ref.watch(currentProfileProvider.future);
      final Map<String, ({double value, DateTime date})> latest = await ref
          .watch(measurementRepositoryProvider)
          .latestValues();
      // The same input Body builds, so both screens agree on every number.
      final BodyStatsInput input = bodyStatsInputFor(latest, profile, now);
      return TodayBody(
        heightCm: input.heightCm,
        profile: profile,
        weightKg: latest['weight']?.value,
        weightDate: latest['weight']?.date,
        bmi: BodyStats.bmi(input),
        bodyFat: BodyStats.bodyFat(input),
        hasAny: latest.isNotEmpty || profile.heightCm != null,
      );
    });
