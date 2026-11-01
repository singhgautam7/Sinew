import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;

import '../../core/db/repositories/exercise_repository.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';
import '../../core/db/repositories/exercise_search_service.dart';
import '../../core/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';

/// The Sex that picks the muscle map base (Profile), null when blank.
final StreamProvider<Sex?> librarySexProvider =
    StreamProvider.autoDispose<Sex?>(
      (Ref ref) => ref
          .watch(profileRepositoryProvider)
          .watch()
          .map((profile) => profile.sex),
    );

/// Exercises per category (browse cards).
final FutureProvider<Map<String, int>> categoryCountsProvider =
    FutureProvider.autoDispose<Map<String, int>>((Ref ref) async {
      final LibraryRepository repo = await ref.watch(
        libraryRepositoryProvider.future,
      );
      return repo.categoryCounts();
    });

/// The user's active custom exercises, live.
final StreamProvider<List<Exercise>> customExercisesProvider =
    StreamProvider.autoDispose<List<Exercise>>(
      (Ref ref) => ref.watch(customExerciseRepositoryProvider).watchAll(),
    );

/// Every flow without its steps.
final FutureProvider<List<Flow>> flowsProvider =
    FutureProvider.autoDispose<List<Flow>>((Ref ref) async {
      final LibraryRepository repo = await ref.watch(
        libraryRepositoryProvider.future,
      );
      return repo.flows();
    });

/// One flow with its steps, or null.
final FutureProviderFamily<Flow?, String> flowProvider = FutureProvider
    .autoDispose
    .family<Flow?, String>((Ref ref, String id) async {
      final LibraryRepository repo = await ref.watch(
        libraryRepositoryProvider.future,
      );
      return repo.flowById(id);
    });

/// Any exercise id (custom, library, tombstoned) or null when unknown.
/// Re-reads when the custom exercises change.
final FutureProviderFamily<Exercise?, String> libraryExerciseProvider =
    FutureProvider.autoDispose.family<Exercise?, String>((
      Ref ref,
      String id,
    ) async {
      ref.watch(customExercisesProvider);
      final ExerciseResolver resolver = await ref.watch(
        exerciseResolverProvider.future,
      );
      return (await resolver.resolve(<String>[id]))[id];
    });

/// Pose names for a flow's steps, keyed by the comma-joined exercise ids (a
/// list key would never be equal to itself and rebuild forever).
final FutureProviderFamily<Map<String, Exercise>, String> flowPosesProvider =
    FutureProvider.autoDispose.family<Map<String, Exercise>, String>((
      Ref ref,
      String joinedIds,
    ) async {
      final ExerciseResolver resolver = await ref.watch(
        exerciseResolverProvider.future,
      );
      return resolver.resolve(joinedIds.split(','));
    });

/// How many exercises match a query and filters (the filter sheet button).
typedef MatchQuery = ({String query, LibraryFilters filters});

final FutureProviderFamily<int, MatchQuery> matchCountProvider = FutureProvider
    .autoDispose
    .family<int, MatchQuery>((Ref ref, MatchQuery q) async {
      final ExerciseSearchService svc = await ref.watch(
        exerciseSearchServiceProvider.future,
      );
      return svc.count(query: q.query, filters: q.filters);
    });

/// The search field's placeholder: "Search 2,890 exercises" once the library
/// count is known, a neutral line until then.
final Provider<String> librarySearchHintProvider = Provider.autoDispose<String>(
  (Ref ref) {
    final int? total = ref
        .watch(matchCountProvider((query: '', filters: const LibraryFilters())))
        .value;
    if (total == null) return 'Search exercises and poses';
    return 'Search ${groupThousands(total)} exercises';
  },
);

/// 2890 -> "2,890" (no locale data needed, the app ships English only).
String groupThousands(int n) {
  final String text = n.abs().toString();
  final StringBuffer out = StringBuffer(n < 0 ? '-' : '');
  for (int i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) out.write(',');
    out.write(text[i]);
  }
  return out.toString();
}

/// The last [LibrarySpec] recent ids viewed, newest first, in prefs.
class RecentExercisesNotifier extends Notifier<List<String>> {
  static const String prefsKey = 'library.recent';
  static const int max = LibrarySpec.recentMax;

  @override
  List<String> build() =>
      ref.watch(prefsProvider).getStringList(prefsKey) ?? const <String>[];

  void add(String id) {
    final List<String> next = <String>[
      id,
      ...state.where((String e) => e != id),
    ].take(max).toList();
    state = next;
    ref.read(prefsProvider).setStringList(prefsKey, next);
  }

  void clear() {
    state = const <String>[];
    ref.read(prefsProvider).remove(prefsKey);
  }
}

final NotifierProvider<RecentExercisesNotifier, List<String>>
recentExercisesProvider =
    NotifierProvider<RecentExercisesNotifier, List<String>>(
      RecentExercisesNotifier.new,
    );

/// The recent ids as list rows, newest first. Unknown, removed and archived
/// exercises are left out.
final FutureProvider<List<ExerciseSummary>> recentSummariesProvider =
    FutureProvider.autoDispose<List<ExerciseSummary>>((Ref ref) async {
      final List<String> ids = ref.watch(recentExercisesProvider);
      if (ids.isEmpty) return const <ExerciseSummary>[];
      ref.watch(customExercisesProvider);
      final ExerciseResolver resolver = await ref.watch(
        exerciseResolverProvider.future,
      );
      final Map<String, Exercise> found = await resolver.resolve(ids);
      return <ExerciseSummary>[
        for (final String id in ids)
          if (found[id] != null &&
              found[id]!.category != 'removed' &&
              !found[id]!.archived)
            summaryOf(found[id]!),
      ];
    });

/// The list row of a full exercise.
ExerciseSummary summaryOf(Exercise e) => ExerciseSummary(
  id: e.id,
  name: e.name,
  category: e.category,
  subcategory: e.subcategory,
  trackingType: e.trackingType,
  primaryMuscles: e.primaryMuscles,
  equipment: e.equipment,
  difficulty: e.difficulty,
  unilateral: e.unilateral,
  isCustom: e.isCustom,
);
