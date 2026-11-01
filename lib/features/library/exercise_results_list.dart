import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/exercise_repository.dart';
import '../../core/db/repositories/exercise_search_service.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/domain/exercise_tile.dart';
import '../../core/widgets/sinew_states.dart';
import 'library_providers.dart';
import 'library_widgets.dart';

/// A virtualised, paged list of search results.
///
/// Give it an already debounced [query] and [filters]; it reloads when either
/// changes, when the custom exercises change, and loads the next
/// [LibrarySpec.pageSize] rows as the end comes near. It owns the loading
/// (behind [Delayed]), empty, no-results and error states.
///
/// [headerSlivers] sit above the results (sections of the picker's browse
/// state). [includeCustom] false lists the bundled library only.
class ExerciseResultsList extends ConsumerStatefulWidget {
  const ExerciseResultsList({
    super.key,
    required this.query,
    required this.filters,
    required this.tileBuilder,
    this.includeCustom = true,
    this.headerSlivers = const <Widget>[],
    this.countLabelBuilder,
    this.noResults,
    this.bottomPadding = Space.xxxl,
    this.controller,
  });

  final String query;
  final LibraryFilters filters;
  final Widget Function(
    BuildContext context,
    ExerciseSummary exercise,
    Sex? sex,
  )
  tileBuilder;
  final bool includeCustom;
  final List<Widget> headerSlivers;

  /// "24 results": shown above the rows when set.
  final String Function(int total)? countLabelBuilder;

  /// Shown instead of the rows when nothing matches.
  final Widget? noResults;
  final double bottomPadding;
  final ScrollController? controller;

  @override
  ConsumerState<ExerciseResultsList> createState() =>
      _ExerciseResultsListState();
}

class _ExerciseResultsListState extends ConsumerState<ExerciseResultsList> {
  late final ScrollController _scroll = widget.controller ?? ScrollController();
  final List<ExerciseSummary> _items = <ExerciseSummary>[];
  int? _total;
  bool _loadingMore = false;
  Object? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    ref.listenManual<AsyncValue<List<Exercise>>>(customExercisesProvider, (
      AsyncValue<List<Exercise>>? prev,
      AsyncValue<List<Exercise>> next,
    ) {
      if (widget.includeCustom && prev != null) _reload(keepItems: true);
    });
    _load(_generation);
  }

  @override
  void didUpdateWidget(ExerciseResultsList old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query || old.filters != widget.filters) {
      _reload();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    if (widget.controller == null) _scroll.dispose();
    super.dispose();
  }

  Future<List<ExerciseSummary>> _page(int offset) async {
    if (widget.includeCustom) {
      final ExerciseSearchService svc = await ref.read(
        exerciseSearchServiceProvider.future,
      );
      return svc.search(
        query: widget.query,
        filters: widget.filters,
        limit: LibrarySpec.pageSize,
        offset: offset,
      );
    }
    final LibraryRepository repo = await ref.read(
      libraryRepositoryProvider.future,
    );
    return repo.search(
      query: widget.query,
      filters: widget.filters,
      limit: LibrarySpec.pageSize,
      offset: offset,
    );
  }

  Future<int> _count() async {
    if (widget.includeCustom) {
      final ExerciseSearchService svc = await ref.read(
        exerciseSearchServiceProvider.future,
      );
      return svc.count(query: widget.query, filters: widget.filters);
    }
    final LibraryRepository repo = await ref.read(
      libraryRepositoryProvider.future,
    );
    return repo.count(query: widget.query, filters: widget.filters);
  }

  Future<void> _reload({bool keepItems = false}) async {
    final int gen = ++_generation;
    if (!keepItems) {
      setState(() {
        _items.clear();
        _total = null;
        _error = null;
      });
    }
    await _load(gen);
  }

  Future<void> _load(int gen) async {
    try {
      final int total = await _count();
      final List<ExerciseSummary> first = await _page(0);
      if (!mounted || gen != _generation) return;
      setState(() {
        _items
          ..clear()
          ..addAll(first);
        _total = total;
        _error = null;
        _loadingMore = false;
      });
    } on Object catch (e) {
      if (!mounted || gen != _generation) return;
      setState(() => _error = e);
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loadingMore) return;
    final int? total = _total;
    if (total == null || _items.length >= total) return;
    if (_scroll.position.extentAfter < LibrarySpec.loadMoreExtent) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final int gen = _generation;
    setState(() => _loadingMore = true);
    try {
      final List<ExerciseSummary> next = await _page(_items.length);
      if (!mounted || gen != _generation) return;
      final Set<String> have = <String>{
        for (final ExerciseSummary s in _items) s.id,
      };
      setState(() {
        _items.addAll(next.where((ExerciseSummary s) => have.add(s.id)));
        _loadingMore = false;
      });
      // A short page can leave the list still shorter than the viewport.
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    } on Object catch (e) {
      if (!mounted || gen != _generation) return;
      setState(() {
        _loadingMore = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int? total = _total;
    final Sex? sex = ref.watch(librarySexProvider).value;
    final List<Widget> slivers = <Widget>[...widget.headerSlivers];

    if (_error != null) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: SinewEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load exercises',
            description: 'Something went wrong reading the library.',
            actionLabel: 'Try again',
            actionIcon: Icons.refresh_rounded,
            onAction: _reload,
          ),
        ),
      );
    } else if (total == null) {
      slivers.add(
        const SliverToBoxAdapter(child: Delayed(child: _ResultsSkeleton())),
      );
    } else if (total == 0) {
      slivers.add(
        SliverToBoxAdapter(
          child:
              widget.noResults ??
              const SinewEmptyState(
                icon: Icons.search_off_rounded,
                title: 'No matches',
                description: 'Try a shorter word or remove a filter.',
              ),
        ),
      );
    } else {
      if (widget.countLabelBuilder != null) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.sm,
                Space.screen,
                Space.sm,
              ),
              child: Text(
                widget.countLabelBuilder!(total).toUpperCase(),
                style: context.sectionHeader,
              ),
            ),
          ),
        );
      }
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Space.screen),
          sliver: SliverList.builder(
            itemCount: _items.length,
            itemBuilder: (BuildContext context, int i) => Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: ExerciseRowCard(
                child: widget.tileBuilder(context, _items[i], sex),
              ),
            ),
          ),
        ),
      );
      if (_loadingMore) {
        slivers.add(
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Space.lg),
              child: SinewLoader(label: 'Loading more exercises'),
            ),
          ),
        );
      }
    }
    slivers.add(
      SliverToBoxAdapter(child: SizedBox(height: widget.bottomPadding)),
    );
    return ColoredBox(
      color: Colors.transparent,
      child: CustomScrollView(
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: slivers,
        semanticChildCount: _items.length,
      ),
    );
  }
}

class _ResultsSkeleton extends StatelessWidget {
  const _ResultsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: Space.screen),
      child: Column(
        children: <Widget>[
          ExerciseTileSkeleton(),
          ExerciseTileSkeleton(),
          ExerciseTileSkeleton(),
          ExerciseTileSkeleton(),
          ExerciseTileSkeleton(),
          ExerciseTileSkeleton(),
        ],
      ),
    );
  }
}
