import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/models/profile.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/units.dart';
import '../../core/widgets/domain/chart_card.dart';
import '../../core/widgets/domain/set_row.dart';
import '../../core/widgets/domain/timer_ring.dart' show ClockText;
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_stat_tile.dart';
import '../../core/widgets/sinew_states.dart';
import '../../engines/records/records.dart';
import 'train_format.dart';
import 'train_providers.dart';
import 'train_widgets.dart';

/// One finished session's work on one exercise.
class ExerciseSessionEntry {
  const ExerciseSessionEntry({
    required this.session,
    required this.sets,
    this.bestE1rmKg,
    this.heaviestKg,
    this.bestReps,
    this.bestHoldSec,
    this.bestDurationSec,
    this.bestDistanceM,
    this.bestRounds,
  });

  final WorkoutSession session;

  /// Completed, non-warm-up sets in order.
  final List<SetEntry> sets;
  final double? bestE1rmKg;
  final double? heaviestKg;
  final int? bestReps;
  final int? bestHoldSec;
  final int? bestDurationSec;
  final double? bestDistanceM;
  final int? bestRounds;
}

class ExerciseHistoryData {
  const ExerciseHistoryData({
    required this.exercise,
    required this.records,
    required this.entries,
  });

  final Exercise exercise;
  final ExerciseRecords? records;

  /// Newest first.
  final List<ExerciseSessionEntry> entries;
}

final exerciseHistoryProvider = FutureProvider.autoDispose
    .family<ExerciseHistoryData, String>((Ref ref, String id) async {
      final List<WorkoutSession> sessions = await ref.watch(
        trainExerciseSessionsProvider(id).future,
      );
      Exercise exercise = Exercise(
        id: id,
        name: id.replaceAll('-', ' '),
        category: 'unknown',
        trackingType: TrackingType.reps,
      );
      try {
        final resolver = await ref.watch(exerciseResolverProvider.future);
        exercise = (await resolver.resolve(<String>[id]))[id] ?? exercise;
      } on Object {
        // No library: the id stands in for the name.
      }
      final List<ExerciseSessionEntry> entries = <ExerciseSessionEntry>[];
      for (final WorkoutSession s in sessions) {
        final List<SetEntry> sets = <SetEntry>[
          for (final SessionExercise e in s.exercises)
            if (e.exerciseId == id)
              for (final SetEntry set in e.sets)
                if (set.completed && !set.isWarmup) set,
        ];
        if (sets.isEmpty) continue;
        double? maxD(Iterable<double?> v) {
          double? m;
          for (final double? x in v) {
            if (x != null && (m == null || x > m)) m = x;
          }
          return m;
        }

        int? maxI(Iterable<int?> v) {
          int? m;
          for (final int? x in v) {
            if (x != null && (m == null || x > m)) m = x;
          }
          return m;
        }

        entries.add(
          ExerciseSessionEntry(
            session: s,
            sets: sets,
            bestE1rmKg: maxD(
              sets.map(
                (SetEntry x) => (x.weightKg == null || x.reps == null)
                    ? null
                    : Records.epley1rm(x.weightKg!, x.reps!),
              ),
            ),
            heaviestKg: maxD(sets.map((SetEntry x) => x.weightKg)),
            bestReps: maxI(sets.map((SetEntry x) => x.reps)),
            bestHoldSec: maxI(sets.map((SetEntry x) => x.holdSec)),
            bestDurationSec: maxI(sets.map((SetEntry x) => x.durationSec)),
            bestDistanceM: maxD(sets.map((SetEntry x) => x.distanceM)),
            bestRounds: maxI(sets.map((SetEntry x) => x.rounds)),
          ),
        );
      }
      entries.sort(
        (ExerciseSessionEntry a, ExerciseSessionEntry b) =>
            b.session.startedAt.compareTo(a.session.startedAt),
      );
      return ExerciseHistoryData(
        exercise: exercise,
        records: Records.computeRecords(sessions)[id],
        entries: entries,
      );
    });

