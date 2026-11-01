import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/repositories/library_types.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/domain/exercise_tile.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_full_sheet.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_search_field.dart';
import 'custom_exercise_screen.dart';
import 'exercise_results_list.dart';
import 'library_filter_sheet.dart';
import 'library_providers.dart';
import 'library_widgets.dart';

/// Opens the exercise picker (library search, filters, custom exercises) and
/// returns the chosen exercise ids in the order picked, or null if cancelled.
///
/// CONTRACT used by Train (routine editor, add exercise, swap) and Today.
/// Owned and implemented by the Library feature; the signature is fixed.
/// - [multiple]: false returns at most one id (swap an exercise).
/// - [exclude]: ids already in the routine/session, shown as added.
/// - [title]: sheet title, e.g. "Add exercises", "Swap exercise".
Future<List<String>?> pickExercises(
  BuildContext context, {
  bool multiple = true,
  Set<String> exclude = const <String>{},
  String? title,
}) {
  return showSinewBottomSheet<List<String>>(
    context: context,
    builder: (BuildContext _) => ExercisePickerSheet(
      multiple: multiple,
      exclude: exclude,
      title: title ?? (multiple ? 'Add exercises' : 'Choose exercise'),
    ),
  );
}

/// The picker's content: search, filters, recent and custom sections, and the
/// paged library. Pops the sheet with the picked ids.
class ExercisePickerSheet extends ConsumerStatefulWidget {
  const ExercisePickerSheet({
    super.key,
    required this.multiple,
    required this.exclude,
    required this.title,
  });

  final bool multiple;
  final Set<String> exclude;
  final String title;

  @override
  ConsumerState<ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<ExercisePickerSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _picked = <String>[];
  Timer? _debounce;
  String _query = '';
  LibraryFilters _filters = const LibraryFilters();

  bool get _browsing => _query.isEmpty && _filters.isEmpty;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String text) {
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      setState(() => _query = '');
      return;
    }
    _debounce = Timer(LibrarySpec.searchDebounce, () {
      if (mounted) setState(() => _query = text.trim());
    });
  }

  Future<void> _openFilters() async {
    final LibraryFilters? next = await showLibraryFilterSheet(
      context,
      initial: _filters,
      query: _query,
    );
    if (next != null && mounted) setState(() => _filters = next);
  }

  void _tap(String id) {
    if (widget.exclude.contains(id)) return;
    if (!widget.multiple) {
      Navigator.of(context).pop(<String>[id]);
      return;
    }
    setState(() {
      if (!_picked.remove(id)) _picked.add(id);
    });
  }

  Future<void> _create() async {
    final String? id = GoRouter.maybeOf(context) != null
        ? await context.push<String>(Routes.newCustomExercise)
        : await Navigator.of(context, rootNavigator: true).push<String>(
            MaterialPageRoute<String>(
              builder: (BuildContext _) => const CustomExerciseScreen(),
            ),
          );
    if (id == null || !mounted) return;
    if (!widget.multiple) {
      Navigator.of(context).pop(<String>[id]);
      return;
    }
    setState(() {
      if (!_picked.contains(id)) _picked.add(id);
    });
  }

  Widget _tile(ExerciseSummary e, Sex? sex) {
    final bool added = widget.exclude.contains(e.id);
    final bool selected = _picked.contains(e.id);
    final Widget? trailing = added
        ? Semantics(
            label: 'Already added',
            child: Icon(
              Icons.check_circle_rounded,
              size: IconSpec.size,
              color: context.cs.onSurfaceVariant,
            ),
          )
        : (widget.multiple ? ExerciseSelectMark(selected: selected) : null);
    return Opacity(
      opacity: added ? Opacities.muted : 1,
      child: exerciseTileFor(
        e,
        sex,
        selected: selected,
        trailing: trailing,
        onTap: added ? null : () => _tap(e.id),
      ),
    );
  }

  List<Widget> _headerSlivers(Sex? sex) {
    final List<ExerciseSummary> recent =
        ref.watch(recentSummariesProvider).value ?? const <ExerciseSummary>[];
    final List<Exercise> mine =
        ref.watch(customExercisesProvider).value ?? const <Exercise>[];
    Widget section(String title, List<ExerciseSummary> items) => Padding(
      padding: const EdgeInsets.only(bottom: Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SinewSectionHeader(title: title),
          for (final ExerciseSummary e in items)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: ExerciseRowCard(child: _tile(e, sex)),
            ),
        ],
      ),
    );
    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.sm,
          Space.screen,
          0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: Space.lg),
              child: SinewCard(
                onTap: _create,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: context.cs.primary,
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Text(
                        'Create custom exercise',
                        style: context.text.titleMedium!.copyWith(
                          color: context.cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (recent.isNotEmpty)
              section(
                'Recent',
                recent.take(LibrarySpec.collapsedRows).toList(),
              ),
            if (mine.isNotEmpty)
              section('Your exercises', <ExerciseSummary>[
                for (final Exercise e in mine) summaryOf(e),
              ]),
            const SinewSectionHeader(title: 'All exercises'),
          ]),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Sex? sex = ref.watch(librarySexProvider).value;
    final int n = _picked.length;
    return SinewFullSheet(
      title: widget.title,
      subtitle: widget.multiple && n > 0 ? '$n selected' : null,
      bottom: widget.multiple
          ? AppButton(
              label: n == 0 ? 'Add exercises' : 'Add $n',
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: n == 0
                  ? null
                  : () => Navigator.of(context).pop(List<String>.of(_picked)),
            )
          : null,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.screen),
            child: SinewSearchField(
              controller: _controller,
              onChanged: _onQuery,
              hint: 'Search exercises and poses',
            ),
          ),
          const SizedBox(height: Space.xs),
          FilterChipsRow(
            filters: _filters,
            onChanged: (LibraryFilters f) => setState(() => _filters = f),
            onOpenFilters: _openFilters,
          ),
          Expanded(
            child: ExerciseResultsList(
              query: _query,
              filters: _filters,
              includeCustom: !_browsing,
              headerSlivers: _browsing ? _headerSlivers(sex) : const <Widget>[],
              countLabelBuilder: _browsing
                  ? null
                  : (int total) => total == 1 ? '1 result' : '$total results',
              tileBuilder: (BuildContext c, ExerciseSummary e, Sex? s) =>
                  _tile(e, s),
            ),
          ),
        ],
      ),
    );
  }
}
