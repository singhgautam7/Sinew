import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/exercise.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_extended_fab.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_menu.dart';
import '../../core/widgets/sinew_states.dart';
import 'routine_style.dart';
import 'train_actions.dart';
import 'train_format.dart';
import 'train_providers.dart';

/// Text scale above which the FAB shows "New" instead of "New routine".
const double _fabLabelScaleLimit = 1.3;

/// The Train tab: routines, a way to start a workout, and entries to History
/// and the Library. A running workout shows as a banner that resumes it.
class TrainScreen extends ConsumerWidget {
  const TrainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Routine>> routines = ref.watch(trainRoutinesProvider);
    final String? activeId = ref.watch(trainActiveIdProvider).value;
    return Scaffold(
      floatingActionButtonLocation: sinewFabLocation,
      floatingActionButton: SinewExtendedFab(
        icon: Icons.add_rounded,
        // The shared FAB does not shrink its label; at large text sizes the
        // short form keeps it inside the screen.
        label: MediaQuery.textScalerOf(context).scale(1) > _fabLabelScaleLimit
            ? 'New'
            : 'New routine',
        onPressed: () => context.push(Routes.newRoutine),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SinewPageHeader(
              title: 'Train',
              actions: <Widget>[
                AppIconButton(
                  icon: Icons.history_rounded,
                  semanticLabel: 'History',
                  onPressed: () => context.push(Routes.history),
                ),
                AppIconButton(
                  icon: Icons.menu_book_rounded,
                  semanticLabel: 'Library',
                  onPressed: () => context.push(Routes.library),
                ),
              ],
            ),
          ),
          if (activeId != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                0,
                Space.screen,
                Space.md,
              ),
              sliver: SliverToBoxAdapter(child: _ResumeBanner(id: activeId)),
            ),
          ...routines.when(
            data: (List<Routine> list) => _routineSlivers(context, ref, list),
            loading: () => <Widget>[
              const SliverToBoxAdapter(child: Delayed(child: _Skeletons())),
            ],
            error: (Object e, StackTrace _) => <Widget>[
              SliverFillRemaining(
                hasScrollBody: false,
                child: SinewErrorState(
                  onRetry: () => ref.invalidate(trainRoutinesProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _routineSlivers(
    BuildContext context,
    WidgetRef ref,
    List<Routine> routines,
  ) {
    if (routines.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SinewEmptyState(
                icon: Icons.list_alt_rounded,
                title: 'No routines yet',
                description:
                    'A routine is a saved list of exercises with your '
                    'targets. You can also just start a workout and save it '
                    'as a routine later.',
                actionLabel: 'New routine',
                onAction: () => context.push(Routes.newRoutine),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.screen),
                child: AppButton(
                  label: 'Start an empty workout',
                  icon: Icons.play_arrow_rounded,
                  type: AppButtonType.outline,
                  fullWidth: true,
                  onPressed: () => startWorkoutAndOpen(context, ref),
                ),
              ),
              const SizedBox(height: SinewExtendedFab.clearance),
            ],
          ),
        ),
      ];
    }
    final Map<String, DateTime> lastDone = ref
        .watch(trainRecentSessionsProvider)
        .maybeWhen(
          data: (List<WorkoutSession> sessions) => <String, DateTime>{
            for (final WorkoutSession s in sessions.reversed)
              if (s.routineId != null) s.routineId!: s.startedAt,
          },
          orElse: () => const <String, DateTime>{},
        );
    final String key = exerciseKey(<String>[
      for (final Routine r in routines)
        for (final RoutineItem i in r.items) i.exerciseId,
    ]);
    final Map<String, Exercise> exercises =
        ref.watch(trainExercisesProvider(key)).value ??
        const <String, Exercise>{};
    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: Space.screen),
        sliver: SliverToBoxAdapter(
          child: AppButton(
            label: 'Start an empty workout',
            icon: Icons.play_arrow_rounded,
            type: AppButtonType.outline,
            fullWidth: true,
            onPressed: () => startWorkoutAndOpen(context, ref),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.xl,
            Space.screen,
            Space.sm,
          ),
          child: Semantics(
            header: true,
            child: Text(
              'MY ROUTINES · ${routines.length}',
              style: context.sectionHeader,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          0,
          Space.screen,
          SinewExtendedFab.clearance,
        ),
        sliver: SliverList.separated(
          itemCount: routines.length,
          separatorBuilder: (BuildContext _, int index) =>
              const SizedBox(height: Space.cardGap),
          itemBuilder: (BuildContext context, int i) => RoutineCard(
            routine: routines[i],
            exercises: exercises,
            lastDone: lastDone[routines[i].id],
          ),
        ),
      ),
    ];
  }
}

