import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/repositories/session_repository.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/models/profile.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/domain/muscle_map.dart';
import '../../engines/records/train_stats.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_states.dart';
import 'train_actions.dart';
import 'train_format.dart';
import 'train_providers.dart';

/// How many finished sessions History has loaded; grows as you scroll.
class HistoryLimit extends Notifier<int> {
  @override
  int build() => TrainSpec.historyPage;

  void more() => state += TrainSpec.historyPage;
}

final NotifierProvider<HistoryLimit, int> trainHistoryLimitProvider =
    NotifierProvider.autoDispose<HistoryLimit, int>(HistoryLimit.new);

final StreamProvider<List<WorkoutSession>> trainHistoryProvider =
    StreamProvider.autoDispose<List<WorkoutSession>>(
      (Ref ref) => ref
          .watch(sessionRepositoryProvider)
          .watchHistory(limit: ref.watch(trainHistoryLimitProvider)),
    );

/// A week of sessions under one heading.
class HistoryWeek {
  const HistoryWeek(this.start, this.sessions);

  final DateTime start;
  final List<WorkoutSession> sessions;
}

/// Newest first, grouped by calendar week (Monday to Sunday).
List<HistoryWeek> groupByWeek(List<WorkoutSession> sessions) {
  final Map<DateTime, List<WorkoutSession>> by =
      <DateTime, List<WorkoutSession>>{};
  for (final WorkoutSession s in sessions) {
    (by[weekStart(s.startedAt)] ??= <WorkoutSession>[]).add(s);
  }
  final List<DateTime> starts = by.keys.toList()
    ..sort((DateTime a, DateTime b) => b.compareTo(a));
  return <HistoryWeek>[for (final DateTime d in starts) HistoryWeek(d, by[d]!)];
}

/// Finished workouts (`Routes.history`): the same sections as the History tab
/// on Train, full screen.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SinewAppBar(title: 'History', showBack: true, showBrand: false),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Space.screen),
            sliver: HistorySections(),
          ),
        ],
      ),
    );
  }
}

