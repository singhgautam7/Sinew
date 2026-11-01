import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/db/repositories/library_types.dart';
import '../../core/models/measurement.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/domain/exercise_tile.dart' show prettyVocab;
import '../today/date_text.dart';

enum SearchKind { exercises, routines, workouts, body, pages }

extension SearchKindText on SearchKind {
  String get label => switch (this) {
    SearchKind.exercises => 'Exercises',
    SearchKind.routines => 'Routines',
    SearchKind.workouts => 'Workouts',
    SearchKind.body => 'Body',
    SearchKind.pages => 'Pages',
  };
}

/// One row in the results.
@immutable
class SearchHit {
  const SearchHit({
    required this.kind,
    required this.icon,
    required this.title,
    required this.route,
    this.subtitle,
  });

  final SearchKind kind;
  final IconData icon;
  final String title;
  final String? subtitle;

  /// Where tapping the row goes (a `Routes` path).
  final String route;
}

/// Hits of one kind, with the number found before any trimming.
@immutable
class SearchGroup {
  const SearchGroup(this.kind, this.hits);

  final SearchKind kind;
  final List<SearchHit> hits;
}

@immutable
class SearchResults {
  const SearchResults({required this.groups, this.libraryUnavailable = false});

  final List<SearchGroup> groups;

  /// The exercise library could not be opened; the other groups still work.
  final bool libraryUnavailable;

  bool get isEmpty => groups.every((SearchGroup g) => g.hits.isEmpty);

  List<SearchHit> of(SearchKind k) => groups
      .firstWhere(
        (SearchGroup g) => g.kind == k,
        orElse: () => SearchGroup(k, const <SearchHit>[]),
      )
      .hits;
}

/// A page of the app a search can jump to.
class _Page {
  const _Page(this.title, this.subtitle, this.icon, this.route, this.words);

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String words;
}

const List<_Page> _pages = <_Page>[
  _Page(
    'Theme',
    'Mode and colour',
    Icons.palette_outlined,
    Routes.theme,
    'theme dark light amoled colour color wallpaper appearance',
  ),
  _Page(
    'Units',
    'Weight, length and distance',
    Icons.straighten_rounded,
    Routes.units,
    'units kg lb cm inch km miles metric imperial',
  ),
  _Page(
    'Backup and restore',
    'Export, import and CSV',
    Icons.backup_outlined,
    Routes.backup,
    'backup restore export import csv json data',
  ),
  _Page(
    'Plates and bars',
    'What you can load',
    Icons.fitness_center_rounded,
    Routes.plates,
    'plates bars barbell dumbbell inventory machine stack',
  ),
  _Page(
    'Profile',
    'Sex, birth year, height, activity',
    Icons.person_outline_rounded,
    Routes.profile,
    'profile height birth year age sex activity bmi cut-offs',
  ),
  _Page(
    'Settings',
    'Workout, timer and sounds',
    Icons.settings_outlined,
    Routes.settings,
    'settings rest haptics sound voice screen text size',
  ),
  _Page(
    'About Sinew',
    'Offline promise, sources, licences',
    Icons.info_outline_rounded,
    Routes.about,
    'about version privacy licences licenses sources attributions',
  ),
  _Page(
    'Permissions',
    'What Sinew can and cannot do',
    Icons.shield_outlined,
    Routes.permissions,
    'permissions notifications vibration internet',
  ),
  _Page(
    'Measurement fields',
    'Choose what you track',
    Icons.tune_rounded,
    Routes.fields,
    'measurement fields tape waist chest',
  ),
];

/// Every page, for the empty-query view.
List<SearchHit> allPageHits() => <SearchHit>[
  for (final _Page p in _pages)
    SearchHit(
      kind: SearchKind.pages,
      icon: p.icon,
      title: p.title,
      subtitle: p.subtitle,
      route: p.route,
    ),
];

/// All of the user's searchable records, loaded once per open search screen.
class _Corpus {
  const _Corpus(this.routines, this.sessions, this.fields);

  final List<Routine> routines;
  final List<WorkoutSession> sessions;
  final List<MeasurementField> fields;
}

final FutureProvider<_Corpus> _corpusProvider =
    FutureProvider.autoDispose<_Corpus>((Ref ref) async {
      final List<Routine> routines = await ref
          .watch(routineRepositoryProvider)
          .allWithItems();
      final List<WorkoutSession> sessions =
          (await ref.watch(sessionRepositoryProvider).allWithTree())
              .where((WorkoutSession s) => s.endedAt != null)
              .toList()
            ..sort(
              (WorkoutSession a, WorkoutSession b) =>
                  b.startedAt.compareTo(a.startedAt),
            );
      final List<MeasurementField> fields = await ref
          .watch(measurementRepositoryProvider)
          .fields();
      return _Corpus(
        routines.where((Routine r) => !r.archived).toList()
          ..sort((Routine a, Routine b) => a.position - b.position),
        sessions,
        fields,
      );
    });

/// Every whitespace-separated word of [query] must appear in [haystack].
bool matchesQuery(String query, String haystack) {
  final String h = haystack.toLowerCase();
  for (final String t in query.toLowerCase().split(RegExp(r'\s+'))) {
    if (t.isNotEmpty && !h.contains(t)) return false;
  }
  return true;
}

