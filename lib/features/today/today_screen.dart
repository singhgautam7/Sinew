import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/repositories/session_repository.dart';
import '../../core/models/enums.dart';
import '../../core/models/timer_preset.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/units.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/domain/stat_card.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_grid.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_states.dart';
import '../../engines/body_stats/body_stats.dart';
import 'date_text.dart';
import 'today_providers.dart';
import 'week_strip.dart';

/// The first tab: what to do next, quick timers, the last workout, the
/// newest body numbers and the week at a glance.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool? _wasActive;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The tab stays alive while another is shown, and body entries have no
    // live stream: re-read them when the tab comes back.
    final bool active = TickerMode.valuesOf(context).enabled;
    if (_wasActive == false && active) {
      // Not while building: providers may not be invalidated mid-frame.
      scheduleMicrotask(() {
        if (!mounted) return;
        ref.invalidate(todayBodyProvider);
        ref.invalidate(todaySummaryProvider);
      });
    }
    _wasActive = active;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<TodaySummary> summary = ref.watch(todaySummaryProvider);
    return Scaffold(
      appBar: SinewAppBar(
        actions: <Widget>[
          AppIconButton(
            icon: Icons.search_rounded,
            semanticLabel: 'Search',
            onPressed: () => context.push(Routes.search),
          ),
        ],
      ),
      body: summary.when(
        loading: () => const Delayed(child: _TodaySkeleton()),
        error: (Object e, StackTrace st) => SinewEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not load Today',
          description: 'Your data is safe. Try again.',
          actionLabel: 'Try again',
          onAction: () => ref.invalidate(todaySummaryProvider),
        ),
        data: (TodaySummary s) => _TodayBody(summary: s),
      ),
    );
  }
}

class _TodaySkeleton extends StatelessWidget {
  const _TodaySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.sm,
        Space.screen,
        Space.bottomSafe,
      ),
      children: const <Widget>[
        SinewSkeletonRow(),
        SizedBox(height: Space.lg),
        SinewSkeletonCard(),
        SizedBox(height: Space.lg),
        SinewSkeletonCard(),
        SizedBox(height: Space.lg),
        SinewSkeletonCard(),
      ],
    );
  }
}

class _TodayBody extends ConsumerWidget {
  const _TodayBody({required this.summary});

  final TodaySummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TodaySummary s = summary;
    final String name = ref.watch(
      settingsProvider.select((AppSettings a) => a.userName),
    );
    final String? activeId = ref.watch(activeSessionIdProvider).value;
    final bool remind = ref.watch(shouldRemindBackupProvider).value ?? false;

