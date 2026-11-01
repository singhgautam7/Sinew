import 'dart:async';

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
import '../../core/units/units.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/configs.dart';
import '../../core/widgets/domain/muscle_map.dart';
import '../../core/widgets/domain/numeric_stepper.dart';
import '../../core/widgets/domain/set_row.dart';
import '../../core/widgets/domain/timer_ring.dart' show ClockText;
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_snackbar.dart';
import '../../core/widgets/sinew_stat_tile.dart';
import 'routine_style.dart';
import 'train_format.dart';
import 'train_providers.dart';
import 'train_records.dart';
import 'train_widgets.dart';

/// A finished workout (`Routes.session`): its numbers, the muscles it worked
/// and every set. Tap a set to correct it; records are recomputed.
class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WorkoutSession?> async = ref.watch(
      trainSessionProvider(sessionId),
    );
    final WorkoutSession? s = async.value;
    return Scaffold(
      appBar: SinewAppBar(
        title: s?.name ?? 'Workout',
        subtitle: s == null ? null : formatSessionWhen(s.startedAt, s.endedAt),
        showBack: true,
        showBrand: false,
        overflowConfig: s == null
            ? null
            : SinewOverflowConfig(
                items: <SinewOverflowItem>[
                  SinewOverflowItem(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete workout',
                    isDestructive: true,
                    onTap: () => unawaited(_delete(context, ref, s)),
                  ),
                ],
              ),
      ),
      body: async.when(
        loading: () => const TrainLoading(),
        error: (Object e, StackTrace _) => SinewErrorState(
          onRetry: () => ref.invalidate(trainSessionProvider(sessionId)),
        ),
        data: (WorkoutSession? s) => s == null
            ? const SinewErrorState(
                title: 'Workout not found',
                description: 'It may have been deleted.',
              )
            : _Body(session: s),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WorkoutSession s,
  ) async {
    final bool yes = await showSinewConfirmDialog(
      context: context,
      title: 'Delete this workout?',
      message:
          'It is removed from your history and your records are worked out '
          'again without it.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!yes || !context.mounted) return;
    final SessionRepository repo = ref.read(sessionRepositoryProvider);
    final OverlayState? overlay = Navigator.of(
      context,
      rootNavigator: true,
    ).overlay;
    // Keep the whole session, to put it back on Undo.
    final WorkoutSession full = await repo.byId(s.id) ?? s;
    await repo.delete(s.id);
    await recomputePrFlags(repo);
    ref.invalidate(trainFinishedTreesProvider);
    if (!context.mounted) return;
    context.pop();
    if (overlay != null && overlay.mounted) {
      showSinewSnackBar(
        overlay.context,
        'Workout deleted',
        overlay: overlay,
        actionLabel: 'Undo',
        onAction: () async {
          await repo.saveTree(full);
          await recomputePrFlags(repo);
          ref.invalidate(trainFinishedTreesProvider);
        },
      );
    }
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Profile profile =
        ref.watch(trainProfileProvider).value ?? const Profile();
    final String key = exerciseKey(
      session.exercises.map((SessionExercise e) => e.exerciseId),
    );
    final Map<String, Exercise> exercises =
        ref.watch(trainExercisesProvider(key)).value ??
        const <String, Exercise>{};
    final muscles = routineMuscles(
      session.exercises.map((SessionExercise e) => e.exerciseId),
      exercises,
    );
    final int sets = session.exercises.fold<int>(
      0,
      (int n, SessionExercise e) => n + e.sets.length,
    );
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.sm,
        Space.screen,
        Space.bottomSafe,
      ),
      children: <Widget>[
        SinewStatGrid(
          children: <Widget>[
            SinewStatTile(
              label: 'Duration',
              value: formatMinutes(session.durationSec ?? 0),
            ),
            SinewStatTile(
              label: 'Volume',
              value: formatVolume(session.volumeKg ?? 0, profile.weightUnit),
            ),
            SinewStatTile(label: 'Sets', value: '$sets'),
            SinewStatTile(
              label: 'Exercises',
              value: '${session.exercises.length}',
            ),
            SinewStatTile(
              label: 'Calories',
              value: session.caloriesKcal == null
                  ? '-'
                  : '${session.caloriesKcal!.round()} kcal',
              caption: session.caloriesKcal == null
                  ? 'no body weight'
                  : 'estimate',
            ),
            SinewStatTile(
              label: 'Effort',
              value: session.perceivedEffort == null
                  ? '-'
                  : '${session.perceivedEffort} / 10',
            ),
          ],
        ),
        if (muscles.primary.isNotEmpty) ...<Widget>[
          const SizedBox(height: Space.md),
          SinewCard(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: TrainSpec.mapPreview,
                  height: TrainSpec.mapPreviewHeight,
                  child: MuscleMap(
                    primary: muscles.primary,
                    secondary: muscles.secondary,
                    sex: profile.sex,
                    showLabels: false,
                  ),
                ),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Muscles worked', style: tt.titleSmall),
                      const SizedBox(height: Space.xxs),
                      Text(
                        'Main: ${muscles.primary.take(4).map(_pretty).join(', ')}.'
                        '${muscles.secondary.isEmpty ? '' : ' Also: ${muscles.secondary.take(3).map(_pretty).join(', ')}.'}',
                        style: tt.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (session.notes != null) ...<Widget>[
          const TrainSectionLabel('Note'),
          Text(session.notes!, style: tt.bodyMedium),
        ],
        for (final SessionExercise e in session.exercises) ...<Widget>[
          const SizedBox(height: Space.lg),
          _ExerciseBlock(
            session: session,
            entry: e,
            exercise:
                exercises[e.exerciseId] ??
                Exercise(
                  id: e.exerciseId,
                  name: e.exerciseId.replaceAll('-', ' '),
                  category: 'unknown',
                  trackingType: TrackingType.reps,
                ),
            profile: profile,
          ),
        ],
      ],
    );
  }

  static String _pretty(String id) => id.isEmpty
      ? id
      : id
            .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (Match _) => ' ')
            .toLowerCase();
}