/// The metric charted for a tracking type: its name, and each session's value
/// in display units (null when the session has none).
class _Metric {
  const _Metric(this.title, this.valueOf, this.format);

  final String title;
  final double? Function(ExerciseSessionEntry) valueOf;
  final String Function(double) format;
}

_Metric _metricFor(TrackingType type, Profile p) {
  switch (type) {
    case TrackingType.weightReps:
      return _Metric(
        'Estimated 1RM',
        (ExerciseSessionEntry e) {
          final double? kg = e.bestE1rmKg ?? e.heaviestKg;
          return kg == null ? null : Units.fromKg(kg, p.weightUnit);
        },
        (double v) =>
            '${Units.trim(v, maxDecimals: 1)} ${Units.weightLabel(p.weightUnit)}',
      );
    case TrackingType.reps || TrackingType.unknown:
      return _Metric(
        'Best set',
        (ExerciseSessionEntry e) => e.bestReps?.toDouble(),
        (double v) => '${v.round()} reps',
      );
    case TrackingType.time:
      return _Metric(
        'Longest set',
        (ExerciseSessionEntry e) => e.bestDurationSec?.toDouble(),
        (double v) => ClockText.format(v.round()),
      );
    case TrackingType.hold:
      return _Metric(
        'Longest hold',
        (ExerciseSessionEntry e) => e.bestHoldSec?.toDouble(),
        (double v) => ClockText.format(v.round()),
      );
    case TrackingType.distanceTime:
      return _Metric(
        'Longest distance',
        (ExerciseSessionEntry e) => e.bestDistanceM == null
            ? null
            : Units.fromMetres(e.bestDistanceM!, p.distanceUnit),
        (double v) => '${Units.trim(v)} ${Units.distanceLabel(p.distanceUnit)}',
      );
    case TrackingType.rounds || TrackingType.flow:
      return _Metric(
        'Most rounds',
        (ExerciseSessionEntry e) => e.bestRounds?.toDouble(),
        (double v) => '${v.round()} rounds',
      );
  }
}

DateTime? _rangeStart(ChartRange r, DateTime now) => switch (r) {
  ChartRange.month1 => now.subtract(const Duration(days: 30)),
  ChartRange.month3 => now.subtract(const Duration(days: 91)),
  ChartRange.month6 => now.subtract(const Duration(days: 182)),
  ChartRange.year1 => now.subtract(const Duration(days: 365)),
  ChartRange.all => null,
};

/// An exercise's records, its trend over time and every session it was in
/// (`Routes.exerciseHistory`).
class ExerciseHistoryScreen extends ConsumerStatefulWidget {
  const ExerciseHistoryScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  ConsumerState<ExerciseHistoryScreen> createState() =>
      _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState extends ConsumerState<ExerciseHistoryScreen> {
  ChartRange _range = ChartRange.all;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ExerciseHistoryData> async = ref.watch(
      exerciseHistoryProvider(widget.exerciseId),
    );
    final Profile profile =
        ref.watch(trainProfileProvider).value ?? const Profile();
    return Scaffold(
      appBar: SinewAppBar(
        title: async.value?.exercise.name ?? 'Exercise history',
        showBack: true,
        showBrand: false,
      ),
      body: async.when(
        loading: () => const TrainLoading(),
        error: (Object e, StackTrace _) => SinewErrorState(
          onRetry: () =>
              ref.invalidate(exerciseHistoryProvider(widget.exerciseId)),
        ),
        data: (ExerciseHistoryData d) => d.entries.isEmpty
            ? const SinewEmptyState(
                icon: Icons.show_chart_rounded,
                title: 'No history yet',
                description:
                    'Log this exercise in a workout and its records and '
                    'trend show up here.',
              )
            : _content(context, d, profile),
      ),
    );
  }

