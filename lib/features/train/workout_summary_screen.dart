import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/ids.dart';
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
import '../../core/widgets/domain/muscle_map.dart';
import '../../core/widgets/domain/set_row.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_snackbar.dart';
import '../../core/widgets/sinew_stat_tile.dart';
import '../../engines/records/records.dart';
import '../../engines/records/train_stats.dart';
import 'routine_style.dart';
import 'train_format.dart';
import 'train_providers.dart';
import 'train_widgets.dart';
import 'workout_controller.dart' show FinishedPrs, lastFinishedPrsProvider;

/// A personal record set, ready to show.
class PrLine {
  const PrLine({
    required this.exerciseName,
    required this.setText,
    this.e1rmKg,
    this.e1rmDeltaKg,
  });

  final String exerciseName;
  final String setText;

  /// Estimated one-rep max of the set, kg.
  final double? e1rmKg;

  /// How much it beat the previous best estimate by, kg.
  final double? e1rmDeltaKg;
}

/// Everything the summary shows, worked out from the stored session and the
/// engines.
class SummaryData {
  const SummaryData({
    required this.session,
    required this.exercises,
    required this.prs,
    required this.bodyWeightKg,
  });

  final WorkoutSession session;
  final Map<String, Exercise> exercises;
  final List<PrLine> prs;

  /// The latest logged body weight the calories were based on, if any.
  final double? bodyWeightKg;
}

final summaryProvider = FutureProvider.autoDispose.family<SummaryData?, String>(
  (Ref ref, String id) async {
    final repo = ref.watch(sessionRepositoryProvider);
    final WorkoutSession? session = await repo.byId(id);
    if (session == null) return null;
    Map<String, Exercise> exercises = <String, Exercise>{};
    try {
      final resolver = await ref.watch(exerciseResolverProvider.future);
      exercises = await resolver.resolve(<String>{
        for (final SessionExercise e in session.exercises) e.exerciseId,
      });
    } on Object {
      // No library: names fall back to ids.
    }
    final Profile profile = await ref.watch(profileRepositoryProvider).get();
    // The records come with the finish that just happened; a summary opened
    // later works them out from the history of these exercises only.
    final FinishedPrs? fresh = ref.read(lastFinishedPrsProvider);
    final List<PrDetail> details;
    if (fresh != null && fresh.sessionId == id) {
      details = fresh.prs;
    } else {
      final List<WorkoutSession> before = <WorkoutSession>[
        for (final WorkoutSession s in await repo.sessionsForExercises(
          session.exercises.map((SessionExercise e) => e.exerciseId),
          excludeSessionId: id,
        ))
          if (s.startedAt.isBefore(session.startedAt)) s,
      ];
      details = prDetails(session, Records.computeRecords(before));
    }
    final List<PrLine> prs = <PrLine>[
      for (final PrDetail d in details)
        PrLine(
          exerciseName:
              (exercises[d.exerciseId]?.name) ??
              d.exerciseId.replaceAll('-', ' '),
          setText: SetRow.summary(
            d.set,
            exercises[d.exerciseId]?.trackingType ?? TrackingType.reps,
            weightUnit: profile.weightUnit,
            distanceUnit: profile.distanceUnit,
          ),
          e1rmKg: d.e1rmKg,
          e1rmDeltaKg: d.e1rmDeltaKg,
        ),
    ];
    final latest = await ref
        .watch(measurementRepositoryProvider)
        .latestValues();
    return SummaryData(
      session: session,
      exercises: exercises,
      prs: prs,
      bodyWeightKg: latest['weight']?.value,
    );
  },
);