/// The History sections as slivers: a month heatmap with its totals, the
/// muscles trained this week, then the sessions a week at a time, newest
/// first. Shared by the Train tab and [HistoryScreen]; the caller pads it.
class HistorySections extends ConsumerWidget {
  const HistorySections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<WorkoutSession>> async = ref.watch(
      trainHistoryProvider,
    );
    final int limit = ref.watch(trainHistoryLimitProvider);
    final Profile profile =
        ref.watch(trainProfileProvider).value ?? const Profile();
    return async.when(
      loading: () =>
          const SliverToBoxAdapter(child: Delayed(child: _Skeletons())),
      error: (Object e, StackTrace _) => SliverFillRemaining(
        hasScrollBody: false,
        child: SinewErrorState(
          onRetry: () => ref.invalidate(trainHistoryProvider),
        ),
      ),
      data: (List<WorkoutSession> sessions) {
        if (sessions.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: SinewEmptyState(
              icon: Icons.calendar_month_rounded,
              title: 'Nothing logged yet',
              description:
                  'Finished workouts show up here with a calendar, your '
                  "records and the muscles you've trained.",
              actionLabel: 'Start a workout',
              actionIcon: Icons.play_arrow_rounded,
              onAction: () => startWorkoutAndOpen(context, ref),
            ),
          );
        }
        final DateTime now = DateTime.now();
        final List<Object> rows = <Object>[];
        for (final HistoryWeek w in groupByWeek(sessions)) {
          rows
            ..add(w)
            ..addAll(w.sessions);
        }
        final bool more = sessions.length >= limit;
        final Map<String, int> prs =
            ref
                .watch(
                  trainPrCountsProvider(
                    sessions.map((WorkoutSession s) => s.id).join(','),
                  ),
                )
                .value ??
            const <String, int>{};
        return SliverMainAxisGroup(
          slivers: <Widget>[
            const SliverToBoxAdapter(child: _CalendarCard()),
            const SliverToBoxAdapter(child: _MusclesWeekCard()),
            SliverList.builder(
              itemCount: rows.length + (more ? 1 : 0),
              itemBuilder: (BuildContext context, int i) {
                if (i >= rows.length) {
                  // Reaching the end asks for the next page, once per page.
                  WidgetsBinding.instance.addPostFrameCallback((Duration _) {
                    if (ref.read(trainHistoryLimitProvider) == limit) {
                      ref.read(trainHistoryLimitProvider.notifier).more();
                    }
                  });
                  return const Padding(
                    padding: EdgeInsets.all(Space.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final Object row = rows[i];
                if (row is HistoryWeek) {
                  return _WeekHeader(week: row, now: now);
                }
                final WorkoutSession s = row as WorkoutSession;
                return _SessionRow(
                  session: s,
                  weightUnit: profile.weightUnit,
                  prCount: prs[s.id] ?? 0,
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Space.bottomSafe)),
          ],
        );
      },
    );
  }
}

/// The month heatmap: one square per day shaded by how many workouts it holds,
/// with the month's totals under it.
class _CalendarCard extends ConsumerStatefulWidget {
  const _CalendarCard();

  @override
  ConsumerState<_CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends ConsumerState<_CalendarCard> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _shift(int by) =>
      setState(() => _month = DateTime(_month.year, _month.month + by));

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final List<SessionHeader> sessions =
        ref.watch(trainMonthSessionsProvider(_month)).value ??
        const <SessionHeader>[];
    final Map<DateTime, int> perDay = sessionsPerDay(
      sessions.map((SessionHeader s) => s.startedAt),
    );
    int seconds = 0;
    for (final SessionHeader s in sessions) {
      seconds += s.durationSec ?? 0;
    }
    final DateTime now = DateTime.now();
    final bool isCurrent = _month.year == now.year && _month.month == now.month;
    final List<Color> heat = context.accents.heat;
    Color shade(int level) => level <= 0
        ? cs.surfaceContainerHighest
        : heat[level.clamp(1, heat.length - 1)];
    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: SinewCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                AppIconButton(
                  icon: Icons.chevron_left_rounded,
                  semanticLabel: 'Previous month',
                  onPressed: () => _shift(-1),
                ),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      '${monthLong(_month)} ${_month.year}',
                      textAlign: TextAlign.center,
                      style: tt.titleMedium,
                    ),
                  ),
                ),
                AppIconButton(
                  icon: Icons.chevron_right_rounded,
                  semanticLabel: 'Next month',
                  onPressed: isCurrent ? null : () => _shift(1),
                ),
              ],
            ),
            const SizedBox(height: Space.xs),
            ExcludeSemantics(
              child: Row(
                children: <Widget>[
                  for (final String d in const <String>[
                    'M',
                    'T',
                    'W',
                    'T',
                    'F',
                    'S',
                    'S',
                  ])
                    Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: tt.labelSmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Space.xs),
            for (final List<DateTime?> week in monthGrid(_month))
              Padding(
                padding: const EdgeInsets.only(bottom: TrainSpec.calendarGap),
                child: Row(
                  children: <Widget>[
                    for (final DateTime? day in week)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TrainSpec.calendarGap / 2,
                          ),
                          child: _DayCell(
                            day: day,
                            count: day == null ? 0 : (perDay[day] ?? 0),
                            fill: shade(
                              heatLevel(day == null ? 0 : (perDay[day] ?? 0)),
                            ),
                            today: day != null && day == dayOf(now),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: Space.xs),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Space.md,
              runSpacing: Space.xs,
              children: <Widget>[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    sessions.isEmpty
                        ? 'No workouts this month'
                        : '${plural(sessions.length, 'session')} · '
                              '${formatMinutes(seconds)}',
                    style: tt.bodyMedium,
                  ),
                ),
                ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'less',
                        style: tt.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      for (int l = 0; l <= 4; l++)
                        Padding(
                          padding: const EdgeInsets.only(left: Space.xxs),
                          child: Container(
                            width: TrainSpec.legendSwatch,
                            height: TrainSpec.legendSwatch,
                            decoration: BoxDecoration(
                              color: shade(l),
                              borderRadius: BorderRadius.circular(
                                TrainSpec.legendSwatch / 4,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: Space.xxs),
                      Text(
                        'more',
                        style: tt.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.count,
    required this.fill,
    required this.today,
  });

  final DateTime? day;
  final int count;
  final Color fill;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final DateTime? d = day;
    if (d == null) return const AspectRatio(aspectRatio: 1);
    final ColorScheme cs = context.cs;
    final bool shaded = count > 0;
    return Semantics(
      label: count == 0
          ? '${formatDay(d)}, no workouts'
          : '${formatDay(d)}, ${plural(count, 'workout')}',
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(TrainSpec.calendarCellRadius),
            border: today
                ? Border.all(color: cs.primary, width: Strokes.focus)
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${d.day}',
              style: context.text.labelSmall!.copyWith(
                color: shaded ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The muscles trained this week as a heat map, with a line saying which got
/// the most sets and which got none.
class _MusclesWeekCard extends ConsumerWidget {
  const _MusclesWeekCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final DateTime start = weekStart(DateTime.now());
    final Map<String, int> counts =
        ref.watch(trainWeekSetCountsProvider(start)).value ??
        const <String, int>{};
    final Map<String, Exercise> exercises =
        ref.watch(trainExercisesProvider(exerciseKey(counts.keys))).value ??
        const <String, Exercise>{};
    final Profile profile =
        ref.watch(trainProfileProvider).value ?? const Profile();
    final Map<String, double> load = muscleLoad(
      counts,
      <String, ({List<String> primary, List<String> secondary})>{
        for (final MapEntry<String, Exercise> e in exercises.entries)
          e.key: (
            primary: e.value.primaryMuscles,
            secondary: e.value.secondaryMuscles,
          ),
      },
    );
    final Map<String, double> heat = muscleHeat(load);
    final List<String> top = topMuscles(load);
    final List<String> idle = untrainedMuscles(load);
    final String summary = heat.isEmpty
        ? 'No sets logged this week yet.'
        : 'Most sets: ${top.map(muscleName).join(', ')}.'
              '${idle.isEmpty ? '' : ' Nothing yet for ${idle.map(muscleName).join(' or ')}.'}';
    return Padding(
      padding: const EdgeInsets.only(top: Space.md),
      child: SinewCard(
        child: Row(
          children: <Widget>[
            SizedBox(
              width: TrainSpec.mapPreview,
              height: TrainSpec.mapPreviewHeight,
              child: MuscleMap(
                primary: const <String>[],
                heat: heat,
                sex: profile.sex,
                showLabels: false,
                semanticLabel: 'Muscles trained this week. $summary',
              ),
            ),
            const SizedBox(width: Space.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text('Muscles this week', style: tt.titleSmall),
                  ),
                  const SizedBox(height: Space.xxs),
                  Text(
                    summary,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.week, required this.now});

  final HistoryWeek week;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    int seconds = 0;
    for (final WorkoutSession s in week.sessions) {
      seconds += s.durationSec ?? 0;
    }
    return Padding(
      padding: const EdgeInsets.only(top: Space.xl, bottom: Space.sm),
      child: Semantics(
        header: true,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Space.md,
          runSpacing: Space.xxs,
          children: <Widget>[
            Text(
              weekLabel(week.start, now).toUpperCase(),
              style: context.sectionHeader,
            ),
            Text(
              '${plural(week.sessions.length, 'session')} · '
              '${formatMinutes(seconds)}',
              style: context.text.bodySmall!.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.weightUnit,
    required this.prCount,
  });

  final WorkoutSession session;
  final WeightUnit weightUnit;
  final int prCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final List<String> bits = <String>[
      if (session.durationSec != null) formatMinutes(session.durationSec!),
      if (session.volumeKg != null && session.volumeKg! > 0)
        formatVolume(session.volumeKg!, weightUnit),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Material(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardR,
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.session(session.id)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Space.listItem2),
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Row(
                children: <Widget>[
                  ExcludeSemantics(
                    child: Container(
                      width: TrainSpec.dateBlock,
                      padding: const EdgeInsets.symmetric(vertical: Space.xs),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(
                          TrainSpec.dateBlockRadius,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            weekdayShort(session.startedAt).toUpperCase(),
                            style: tt.labelSmall!.copyWith(
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                          Text(
                            '${session.startedAt.day}',
                            style: tt.titleMedium!.copyWith(
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Semantics(
                      label:
                          '${session.name ?? 'Workout'}, '
                          '${formatDay(session.startedAt)}, ${bits.join(', ')}'
                          '${prCount > 0 ? ', ${plural(prCount, 'record')}' : ''}',
                      excludeSemantics: true,
                      button: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            session.name ?? 'Workout',
                            style: tt.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (bits.isNotEmpty)
                            Text(
                              bits.join(' · '),
                              style: tt.bodySmall!.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (prCount > 0) ...<Widget>[
                    ExcludeSemantics(
                      child: SinewPill(
                        label: prCount == 1 ? 'PR' : '$prCount PRs',
                        tone: SinewTone.primary,
                      ),
                    ),
                    const SizedBox(width: Space.xs),
                  ],
                  Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Skeletons extends StatelessWidget {
  const _Skeletons();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(Space.screen),
      child: Column(
        children: <Widget>[
          SinewSkeletonCard(lines: 2),
          SizedBox(height: Space.sm),
          SinewSkeletonCard(lines: 2),
          SizedBox(height: Space.sm),
          SinewSkeletonCard(lines: 2),
        ],
      ),
    );
  }
}