    final List<Widget> children = <Widget>[
      _Greeting(
        title: s.isNewUser ? 'Welcome' : DateText.greeting(s.now, name),
        date: DateText.full(s.now),
      ),
      const SizedBox(height: Space.lg),
      if (activeId != null) ...<Widget>[
        const _ResumeBanner(),
        const SizedBox(height: Space.lg),
      ],
      if (s.isNewUser)
        const _NewUserCard()
      else if (s.next != null && !s.trainedToday)
        _PlannedCard(routine: s.next!)
      else
        _RestCard(next: s.next, trainedToday: s.trainedToday),
      if (remind) ...<Widget>[
        const SizedBox(height: Space.lg),
        const _BackupReminder(),
      ],
      if (s.quickTimers.isNotEmpty) ...<Widget>[
        const SizedBox(height: Space.section),
        _QuickTimers(presets: s.quickTimers),
      ],
      if (s.last != null) ...<Widget>[
        const SizedBox(height: Space.section),
        _LastSession(
          session: s.last!,
          now: s.now,
          profile: s.profile.weightUnit,
        ),
      ],
      const SizedBox(height: Space.section),
      const _BodyLatest(),
      const SizedBox(height: Space.section),
      SinewSectionHeader(
        title: s.weekSessions == 0
            ? 'This week'
            : 'This week · ${DateText.count(s.weekSessions, 'session')}',
      ),
      WeekStrip(
        counts: s.week,
        todayIndex: s.todayIndex,
        now: s.now,
        mondayFirst: s.weekStartsMonday,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.sm,
        Space.screen,
        Space.bottomSafe,
      ),
      children: children,
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.title, required this.date});

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            title,
            style: context.text.headlineMedium!.copyWith(
              color: context.cs.onSurface,
            ),
          ),
        ),
        Text(
          date,
          style: context.text.bodyMedium!.copyWith(
            color: context.cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// "Workout in progress", straight back to the logging screen.
class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Semantics(
      button: true,
      label: 'Resume your workout in progress',
      child: SinewCard(
        color: cs.primaryContainer,
        borderColor: cs.primaryContainer,
        onTap: () => context.push(Routes.workout),
        child: Row(
          children: <Widget>[
            const SinewIconTile(
              icon: Icons.play_arrow_rounded,
              tone: SinewTone.primary,
              circle: true,
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Workout in progress',
                    style: context.text.titleMedium!.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Tap to pick up where you left off.',
                    style: context.text.bodyMedium!.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: context.sectionHeader);
}

/// The next routine in order, with the one big action.
class _PlannedCard extends StatelessWidget {
  const _PlannedCard({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final int n = routine.items.length;
    return SinewCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _CardLabel('Planned today'),
          const SizedBox(height: Space.xs),
          Text(
            routine.name,
            style: context.text.headlineSmall!.copyWith(
              color: context.cs.onSurface,
            ),
          ),
          if (n > 0)
            Text(
              DateText.count(n, 'exercise'),
              style: context.text.bodyMedium!.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: Space.lg),
          AppButton(
            label: 'Start workout',
            icon: Icons.play_arrow_rounded,
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: () => context.push(Routes.routine(routine.id)),
          ),
        ],
      ),
    );
  }
}

class _RestCard extends ConsumerWidget {
  const _RestCard({required this.next, required this.trainedToday});

  final Routine? next;
  final bool trainedToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String body = trainedToday
        ? (next == null
              ? 'Nice work. That is today done.'
              : 'Nice work. Next up is ${next!.name}.')
        : (next == null
              ? 'Nothing planned. Start a workout whenever you like.'
              : 'Nothing planned. Next up is ${next!.name}.');
    return SinewCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _CardLabel('Today'),
          const SizedBox(height: Space.xs),
          Text(
            trainedToday ? 'Done for today' : 'Rest day',
            style: context.text.headlineSmall!.copyWith(
              color: context.cs.onSurface,
            ),
          ),
          Text(
            body,
            style: context.text.bodyMedium!.copyWith(
              color: context.cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: <Widget>[
              AppButton(
                label: 'Start a workout',
                icon: Icons.play_arrow_rounded,
                type: AppButtonType.primary,
                onPressed: () => startEmptyWorkout(context, ref),
              ),
              if (next != null)
                AppButton(
                  label: 'Open ${next!.name}',
                  type: AppButtonType.outline,
                  onPressed: () => context.push(Routes.routine(next!.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Starts (or resumes) an empty workout and opens the logging screen.
Future<void> startEmptyWorkout(BuildContext context, WidgetRef ref) async {
  try {
    await ref.read(sessionRepositoryProvider).start();
  } on ActiveSessionExists {
    // Already running: just go back to it.
  }
  if (context.mounted) unawaited(context.push<void>(Routes.workout));
}

class _NewUserCard extends ConsumerWidget {
  const _NewUserCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SinewCard(
          hero: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Log your first workout',
                style: context.text.headlineSmall!.copyWith(
                  color: context.cs.onSurface,
                ),
              ),
              const SizedBox(height: Space.xs),
              Text(
                'Add exercises as you go. Tap a set to save it. That is it.',
                style: context.text.bodyMedium!.copyWith(
                  color: context.cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.lg),
              AppButton(
                label: 'Start empty workout',
                icon: Icons.play_arrow_rounded,
                type: AppButtonType.primary,
                fullWidth: true,
                onPressed: () => startEmptyWorkout(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.section),
        const SinewSectionHeader(title: 'Or start here'),
        SinewGroup(
          children: <Widget>[
            SinewListRow(
              leading: const SinewIconTile(icon: Icons.menu_book_outlined),
              title: 'Browse exercises',
              subtitle: 'Strength, yoga, mobility, cardio and more',
              trailing: const SinewChevron(),
              onTap: () => context.push(Routes.library),
            ),
            SinewListRow(
              leading: const SinewIconTile(icon: Icons.list_alt_rounded),
              title: 'Build a routine',
              subtitle: 'Save a workout you repeat',
              trailing: const SinewChevron(),
              onTap: () => context.push(Routes.newRoutine),
            ),
            SinewListRow(
              leading: const SinewIconTile(icon: Icons.timer_outlined),
              title: 'Run a timer',
              subtitle: 'Intervals, Tabata, rounds and more',
              trailing: const SinewChevron(),
              onTap: () => context.go(Routes.timer),
            ),
          ],
        ),
      ],
    );
  }
}

class _BackupReminder extends StatelessWidget {
  const _BackupReminder();

  @override
  Widget build(BuildContext context) {
    return SinewCard(
      onTap: () => context.push(Routes.backup),
      child: Row(
        children: <Widget>[
          const SinewIconTile(
            icon: Icons.backup_outlined,
            tone: SinewTone.warning,
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Back up your workouts', style: context.text.titleMedium),
                Text(
                  'Everything lives on this phone. Save a copy so a lost '
                  'phone does not take it with it.',
                  style: context.text.bodyMedium!.copyWith(
                    color: context.cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SinewChevron(),
        ],
      ),
    );
  }
}

class _QuickTimers extends StatelessWidget {
  const _QuickTimers({required this.presets});

  final List<TimerPreset> presets;

  @override
  Widget build(BuildContext context) {
    final List<TimerPreset> shown = presets
        .take(TodaySpec.quickTimerCount)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SinewSectionHeader(
          title: 'Quick timers',
          trailing: SinewSectionAction(
            label: 'All',
            onTap: () => context.go(Routes.timer),
          ),
        ),
        SinewTwoColumnGrid(
          children: <Widget>[
            for (final TimerPreset p in shown)
              SinewCard(
                onTap: () => context.push(
                  Routes.timerSetup(p.mode.name, presetId: p.id),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(_modeIcon(p.mode), color: context.cs.primary),
                    const SizedBox(height: Space.sm),
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium,
                    ),
                    if (presetSummary(p) != p.name)
                      Text(
                        presetSummary(p),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall!.copyWith(
                          color: context.cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

IconData _modeIcon(TimerMode m) => switch (m) {
  TimerMode.stopwatch => Icons.timer_outlined,
  TimerMode.countdown => Icons.hourglass_top_rounded,
  TimerMode.interval => Icons.repeat_rounded,
  TimerMode.tabata => Icons.timer_rounded,
  TimerMode.emom => Icons.repeat_one_rounded,
  TimerMode.amrap => Icons.all_inclusive_rounded,
  TimerMode.boxing => Icons.sports_mma_rounded,
  TimerMode.yogaFlow => Icons.self_improvement_rounded,
  TimerMode.custom => Icons.tune_rounded,
};

String _modeName(TimerMode m) => switch (m) {
  TimerMode.stopwatch => 'Stopwatch',
  TimerMode.countdown => 'Countdown',
  TimerMode.interval => 'Intervals',
  TimerMode.tabata => 'Tabata',
  TimerMode.emom => 'EMOM',
  TimerMode.amrap => 'AMRAP',
  TimerMode.boxing => 'Rounds',
  TimerMode.yogaFlow => 'Yoga flow',
  TimerMode.custom => 'Custom',
};

/// `4:00` when every step has a length, otherwise the mode's name.
String presetSummary(TimerPreset p) {
  int totalMs = 0;
  for (final TimerStepSpec s in p.steps) {
    final int? d = s.durationMs;
    if (d == null) return _modeName(p.mode);
    totalMs += d;
  }
  if (totalMs <= 0) return _modeName(p.mode);
  return DateText.clock((totalMs / 1000).round());
}

class _LastSession extends StatelessWidget {
  const _LastSession({
    required this.session,
    required this.now,
    required this.profile,
  });

  final WorkoutSession session;
  final DateTime now;
  final WeightUnit profile;

  @override
  Widget build(BuildContext context) {
    final int sets = <SetEntry>[
      for (final SessionExercise e in session.exercises)
        for (final SetEntry s in e.sets)
          if (s.completed) s,
    ].length;
    final int prs = <SetEntry>[
      for (final SessionExercise e in session.exercises)
        for (final SetEntry s in e.sets)
          if (s.isPR) s,
    ].length;
    final String when = DateText.recent(session.startedAt, now);
    final int? dur = session.durationSec;
    final double? volume = session.volumeKg;
    final double? kcal = session.caloriesKcal;
    final String title = session.name ?? 'Workout';
    final List<(String, String)> facts = <(String, String)>[
      if (volume != null && volume > 0)
        (
          _thousands(Units.fromKg(volume, profile)),
          '${Units.weightLabel(profile)} volume',
        ),
      if (sets > 0) ('$sets', sets == 1 ? 'set' : 'sets'),
      if (kcal != null && kcal > 0) ('${kcal.round()} kcal', 'est. burned'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SinewSectionHeader(title: 'Last session'),
        Semantics(
          button: true,
          label: '$title, $when',
          child: SinewCard(
            onTap: () => context.push(Routes.session(session.id)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleMedium,
                          ),
                          Text(
                            dur == null
                                ? when
                                : '$when · ${DateText.durationText(dur)}',
                            style: context.text.bodyMedium!.copyWith(
                              color: context.cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (prs > 0)
                      SinewPill(
                        label: prs == 1 ? '1 PR' : '$prs PRs',
                        tone: SinewTone.primary,
                      ),
                  ],
                ),
                if (facts.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Space.md),
                  Wrap(
                    spacing: Space.xl,
                    runSpacing: Space.sm,
                    children: <Widget>[
                      for (final (String v, String l) in facts)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(v, style: context.text.titleLarge),
                            Text(
                              l,
                              style: context.text.bodySmall!.copyWith(
                                color: context.cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _thousands(double v) {
  final String s = v.round().toString();
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// Weight, BMI and body fat from the newest entries, through the engine.
class _BodyLatest extends ConsumerWidget {
  const _BodyLatest();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TodayBody> body = ref.watch(todayBodyProvider);
    return body.when(
      loading: () => const Delayed(child: SinewSkeletonCard()),
      error: (Object e, StackTrace st) => const SizedBox.shrink(),
      data: (TodayBody b) {
        if (!b.hasAny) return const _AddBodyNudge();
        final WeightUnit unit = b.profile.weightUnit;
        final BmiCutoffs cutoffs = b.profile.bmiCutoffs;
        final bool heightMissing = b.profile.heightCm == null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SinewSectionHeader(
              title: 'Body · latest',
              trailing: SinewSectionAction(
                label: 'All',
                onTap: () => context.go(Routes.body),
              ),
            ),
            SinewTwoColumnGrid(
              children: <Widget>[
                StatCard<double>(
                  compact: true,
                  label: 'Weight',
                  result: b.weight,
                  format: (double kg) =>
                      Units.trim(Units.fromKg(kg, unit), maxDecimals: 1),
                  unit: Units.weightLabel(unit),
                  onTap: () => context.push(Routes.progress('weight')),
                  lockedActionLabel: 'Add weight',
                  onLockedAction: () => context.push(Routes.newEntry),
                ),
                StatCard<double>(
                  compact: true,
                  label: 'BMI',
                  result: b.bmi,
                  format: (double v) => Units.trim(v, maxDecimals: 1),
                  category: switch (b.bmi) {
                    StatValue<double>(:final double value) => _bmiWord(
                      BodyStats.bmiCategory(value, cutoffs),
                    ),
                    _ => null,
                  },
                  categoryTone: switch (b.bmi) {
                    StatValue<double>(:final double value) =>
                      BodyStats.bmiCategory(value, cutoffs) ==
                              BmiCategory.normal
                          ? SinewTone.success
                          : SinewTone.warning,
                    _ => SinewTone.secondary,
                  },
                  lockedActionLabel: heightMissing
                      ? 'Add height'
                      : 'Add weight',
                  onLockedAction: () => context.push(
                    heightMissing ? Routes.profile : Routes.newEntry,
                  ),
                ),
                StatCard<BodyFat>(
                  compact: true,
                  label: 'Body fat',
                  result: b.bodyFat,
                  format: (BodyFat f) => Units.trim(f.primary, maxDecimals: 1),
                  unit: '%',
                  onTap: () => context.push(Routes.progress('body-fat')),
                  onLockedAction: () => context.push(Routes.newEntry),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

String _bmiWord(BmiCategory c) => switch (c) {
  BmiCategory.underweight => 'Underweight',
  BmiCategory.normal => 'Healthy',
  BmiCategory.overweight => 'Overweight',
  BmiCategory.obese => 'Obese',
};

class _AddBodyNudge extends StatelessWidget {
  const _AddBodyNudge();

  @override
  Widget build(BuildContext context) {
    return SinewCard(
      onTap: () => context.push(Routes.newEntry),
      child: Row(
        children: <Widget>[
          const SinewIconTile(icon: Icons.straighten_rounded),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              'Add height and weight to see BMI.',
              style: context.text.bodyLarge,
            ),
          ),
          const SizedBox(width: Space.sm),
          Text(
            'Add',
            style: context.text.labelLarge!.copyWith(color: context.cs.primary),
          ),
        ],
      ),
    );
  }
}