  Widget _content(BuildContext context, ExerciseHistoryData d, Profile p) {
    final ColorScheme cs = context.cs;
    final Exercise ex = d.exercise;
    final _Metric metric = _metricFor(ex.trackingType, p);
    final DateTime now = DateTime.now();
    final DateTime? from = _rangeStart(_range, now);
    final List<ChartPoint> points = <ChartPoint>[
      for (final ExerciseSessionEntry e in d.entries.reversed)
        if (metric.valueOf(e) != null &&
            (from == null || e.session.startedAt.isAfter(from)))
          ChartPoint(e.session.startedAt, metric.valueOf(e)!),
    ];
    final double? latest = points.isEmpty ? null : points.last.value;
    final double? delta = points.length < 2
        ? null
        : points.last.value - points.first.value;
    final ExerciseRecords? r = d.records;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.sm,
        Space.screen,
        Space.bottomSafe,
      ),
      children: <Widget>[
        SinewStatGrid(children: _tiles(ex, d, p)),
        const SizedBox(height: Space.lg),
        ChartCard(
          title: metric.title,
          primary: ChartSeries(label: metric.title, points: points),
          latestLabel: latest == null ? null : metric.format(latest),
          deltaLabel: delta == null || delta == 0
              ? null
              : '${delta > 0 ? '+' : '-'}${metric.format(delta.abs())}',
          range: _range,
          ranges: const <ChartRange>[
            ChartRange.month3,
            ChartRange.month6,
            ChartRange.year1,
            ChartRange.all,
          ],
          onRangeChanged: (ChartRange v) => setState(() => _range = v),
          emptyMessage: 'No sessions in this range',
        ),
        if (r != null) ...<Widget>[
          const TrainSectionLabel('Records'),
          SinewGroup(children: _recordRows(context, ex, r, p)),
        ],
        const TrainSectionLabel('Recent'),
        SinewGroup(
          children: <Widget>[
            for (final ExerciseSessionEntry e in d.entries.take(
              TrainSpec.recentSessions,
            ))
              _RecentRow(entry: e, exercise: ex, profile: p),
          ],
        ),
        if (d.entries.length > TrainSpec.recentSessions)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Text(
              'Showing the latest ${TrainSpec.recentSessions} of '
              '${d.entries.length} sessions.',
              style: context.text.bodySmall!.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _tiles(Exercise ex, ExerciseHistoryData d, Profile p) {
    final ExerciseRecords? r = d.records;
    final DateTime first = d.entries.last.session.startedAt;
    final Widget sessions = SinewStatTile(
      label: 'Sessions',
      value: '${d.entries.length}',
      caption: 'since ${monthShort(first)} ${first.year}',
    );
    String dated(RecordEntry? e) => e == null ? '' : formatDay(e.date);
    switch (ex.trackingType) {
      case TrackingType.weightReps:
        final RecordEntry? best = r?.heaviestWeight;
        final RecordEntry? e1 = r?.bestE1rm;
        return <Widget>[
          SinewStatTile(
            label: 'Heaviest',
            value: best == null
                ? '-'
                : Units.formatWeight(best.value, p.weightUnit, maxDecimals: 1),
            caption: dated(best),
          ),
          SinewStatTile(
            label: 'Est. 1RM',
            value: e1 == null
                ? '-'
                : Units.formatWeight(e1.value, p.weightUnit, maxDecimals: 0),
            caption: 'Epley',
          ),
          sessions,
        ];
      case TrackingType.hold:
        return <Widget>[
          SinewStatTile(
            label: 'Longest hold',
            value: r?.longestHold == null
                ? '-'
                : ClockText.format(r!.longestHold!.value.round()),
            caption: dated(r?.longestHold),
          ),
          sessions,
        ];
      case TrackingType.distanceTime:
        return <Widget>[
          SinewStatTile(
            label: 'Longest distance',
            value: r?.longestDistance == null
                ? '-'
                : Units.formatDistance(
                    r!.longestDistance!.value,
                    p.distanceUnit,
                  ),
            caption: dated(r?.longestDistance),
          ),
          SinewStatTile(
            label: 'Longest time',
            value: r?.longestDuration == null
                ? '-'
                : ClockText.format(r!.longestDuration!.value.round()),
          ),
          sessions,
        ];
      case TrackingType.time:
        return <Widget>[
          SinewStatTile(
            label: 'Longest set',
            value: r?.longestDuration == null
                ? '-'
                : ClockText.format(r!.longestDuration!.value.round()),
            caption: dated(r?.longestDuration),
          ),
          sessions,
        ];
      case TrackingType.reps ||
          TrackingType.unknown ||
          TrackingType.rounds ||
          TrackingType.flow:
        int best = 0;
        int total = 0;
        for (final ExerciseSessionEntry e in d.entries) {
          final int top = e.bestReps ?? e.bestRounds ?? 0;
          if (top > best) best = top;
          for (final SetEntry s in e.sets) {
            total += s.reps ?? s.rounds ?? 0;
          }
        }
        final String unit =
            ex.trackingType == TrackingType.reps ||
                ex.trackingType == TrackingType.unknown
            ? 'reps'
            : 'rounds';
        return <Widget>[
          SinewStatTile(label: 'Best set', value: '$best $unit'),
          SinewStatTile(label: 'Total', value: '$total $unit'),
          sessions,
        ];
    }
  }

  List<Widget> _recordRows(
    BuildContext context,
    Exercise ex,
    ExerciseRecords r,
    Profile p,
  ) {
    String w(double kg) => Units.formatWeight(kg, p.weightUnit, maxDecimals: 1);
    Widget row(String label, String value, RecordEntry? e) => SinewListRow(
      title: label,
      subtitle: e == null ? null : formatDay(e.date),
      trailing: Text(value, style: context.text.titleSmall),
      onTap: e == null ? null : () => context.push(Routes.session(e.sessionId)),
    );
    final List<MapEntry<double, RecordEntry>> reps =
        r.repsAtWeight.entries.toList()..sort(
          (MapEntry<double, RecordEntry> a, MapEntry<double, RecordEntry> b) =>
              b.key.compareTo(a.key),
        );
    return <Widget>[
      if (r.heaviestWeight != null)
        row('Heaviest weight', w(r.heaviestWeight!.value), r.heaviestWeight),
      if (r.bestE1rm != null)
        row('Best estimated 1RM', w(r.bestE1rm!.value), r.bestE1rm),
      if (r.mostVolumeInSession != null)
        row(
          'Most volume in a session',
          formatVolume(r.mostVolumeInSession!.value, p.weightUnit),
          r.mostVolumeInSession,
        ),
      for (final MapEntry<double, RecordEntry> e in reps.take(4))
        row('Reps at ${w(e.key)}', '${e.value.value.round()}', e.value),
      if (r.longestHold != null)
        row(
          'Longest hold',
          ClockText.format(r.longestHold!.value.round()),
          r.longestHold,
        ),
      if (r.longestDistance != null)
        row(
          'Longest distance',
          Units.formatDistance(r.longestDistance!.value, p.distanceUnit),
          r.longestDistance,
        ),
      if (r.longestDuration != null)
        row(
          'Longest time',
          ClockText.format(r.longestDuration!.value.round()),
          r.longestDuration,
        ),
    ];
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.entry,
    required this.exercise,
    required this.profile,
  });

  final ExerciseSessionEntry entry;
  final Exercise exercise;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final List<String> parts = <String>[
      for (final SetEntry s in entry.sets.take(4))
        SetRow.summary(
          s,
          exercise.trackingType,
          weightUnit: profile.weightUnit,
          distanceUnit: profile.distanceUnit,
        ),
      if (entry.sets.length > 4) '+${entry.sets.length - 4} more',
    ];
    return SinewListRow(
      title: formatDay(entry.session.startedAt),
      subtitle: parts.join(', '),
      trailing: Text(
        plural(entry.sets.length, 'set'),
        style: context.text.bodySmall!.copyWith(
          color: context.cs.onSurfaceVariant,
        ),
      ),
      onTap: () => context.push(Routes.session(entry.session.id)),
    );
  }
}
