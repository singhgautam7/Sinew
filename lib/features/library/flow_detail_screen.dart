import 'package:flutter/material.dart' hide Flow;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/repositories/library_types.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_states.dart';
import '../../core/widgets/domain/exercise_tile.dart';
import 'library_labels.dart';
import 'library_providers.dart';

/// A yoga or mobility flow: its poses in order, the total time, and a button
/// that opens the timer's flow setup with this flow selected.
class FlowDetailScreen extends ConsumerWidget {
  const FlowDetailScreen({super.key, required this.flowId});

  final String flowId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Flow?> async = ref.watch(flowProvider(flowId));
    return async.when(
      loading: () => const Scaffold(
        appBar: SinewAppBar(showBack: true, showBrand: false),
        body: Delayed(child: SinewLoader()),
      ),
      error: (Object e, StackTrace _) => Scaffold(
        appBar: const SinewAppBar(showBack: true, showBrand: false),
        body: SinewEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not open this flow',
          description: 'Something went wrong reading it.',
          actionLabel: 'Try again',
          actionIcon: Icons.refresh_rounded,
          onAction: () => ref.invalidate(flowProvider(flowId)),
        ),
      ),
      data: (Flow? flow) {
        if (flow == null) {
          return const Scaffold(
            appBar: SinewAppBar(showBack: true, showBrand: false),
            body: SinewEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Flow not found',
              description: 'It may have been removed from the library.',
            ),
          );
        }
        return _FlowBody(flow: flow);
      },
    );
  }
}

class _FlowBody extends ConsumerWidget {
  const _FlowBody({required this.flow});

  final Flow flow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final List<String> ids = <String>{
      for (final FlowStep s in flow.steps) s.exerciseId,
    }.toList()..sort();
    final Map<String, Exercise> poses =
        ref.watch(flowPosesProvider(ids.join(','))).value ??
        const <String, Exercise>{};
    final List<String> facts = <String>[
      durationLabel(flow.totalDurationSec),
      if (flow.rounds > 1) '${flow.rounds} rounds',
      '${flow.steps.length} poses',
      if (flow.difficulty != null) difficultyLabel(flow.difficulty!),
    ];
    return Scaffold(
      appBar: const SinewAppBar(showBack: true, showBrand: false),
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
              flow.name,
              style: tt.headlineMedium!.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${categoryLabel(flow.category)} flow',
            style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: <Widget>[
              for (final String f in facts)
                SinewPill(label: f, tone: SinewTone.secondary),
            ],
          ),
          if (flow.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: Space.lg),
            Text(
              flow.description,
              style: tt.bodyLarge!.copyWith(color: cs.onSurface),
            ),
          ],
          const SizedBox(height: Space.xl),
          const SinewSectionHeader(title: 'Poses'),
          SinewGroup(
            children: <Widget>[
              for (final FlowStep s in flow.steps)
                SinewListRow(
                  leading: Container(
                    width: LibrarySpec.stepBadge,
                    height: LibrarySpec.stepBadge,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${s.position + 1}',
                      style: tt.labelLarge!.copyWith(
                        color: cs.onSecondaryContainer,
                      ),
                    ),
                  ),
                  title: poses[s.exerciseId]?.name ?? s.label ?? s.exerciseId,
                  subtitle: <String>[
                    'Hold ${durationLabel(s.holdSec)}',
                    if (s.transitionSec > 0)
                      'then ${durationLabel(s.transitionSec)} to move',
                    if (s.cue != null && s.cue!.isNotEmpty) s.cue!,
                  ].join(' · '),
                  subtitleLines: 2,
                  trailing: const SinewChevron(),
                  onTap: () => context.push(Routes.exercise(s.exerciseId)),
                ),
            ],
          ),
          if (flow.tags.isNotEmpty) ...<Widget>[
            const SizedBox(height: Space.lg),
            Text(
              flow.tags.map(prettyVocab).join(' · '),
              style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
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
        child: AppButton(
          label: 'Start flow',
          type: AppButtonType.primary,
          icon: Icons.play_arrow_rounded,
          fullWidth: true,
          onPressed: () => context.push(
            Routes.timerSetup(TimerMode.yogaFlow.name, flowId: flow.id),
          ),
        ),
      ),
    );
  }
}