/// The screen after Finish (`Routes.workoutSummary`): the numbers, any
/// records, how hard it felt, and a note.
class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen> {
  final TextEditingController _notes = TextEditingController();
  late final SessionRepository _repo;
  WorkoutSession? _session;
  int? _effort;
  bool _loadedFields = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(sessionRepositoryProvider);
  }

  @override
  void dispose() {
    // Leaving by any route keeps what was typed.
    if (_dirty) unawaited(_persist());
    _notes.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    final WorkoutSession? s = _session;
    if (s == null || s.endedAt == null) return;
    _dirty = false;
    // A blank note clears the field (stored as null).
    await _repo.updateSummary(
      s.id,
      perceivedEffort: _effort,
      notes: _notes.text,
    );
  }

  Future<void> _saveAsRoutine(SummaryData d) async {
    final WorkoutSession s = d.session;
    final List<RoutineItem> items = <RoutineItem>[];
    for (final SessionExercise e in s.exercises) {
      final SetEntry? last = e.sets.isEmpty ? null : e.sets.last;
      final TrackingType type =
          d.exercises[e.exerciseId]?.trackingType ?? TrackingType.reps;
      items.add(
        RoutineItem(
          id: newId(),
          exerciseId: e.exerciseId,
          position: items.length,
          supersetGroup: e.supersetGroup,
          targetSets: e.sets.length,
          targetReps: switch (type) {
            TrackingType.weightReps ||
            TrackingType.reps ||
            TrackingType.rounds ||
            TrackingType.flow ||
            TrackingType.unknown => last?.reps ?? last?.rounds,
            _ => null,
          },
          targetWeightKg: type == TrackingType.weightReps
              ? last?.weightKg
              : null,
          targetDurationSec: switch (type) {
            TrackingType.hold => last?.holdSec,
            TrackingType.time || TrackingType.distanceTime => last?.durationSec,
            _ => null,
          },
          targetDistanceM: type == TrackingType.distanceTime
              ? last?.distanceM
              : null,
        ),
      );
    }
    final repo = ref.read(routineRepositoryProvider);
    final int position = (await repo.allWithItems()).length;
    final DateTime now = DateTime.now();
    await repo.save(
      Routine(
        id: newId(),
        name: s.name ?? 'Workout ${formatDay(s.startedAt)}',
        position: position,
        items: items,
        createdAt: now,
        updatedAt: now,
      ),
    );
    if (mounted) showSinewSnackBar(context, 'Saved as a routine in Train.');
  }

  void _done() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.train);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SummaryData?> async = ref.watch(
      summaryProvider(widget.sessionId),
    );
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: async.when(
          loading: () => const TrainLoading(),
          error: (Object e, StackTrace _) => SinewErrorState(
            onRetry: () => ref.invalidate(summaryProvider(widget.sessionId)),
          ),
          data: (SummaryData? d) {
            if (d == null) {
              return SinewErrorState(
                title: 'Workout not found',
                description: 'It may have been deleted.',
                onRetry: _done,
              );
            }
            if (!_loadedFields) {
              _loadedFields = true;
              _session = d.session;
              _effort = d.session.perceivedEffort;
              _notes.text = d.session.notes ?? '';
            }
            return _content(context, d);
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, SummaryData d) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final WorkoutSession s = d.session;
    final Profile profile =
        ref.watch(trainProfileProvider).value ?? const Profile();
    final int sets = <SetEntry>[
      for (final SessionExercise e in s.exercises) ...e.sets,
    ].length;
    final muscles = routineMuscles(
      s.exercises.map((SessionExercise e) => e.exerciseId),
      d.exercises,
    );
    final double? kcal = s.caloriesKcal;
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.xl,
                Space.screen,
                Space.lg,
              ),
              children: <Widget>[
                Column(
                  children: <Widget>[
                    ExcludeSemantics(
                      child: Container(
                        width: TrainSpec.summaryBadge,
                        height: TrainSpec.summaryBadge,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: TrainSpec.summaryBadgeGlyph,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    Semantics(
                      header: true,
                      child: Text('Workout saved', style: tt.headlineSmall),
                    ),
                    Text(
                      '${s.name ?? 'Workout'} · ${formatDay(s.startedAt)}',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.xl),
                SinewStatGrid(
                  children: <Widget>[
                    SinewStatTile(
                      label: 'Duration',
                      value: formatMinutes(s.durationSec ?? 0),
                    ),
                    SinewStatTile(
                      label: 'Volume',
                      value: formatVolume(s.volumeKg ?? 0, profile.weightUnit),
                    ),
                    SinewStatTile(label: 'Sets', value: '$sets'),
                    SinewStatTile(
                      label: 'Exercises',
                      value: '${s.exercises.length}',
                    ),
                    SinewStatTile(
                      label: 'Records',
                      value: '${d.prs.length}',
                      emphasis: d.prs.isNotEmpty,
                    ),
                    SinewStatTile(
                      label: 'Calories',
                      value: kcal == null ? '-' : '${kcal.round()} kcal',
                      caption: kcal == null ? 'needs body weight' : 'estimate',
                    ),
                  ],
                ),
                for (final PrLine pr in d.prs) ...<Widget>[
                  const SizedBox(height: Space.md),
                  _PrCard(line: pr, weightUnit: profile.weightUnit),
                ],
                const SizedBox(height: Space.md),
                SinewCard(
                  child: Row(
                    children: <Widget>[
                      if (muscles.primary.isNotEmpty)
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
                      if (muscles.primary.isNotEmpty)
                        const SizedBox(width: Space.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              kcal == null
                                  ? 'Calories need a body weight'
                                  : 'Calories are an estimate',
                              style: tt.titleSmall,
                            ),
                            const SizedBox(height: Space.xxs),
                            Text(
                              kcal == null
                                  ? 'Log your weight in Body and the next '
                                        'workout shows an estimate.'
                                  : d.bodyWeightKg == null
                                  ? 'Based on your body weight and each '
                                        "exercise's MET value."
                                  : 'Based on '
                                        '${Units.formatWeight(d.bodyWeightKg!, profile.weightUnit)}'
                                        " body weight and each exercise's MET "
                                        'value.',
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
                const TrainSectionLabel('How hard was it?'),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: <Widget>[
                    for (int i = 1; i <= 10; i++)
                      SinewChip(
                        key: ValueKey<String>('effort-$i'),
                        label: '$i',
                        selected: _effort == i,
                        showCheck: false,
                        onTap: () {
                          setState(() {
                            _effort = _effort == i ? null : i;
                            _dirty = true;
                          });
                          unawaited(_persist());
                        },
                      ),
                  ],
                ),
                const SizedBox(height: Space.xs),
                Text(
                  '1 is very easy, 10 is all you had.',
                  style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: Space.lg),
                SinewTextField(
                  label: 'Note',
                  controller: _notes,
                  optional: true,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (String _) => _dirty = true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.sm,
              Space.screen,
              Space.lg,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    label: 'Save as routine',
                    type: AppButtonType.outline,
                    onPressed: () => _saveAsRoutine(d),
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: AppButton(
                    label: 'Done',
                    type: AppButtonType.primary,
                    onPressed: () async {
                      if (_dirty) await _persist();
                      _done();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrCard extends StatelessWidget {
  const _PrCard({required this.line, required this.weightUnit});

  final PrLine line;
  final WeightUnit weightUnit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final String extra = line.e1rmKg == null
        ? 'Best so far.'
        : 'Est. 1RM ${Units.formatWeight(line.e1rmKg!, weightUnit, maxDecimals: 0)}'
              '${line.e1rmDeltaKg == null ? '' : ' (+${Units.trim(Units.fromKg(line.e1rmDeltaKg!, weightUnit), maxDecimals: 1)})'}.';
    return SinewCard(
      child: Semantics(
        container: true,
        label: 'Personal record. ${line.exerciseName}, ${line.setText}. $extra',
        excludeSemantics: true,
        child: Row(
          children: <Widget>[
            const SinewPill(label: 'PR', tone: SinewTone.primary),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${line.exerciseName} · ${line.setText}',
                    style: tt.titleSmall,
                  ),
                  Text(
                    extra,
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