/// Results for a trimmed, non-empty query. The key is the query itself, so a
/// repeated search is free and an old one is dropped with the screen.
final searchResultsProvider = FutureProvider.autoDispose
    .family<SearchResults, String>((Ref ref, String query) async {
      final String q = query.trim();
      if (q.isEmpty) return const SearchResults(groups: <SearchGroup>[]);
      final _Corpus corpus = await ref.watch(_corpusProvider.future);

      // Exercises first: routines and workouts also match through them.
      List<ExerciseSummary> found = const <ExerciseSummary>[];
      bool unavailable = false;
      try {
        found = await (await ref.watch(exerciseSearchServiceProvider.future))
            .search(query: q, limit: 40);
      } on Object {
        unavailable = true;
      }
      final Map<String, String> nameOf = <String, String>{
        for (final ExerciseSummary e in found) e.id: e.name,
      };

      final List<SearchHit> exercises = <SearchHit>[
        for (final ExerciseSummary e in found)
          SearchHit(
            kind: SearchKind.exercises,
            icon: Icons.fitness_center_rounded,
            title: e.name,
            subtitle: <String>[
              if (e.primaryMuscles.isNotEmpty)
                prettyVocab(e.primaryMuscles.first),
              if (e.equipment.isNotEmpty) prettyVocab(e.equipment.first),
              if (e.primaryMuscles.isEmpty && e.equipment.isEmpty)
                prettyVocab(e.category),
            ].join(' · '),
            route: Routes.exercise(e.id),
          ),
      ];

      String? includes(Iterable<String> exerciseIds) {
        for (final String id in exerciseIds) {
          final String? n = nameOf[id];
          if (n != null) return 'Includes $n';
        }
        return null;
      }

      final List<SearchHit> routines = <SearchHit>[];
      for (final Routine r in corpus.routines) {
        final String? via = includes(
          r.items.map((RoutineItem i) => i.exerciseId),
        );
        if (matchesQuery(q, r.name) || via != null) {
          routines.add(
            SearchHit(
              kind: SearchKind.routines,
              icon: Icons.list_alt_rounded,
              title: r.name,
              subtitle: via ?? DateText.count(r.items.length, 'exercise'),
              route: Routes.routine(r.id),
            ),
          );
        }
      }

      final List<SearchHit> workouts = <SearchHit>[];
      for (final WorkoutSession s in corpus.sessions) {
        final DateTime d = s.startedAt.toLocal();
        final String label = s.name ?? 'Workout';
        final String dateWords =
            '${DateText.dayMonth(d)} ${DateText.month(d)} ${DateText.weekday(d)} ${d.year}';
        final String? via = includes(
          s.exercises.map((SessionExercise e) => e.exerciseId),
        );
        if (matchesQuery(q, '$label $dateWords') || via != null) {
          workouts.add(
            SearchHit(
              kind: SearchKind.workouts,
              icon: Icons.history_rounded,
              title: '$label · ${DateText.dayMonth(d)}',
              subtitle: via ?? DateText.weekday(d),
              route: Routes.session(s.id),
            ),
          );
        }
      }

      final List<SearchHit> body = <SearchHit>[
        for (final MeasurementField f in corpus.fields)
          if (matchesQuery(q, f.name) ||
              matchesQuery(q, '${f.name} ${f.side.name}'))
            SearchHit(
              kind: SearchKind.body,
              icon: Icons.accessibility_new_rounded,
              title: f.name,
              subtitle: 'Progress and history',
              route: Routes.progress(f.id),
            ),
      ];

      final List<SearchHit> pages = <SearchHit>[
        for (final _Page p in _pages)
          if (matchesQuery(q, '${p.title} ${p.words}'))
            SearchHit(
              kind: SearchKind.pages,
              icon: p.icon,
              title: p.title,
              subtitle: p.subtitle,
              route: p.route,
            ),
      ];

      return SearchResults(
        libraryUnavailable: unavailable,
        groups: <SearchGroup>[
          SearchGroup(SearchKind.exercises, exercises),
          SearchGroup(SearchKind.routines, routines),
          SearchGroup(SearchKind.workouts, workouts),
          SearchGroup(SearchKind.body, body),
          SearchGroup(SearchKind.pages, pages),
        ],
      );
    });

/// The last few searches, newest first. Device-only (SharedPreferences), and
/// not part of a backup.
class RecentSearches extends Notifier<List<String>> {
  static const String key = 'search.recent';

  @override
  List<String> build() =>
      ref.watch(prefsProvider).getStringList(key) ?? const <String>[];

  SharedPreferences get _prefs => ref.read(prefsProvider);

  Future<void> add(String query) async {
    final String q = query.trim();
    if (q.length < 2) return;
    final List<String> next = <String>[
      q,
      ...state.where((String s) => s.toLowerCase() != q.toLowerCase()),
    ].take(TodaySpec.recentSearches).toList();
    state = next;
    await _prefs.setStringList(key, next);
  }

  Future<void> clear() async {
    state = const <String>[];
    await _prefs.remove(key);
  }
}

final NotifierProvider<RecentSearches, List<String>> recentSearchesProvider =
    NotifierProvider<RecentSearches, List<String>>(RecentSearches.new);
