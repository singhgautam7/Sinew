import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/configs.dart';
import '../../core/widgets/domain/exercise_tile.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_snackbar.dart';
import '../../core/widgets/sinew_states.dart';
import '../exercise_media/presentation/exercise_media_view.dart';
import 'add_to_routine.dart';
import 'library_labels.dart';
import 'library_providers.dart';

/// An exercise or a pose: names, facts, muscle map, steps and notes.
/// Resolves custom, library and removed (tombstoned) ids.
class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<Exercise?>>(
      libraryExerciseProvider(widget.exerciseId),
      (AsyncValue<Exercise?>? _, AsyncValue<Exercise?> next) {
        final Exercise? e = next.value;
        if (e != null && e.category != 'removed') {
          Future<void>.microtask(
            () => ref
                .read(recentExercisesProvider.notifier)
                .add(widget.exerciseId),
          );
        }
      },
      fireImmediately: true,
    );
  }

  Future<void> _archive(Exercise e) async {
    final bool ok = await showSinewConfirmDialog(
      context: context,
      title: 'Archive ${e.name}?',
      message: 'It is hidden from the picker and search. Your history keeps it and you can restore it later.',
      confirmLabel: 'Archive',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref
        .read(customExerciseRepositoryProvider)
        .setArchived(e.id, archived: true);
    if (!mounted) return;
    ref.invalidate(libraryExerciseProvider(e.id));
    showSinewUndoSnackBar(
      context,
      'Archived ${e.name}',
      onUndo: () => _restore(e),
    );
  }

  Future<void> _restore(Exercise e) async {
    await ref
        .read(customExerciseRepositoryProvider)
        .setArchived(e.id, archived: false);
    if (!mounted) return;
    ref.invalidate(libraryExerciseProvider(e.id));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Exercise?> async = ref.watch(
      libraryExerciseProvider(widget.exerciseId),
    );
    return async.when(
      loading: () => const Scaffold(
        appBar: SinewAppBar(showBack: true, showBrand: false),
        body: Delayed(child: SinewLoader()),
      ),
      error: (Object e, StackTrace _) => Scaffold(
        appBar: const SinewAppBar(showBack: true, showBrand: false),
        body: SinewEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not open this exercise',
          description: 'Something went wrong reading it.',
          actionLabel: 'Try again',
          actionIcon: Icons.refresh_rounded,
          onAction: () =>
              ref.invalidate(libraryExerciseProvider(widget.exerciseId)),
        ),
      ),
      data: (Exercise? e) {
        if (e == null) {
          return const Scaffold(
            appBar: SinewAppBar(showBack: true, showBrand: false),
            body: SinewEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Exercise not found',
              description: 'It may have been removed from the library.',
            ),
          );
        }
        return _Detail(
          exercise: e,
          onArchive: () => _archive(e),
          onRestore: () => _restore(e),
        );
      },
    );
  }
}

bool _isPose(Exercise e) => e.category == 'yoga' || e.category == 'mobility';

class _Detail extends ConsumerStatefulWidget {
  const _Detail({
    required this.exercise,
    required this.onArchive,
    required this.onRestore,
  });

  final Exercise exercise;
  final VoidCallback onArchive;
  final VoidCallback onRestore;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  int? _activeStepIndex;