/// Rough minutes for a routine: work plus rest for every set, to 5 minutes.
/// Zero for an empty routine.
int estimateRoutineMinutes(List<RoutineItem> items) {
  if (items.isEmpty) return 0;
  int seconds = 0;
  for (final RoutineItem i in items) {
    seconds +=
        i.targetSets *
        (TrainSpec.estimatedWorkSecPerSet +
            (i.restSec ?? TrainSpec.defaultRestSec));
  }
  final int minutes = ((seconds / 60) / 5).round() * 5;
  return minutes < 5 ? 5 : minutes;
}

/// "6 exercises · about 50 min".
String routineSummary(Routine r) {
  final String count = plural(r.items.length, 'exercise');
  if (r.items.isEmpty) return count;
  return '$count · about ${estimateRoutineMinutes(r.items)} min';
}

class RoutineCard extends ConsumerWidget {
  const RoutineCard({
    super.key,
    required this.routine,
    required this.exercises,
    this.lastDone,
  });

  final Routine routine;
  final Map<String, Exercise> exercises;
  final DateTime? lastDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final RoutineStyle style = ref.watch(routineStyleProvider(routine.id));
    final muscles = routineMuscles(
      routine.items.map((RoutineItem i) => i.exerciseId),
      exercises,
    );
    return Builder(
      builder: (BuildContext cardContext) => SinewCard(
        padding: const EdgeInsets.all(Space.md),
        onTap: () => context.push(Routes.routine(routine.id)),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () => _menu(cardContext, ref),
          child: Row(
            children: <Widget>[
              RoutineTile(
                style: style,
                primary: muscles.primary,
                secondary: muscles.secondary,
                size: TrainSpec.routineTile,
              ),
              const SizedBox(width: Space.md + Space.xxs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      routine.name,
                      style: tt.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      routineSummary(routine),
                      style: tt.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      lastDone == null
                          ? 'Not done yet'
                          : 'Last done ${formatAgo(lastDone!, DateTime.now())}',
                      style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.sm),
              Semantics(
                button: true,
                label: 'Start ${routine.name}',
                excludeSemantics: true,
                child: Material(
                  color: cs.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () =>
                        startWorkoutAndOpen(context, ref, routine: routine),
                    child: SizedBox.square(
                      dimension: TrainSpec.routinePlay,
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: TrainSpec.routinePlayGlyph,
                        color: cs.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _menu(BuildContext anchor, WidgetRef ref) async {
    final String? pick = await showSinewMenu<String>(
      context: anchor,
      entries: const <SinewMenuEntry<String>>[
        SinewMenuEntry<String>(
          value: 'edit',
          label: 'Edit',
          icon: Icons.edit_outlined,
        ),
        SinewMenuEntry<String>(
          value: 'delete',
          label: 'Delete',
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
      ],
    );
    if (pick == null || !anchor.mounted) return;
    if (pick == 'edit') {
      await anchor.push(Routes.routine(routine.id));
      return;
    }
    final bool yes = await showSinewConfirmDialog(
      context: anchor,
      title: 'Delete ${routine.name}?',
      message:
          'The routine is removed. Workouts you did with it stay in '
          'your history.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!yes) return;
    await ref.read(routineRepositoryProvider).delete(routine.id);
    await ref.read(routineStyleStoreProvider).remove(routine.id);
  }
}

class _ResumeBanner extends ConsumerWidget {
  const _ResumeBanner({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = context.cs;
    final String name =
        ref.watch(trainSessionProvider(id)).value?.name ?? 'Workout';
    return SinewCard(
      color: cs.primaryContainer,
      borderColor: cs.primaryContainer,
      onTap: () => context.push(Routes.workout),
      child: Semantics(
        button: true,
        label: 'Workout in progress, $name. Resume.',
        excludeSemantics: true,
        child: Row(
          children: <Widget>[
            Icon(Icons.timer_outlined, color: cs.onPrimaryContainer),
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
                    name,
                    style: context.text.bodyMedium!.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Space.sm),
            Text(
              'Resume',
              style: context.text.labelLarge!.copyWith(
                color: cs.onPrimaryContainer,
              ),
            ),
          ],
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
      padding: EdgeInsets.symmetric(horizontal: Space.screen),
      child: Column(
        children: <Widget>[
          SinewSkeletonCard(),
          SizedBox(height: Space.cardGap),
          SinewSkeletonCard(),
          SizedBox(height: Space.cardGap),
          SinewSkeletonCard(),
        ],
      ),
    );
  }
}
