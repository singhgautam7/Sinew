// Container view providing toggle between procedural Exercise Figure and Muscle Map.
//
// Follows Sinew design tokens:
// - Uses SinewSegmentedControl for Figure vs Muscle Map toggle
// - Preserves MuscleMap fallback for null/corrupt motions and mapOnly tier
// - Synchronizes active step frame with steps list below
// - Fully responsive per breakpoint

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/theme/app_theme.dart' hide Motion;
import 'package:sinew/core/widgets/domain/muscle_map.dart';
import 'package:sinew/core/widgets/sinew_list.dart';
import 'package:sinew/core/widgets/sinew_segmented_control.dart';
import 'package:sinew/features/library/library_labels.dart';

import '../data/motion_model.dart';
import 'frame_strip_view.dart';
import 'media_providers.dart';
import 'motion_player.dart';

enum ExerciseMediaTab { figure, muscleMap }

/// Displays exercise figure media or falls back to the canonical muscle map.
class ExerciseMediaView extends ConsumerStatefulWidget {
  const ExerciseMediaView({
    super.key,
    required this.exercise,
    this.sex,
    this.pose = false,
    this.activeStepIndex,
    this.onStepChanged,
    this.height = 260.0,
  });

  final Exercise exercise;
  final Sex? sex;
  final bool pose;
  final int? activeStepIndex;
  final ValueChanged<int>? onStepChanged;
  final double height;

  @override
  ConsumerState<ExerciseMediaView> createState() => _ExerciseMediaViewState();
}

class _ExerciseMediaViewState extends ConsumerState<ExerciseMediaView> {
  ExerciseMediaTab _selectedTab = ExerciseMediaTab.figure;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Motion?> motionAsync = ref.watch(
      motionProvider(widget.exercise.id),
    );

    return motionAsync.when(
      loading: () => _buildMuscleMapCard(context),
      error: (Object _, StackTrace? _) => _buildMuscleMapCard(context),
      data: (Motion? motion) {
        if (motion == null || motion.tier == MotionTier.mapOnly) {
          return _buildMuscleMapCard(context);
        }
        return _buildInteractiveCard(context, motion);
      },
    );
  }

  Widget _buildInteractiveCard(BuildContext context, Motion motion) {
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    return SinewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header Segmented Control
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SinewSegmentedControl<ExerciseMediaTab>(
                  compact: true,
                  values: const <ExerciseMediaTab>[
                    ExerciseMediaTab.figure,
                    ExerciseMediaTab.muscleMap,
                  ],
                  labels: const <String>['Figure', 'Muscles'],
                  selected: _selectedTab,
                  onSelected: (ExerciseMediaTab tab) {
                    setState(() => _selectedTab = tab);
                  },
                ),
              ],
            ),
          ),

          // Content
          if (_selectedTab == ExerciseMediaTab.figure) ...<Widget>[
            if (motion.tier == MotionTier.frames || disableAnimations)
              FrameStripView(
                motion: motion,
                activeStepIndex: widget.activeStepIndex ?? 0,
                onStepChanged: widget.onStepChanged,
                height: widget.height,
              )
            else
              MotionPlayer(
                motion: motion,
                activeStepIndex: widget.activeStepIndex,
                onStepChanged: widget.onStepChanged,
                height: widget.height,
              ),
            const SizedBox(height: Space.md),
            Align(alignment: Alignment.centerLeft, child: _buildLegend(context)),
          ] else ...<Widget>[
            _buildMuscleMapContent(context),
          ],
        ],
      ),
    );
  }

  Widget _buildMuscleMapCard(BuildContext context) {
    return SinewCard(
      child: _buildMuscleMapContent(context),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final Exercise e = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _Legend(
          title: 'Primary',
          muscles: e.primaryMuscles,
          color: context.accents.musclePrimary,
        ),
        if (e.secondaryMuscles.isNotEmpty) ...<Widget>[
          const SizedBox(height: Space.md),
          _Legend(
            title: 'Secondary',
            muscles: e.secondaryMuscles,
            color: context.accents.muscleSecondary,
          ),
        ],
      ],
    );
  }

  Widget _buildMuscleMapContent(BuildContext context) {
    final Exercise e = widget.exercise;
    final ColorScheme cs = context.cs;
    final String label =
        'Muscles. Primary: ${e.primaryMuscles.map(muscleLabel).join(', ')}. '
        'Secondary: ${e.secondaryMuscles.map(muscleLabel).join(', ')}.';

    final Widget legend = _buildLegend(context);

    if (widget.pose) {
      return Row(
        children: <Widget>[
          Container(
            width: LibrarySpec.poseMap,
            height: LibrarySpec.poseMap,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: Radii.thumbR,
            ),
            clipBehavior: Clip.antiAlias,
            child: MuscleMap(
              primary: e.primaryMuscles,
              secondary: e.secondaryMuscles,
              fit: MuscleMapFit.crop,
              sex: widget.sex,
              showLabels: false,
              semanticLabel: label,
            ),
          ),
          const SizedBox(width: Space.lg),
          Expanded(child: legend),
        ],
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: widget.height,
          child: MuscleMap(
            primary: e.primaryMuscles,
            secondary: e.secondaryMuscles,
            sex: widget.sex,
            semanticLabel: label,
          ),
        ),
        const SizedBox(height: Space.md),
        Align(alignment: Alignment.centerLeft, child: legend),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.title,
    required this.muscles,
    required this.color,
  });

  final String title;
  final List<String> muscles;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: Space.md,
              height: Space.md,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: Space.sm),
            Text(
              title,
              style: tt.labelLarge!.copyWith(color: context.cs.onSurface),
            ),
          ],
        ),
        Text(
          muscles.isEmpty ? 'None' : muscles.map(muscleLabel).join(', '),
          style: tt.bodyMedium!.copyWith(color: context.cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