  @override
  Widget build(BuildContext context) {
    final Exercise e = widget.exercise;
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    final Sex? sex = ref.watch(librarySexProvider).value;
    final bool removed = e.category == 'removed';
    final bool pose = _isPose(e);
    final List<SinewOverflowItem> menu = <SinewOverflowItem>[
      if (e.isCustom) ...<SinewOverflowItem>[
        SinewOverflowItem(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: () => context.push(Routes.editCustomExercise(e.id)),
        ),
        if (e.archived)
          SinewOverflowItem(
            icon: Icons.unarchive_outlined,
            label: 'Restore',
            onTap: widget.onRestore,
          )
        else
          SinewOverflowItem(
            icon: Icons.archive_outlined,
            label: 'Archive',
            onTap: widget.onArchive,
            isDestructive: true,
          ),
      ],
    ];
    final String? subtitle = pose
        ? <String>[
            if (e.sanskritName != null) e.sanskritName!,
            categoryLabel(e.category),
          ].join(' · ')
        : null;

    return Scaffold(
      appBar: SinewAppBar(
        showBack: true,
        showBrand: false,
        overflowConfig: menu.isEmpty ? null : SinewOverflowConfig(items: menu),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.xs,
          Space.screen,
          Space.xl,
        ),
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              e.name,
              style: tt.headlineMedium!.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
            ),
          if (e.aliases.isNotEmpty)
            Text(
              'Also: ${e.aliases.join(', ')}',
              style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            ),
          if (e.archived) ...<Widget>[
            const SizedBox(height: Space.md),
            const SinewCallout(
              tone: SinewCalloutTone.info,
              icon: Icons.archive_outlined,
              child: Text(
                'Archived. Hidden from search and the picker; your history keeps it.',
              ),
            ),
          ],
          if (removed) ...<Widget>[
            const SizedBox(height: Space.md),
            const SinewCallout(
              tone: SinewCalloutTone.info,
              icon: Icons.info_outline_rounded,
              child: Text(
                'This exercise was removed from the library. Your history keeps it.',
              ),
            ),
          ],
          const SizedBox(height: Space.md),
          if (pose && !removed)
            _PoseFacts(exercise: e)
          else if (!removed)
            _MetaChips(exercise: e),
          if (!removed) ...<Widget>[
            const SizedBox(height: Space.lg),
            ExerciseMediaView(
              exercise: e,
              sex: sex,
              pose: pose,
              activeStepIndex: _activeStepIndex,
              onStepChanged: (int idx) => setState(() => _activeStepIndex = idx),
            ),
            if (pose) ...<Widget>[
              const SizedBox(height: Space.lg),
              _MetaChips(exercise: e),
            ],
            if (e.steps.isNotEmpty) ...<Widget>[
              const SizedBox(height: Space.xl),
              const SinewSectionHeader(title: 'Steps'),
              _Steps(
                steps: e.steps,
                activeStepIndex: _activeStepIndex,
                onStepTapped: (int idx) => setState(() => _activeStepIndex = idx),
              ),
            ],
            _Notes(
              title: 'Tips',
              icon: Icons.lightbulb_outline_rounded,
              items: e.tips,
            ),
            _Notes(
              title: 'Common mistakes',
              icon: Icons.error_outline_rounded,
              items: e.commonMistakes,
            ),
            _Notes(
              title: 'Safety',
              icon: Icons.health_and_safety_outlined,
              items: e.safetyNotes,
            ),
            _Notes(
              title: 'Not advised with',
              icon: Icons.block_rounded,
              items: e.contraindications,
            ),
            const SizedBox(height: Space.xl),
            _Facts(exercise: e),
          ],
        ],
      ),
      bottomNavigationBar: _ActionBar(exercise: e),
    );
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = context.cs;
    final bool removed = exercise.category == 'removed';
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: Strokes.hairline),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        Space.screen,
        Space.md,
        Space.screen,
        Space.lg + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!removed) ...<Widget>[
            AppButton(
              label: _isPose(exercise)
                  ? 'Add to flow or routine'
                  : 'Add to routine',
              type: AppButtonType.primary,
              icon: Icons.playlist_add_rounded,
              fullWidth: true,
              onPressed: () => addExerciseToRoutineFlow(context, ref, exercise),
            ),
            const SizedBox(height: Space.sm),
          ],
          Row(
            children: <Widget>[
              if (exercise.isCustom) ...<Widget>[
                Expanded(
                  child: AppButton(
                    label: 'Edit',
                    type: AppButtonType.outline,
                    icon: Icons.edit_outlined,
                    fullWidth: true,
                    onPressed: () =>
                        context.push(Routes.editCustomExercise(exercise.id)),
                  ),
                ),
                const SizedBox(width: Space.md),
              ],
              Expanded(
                child: AppButton(
                  label: 'History',
                  type: AppButtonType.outline,
                  icon: Icons.history_rounded,
                  fullWidth: true,
                  onPressed: () =>
                      context.push(Routes.exerciseHistory(exercise.id)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact {
  const _Fact(this.icon, this.text);
  final IconData icon;
  final String text;
}

class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final Exercise e = exercise;
    final List<_Fact> facts = <_Fact>[
      _Fact(categoryIcon(e.category), categoryLabel(e.category)),
      if (e.equipment.isNotEmpty)
        _Fact(
          Icons.fitness_center_rounded,
          e.equipment.map(equipmentLabel).join(', '),
        ),
      if (e.difficulty != null)
        _Fact(Icons.stacked_bar_chart_rounded, difficultyLabel(e.difficulty!)),
      _Fact(trackingTypeIcon(e.trackingType), trackingLabel(e.trackingType)),
      if (e.unilateral)
        const _Fact(Icons.swap_horiz_rounded, 'One side at a time'),
    ];
    return Wrap(
      spacing: Space.sm - Space.xxs,
      runSpacing: Space.sm - Space.xxs,
      children: <Widget>[
        for (final _Fact f in facts)
          Container(
            constraints: const BoxConstraints(minHeight: Sizes.chip - Space.xs),
            padding: const EdgeInsets.symmetric(
              horizontal: Space.md - Space.xxs,
              vertical: Space.xs,
            ),
            decoration: BoxDecoration(
              color: context.cs.secondaryContainer,
              borderRadius: Radii.chipR,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(f.icon, size: IconSpec.tiny, color: context.cs.primary),
                const SizedBox(width: Space.xs),
                Flexible(
                  child: Text(
                    f.text,
                    style: context.text.labelLarge!.copyWith(
                      color: context.cs.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Hold, level and sides at a glance (pose detail).
class _PoseFacts extends StatelessWidget {
  const _PoseFacts({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final Exercise e = exercise;
    final int? hold = e.defaultHoldSec;
    final List<(String, String)> cells = <(String, String)>[
      ('Hold', hold == null ? 'Your pace' : durationLabel(hold)),
      ('Level', e.difficulty == null ? 'Any' : difficultyLabel(e.difficulty!)),
      ('Sides', e.unilateral ? 'Each side' : 'Both'),
    ];
    return Row(
      children: <Widget>[
        for (int i = 0; i < cells.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: Space.sm),
          Expanded(
            child: SinewCard(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md,
                vertical: Space.md,
              ),
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      cells[i].$1,
                      style: context.text.bodySmall!.copyWith(
                        color: context.cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      cells[i].$2,
                      style: context.text.titleMedium!.copyWith(
                        color: context.cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({
    required this.steps,
    this.activeStepIndex,
    this.onStepTapped,
  });

  final List<String> steps;
  final int? activeStepIndex;
  final ValueChanged<int>? onStepTapped;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Column(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: InkWell(
              borderRadius: Radii.mediumR,
              onTap: () => onStepTapped?.call(i),
              child: AnimatedContainer(
                duration: Motion.of(context, Motion.fast),
                curve: Motion.curveOf(context, Motion.standard),
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.sm,
                  vertical: Space.xs,
                ),
                decoration: BoxDecoration(
                  color: i == activeStepIndex
                      ? cs.primaryContainer.withValues(alpha: 0.35)
                      : Colors.transparent,
                  borderRadius: Radii.mediumR,
                  border: Border.all(
                    color: i == activeStepIndex
                        ? cs.primary.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedContainer(
                      duration: Motion.of(context, Motion.fast),
                      width: LibrarySpec.stepBadge,
                      height: LibrarySpec.stepBadge,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == activeStepIndex
                            ? cs.primary
                            : cs.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: tt.labelLarge!.copyWith(
                          color: i == activeStepIndex
                              ? cs.onPrimary
                              : cs.onSecondaryContainer,
                          fontWeight: i == activeStepIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: Space.xs),
                        child: Text(
                          steps[i],
                          style: tt.bodyLarge!.copyWith(
                            color: cs.onSurface,
                            fontWeight: i == activeStepIndex
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes({required this.title, required this.icon, required this.items});

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final ColorScheme cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(top: Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SinewSectionHeader(title: title),
          SinewGroup(
            children: <Widget>[
              for (final String t in items)
                Padding(
                  padding: const EdgeInsets.all(Space.cardPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(icon, size: IconSpec.glyph, color: cs.primary),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Text(
                          t,
                          style: context.text.bodyMedium!.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// MET, default rest and hold, and where the entry comes from.
class _Facts extends StatelessWidget {
  const _Facts({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final Exercise e = exercise;
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final List<(String, String)> rows = <(String, String)>[
      if (e.metValue != null)
        ('MET (energy estimate)', e.metValue!.toStringAsFixed(1)),
      if (e.defaultRestSec != null)
        ('Default rest', durationLabel(e.defaultRestSec!)),
      if (e.defaultHoldSec != null)
        ('Default hold', durationLabel(e.defaultHoldSec!)),
    ];
    final String? source = e.isCustom
        ? 'Your own exercise'
        : (e.source == null
              ? null
              : 'Source: ${e.source}${e.license == null ? '' : ', licence: ${e.license}'}');
    if (rows.isEmpty && source == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (rows.isNotEmpty) ...<Widget>[
          const SinewSectionHeader(title: 'Details'),
          SinewGroup(
            children: <Widget>[
              for (final (String, String) r in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.cardPadding,
                    vertical: Space.md,
                  ),
                  child: MergeSemantics(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            r.$1,
                            style: tt.bodyMedium!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          r.$2,
                          style: tt.titleSmall!.copyWith(color: cs.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (source != null) ...<Widget>[
          const SizedBox(height: Space.md),
          Text(
            source,
            style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
