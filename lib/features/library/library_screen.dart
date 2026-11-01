import 'dart:async';

import 'package:flutter/material.dart' hide Flow;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/repositories/library_types.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_search_field.dart';
import '../../core/widgets/sinew_states.dart';
import 'exercise_results_list.dart';
import 'library_filter_sheet.dart';
import 'library_labels.dart';
import 'library_providers.dart';
import 'library_widgets.dart';

/// Browse and search the library. Pushed above the shell.
///
/// With no query and no filter it shows the browse sections (categories,
/// your exercises, recently viewed, flows); as soon as there is either it
/// shows a paged result list.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  LibraryFilters _filters = const LibraryFilters();

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

  void _clearAll() {
    _controller.clear();
    setState(() {
      _query = '';
      _filters = const LibraryFilters();
    });
  }

  bool get _browsing => _query.isEmpty && _filters.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SinewAppBar(title: 'Library', showBack: true),
      body: Column(
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
            child: _browsing
                ? _Browse(
                    onCategory: (String c) => setState(
                      () =>
                          _filters = _filters.copyWith(categories: <String>{c}),
                    ),
                  )
                : ExerciseResultsList(
                    query: _query,
                    filters: _filters,
                    countLabelBuilder: (int n) =>
                        n == 1 ? '1 result' : '$n results',
                    tileBuilder:
                        (BuildContext c, ExerciseSummary e, Sex? sex) =>
                            exerciseTileFor(
                              e,
                              sex,
                              onTap: () => context.push(Routes.exercise(e.id)),
                            ),
                    noResults: _NoResults(
                      query: _query,
                      hasFilters: !_filters.isEmpty,
                      onClear: _clearAll,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({
    required this.query,
    required this.hasFilters,
    required this.onClear,
  });

  final String query;
  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final String what = query.isEmpty ? 'those filters' : '"$query"';
    return SinewEmptyState(
      icon: Icons.search_off_rounded,
      title: 'No matches for $what',
      description: hasFilters
          ? 'Try a shorter word, or remove a filter. You can also add it yourself.'
          : 'Try a shorter word. You can also add it yourself.',
      actionLabel: 'Create exercise',
      onAction: () => context.push(Routes.newCustomExercise),
    );
  }
}

class _Browse extends ConsumerStatefulWidget {
  const _Browse({required this.onCategory});

  final ValueChanged<String> onCategory;

  @override
  ConsumerState<_Browse> createState() => _BrowseState();
}

class _BrowseState extends ConsumerState<_Browse> {
  bool _allMine = false;
  bool _allFlows = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map<String, int>> counts = ref.watch(
      categoryCountsProvider,
    );
    final List<Exercise> mine =
        ref.watch(customExercisesProvider).value ?? const <Exercise>[];
    final List<ExerciseSummary> recent =
        ref.watch(recentSummariesProvider).value ?? const <ExerciseSummary>[];
    final AsyncValue<List<Flow>> flows = ref.watch(flowsProvider);
    final Sex? sex = ref.watch(librarySexProvider).value;

    if (counts.hasError) {
      return SinewEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Library unavailable',
        description: 'The exercise library could not be opened.',
        actionLabel: 'Try again',
        actionIcon: Icons.refresh_rounded,
        onAction: () {
          ref.invalidate(categoryCountsProvider);
          ref.invalidate(flowsProvider);
        },
      );
    }
    if (!counts.hasValue) {
      return const Delayed(
        child: Padding(
          padding: EdgeInsets.all(Space.screen),
          child: Column(
            children: <Widget>[
              SinewSkeletonCard(),
              SizedBox(height: Space.cardGap),
              SinewSkeletonCard(),
            ],
          ),
        ),
      );
    }

    final Map<String, int> byCategory = counts.requireValue;
    final List<String> categories = <String>[
      for (final String c in kCategories)
        if (byCategory.containsKey(c)) c,
    ];
    final int mineShown = _allMine
        ? mine.length
        : mine.length.clamp(0, LibrarySpec.collapsedRows);
    final List<Flow> flowList = flows.value ?? const <Flow>[];
    final int flowsShown = _allFlows
        ? flowList.length
        : flowList.length.clamp(0, LibrarySpec.collapsedRows);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.md,
        Space.screen,
        Space.xxxl,
      ),
      children: <Widget>[
        const SinewSectionHeader(title: 'Categories'),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final double w = (c.maxWidth - Space.cardGap) / 2;
            return Wrap(
              spacing: Space.cardGap,
              runSpacing: Space.cardGap,
              children: <Widget>[
                for (final String cat in categories)
                  SizedBox(
                    width: w,
                    child: _CategoryCard(
                      category: cat,
                      count: byCategory[cat] ?? 0,
                      onTap: () => widget.onCategory(cat),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: Space.section),
        SinewSectionHeader(
          title: 'Your exercises',
          trailing: SinewSectionAction(
            label: 'New',
            onTap: () => context.push(Routes.newCustomExercise),
          ),
        ),
        if (mine.isEmpty)
          SinewCard(
            onTap: () => context.push(Routes.newCustomExercise),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: context.cs.primary,
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Text(
                    'Create your own exercise',
                    style: context.text.titleMedium!.copyWith(
                      color: context.cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...<Widget>[
          SinewGroup(
            children: <Widget>[
              for (final Exercise e in mine.take(mineShown))
                exerciseTileFor(
                  summaryOf(e),
                  sex,
                  onTap: () => context.push(Routes.exercise(e.id)),
                ),
            ],
          ),
          if (mine.length > LibrarySpec.collapsedRows)
            _ShowMore(
              expanded: _allMine,
              total: mine.length,
              onTap: () => setState(() => _allMine = !_allMine),
            ),
        ],
        if (recent.isNotEmpty) ...<Widget>[
          const SizedBox(height: Space.section),
          SinewSectionHeader(
            title: 'Recently viewed',
            trailing: SinewSectionAction(
              label: 'Clear',
              onTap: () => ref.read(recentExercisesProvider.notifier).clear(),
            ),
          ),
          SinewGroup(
            children: <Widget>[
              for (final ExerciseSummary e in recent.take(
                LibrarySpec.collapsedRows,
              ))
                exerciseTileFor(
                  e,
                  sex,
                  onTap: () => context.push(Routes.exercise(e.id)),
                ),
            ],
          ),
        ],
        if (flowList.isNotEmpty) ...<Widget>[
          const SizedBox(height: Space.section),
          const SinewSectionHeader(title: 'Flows'),
          SinewGroup(
            children: <Widget>[
              for (final Flow f in flowList.take(flowsShown))
                SinewListRow(
                  leading: SinewIconTile(
                    icon: categoryIcon(f.category),
                    tone: SinewTone.secondary,
                  ),
                  title: f.name,
                  subtitle: <String>[
                    durationLabel(f.totalDurationSec),
                    if (f.difficulty != null) difficultyLabel(f.difficulty!),
                  ].join(' · '),
                  trailing: const SinewChevron(),
                  onTap: () => context.push(Routes.flow(f.id)),
                ),
            ],
          ),
          if (flowList.length > LibrarySpec.collapsedRows)
            _ShowMore(
              expanded: _allFlows,
              total: flowList.length,
              onTap: () => setState(() => _allFlows = !_allFlows),
            ),
        ],
      ],
    );
  }
}

class _ShowMore extends StatelessWidget {
  const _ShowMore({
    required this.expanded,
    required this.total,
    required this.onTap,
  });

  final bool expanded;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        child: Text(expanded ? 'Show fewer' : 'Show all $total'),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.onTap,
  });

  final String category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Semantics(
      button: true,
      label: '${categoryLabel(category)}, $count exercises',
      excludeSemantics: true,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: LibrarySpec.categoryCardMinHeight,
        ),
        child: SinewCard(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                categoryIcon(category),
                size: LibrarySpec.categoryGlyph,
                color: cs.primary,
              ),
              const SizedBox(height: Space.sm),
              Text(
                categoryLabel(category),
                style: tt.titleMedium!.copyWith(color: cs.onSurface),
              ),
              Text(
                '$count',
                style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
