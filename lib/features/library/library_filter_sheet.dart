import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/library_types.dart';
import '../../core/models/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/domain/exercise_tile.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_full_sheet.dart';
import '../../core/widgets/sinew_settings.dart';
import 'library_labels.dart';
import 'library_providers.dart';

/// Opens the filter sheet with [initial] applied. Returns the chosen filters
/// when the person taps "Show N exercises", null when dismissed.
///
/// [query] only feeds the live result count on the button.
Future<LibraryFilters?> showLibraryFilterSheet(
  BuildContext context, {
  required LibraryFilters initial,
  String query = '',
}) {
  return showSinewBottomSheet<LibraryFilters>(
    context: context,
    builder: (BuildContext _) =>
        LibraryFilterSheet(initial: initial, query: query),
  );
}

class LibraryFilterSheet extends ConsumerStatefulWidget {
  const LibraryFilterSheet({super.key, required this.initial, this.query = ''});

  final LibraryFilters initial;
  final String query;

  @override
  ConsumerState<LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends ConsumerState<LibraryFilterSheet> {
  late LibraryFilters _f = widget.initial;
  bool _allEquipment = false;

  Set<T> _toggle<T>(Set<T> set, T v) =>
      set.contains(v) ? (<T>{...set}..remove(v)) : (<T>{...set, v});

  @override
  Widget build(BuildContext context) {
    final int? count = ref
        .watch(matchCountProvider((query: widget.query, filters: _f)))
        .value;
    final List<String> equipment = _allEquipment
        ? kEquipment
        : <String>[
            ...kEquipment.take(LibrarySpec.equipmentCollapsed),
            for (final String e in _f.equipment)
              if (kEquipment.indexOf(e) >= LibrarySpec.equipmentCollapsed) e,
          ];
    return SinewFullSheet(
      title: 'Filters',
      headerAction: TextButton(
        onPressed: _f.isEmpty
            ? null
            : () => setState(
                () => _f = LibraryFilters(
                  includeSecondaryMuscles: _f.includeSecondaryMuscles,
                ),
              ),
        child: const Text('Reset'),
      ),
      bottom: AppButton(
        label: count == null ? 'Show results' : 'Show ${_exercises(count)}',
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () => Navigator.of(context).pop(_f),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.sm,
          Space.screen,
          Space.xl,
        ),
        children: <Widget>[
          _Group(
            title: 'Category',
            children: <Widget>[
              for (final String c in kCategories)
                SinewChip(
                  shrink: true,
                  label: categoryLabel(c),
                  selected: _f.categories.contains(c),
                  onTap: () => setState(
                    () =>
                        _f = _f.copyWith(categories: _toggle(_f.categories, c)),
                  ),
                ),
            ],
          ),
          _Group(
            title: 'Muscle',
            children: <Widget>[
              for (final String m in kMuscles)
                SinewChip(
                  shrink: true,
                  label: muscleLabel(m),
                  selected: _f.muscles.contains(m),
                  onTap: () => setState(
                    () => _f = _f.copyWith(muscles: _toggle(_f.muscles, m)),
                  ),
                ),
            ],
          ),
          SinewSwitchRow(
            icon: Icons.add_circle_outline_rounded,
            label: 'Include secondary muscles',
            subtitle: 'Also match exercises that only assist',
            value: _f.includeSecondaryMuscles,
            onChanged: (bool v) =>
                setState(() => _f = _f.copyWith(includeSecondaryMuscles: v)),
          ),
          const SizedBox(height: Space.lg),
          _Group(
            title: 'Equipment',
            children: <Widget>[
              for (final String e in equipment)
                SinewChip(
                  shrink: true,
                  label: equipmentLabel(e),
                  selected: _f.equipment.contains(e),
                  onTap: () => setState(
                    () => _f = _f.copyWith(equipment: _toggle(_f.equipment, e)),
                  ),
                ),
              SinewChip(
                shrink: true,
                label: _allEquipment ? 'Fewer' : 'More',
                icon: _allEquipment
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                showCheck: false,
                onTap: () => setState(() => _allEquipment = !_allEquipment),
              ),
            ],
          ),
          _Group(
            title: 'Difficulty',
            children: <Widget>[
              for (final Difficulty d in Difficulty.values)
                SinewChip(
                  shrink: true,
                  label: difficultyLabel(d),
                  selected: _f.difficulties.contains(d),
                  onTap: () => setState(
                    () => _f = _f.copyWith(
                      difficulties: _toggle(_f.difficulties, d),
                    ),
                  ),
                ),
            ],
          ),
          _Group(
            title: 'Tracking type',
            children: <Widget>[
              for (final TrackingType t in kTrackingTypes)
                SinewChip(
                  shrink: true,
                  label: trackingLabel(t),
                  icon: trackingTypeIcon(t),
                  selected: _f.trackingTypes.contains(t),
                  onTap: () => setState(
                    () => _f = _f.copyWith(
                      trackingTypes: _toggle(_f.trackingTypes, t),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _exercises(int n) => n == 1 ? '1 exercise' : '$n exercises';
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title.toUpperCase(), style: context.sectionHeader),
          const SizedBox(height: Space.sm),
          Wrap(spacing: Space.sm, children: children),
        ],
      ),
    );
  }
}
