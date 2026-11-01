import '../../models/exercise.dart';
import '../library/search_text.dart';
import 'exercise_repository.dart';

// PURE DART.

/// One search over the bundled library and the user's own exercises.
///
/// Custom exercises come first (the user made them, they are what they look
/// for), then the library, deduped by id. Paging is over the merged list:
/// the custom matches are the head of it, the library pages follow.
class ExerciseSearchService {
  ExerciseSearchService({required this._library, required this._custom});

  final LibraryRepository _library;
  final CustomExerciseRepository _custom;

  Future<List<ExerciseSummary>> search({
    String query = '',
    LibraryFilters filters = const LibraryFilters(),
    int limit = 50,
    int offset = 0,
  }) async {
    final List<ExerciseSummary> mine = await _customMatches(query, filters);
    final List<ExerciseSummary> head = offset < mine.length
        ? mine.sublist(
            offset,
            offset + limit > mine.length ? mine.length : offset + limit,
          )
        : const <ExerciseSummary>[];
    final int libraryLimit = limit - head.length;
    if (libraryLimit <= 0) return head;
    final int libraryOffset = offset > mine.length ? offset - mine.length : 0;
    final Set<String> seen = <String>{
      for (final ExerciseSummary s in mine) s.id,
    };
    final List<ExerciseSummary> fromLibrary = await _library.search(
      query: query,
      filters: filters,
      limit: libraryLimit,
      offset: libraryOffset,
    );
    return <ExerciseSummary>[
      ...head,
      for (final ExerciseSummary s in fromLibrary)
        if (seen.add(s.id)) s,
    ];
  }

  Future<int> count({
    String query = '',
    LibraryFilters filters = const LibraryFilters(),
  }) async =>
      (await _customMatches(query, filters)).length +
      await _library.count(query: query, filters: filters);

  Future<List<ExerciseSummary>> _customMatches(
    String query,
    LibraryFilters filters,
  ) async {
    final List<String> tokens = normalizeSearchText(query)
        .split(' ')
        .where((String t) => t.isNotEmpty)
        .toList();
    final List<ExerciseSummary> out = <ExerciseSummary>[];
    for (final Exercise e in await _custom.allActive()) {
      if (!_passes(e, filters)) continue;
      if (tokens.isNotEmpty) {
        final String haystack = normalizeSearchText(
          <String>[e.name, ...e.aliases].join(' '),
        );
        if (!tokens.every(haystack.contains)) continue;
      }
      out.add(
        ExerciseSummary(
          id: e.id,
          name: e.name,
          category: e.category,
          subcategory: e.subcategory,
          trackingType: e.trackingType,
          primaryMuscles: e.primaryMuscles,
          equipment: e.equipment,
          difficulty: e.difficulty,
          unilateral: e.unilateral,
          isCustom: true,
        ),
      );
    }
    final String q = normalizeSearchText(query);
    out.sort((ExerciseSummary a, ExerciseSummary b) {
      final int ra = _rank(normalizeSearchText(a.name), q);
      final int rb = _rank(normalizeSearchText(b.name), q);
      if (ra != rb) return ra - rb;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return out;
  }

  static int _rank(String name, String q) {
    if (q.isEmpty) return 0;
    if (name == q) return 0;
    if (name.startsWith(q)) return 1;
    return 2;
  }

  static bool _passes(Exercise e, LibraryFilters f) {
    if (f.categories.isNotEmpty && !f.categories.contains(e.category)) {
      return false;
    }
    if (f.trackingTypes.isNotEmpty &&
        !f.trackingTypes.contains(e.trackingType)) {
      return false;
    }
    if (f.difficulties.isNotEmpty &&
        (e.difficulty == null || !f.difficulties.contains(e.difficulty))) {
      return false;
    }
    if (f.muscles.isNotEmpty) {
      final Iterable<String> have = <String>[
        ...e.primaryMuscles,
        if (f.includeSecondaryMuscles) ...e.secondaryMuscles,
      ];
      if (!have.any(f.muscles.contains)) return false;
    }
    if (f.equipment.isNotEmpty && !e.equipment.any(f.equipment.contains)) {
      return false;
    }
    return true;
  }
}