class _ExerciseBlock extends ConsumerWidget {
  const _ExerciseBlock({
    required this.session,
    required this.entry,
    required this.exercise,
    required this.profile,
  });

  final WorkoutSession session;
  final SessionExercise entry;
  final Exercise exercise;
  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme tt = context.text;
    final int prs = entry.sets.where((SetEntry s) => s.isPR).length;
    return SinewCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            borderRadius: Radii.mediumR,
            onTap: () => context.push(Routes.exerciseHistory(exercise.id)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: IconSpec.tapTarget),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: '${exercise.name}. Open exercise history.',
                      excludeSemantics: true,
                      child: Text(exercise.name, style: tt.titleSmall),
                    ),
                  ),
                  if (prs > 0) ...<Widget>[
                    const SizedBox(width: Space.sm),
                    SinewPill(
                      label: prs == 1 ? 'PR' : '$prs PRs',
                      tone: SinewTone.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (entry.notes != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: Text(
                entry.notes!,
                style: tt.bodySmall!.copyWith(
                  color: context.cs.onSurfaceVariant,
                ),
              ),
            ),
          for (final SetEntry set in entry.sets)
            SetRow.compact(
              key: ValueKey<String>(set.id),
              entry: set,
              trackingType: exercise.trackingType,
              number: set.position + 1,
              weightUnit: profile.weightUnit,
              distanceUnit: profile.distanceUnit,
              onTap: () => _edit(context, ref, set),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, SetEntry set) async {
    final _Edit? result = await showSinewBottomSheet<_Edit>(
      context: context,
      builder: (BuildContext ctx) => _SetEditorSheet(
        set: set,
        type: exercise.trackingType,
        title: '${exercise.name}, set ${set.position + 1}',
        profile: profile,
      ),
    );
    if (result == null) return;
    final List<SessionExercise> exercises = <SessionExercise>[];
    for (final SessionExercise e in session.exercises) {
      if (e.id != entry.id) {
        exercises.add(e);
        continue;
      }
      final List<SetEntry> sets = <SetEntry>[];
      for (final SetEntry s in e.sets) {
        if (s.id != set.id) {
          sets.add(s);
        } else if (result.entry != null) {
          sets.add(result.entry!);
        }
      }
      if (sets.isEmpty) continue; // an exercise with no sets goes
      exercises.add(
        e.copyWith(
          sets: <SetEntry>[
            for (int i = 0; i < sets.length; i++) sets[i].copyWith(position: i),
          ],
        ),
      );
    }
    final WorkoutSession edited = session.copyWith(
      exercises: <SessionExercise>[
        for (int i = 0; i < exercises.length; i++)
          exercises[i].copyWith(position: i),
      ],
      updatedAt: DateTime.now(),
    );
    await recomputePrFlags(
      ref.read(sessionRepositoryProvider),
      replace: edited,
    );
    ref
      ..invalidate(trainSessionProvider(session.id))
      ..invalidate(trainFinishedTreesProvider);
  }
}

/// The outcome of the set editor: a changed set, or null to delete it.
class _Edit {
  const _Edit(this.entry);

  final SetEntry? entry;
}

/// Correct one logged set: the numbers for its tracking type, in the user's
/// units, or delete it.
class _SetEditorSheet extends StatefulWidget {
  const _SetEditorSheet({
    required this.set,
    required this.type,
    required this.title,
    required this.profile,
  });

  final SetEntry set;
  final TrackingType type;
  final String title;
  final Profile profile;

  @override
  State<_SetEditorSheet> createState() => _SetEditorSheetState();
}

class _SetEditorSheetState extends State<_SetEditorSheet> {
  late SetEntry _set = widget.set;

  Widget _row(String label, Widget stepper) => Padding(
    padding: const EdgeInsets.only(bottom: Space.md),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: context.text.bodyLarge!.copyWith(
              color: context.cs.onSurfaceVariant,
            ),
          ),
        ),
        stepper,
      ],
    ),
  );

  Widget _clock(
    String label,
    int? value,
    SetEntry Function(SetEntry, int?) set,
  ) => _row(
    label,
    NumericStepper(
      value: (value ?? 0).toDouble(),
      step: 5,
      max: 36000,
      maxDecimals: 0,
      semanticLabel: label,
      format: (double v) => ClockText.format(v.round()),
      onChanged: (double v) =>
          setState(() => _set = set(_set, v == 0 ? null : v.round())),
    ),
  );

  Widget _reps(
    String label,
    int? value,
    SetEntry Function(SetEntry, int?) set,
  ) => _row(
    label,
    NumericStepper(
      value: (value ?? 0).toDouble(),
      max: 1000,
      maxDecimals: 0,
      semanticLabel: label,
      onChanged: (double v) =>
          setState(() => _set = set(_set, v == 0 ? null : v.round())),
    ),
  );

  List<Widget> _fields() {
    final WeightUnit wu = widget.profile.weightUnit;
    final DistanceUnit du = widget.profile.distanceUnit;
    final Widget weight = _row(
      'Weight',
      NumericStepper(
        value: Units.fromKg(_set.weightKg ?? 0, wu),
        step: wu == WeightUnit.kg ? 2.5 : 5,
        max: 2000,
        unit: Units.weightLabel(wu),
        semanticLabel: 'Weight',
        onChanged: (double v) => setState(
          () =>
              _set = _set.copyWith(weightKg: v == 0 ? null : Units.toKg(v, wu)),
        ),
      ),
    );
    final Widget reps = _reps(
      'Reps',
      _set.reps,
      (SetEntry s, int? v) => s.copyWith(reps: v),
    );
    final Widget time = _clock(
      'Time',
      _set.durationSec,
      (SetEntry s, int? v) => s.copyWith(durationSec: v),
    );
    return switch (widget.type) {
      TrackingType.weightReps => <Widget>[weight, reps],
      TrackingType.reps || TrackingType.unknown => <Widget>[reps],
      TrackingType.time => <Widget>[time],
      TrackingType.hold => <Widget>[
        _clock(
          'Hold',
          _set.holdSec,
          (SetEntry s, int? v) => s.copyWith(holdSec: v),
        ),
      ],
      TrackingType.distanceTime => <Widget>[
        _row(
          'Distance',
          NumericStepper(
            value: Units.fromMetres(_set.distanceM ?? 0, du),
            step: 0.5,
            max: 1000,
            unit: Units.distanceLabel(du),
            semanticLabel: 'Distance',
            onChanged: (double v) => setState(
              () => _set = _set.copyWith(
                distanceM: v == 0 ? null : Units.toMetres(v, du),
              ),
            ),
          ),
        ),
        time,
      ],
      TrackingType.rounds || TrackingType.flow => <Widget>[
        _reps(
          'Rounds',
          _set.rounds,
          (SetEntry s, int? v) => s.copyWith(rounds: v),
        ),
        time,
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return SinewBottomSheet(
      title: 'Edit set',
      description: widget.title,
      actions: Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              label: 'Delete set',
              type: AppButtonType.danger,
              onPressed: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pop(const _Edit(null)),
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: AppButton(
              label: 'Save',
              type: AppButtonType.primary,
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(_Edit(_set)),
            ),
          ),
        ],
      ),
      child: Column(children: _fields()),
    );
  }
}

/// A one-line summary of a set for lists ("82.5 kg × 8").
String setSummaryLine(SetEntry s, TrackingType t, Profile p) => SetRow.summary(
  s,
  t,
  weightUnit: p.weightUnit,
  distanceUnit: p.distanceUnit,
);
