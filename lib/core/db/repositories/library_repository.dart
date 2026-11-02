import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/exercise.dart';
import '../converters.dart';
import '../library/library_db.dart';
import '../library/search_text.dart';
import 'library_types.dart';

/// Read access to the bundled library: lookup, search, filters and flows.
class LibraryRepository {
  LibraryRepository(this._db);

  final LibraryDatabase _db;

  static const String _summaryColumns =
      'e.id, e.name, e.category, e.subcategory, e.tracking_type, '
      'e.primary_muscles, e.equipment, e.difficulty, e.unilateral';

  /// How many exercises match. With no arguments, the size of the library.
  Future<int> count({
    String query = '',
    LibraryFilters filters = const LibraryFilters(),
  }) async {
    final _Sql sql = _searchSql(
      query: query,
      filters: filters,
      countOnly: true,
    );
    final List<QueryRow> rows = await _db
        .customSelect(sql.text, variables: sql.vars, readsFrom: _reads)
        .get();
    return rows.first.read<int>('n');
  }

  Future<String?> libraryVersion() => _db.meta('libraryVersion');

  /// Exercises matching [query] (prefix search over name, aliases and
  /// primary muscles, every word must match) and [filters], best first:
  /// exact name, then name prefix, then FTS5 bm25, then name. With an empty
  /// query only the filters apply and the order is alphabetical.
  Future<List<ExerciseSummary>> search({
    String query = '',
    LibraryFilters filters = const LibraryFilters(),
    int limit = 50,
    int offset = 0,
  }) async {
    final _Sql sql = _searchSql(
      query: query,
      filters: filters,
      limit: limit,
      offset: offset,
    );
    final List<QueryRow> rows = await _db
        .customSelect(sql.text, variables: sql.vars, readsFrom: _reads)
        .get();
    return rows.map(_summary).toList();
  }

  /// SQLite's query plan for [search], one line per step. Tests use it to
  /// prove every query is index-backed.
  Future<List<String>> explainSearch({
    String query = '',
    LibraryFilters filters = const LibraryFilters(),
    int limit = 50,
    int offset = 0,
  }) async {
    final _Sql sql = _searchSql(
      query: query,
      filters: filters,
      limit: limit,
      offset: offset,
    );
    final List<QueryRow> rows = await _db
        .customSelect(
          'EXPLAIN QUERY PLAN ${sql.text}',
          variables: sql.vars,
          readsFrom: _reads,
        )
        .get();
    return rows.map((QueryRow r) => r.read<String>('detail')).toList();
  }

