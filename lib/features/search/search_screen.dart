import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_states.dart';
import 'search_providers.dart';

/// One field over everything in the app: exercises, routines, past workouts,
/// body measurements and the More pages.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.debounce = TodaySpec.searchDebounce});

  /// How long to wait after the last keystroke. Tests shorten it.
  final Duration debounce;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _timer;

  /// The query the results are for (after the debounce).
  String _query = '';

  /// Null shows every group; a kind shows only that one, untrimmed.
  SearchKind? _only;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _timer?.cancel();
    setState(() {});
    if (text.trim().isEmpty) {
      setState(() => _query = '');
      return;
    }
    _timer = Timer(widget.debounce, () {
      if (mounted) setState(() => _query = text.trim());
    });
  }

  void _setQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    _timer?.cancel();
    setState(() => _query = q.trim());
  }

  void _open(SearchHit hit) {
    ref.read(recentSearchesProvider.notifier).add(_query);
    context.push(hit.route);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                Space.sm,
                Space.lg,
                Space.sm,
              ),
              child: Row(
                children: <Widget>[
                  AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: Space.xs),
                  Expanded(
                    child: TextField(
                      key: const ValueKey<String>('search-field'),
                      controller: _controller,
                      focusNode: _focus,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: _onChanged,
                      onSubmitted: (String v) {
                        _setQuery(v);
                        ref.read(recentSearchesProvider.notifier).add(v);
                      },
                      style: context.text.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search exercises, routines, workouts',
                        filled: true,
                        fillColor: cs.surfaceContainerHigh,
                        border: const OutlineInputBorder(
                          borderRadius: Radii.fullR,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Space.lg,
                          vertical: Space.md,
                        ),
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty) ...<Widget>[
                    const SizedBox(width: Space.xs),
                    AppIconButton(
                      icon: Icons.close_rounded,
                      semanticLabel: 'Clear search',
                      onPressed: () {
                        _controller.clear();
                        _setQuery('');
                        _focus.requestFocus();
                      },
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _query.isEmpty
                  ? _Suggestions(onRecent: _setQuery, onOpen: _open)
                  : _Results(
                      query: _query,
                      only: _only,
                      onOnly: (SearchKind? k) => setState(() => _only = k),
                      onOpen: _open,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Before anything is typed: recent searches, then every page.
class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.onRecent, required this.onOpen});

  final ValueChanged<String> onRecent;
  final ValueChanged<SearchHit> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> recent = ref.watch(recentSearchesProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.sm,
        Space.screen,
        Space.bottomSafe,
      ),
      children: <Widget>[
        if (recent.isNotEmpty) ...<Widget>[
          SinewSectionHeader(
            title: 'Recent',
            trailing: SinewSectionAction(
              label: 'Clear',
              onTap: () => ref.read(recentSearchesProvider.notifier).clear(),
            ),
          ),
          SinewGroup(
            children: <Widget>[
              for (final String q in recent)
                SinewListRow(
                  leading: const Icon(Icons.history_rounded),
                  title: q,
                  onTap: () => onRecent(q),
                ),
            ],
          ),
          const SizedBox(height: Space.section),
        ],
        const SinewSectionHeader(title: 'Jump to'),
        SinewGroup(
          children: <Widget>[
            for (final SearchHit h in allPageHits())
              SinewListRow(
                leading: SinewIconTile(icon: h.icon),
                title: h.title,
                subtitle: h.subtitle,
                trailing: const SinewChevron(),
                onTap: () => onOpen(h),
              ),
          ],
        ),
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.query,
    required this.only,
    required this.onOnly,
    required this.onOpen,
  });

  final String query;
  final SearchKind? only;
  final ValueChanged<SearchKind?> onOnly;
  final ValueChanged<SearchHit> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SearchResults> results = ref.watch(
      searchResultsProvider(query),
    );
    return results.when(
      loading: () => const Delayed(child: SinewLoader()),
      error: (Object e, StackTrace st) => const SinewEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Search failed',
        description: 'Nothing was changed. Try another search.',
      ),
      data: (SearchResults r) {
        final List<SearchGroup> groups = <SearchGroup>[
          for (final SearchGroup g in r.groups)
            if (g.hits.isNotEmpty && (only == null || only == g.kind)) g,
        ];
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.xs,
            Space.screen,
            Space.bottomSafe,
          ),
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  SinewChip(
                    label: 'All',
                    selected: only == null,
                    onTap: () => onOnly(null),
                  ),
                  for (final SearchKind k in SearchKind.values) ...<Widget>[
                    const SizedBox(width: Space.sm),
                    SinewChip(
                      label: k.label,
                      selected: only == k,
                      onTap: () => onOnly(k),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Space.lg),
            if (r.libraryUnavailable)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.md),
                child: Text(
                  'The exercise library is not available right now.',
                  style: context.text.bodyMedium!.copyWith(
                    color: context.cs.onSurfaceVariant,
                  ),
                ),
              ),
            if (groups.isEmpty)
              SinewEmptyState(
                icon: Icons.search_off_rounded,
                title: 'No results for "$query"',
                description: 'Try a shorter word or another spelling.',
              ),
            for (final SearchGroup g in groups) ...<Widget>[
              _GroupView(
                group: g,
                trim: only == null,
                onShowAll: () => onOnly(g.kind),
                onOpen: onOpen,
              ),
              const SizedBox(height: Space.section),
            ],
          ],
        );
      },
    );
  }
}

class _GroupView extends StatelessWidget {
  const _GroupView({
    required this.group,
    required this.trim,
    required this.onShowAll,
    required this.onOpen,
  });

  final SearchGroup group;
  final bool trim;
  final VoidCallback onShowAll;
  final ValueChanged<SearchHit> onOpen;

  @override
  Widget build(BuildContext context) {
    final List<SearchHit> all = group.hits;
    final List<SearchHit> shown = trim
        ? all.take(TodaySpec.searchGroupLimit).toList()
        : all;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SinewSectionHeader(
          title: '${group.kind.label} · ${all.length}',
          trailing: trim && all.length > shown.length
              ? SinewSectionAction(label: 'Show all', onTap: onShowAll)
              : null,
        ),
        SinewGroup(
          children: <Widget>[
            for (final SearchHit h in shown)
              SinewListRow(
                leading: SinewIconTile(icon: h.icon),
                title: h.title,
                subtitle: h.subtitle,
                trailing: const SinewChevron(),
                onTap: () => onOpen(h),
              ),
          ],
        ),
      ],
    );
  }
}
