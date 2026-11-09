import 'package:flutter/material.dart';

import '../../db/repositories/library_types.dart';
import '../../models/enums.dart';
import '../../theme/app_theme.dart';
import '../../../features/exercise_media/presentation/figure_thumbnail.dart';
import '../sinew_list.dart';
import '../sinew_states.dart';

/// "smithMachine" to "Smith machine", "hiit" to "HIIT".
String prettyVocab(String id) {
  if (id == 'hiit') return 'HIIT';
  final String spaced = id
      .replaceAllMapped(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), (Match _) => ' ')
      .replaceAll(RegExp(r'[-_]'), ' ')
      .toLowerCase();
  return spaced.isEmpty
      ? spaced
      : spaced[0].toUpperCase() + spaced.substring(1);
}

/// The glyph for how an exercise is logged.
IconData trackingTypeIcon(TrackingType t) => switch (t) {
  TrackingType.weightReps => Icons.fitness_center_rounded,
  TrackingType.reps || TrackingType.unknown => Icons.repeat_rounded,
  TrackingType.time => Icons.timer_outlined,
  TrackingType.distanceTime => Icons.directions_run_rounded,
  TrackingType.rounds => Icons.sports_mma_rounded,
  TrackingType.hold => Icons.pause_circle_outline_rounded,
  TrackingType.flow => Icons.self_improvement_rounded,
};

/// Plain words for TalkBack: "weight and reps".
String trackingTypeWords(TrackingType t) => switch (t) {
  TrackingType.weightReps => 'weight and reps',
  TrackingType.reps || TrackingType.unknown => 'reps',
  TrackingType.time => 'time',
  TrackingType.distanceTime => 'distance and time',
  TrackingType.rounds => 'rounds',
  TrackingType.hold => 'hold time',
  TrackingType.flow => 'flow',
};

/// A library or search list row for an [ExerciseSummary]: a cropped muscle
/// map thumbnail, the name, "Category, equipment, difficulty", the tracking
/// type glyph, a Custom badge for the user's own exercises, and an optional
/// trailing widget ([ExerciseAddButton], [ExerciseSelectMark] or your own).
///
/// The summary carries primary muscles only; pass [secondaryMuscles] from the
/// detail record when the caller has them.
class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    super.key,
    required this.exercise,
    this.secondaryMuscles = const <String>[],
    this.sex,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  final ExerciseSummary exercise;
  final List<String> secondaryMuscles;

  /// Base for the thumbnail; male when null.
  final Sex? sex;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Multi-select fill.
  final bool selected;

  /// "Strength, Barbell, Intermediate" with a dot between the parts.
  static String metaLine(ExerciseSummary e) => <String>[
    prettyVocab(e.category),
    if (e.equipment.isNotEmpty) prettyVocab(e.equipment.first),
    if (e.difficulty != null) prettyVocab(e.difficulty!.name),
  ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Color metaColor = selected
        ? cs.onSecondaryContainer
        : cs.onSurfaceVariant;
    return SinewListRow(
      minHeight: Space.listItem2,
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
      leading: FigureThumbnail(
        exerciseId: exercise.id,
        primaryMuscles: exercise.primaryMuscles,
        secondaryMuscles: secondaryMuscles,
        sex: sex,
        size: MapSpec.thumb,
      ),
      title: exercise.name,
      titleTrailing: exercise.isCustom
          ? const SinewPill(label: 'Custom', tone: SinewTone.primary)
          : null,
      below: Row(
        children: <Widget>[
          Icon(
            trackingTypeIcon(exercise.trackingType),
            size: ExerciseTileSpec.metaGlyph,
            color: metaColor,
            semanticLabel:
                'Tracked by ${trackingTypeWords(exercise.trackingType)}',
          ),
          const SizedBox(width: Space.xs + Space.xxs),
          Expanded(
            child: Text(
              metaLine(exercise),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyMedium!.copyWith(color: metaColor),
            ),
          ),
        ],
      ),
      trailing: trailing,
    );
  }
}

/// The 40dp tonal "+" at the end of a tile (48dp hit area).
class ExerciseAddButton extends StatelessWidget {
  const ExerciseAddButton({
    super.key,
    required this.onPressed,
    this.semanticLabel = 'Add exercise',
  });

  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onPressed,
      child: SizedBox(
        width: IconSpec.tapTarget,
        height: IconSpec.tapTarget,
        child: Center(
          child: Material(
            color: cs.secondaryContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                width: ExerciseTileSpec.actionSize,
                height: ExerciseTileSpec.actionSize,
                child: Icon(
                  Icons.add_rounded,
                  size: ExerciseTileSpec.actionGlyph,
                  color: cs.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The multi-select mark at the end of a tile: a filled check when
/// [selected], an empty ring otherwise. Decorative; the tile itself reports
/// the selected state to TalkBack.
class ExerciseSelectMark extends StatelessWidget {
  const ExerciseSelectMark({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return ExcludeSemantics(
      child: Container(
        width: IconSpec.size,
        height: IconSpec.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? cs.primary : Colors.transparent,
          border: selected
              ? null
              : Border.all(color: cs.outline, width: Strokes.focus),
        ),
        child: selected
            ? Icon(
                Icons.check_rounded,
                size: IconSpec.small,
                color: cs.onPrimary,
              )
            : null,
      ),
    );
  }
}

/// A loading placeholder shaped like an [ExerciseTile].
class ExerciseTileSkeleton extends StatelessWidget {
  const ExerciseTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading exercise',
      excludeSemantics: true,
      child: const SinewSkeletonRow(),
    );
  }
}