  /// Exercises per category (the Library tab's chips and the debug section).
  Future<Map<String, int>> categoryCounts() async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT category, COUNT(*) AS n FROM exercises '
          'GROUP BY category ORDER BY category',
          readsFrom: _reads,
        )
        .get();
    return <String, int>{
      for (final QueryRow r in rows)
        r.read<String>('category'): r.read<int>('n'),
    };
  }

  /// Every flow without its steps, by category then name.
  Future<List<Flow>> flows({String? category}) async {
    final SimpleSelectStatement<$FlowsTable, LibraryFlowRow> q =
        _db.select(_db.flows)..orderBy(<OrderClauseGenerator<$FlowsTable>>[
          ($FlowsTable t) => OrderingTerm.asc(t.category),
          ($FlowsTable t) => OrderingTerm.asc(t.name),
        ]);
    if (category != null) {
      q.where(($FlowsTable t) => t.category.equals(category));
    }
    return (await q.get()).map((LibraryFlowRow r) => _flow(r)).toList();
  }

  /// One flow with its steps in order, or null.
  Future<Flow?> flowById(String id) async {
    final LibraryFlowRow? row = await (_db.select(
      _db.flows,
    )..where(($FlowsTable t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final List<LibraryFlowStepRow> steps =
        await (_db.select(_db.flowSteps)
              ..where(($FlowStepsTable t) => t.flowId.equals(id))
              ..orderBy(<OrderClauseGenerator<$FlowStepsTable>>[
                ($FlowStepsTable t) => OrderingTerm.asc(t.position),
              ]))
            .get();
    return _flow(
      row,
      steps: <FlowStep>[
        for (final LibraryFlowStepRow s in steps)
          FlowStep(
            position: s.position,
            exerciseId: s.exerciseId,
            label: s.label,
            holdSec: s.holdSec,
            transitionSec: s.transitionSec,
            cue: s.cue,
          ),
      ],
    );
  }

  Future<Exercise?> byId(String id) async {
    final LibraryExerciseRow? row = await (_db.select(
      _db.exercises,
    )..where(($ExercisesTable t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : mapLibraryRow(row);
  }

  /// Batched by 250 ids so SQLite's parameter limit is never reached.
  Future<Map<String, Exercise>> byIds(Iterable<String> ids) async {
    final List<String> all = ids.toSet().toList();
    final Map<String, Exercise> out = <String, Exercise>{};
    for (int i = 0; i < all.length; i += 250) {
      final List<String> chunk = all.sublist(
        i,
        i + 250 > all.length ? all.length : i + 250,
      );
      final List<LibraryExerciseRow> rows = await (_db.select(
        _db.exercises,
      )..where(($ExercisesTable t) => t.id.isIn(chunk))).get();
      for (final LibraryExerciseRow r in rows) {
        out[r.id] = mapLibraryRow(r);
      }
    }
    return out;
  }

  Set<TableInfo<Table, dynamic>> get _reads => <TableInfo<Table, dynamic>>{
    _db.exercises,
    _db.exerciseMuscles,
    _db.exerciseEquipment,
  };

  _Sql _searchSql({
    required String query,
    required LibraryFilters filters,
    bool countOnly = false,
    int limit = 50,
    int offset = 0,
  }) {
    final String? match = ftsMatchQuery(query);
    final String norm = normalizeSearchText(query);
    final List<Variable<Object>> vars = <Variable<Object>>[];
    final List<String> where = <String>[];

    if (match != null) {
      where.add('${LibraryDatabase.ftsTable} MATCH ?');
      vars.add(Variable<String>(match));
    }
    if (filters.categories.isNotEmpty) {
      where.add('e.category IN (${_marks(filters.categories.length)})');
      vars.addAll(filters.categories.map(Variable<String>.new));
    }
    if (filters.trackingTypes.isNotEmpty) {
      where.add('e.tracking_type IN (${_marks(filters.trackingTypes.length)})');
      vars.addAll(
        filters.trackingTypes.map((TrackingType t) => Variable<String>(t.name)),
      );
    }
    if (filters.difficulties.isNotEmpty) {
      where.add('e.difficulty IN (${_marks(filters.difficulties.length)})');
      vars.addAll(
        filters.difficulties.map((Difficulty d) => Variable<String>(d.name)),
      );
    }
    if (filters.muscles.isNotEmpty) {
      final String role = filters.includeSecondaryMuscles
          ? ''
          : " AND role = 'primary'";
      where.add(
        'e.id IN (SELECT exercise_id FROM exercise_muscles '
        'WHERE muscle IN (${_marks(filters.muscles.length)})$role)',
      );
      vars.addAll(filters.muscles.map(Variable<String>.new));
    }
    if (filters.equipment.isNotEmpty) {
      where.add(
        'e.id IN (SELECT exercise_id FROM exercise_equipment '
        'WHERE equipment IN (${_marks(filters.equipment.length)}))',
      );
      vars.addAll(filters.equipment.map(Variable<String>.new));
    }

    final String from = match != null
        ? '${LibraryDatabase.ftsTable} JOIN exercises e '
              'ON e.seq = ${LibraryDatabase.ftsTable}.rowid'
        : 'exercises e';
    final String whereSql = where.isEmpty
        ? ''
        : ' WHERE ${where.join(' AND ')}';

    if (countOnly) {
      return _Sql('SELECT COUNT(*) AS n FROM $from$whereSql', vars);
    }
    final String order;
    if (match != null) {
      order =
          '(e.name_norm = ?) DESC, (e.name_norm LIKE ?) DESC, '
          'bm25(${LibraryDatabase.ftsTable}, 10.0, 4.0, 1.0), '
          'e.name_norm, e.name';
      vars
        ..add(Variable<String>(norm))
        ..add(Variable<String>('$norm%'));
    } else {
      order = 'e.name_norm, e.name';
    }
    vars
      ..add(Variable<int>(limit))
      ..add(Variable<int>(offset));
    return _Sql(
      'SELECT $_summaryColumns FROM $from$whereSql '
      'ORDER BY $order LIMIT ? OFFSET ?',
      vars,
    );
  }

  static String _marks(int n) => List<String>.filled(n, '?').join(', ');

  static ExerciseSummary _summary(QueryRow r) {
    const StringListConverter lists = StringListConverter();
    return ExerciseSummary(
      id: r.read<String>('id'),
      name: r.read<String>('name'),
      category: r.read<String>('category'),
      subcategory: r.readNullable<String>('subcategory'),
      trackingType: enumByName(
        TrackingType.values,
        r.read<String>('tracking_type'),
        TrackingType.unknown,
      ),
      primaryMuscles: lists.fromSql(r.read<String>('primary_muscles')),
      equipment: lists.fromSql(r.read<String>('equipment')),
      difficulty: enumByNameOrNull(
        Difficulty.values,
        r.readNullable<String>('difficulty'),
      ),
      unilateral: r.read<bool>('unilateral'),
    );
  }

  static Flow _flow(
    LibraryFlowRow r, {
    List<FlowStep> steps = const <FlowStep>[],
  }) => Flow(
    id: r.id,
    name: r.name,
    category: r.category,
    difficulty: enumByNameOrNull(Difficulty.values, r.difficulty),
    description: r.description,
    totalDurationSec: r.totalDurationSec,
    rounds: r.rounds,
    tags: r.tags,
    steps: steps,
  );

  static Exercise mapLibraryRow(LibraryExerciseRow r) => Exercise(
    id: r.id,
    name: r.name,
    aliases: r.aliases,
    sanskritName: r.sanskritName,
    category: r.category,
    subcategory: r.subcategory,
    trackingType: enumByName(
      TrackingType.values,
      r.trackingType,
      TrackingType.unknown,
    ),
    primaryMuscles: r.primaryMuscles,
    secondaryMuscles: r.secondaryMuscles,
    equipment: r.equipment,
    difficulty: enumByNameOrNull(Difficulty.values, r.difficulty),
    unilateral: r.unilateral,
    mechanic: r.mechanic,
    force: r.force,
    steps: r.steps,
    tips: r.tips,
    commonMistakes: r.commonMistakes,
    safetyNotes: r.safetyNotes,
    contraindications: r.contraindications,
    metValue: r.metValue,
    defaultRestSec: r.defaultRestSec,
    defaultHoldSec: r.defaultHoldSec,
    variationOf: r.variationOf,
    tags: r.tags,
    source: r.source,
    license: r.license,
  );
}

class _Sql {
  const _Sql(this.text, this.vars);

  final String text;
  final List<Variable<Object>> vars;
}
