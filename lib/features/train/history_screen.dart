import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/models/profile.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sinew_app_bar.dart';
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

/// Finished workouts, newest first, a week at a time (`Routes.history`).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<WorkoutSession>> async = ref.watch(
      trainHistoryProvider,
    );
    final int limit = ref.watch(trainHistoryLimitProvider);
    final Profile profile =
        ref.watch(trainProfileProvider).value ?? const Profile();
    return Scaffold(
      appBar: const SinewAppBar(
        title: 'History',
        showBack: true,
        showBrand: false,
      ),
      body: async.when(
        loading: () => const Delayed(child: _Skeletons()),
        error: (Object e, StackTrace _) => SinewErrorState(
          onRetry: () => ref.invalidate(trainHistoryProvider),
        ),
        data: (List<WorkoutSession> sessions) {
          if (sessions.isEmpty) {
            return SinewEmptyState(
              icon: Icons.calendar_month_rounded,
              title: 'Nothing logged yet',
              description:
                  'Finished workouts show up here, grouped by week, with '
                  'their records.',
              actionLabel: 'Start a workout',
              actionIcon: Icons.play_arrow_rounded,
              onAction: () => startWorkoutAndOpen(context, ref),
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
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              0,
              Space.screen,
              Space.bottomSafe,
            ),
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
              return _SessionRow(
                session: row as WorkoutSession,
                weightUnit: profile.weightUnit,
              );
            },
          );
        },
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
  const _SessionRow({required this.session, required this.weightUnit});

  final WorkoutSession session;
  final WeightUnit weightUnit;

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
                          '${formatDay(session.startedAt)}, ${bits.join(', ')}',
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
