import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/models/plate_inventory.dart';
import '../../core/models/profile.dart';
import '../../core/models/training.dart';
import '../../core/routing/nav_visibility.dart';
import '../../core/routing/router.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/domain/plate_loader.dart';
import '../../core/widgets/domain/set_row.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_menu.dart';
import '../../core/widgets/sinew_states.dart';
import '../../engines/plates/plates.dart';
import '../timer/api/timer_api.dart';
import 'rest_timer.dart';
import 'train_format.dart';
import 'train_providers.dart';
import 'train_widgets.dart';
import 'workout_controller.dart';

/// The active workout (`Routes.workout`): full screen, nav hidden, screen
/// kept on. Resumes the running session; with [startRoutineId] and no running
/// session it starts that routine first.
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key, this.startRoutineId});

  final String? startRoutineId;

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  int? _index;
  String? _focusSetId;
  bool _restExpanded = false;
  bool _busy = false;
  bool _starting = false;
  final Map<String, int> _barChoice = <String, int>{};

  late final NavHideReasons _nav;
  late final ScreenWake _wake;

  @override
  void initState() {
    super.initState();
    _nav = ref.read(navHideReasonsProvider.notifier);
    _wake = ref.read(screenWakeProvider);
    holdNavHidden(_nav, const <NavHideReason>[NavHideReason.activeWorkout]);
    Future<void>.microtask(() {
      unawaited(_wake.keepOn(on: true));
      unawaited(ref.read(trainRestProvider.notifier).restore());
    });
    final String? routineId = widget.startRoutineId;
    if (routineId != null) {
      _starting = true;
      unawaited(_startRoutine(routineId));
    }
  }

  @override
  void dispose() {
    // Minimising the workout gives the screen back; a rest that is still
    // running keeps going in the background.
    releaseNav(_nav, const <NavHideReason>[
      NavHideReason.activeWorkout,
      NavHideReason.restTimer,
    ]);
    unawaited(_wake.keepOn(on: false));
    super.dispose();
  }

  Future<void> _startRoutine(String id) async {
    final Routine? routine = await ref.read(routineRepositoryProvider).byId(id);
    if (routine != null) {
      await ref.read(workoutLauncherProvider).start(routine: routine);
    }
    if (mounted) setState(() => _starting = false);
  }

  WorkoutController get _ctrl => ref.read(workoutProvider.notifier);

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.train);
    }
  }

  // ── Derived ───────────────────────────────────────────────────────────────

  int _firstOpen(WorkoutState ws) {
    final List<SessionExercise> ex = ws.session.exercises;
    for (int i = 0; i < ex.length; i++) {
      if (ex[i].sets.any((SetEntry s) => !s.completed)) return i;
    }
    return ex.isEmpty ? 0 : ex.length - 1;
  }

  SetEntry? _focusedSet(SessionExercise e) {
    if (_focusSetId != null) {
      for (final SetEntry s in e.sets) {
        if (s.id == _focusSetId && !s.completed) return s;
      }
    }
    for (final SetEntry s in e.sets) {
      if (!s.completed) return s;
    }
    return null;
  }

  SetEntry? _previousFor(WorkoutState ws, SessionExercise e, SetEntry s) {
    final List<SetEntry> prev = ws.previous[e.exerciseId] ?? <SetEntry>[];
    if (prev.isEmpty) return null;
    return s.position < prev.length ? prev[s.position] : prev.last;
  }

  /// [s] with its empty fields taken from [prev] (what the check accepts).
  SetEntry _prefilled(SetEntry s, SetEntry? prev) {
    if (prev == null) return s;
    return s.copyWith(
      weightKg: s.weightKg ?? prev.weightKg,
      reps: s.reps ?? prev.reps,
      durationSec: s.durationSec ?? prev.durationSec,
      distanceM: s.distanceM ?? prev.distanceM,
      rounds: s.rounds ?? prev.rounds,
      holdSec: s.holdSec ?? prev.holdSec,
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _complete(
    SessionExercise e,
    SetEntry set, {
    required bool done,
  }) async {
    await _ctrl.setCompleted(e.id, set.id, done: done);
    if (!done || !mounted) return;
    setState(() => _focusSetId = null);
    final WorkoutState? ws = ref.read(workoutProvider).value;
    if (ws == null) return;
    final List<SessionExercise> list = ws.session.exercises;
    final int at = list.indexWhere((SessionExercise x) => x.id == e.id);
    if (at < 0) return;

    // In a superset the next exercise of the group comes straight after,
    // and the rest starts once the group's round is done.
    final int? group = list[at].supersetGroup;
    if (group != null) {
      final int next = list.indexWhere(
        (SessionExercise x) =>
            x.supersetGroup == group &&
            list.indexOf(x) > at &&
            x.sets.any((SetEntry s) => !s.completed),
      );
      if (next >= 0) {
        setState(() => _index = next);
        return;
      }
      final int first = list.indexWhere(
        (SessionExercise x) =>
            x.supersetGroup == group &&
            x.sets.any((SetEntry s) => !s.completed),
      );
      if (first >= 0) setState(() => _index = first);
    }

    final ({String label, String detail})? upNext = _nextUp(ws);
    if (upNext == null) return; // nothing left to rest for
    final int restSec = ws.restSecFor(list[at].exerciseId);
    if (restSec <= 0) return;
    await ref
        .read(trainRestProvider.notifier)
        .start(restSec, nextLabel: upNext.label, nextDetail: upNext.detail);
  }

  /// What follows the set just done: the next open set of the current
  /// exercise, else the first open set of a later one.
  ({String label, String detail})? _nextUp(WorkoutState ws) {
    final List<SessionExercise> list = ws.session.exercises;
    final int current = (_index ?? _firstOpen(ws)).clamp(0, list.length - 1);
    final List<int> order = <int>[
      current,
      for (int i = 0; i < list.length; i++)
        if (i != current) i,
    ];
    final Profile profile =
        ref.read(trainProfileProvider).value ?? const Profile();
    for (final int i in order) {
      final SessionExercise e = list[i];
      final SetEntry? s = _firstOpenSet(e);
      if (s == null) continue;
      final Exercise ex = ws.exerciseOf(e.exerciseId);
      final SetEntry shown = _prefilled(s, _previousFor(ws, e, s));
      return (
        label: i == current
            ? 'set ${s.position + 1} of ${e.sets.length}'
            : '${ex.name}, set ${s.position + 1}',
        detail: SetRow.summary(
          shown,
          ex.trackingType,
          weightUnit: profile.weightUnit,
          distanceUnit: profile.distanceUnit,
        ),
      );
    }
    return null;
  }

  SetEntry? _firstOpenSet(SessionExercise e) {
    for (final SetEntry s in e.sets) {
      if (!s.completed) return s;
    }
    return null;
  }

  Future<void> _addExercises() async {
    final WorkoutState? ws = ref.read(workoutProvider).value;
    if (ws == null) return;
    final List<String>? ids = await ref.read(exercisePickerProvider)(
      context,
      exclude: <String>{
        for (final SessionExercise e in ws.session.exercises) e.exerciseId,
      },
      title: 'Add exercises',
    );
    if (ids == null || ids.isEmpty || !mounted) return;
    final int before = ws.session.exercises.length;
    await _ctrl.addExercises(ids);
    if (mounted) setState(() => _index = before);
  }

  Future<void> _swap(SessionExercise e) async {
    final WorkoutState? ws = ref.read(workoutProvider).value;
    if (ws == null) return;
    final List<String>? ids = await ref.read(exercisePickerProvider)(
      context,
      multiple: false,
      exclude: <String>{
        for (final SessionExercise x in ws.session.exercises) x.exerciseId,
      },
      title: 'Swap ${ws.exerciseOf(e.exerciseId).name}',
    );
    if (ids == null || ids.isEmpty || !mounted) return;
    await _ctrl.swapExercise(e.id, ids.first);
  }

  Future<void> _editNote(SessionExercise e) async {
    final TextEditingController c = TextEditingController(text: e.notes ?? '');
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Exercise note'),
        content: SinewTextField(
          label: 'Note',
          controller: c,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(c.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    c.dispose();
    if (result != null) await _ctrl.setNotes(e.id, result);
  }

  Future<void> _finish(WorkoutState ws) async {
    if (ws.completedSets == 0) {
      final bool discard = await showSinewConfirmDialog(
        context: context,
        title: 'Nothing logged yet',
        message:
            'No sets are done, so there is nothing to save. Discard this '
            'workout?',
        confirmLabel: 'Discard',
        destructive: true,
      );
      if (discard && mounted) await _discard();
      return;
    }
    final int open = ws.totalSets - ws.completedSets;
    final bool yes = await showSinewConfirmDialog(
      context: context,
      title: 'Finish workout?',
      message: open > 0
          ? '${ws.completedSets} of ${ws.totalSets} sets are done. '
                'The ${plural(open, 'unfinished set')} will be left out.'
          : 'All ${ws.totalSets} sets are done.',
      confirmLabel: 'Finish',
    );
    if (!yes || !mounted) return;
    setState(() => _busy = true);
    final FinishOutcome out = await _ctrl.finish();
    if (!mounted) return;
    context.pushReplacement(Routes.workoutSummary(out.sessionId));
  }

  Future<void> _discard() async {
    final bool yes = await showSinewConfirmDialog(
      context: context,
      title: 'Discard this workout?',
      message: 'Everything you logged in it is deleted. This cannot be undone.',
      confirmLabel: 'Discard',
      destructive: true,
    );
    if (!yes || !mounted) return;
    setState(() => _busy = true);
    await _ctrl.discard();
    if (mounted) _leave();
  }

  Future<void> _setMenu(
    BuildContext anchor,
    SessionExercise e,
    SetEntry set,
  ) async {
    final String? pick = await showSinewMenu<String>(
      context: anchor,
      entries: <SinewMenuEntry<String>>[
        SinewMenuEntry<String>(
          value: 'warmup',
          label: set.isWarmup ? 'Working set' : 'Warm-up set',
          icon: Icons.whatshot_outlined,
          selected: set.isWarmup,
        ),
        const SinewMenuEntry<String>.divider(),
        SinewMenuEntry<String>(
          value: 'normal',
          label: 'Normal',
          selected: set.type == SetType.normal,
        ),
        SinewMenuEntry<String>(
          value: 'drop',
          label: 'Drop set',
          selected: set.type == SetType.drop,
        ),
        SinewMenuEntry<String>(
          value: 'failure',
          label: 'To failure',
          selected: set.type == SetType.failure,
        ),
        SinewMenuEntry<String>(
          value: 'amrap',
          label: 'AMRAP',
          selected: set.type == SetType.amrap,
        ),
        const SinewMenuEntry<String>.divider(),
        const SinewMenuEntry<String>(
          value: 'delete',
          label: 'Delete set',
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
      ],
    );
    if (pick == null) return;
    switch (pick) {
      case 'warmup':
        await _ctrl.updateSet(e.id, set.copyWith(isWarmup: !set.isWarmup));
      case 'delete':
        await _ctrl.removeSet(e.id, set.id);
      default:
        final SetType type = SetType.values.firstWhere(
          (SetType t) => t.name == pick,
          orElse: () => SetType.normal,
        );
        await _ctrl.updateSet(e.id, set.copyWith(type: type));
    }
  }

  Future<void> _exerciseMenu(
    BuildContext anchor,
    WorkoutState ws,
    SessionExercise e,
    int index,
  ) async {
    final bool isLast = index == ws.session.exercises.length - 1;
    final bool linked =
        e.supersetGroup != null &&
        !isLast &&
        ws.session.exercises[index + 1].supersetGroup == e.supersetGroup;
    final String? pick = await showSinewMenu<String>(
      context: anchor,
      entries: <SinewMenuEntry<String>>[
        SinewMenuEntry<String>(
          value: 'note',
          label: e.notes == null ? 'Add note' : 'Edit note',
          icon: Icons.sticky_note_2_outlined,
        ),
        if (!isLast)
          SinewMenuEntry<String>(
            value: 'superset',
            label: linked ? 'Unlink superset' : 'Superset with next',
            icon: Icons.link_rounded,
          ),
        const SinewMenuEntry<String>.divider(),
        const SinewMenuEntry<String>(
          value: 'remove',
          label: 'Remove exercise',
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
      ],
    );
    if (pick == null || !mounted) return;
    switch (pick) {
      case 'note':
        await _editNote(e);
      case 'superset':
        await _ctrl.toggleSupersetWithNext(e.id);
      case 'remove':
        final bool yes = await showSinewConfirmDialog(
          context: context,
          title: 'Remove ${ws.exerciseOf(e.exerciseId).name}?',
          message: 'Its sets in this workout are deleted.',
          confirmLabel: 'Remove',
          destructive: true,
        );
        if (yes) await _ctrl.removeExercise(e.id);
    }
  }

  Future<void> _jumpTo(WorkoutState ws) async {
    final int? picked = await showSinewBottomSheet<int>(
      context: context,
      builder: (BuildContext ctx) => SinewBottomSheet(
        title: 'Exercises',
        child: Column(
          children: <Widget>[
            for (int i = 0; i < ws.session.exercises.length; i++)
              _JumpRow(
                name: ws.exerciseOf(ws.session.exercises[i].exerciseId).name,
                done: ws.session.exercises[i].sets
                    .where((SetEntry s) => s.completed)
                    .length,
                total: ws.session.exercises[i].sets.length,
                onTap: () => Navigator.of(ctx).pop(i),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _index = picked;
        _focusSetId = null;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final AsyncValue<WorkoutState?> async = ref.watch(workoutProvider);
    final bool resting = ref.watch(trainRestProvider) != null;
    final Widget body = async.when(
      loading: () => const TrainLoading(),
      error: (Object e, StackTrace _) =>
          SinewErrorState(onRetry: () => ref.invalidate(workoutProvider)),
      data: (WorkoutState? ws) {
        if (_busy || _starting) {
          return const TrainLoading();
        }
        if (ws == null) return _NoWorkout(onLeave: _leave);
        return _active(context, ws);
      },
    );
    return PopScope(
      canPop: !(_restExpanded && resting),
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) setState(() => _restExpanded = false);
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned.fill(child: body),
            if (_restExpanded && resting)
              Positioned.fill(
                child: RestExpanded(
                  onCollapse: () => setState(() => _restExpanded = false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _active(BuildContext context, WorkoutState ws) {
    final List<SessionExercise> list = ws.session.exercises;
    final Profile profile =
        ref.watch(trainProfileProvider).value ?? const Profile();
    final int index = list.isEmpty
        ? 0
        : (_index ?? _firstOpen(ws)).clamp(0, list.length - 1);
    final SessionExercise? current = list.isEmpty ? null : list[index];
    final bool resting = ref.watch(trainRestProvider) != null;
    return SafeArea(
      child: Column(
        children: <Widget>[
          _Header(
            ws: ws,
            onMinimise: _leave,
            onFinish: () => _finish(ws),
            onDiscard: _discard,
          ),
          _Progress(ws: ws, index: index),
          Expanded(
            child: current == null
                ? _EmptyWorkout(onAdd: _addExercises)
                : _exercisePage(context, ws, profile, current, index),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.sm,
              Space.screen,
              Space.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (resting)
                  RestBar(onExpand: () => setState(() => _restExpanded = true)),
                _ActionRow(
                  ws: ws,
                  index: index,
                  focused: current == null ? null : _focusedSet(current),
                  onAdd: _addExercises,
                  onComplete: () {
                    final SessionExercise e = current!;
                    final SetEntry s = _focusedSet(e)!;
                    final SetEntry filled = _prefilled(
                      s,
                      _previousFor(ws, e, s),
                    );
                    if (filled != s) unawaited(_ctrl.updateSet(e.id, filled));
                    unawaited(_complete(e, s, done: true));
                  },
                  onNext: () => setState(() {
                    _index = index + 1;
                    _focusSetId = null;
                  }),
                  onFinish: () => _finish(ws),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _exercisePage(
    BuildContext context,
    WorkoutState ws,
    Profile profile,
    SessionExercise e,
    int index,
  ) {
    final Exercise ex = ws.exerciseOf(e.exerciseId);
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    final SetEntry? focused = _focusedSet(e);
    final List<String> partners = <String>[
      if (e.supersetGroup != null)
        for (final SessionExercise x in ws.session.exercises)
          if (x.id != e.id && x.supersetGroup == e.supersetGroup)
            ws.exerciseOf(x.exerciseId).name,
    ];
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.md,
            Space.screen,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    borderRadius: Radii.mediumR,
                    onTap: () => _jumpTo(ws),
                    child: Semantics(
                      button: true,
                      label:
                          'Exercise ${index + 1} of '
                          '${ws.session.exercises.length}, ${ex.name}. '
                          'Opens the list of exercises.',
                      excludeSemantics: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'EXERCISE ${index + 1} OF '
                            '${ws.session.exercises.length}',
                            style: context.sectionHeader,
                          ),
                          Text(
                            ex.name,
                            style: tt.titleLarge,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AppIconButton(
                  icon: Icons.swap_horiz_rounded,
                  semanticLabel: 'Swap ${ex.name}',
                  onPressed: () => _swap(e),
                ),
                AppIconButton(
                  icon: Icons.info_outline_rounded,
                  semanticLabel: 'About ${ex.name}',
                  onPressed: () => context.push(Routes.exercise(ex.id)),
                ),
                Builder(
                  builder: (BuildContext ctx) => AppIconButton(
                    icon: Icons.more_vert_rounded,
                    semanticLabel: 'More for ${ex.name}',
                    onPressed: () => _exerciseMenu(ctx, ws, e, index),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (partners.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.xs,
              Space.screen,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.link_rounded,
                    size: IconSpec.small,
                    color: cs.primary,
                  ),
                  const SizedBox(width: Space.xs),
                  Expanded(
                    child: Text(
                      'Superset with ${partners.join(', ')}',
                      style: tt.bodySmall!.copyWith(color: cs.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (e.notes != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.xs,
              Space.screen,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                e.notes!,
                style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: _PlateStage(
            exercise: ex,
            set: focused,
            hint: focused == null ? null : _previousFor(ws, e, focused),
            weightUnit: profile.weightUnit,
            barChoice: _barChoice[ex.id] ?? 0,
            onBarChoice: (int i) => setState(() => _barChoice[ex.id] = i),
            onPickWeight: (double kg) {
              final SetEntry? f = focused;
              if (f != null) {
                unawaited(_ctrl.updateSet(e.id, f.copyWith(weightKg: kg)));
              }
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.md,
            Space.screen,
            0,
          ),
          sliver: SliverList.separated(
            itemCount: e.sets.length,
            separatorBuilder: (BuildContext _, int index) =>
                const SizedBox(height: TrainSpec.setGap),
            itemBuilder: (BuildContext context, int i) {
              final SetEntry set = e.sets[i];
              final SetEntry? prev = _previousFor(ws, e, set);
              final bool isFocus = focused?.id == set.id;
              final bool planned = !set.completed && !isFocus;
              return Builder(
                key: ValueKey<String>(set.id),
                builder: (BuildContext rowContext) => SetRow(
                  entry: planned ? _prefilled(set, prev) : set,
                  trackingType: ex.trackingType,
                  previous: prev,
                  number: i + 1,
                  weightUnit: profile.weightUnit,
                  distanceUnit: profile.distanceUnit,
                  focused: isFocus,
                  planned: planned,
                  onTap: planned
                      ? () => setState(() => _focusSetId = set.id)
                      : null,
                  onChanged: (SetEntry next) {
                    unawaited(_ctrl.updateSet(e.id, next));
                  },
                  onComplete: (bool done) =>
                      unawaited(_complete(e, set, done: done)),
                  onLongPress: () => _setMenu(rowContext, e, set),
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.sm,
            Space.screen,
            Space.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton(
                label: 'Add set',
                icon: Icons.add_rounded,
                type: AppButtonType.normal,
                height: Sizes.buttonSmall,
                onPressed: () => _ctrl.addSet(e.id),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoWorkout extends ConsumerWidget {
  const _NoWorkout({required this.onLeave});

  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: AppIconButton(
                icon: Icons.keyboard_arrow_down_rounded,
                semanticLabel: 'Close',
                onPressed: onLeave,
              ),
            ),
          ),
          Expanded(
            child: SinewEmptyState(
              icon: Icons.fitness_center_rounded,
              title: 'No workout in progress',
              description:
                  'Start an empty workout, or pick a routine on the Train '
                  'tab.',
              actionLabel: 'Start workout',
              actionIcon: Icons.play_arrow_rounded,
              onAction: () async {
                await ref.read(workoutLauncherProvider).start();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWorkout extends StatelessWidget {
  const _EmptyWorkout({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => SinewEmptyState(
    icon: Icons.fitness_center_rounded,
    title: 'Add your first exercise',
    description: 'Pick from the library, then log each set as you go.',
    actionLabel: 'Add exercise',
    onAction: onAdd,
  );
}

/// Minimise, name and clock, overflow, and Finish.
class _Header extends ConsumerWidget {
  const _Header({
    required this.ws,
    required this.onMinimise,
    required this.onFinish,
    required this.onDiscard,
  });

  final WorkoutState ws;
  final VoidCallback onMinimise;
  final VoidCallback onFinish;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme tt = context.text;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.sm,
        Space.sm,
        Space.lg,
        Space.xs,
      ),
      child: Row(
        children: <Widget>[
          AppIconButton(
            icon: Icons.keyboard_arrow_down_rounded,
            semanticLabel: 'Minimise workout',
            onPressed: onMinimise,
          ),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ws.session.name ?? 'Workout',
                  style: tt.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                ElapsedClock(
                  startedAt: ws.session.startedAt,
                  style: tt.bodyMedium!.copyWith(
                    color: context.cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (BuildContext ctx) => AppIconButton(
              icon: Icons.more_vert_rounded,
              semanticLabel: 'More',
              onPressed: () async {
                final String? pick = await showSinewMenu<String>(
                  context: ctx,
                  entries: const <SinewMenuEntry<String>>[
                    SinewMenuEntry<String>(
                      value: 'discard',
                      label: 'Discard workout',
                      icon: Icons.delete_outline_rounded,
                      destructive: true,
                    ),
                  ],
                );
                if (pick == 'discard') onDiscard();
              },
            ),
          ),
          const SizedBox(width: Space.xs),
          AppButton(
            label: 'Finish',
            type: AppButtonType.primary,
            height: Sizes.buttonSmall,
            onPressed: onFinish,
          ),
        ],
      ),
    );
  }
}

/// The workout's running time, from its start stamp. Repaints each second.
class ElapsedClock extends ConsumerStatefulWidget {
  const ElapsedClock({super.key, required this.startedAt, this.style});

  final DateTime startedAt;
  final TextStyle? style;

  @override
  ConsumerState<ElapsedClock> createState() => _ElapsedClockState();
}

class _ElapsedClockState extends ConsumerState<ElapsedClock> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer _) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int now = ref.read(trainNowMsProvider)();
    final int sec = (now - widget.startedAt.millisecondsSinceEpoch) ~/ 1000;
    return Semantics(
      label: 'Workout time ${formatElapsed(sec)}',
      excludeSemantics: true,
      child: Text(
        formatElapsed(sec),
        key: const ValueKey<String>('workout-elapsed'),
        style: widget.style,
      ),
    );
  }
}

/// One thin segment per exercise: done, current, to do. Decorative; the
/// exercise header carries the spoken position.
class _Progress extends StatelessWidget {
  const _Progress({required this.ws, required this.index});

  final WorkoutState ws;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final List<SessionExercise> list = ws.session.exercises;
    if (list.isEmpty) return const SizedBox.shrink();
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.screen),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < list.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: TrainSpec.exerciseBarGap),
              Expanded(
                child: Container(
                  height: TrainSpec.progressSegment,
                  decoration: BoxDecoration(
                    borderRadius: Radii.fullR,
                    color:
                        list[i].sets.isNotEmpty &&
                            list[i].sets.every((SetEntry s) => s.completed)
                        ? cs.primary
                        : (i == index
                              ? cs.primary.withValues(alpha: Opacities.muted)
                              : cs.surfaceContainerHighest),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _JumpRow extends StatelessWidget {
  const _JumpRow({
    required this.name,
    required this.done,
    required this.total,
    required this.onTap,
  });

  final String name;
  final int done;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: IconSpec.tapTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.sm),
          child: Row(
            children: <Widget>[
              Icon(
                done == total && total > 0
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done == total && total > 0
                    ? cs.primary
                    : cs.onSurfaceVariant,
              ),
              const SizedBox(width: Space.md),
              Expanded(child: Text(name, style: context.text.bodyLarge)),
              Text(
                '$done/$total',
                style: context.text.bodyMedium!.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The bottom row: add exercise, and the one thing to do next.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.ws,
    required this.index,
    required this.focused,
    required this.onAdd,
    required this.onComplete,
    required this.onNext,
    required this.onFinish,
  });

  final WorkoutState ws;
  final int index;
  final SetEntry? focused;
  final VoidCallback onAdd;
  final VoidCallback onComplete;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final bool hasOpen = focused != null;
    final bool last = index >= ws.session.exercises.length - 1;
    final String label = hasOpen
        ? 'Complete set ${focused!.position + 1}'
        : (last ? 'Finish workout' : 'Next exercise');
    final IconData icon = hasOpen
        ? Icons.check_rounded
        : (last ? Icons.flag_rounded : Icons.arrow_forward_rounded);
    final VoidCallback action = hasOpen
        ? onComplete
        : (last ? onFinish : onNext);
    return Row(
      children: <Widget>[
        SizedBox.square(
          dimension: SinewSpace.gloveTarget,
          child: Semantics(
            button: true,
            label: 'Add exercise',
            excludeSemantics: true,
            child: IconButton.filledTonal(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              iconSize: TrainSpec.headerGlyph,
            ),
          ),
        ),
        const SizedBox(width: Space.md),
        Expanded(
          child: SizedBox(
            height: SinewSpace.gloveTarget,
            child: FilledButton.icon(
              onPressed: action,
              icon: Icon(icon),
              label: Text(label, maxLines: 2, textAlign: TextAlign.center),
            ),
          ),
        ),
      ],
    );
  }
}

/// The plate loader for barbell, dumbbell and stack exercises, driven by the
/// set being worked on (its weight, else last time's).
class _PlateStage extends ConsumerWidget {
  const _PlateStage({
    required this.exercise,
    required this.set,
    required this.hint,
    required this.weightUnit,
    required this.barChoice,
    required this.onBarChoice,
    required this.onPickWeight,
  });

  final Exercise exercise;
  final SetEntry? set;
  final SetEntry? hint;
  final WeightUnit weightUnit;
  final int barChoice;
  final ValueChanged<int> onBarChoice;
  final ValueChanged<double> onPickWeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exercise.trackingType != TrackingType.weightReps) {
      return const SizedBox.shrink();
    }
    final double? kg = set?.weightKg ?? hint?.weightKg;
    if (kg == null || kg <= 0) return const SizedBox.shrink();
    final bool barbell =
        exercise.equipment.contains('barbell') ||
        exercise.equipment.contains('ezBar');
    final bool dumbbell = !barbell && exercise.equipment.contains('dumbbell');
    final bool stack =
        !barbell &&
        !dumbbell &&
        (exercise.equipment.contains('cable') ||
            exercise.equipment.contains('machine'));
    if (!barbell && !dumbbell && !stack) return const SizedBox.shrink();
    final PlateInventory inv =
        ref.watch(trainPlateInventoryProvider).value ??
        PlateInventory.metricDefault;
    final Widget loader;
    Widget? chips;
    if (stack) {
      loader = PlateLoader.stack(
        targetKg: kg,
        stepKg: inv.machineStepKg,
        unit: weightUnit,
        onPickNearest: onPickWeight,
      );
    } else {
      final List<Bar> bars = <Bar>[
        for (final Bar b in inv.bars)
          if (b.isDumbbell == dumbbell) b,
      ];
      if (bars.isEmpty) return const SizedBox.shrink();
      int pick = barChoice.clamp(0, bars.length - 1);
      if (barChoice == 0 && exercise.equipment.contains('ezBar')) {
        final int ez = bars.indexWhere(
          (Bar b) => b.name.toLowerCase().contains('ez'),
        );
        if (ez >= 0) pick = ez;
      }
      final Bar bar = bars[pick];
      loader = PlateLoader(
        result: PlateEngine.solve(targetKg: kg, bar: bar, inventory: inv),
        targetKg: kg,
        bar: bar,
        unit: weightUnit,
        onPickNearest: onPickWeight,
      );
      if (bars.length > 1) {
        chips = Wrap(
          alignment: WrapAlignment.center,
          spacing: Space.sm,
          runSpacing: Space.xs,
          children: <Widget>[
            for (int i = 0; i < bars.length; i++)
              SinewChip(
                shrink: true,
                label: bars[i].name,
                selected: i == pick,
                onTap: () => onBarChoice(i),
              ),
          ],
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.md,
        Space.screen,
        0,
      ),
      child: Column(
        children: <Widget>[
          FittedBox(fit: BoxFit.scaleDown, child: loader),
          if (chips != null) ...<Widget>[
            const SizedBox(height: Space.sm),
            chips,
          ],
        ],
      ),
    );
  }
}
