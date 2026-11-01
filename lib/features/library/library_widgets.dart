import 'package:flutter/material.dart';

import '../../core/models/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/domain/exercise_tile.dart';
import '../../core/db/repositories/library_types.dart';
import '../../core/widgets/sinew_chips.dart';
import 'library_labels.dart';

/// One result row on its own rounded card (the list is virtualised, so rows
/// cannot share a single `SinewGroup`).
class ExerciseRowCard extends StatelessWidget {
  const ExerciseRowCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Material(
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.cardR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// The filter button and the removable chips of every active filter, in one
/// horizontally scrolling row. [onOpenFilters] opens the filter sheet.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.onChanged,
    required this.onOpenFilters,
  });

  final LibraryFilters filters;
  final ValueChanged<LibraryFilters> onChanged;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final int active =
        filters.categories.length +
        filters.muscles.length +
        filters.equipment.length +
        filters.difficulties.length +
        filters.trackingTypes.length;
    final List<Widget> chips = <Widget>[
      SinewChip(
        shrink: true,
        label: 'Filters',
        icon: Icons.tune_rounded,
        badge: active == 0 ? null : '$active',
        showCheck: false,
        onTap: onOpenFilters,
      ),
      for (final String c in filters.categories)
        SinewChip(
          shrink: true,
          label: categoryLabel(c),
          selected: true,
          onDeleted: () => onChanged(
            filters.copyWith(
              categories: <String>{...filters.categories}..remove(c),
            ),
          ),
        ),
      for (final String m in filters.muscles)
        SinewChip(
          shrink: true,
          label: muscleLabel(m),
          selected: true,
          onDeleted: () => onChanged(
            filters.copyWith(muscles: <String>{...filters.muscles}..remove(m)),
          ),
        ),
      for (final String e in filters.equipment)
        SinewChip(
          shrink: true,
          label: equipmentLabel(e),
          selected: true,
          onDeleted: () => onChanged(
            filters.copyWith(
              equipment: <String>{...filters.equipment}..remove(e),
            ),
          ),
        ),
      for (final Difficulty d in filters.difficulties)
        SinewChip(
          shrink: true,
          label: difficultyLabel(d),
          selected: true,
          onDeleted: () => onChanged(
            filters.copyWith(
              difficulties: <Difficulty>{...filters.difficulties}..remove(d),
            ),
          ),
        ),
      for (final TrackingType t in filters.trackingTypes)
        SinewChip(
          shrink: true,
          label: trackingLabel(t),
          selected: true,
          onDeleted: () => onChanged(
            filters.copyWith(
              trackingTypes: <TrackingType>{...filters.trackingTypes}
                ..remove(t),
            ),
          ),
        ),
    ];
    return SizedBox(
      height: IconSpec.tapTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Space.screen),
        itemCount: chips.length,
        separatorBuilder: (BuildContext _, int _) =>
            const SizedBox(width: Space.sm),
        itemBuilder: (BuildContext _, int i) => Center(child: chips[i]),
      ),
    );
  }
}

/// A standard exercise tile for [summary], tapping calls [onTap].
ExerciseTile exerciseTileFor(
  ExerciseSummary summary,
  Sex? sex, {
  VoidCallback? onTap,
  Widget? trailing,
  bool selected = false,
}) => ExerciseTile(
  exercise: summary,
  sex: sex,
  onTap: onTap,
  trailing: trailing,
  selected: selected,
);
