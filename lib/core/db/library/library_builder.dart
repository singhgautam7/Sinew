import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../../../features/exercise_media/core/binary_payload.dart';
import 'library_db.dart';
import 'search_text.dart';

// PURE DART: runs under `dart run tool/build_library_db.dart` and in tests.

/// A record in the source JSON that cannot be built.
class LibraryBuildError implements Exception {
  const LibraryBuildError(this.message);

  final String message;

  @override
  String toString() => 'LibraryBuildError: $message';
}

/// What a build produced.
class LibraryBuildReport {
  const LibraryBuildReport({
    required this.exerciseCount,
    required this.flowCount,
    required this.countsByCategory,
    required this.warnings,
    this.motionCount = 0,
    this.averagePayloadBytes = 0.0,
  });

  final int exerciseCount;
  final int flowCount;
  final Map<String, int> countsByCategory;
  final List<String> warnings;
  final int motionCount;
  final double averagePayloadBytes;
}

/// Builds the library file with [LibraryDatabase] itself, so the asset and
/// the app can never disagree about the schema.
///
/// Deterministic: rows are inserted in source order, nothing depends on the
/// clock (`builtAt` comes from the manifest), and the file is deleted first
/// and VACUUMed last, so the same inputs give the same bytes.
class LibraryBuilder {
  const LibraryBuilder();

  static const List<String> _stringLists = <String>[
    'aliases',
    'primaryMuscles',
    'secondaryMuscles',
    'equipment',
    'steps',
    'tips',
    'commonMistakes',
    'safetyNotes',
    'contraindications',
    'tags',
  ];

  static const Set<String> _knownMuscles = <String>{
    'abductors',
    'adductors',
    'biceps',
    'calves',
    'chest',
    'core',
    'forearms',
    'fullBody',
    'glutes',
    'hamstrings',
    'hipFlexors',
    'lats',
    'lowerBack',
    'neck',
    'obliques',
    'quadriceps',
    'rearDeltoids',
    'rhomboids',
    'rotatorCuff',
    'shoulders',
    'tibialis',
    'trapezius',
    'triceps',
  };

  Future<LibraryBuildReport> build({
    required File output,
    required List<Object?> exercises,
    List<Object?> flows = const <Object?>[],
    List<Object?> motions = const <Object?>[],
    required String libraryVersion,
    required String builtAt,
    required String sha256,
  }) async {
    final List<Map<String, Object?>> records = <Map<String, Object?>>[
      for (int i = 0; i < exercises.length; i++) _validate(exercises[i], i),
    ];
    final Set<String> ids = <String>{};
    for (final Map<String, Object?> r in records) {
      if (!ids.add(r['id']! as String)) {
        throw LibraryBuildError('duplicate exercise id "${r['id']}"');
      }
    }

    for (final String suffix in <String>['', '-journal', '-wal', '-shm']) {
      final File f = File('${output.path}$suffix');
      if (f.existsSync()) f.deleteSync();
    }
    await output.parent.create(recursive: true);

    final LibraryDatabase db = LibraryDatabase.forBuild(NativeDatabase(output));
    final Map<String, int> counts = <String, int>{};
    final List<String> warnings = <String>[];
    int totalPayloadBytes = 0;
    int motionCount = 0;
    try {
      final Map<String, String> names = <String, String>{
        for (final Map<String, Object?> r in records)
          r['id']! as String: r['name']! as String,
      };
      await db.transaction(() async {
        // `seq` is the FTS rowid: assigned 1..n in source order.
        for (final Map<String, Object?> r in records) {
          final String category = r['category']! as String;
          counts[category] = (counts[category] ?? 0) + 1;
          await _insertExercise(db, r);
        }
        final Map<String, int> flowStepsSeen = <String, int>{};
        for (int i = 0; i < flows.length; i++) {
          await _insertFlow(db, flows[i], i, names, warnings, flowStepsSeen);
        }
        for (int i = 0; i < motions.length; i++) {
          final Map<String, Object?> m = _validateMotion(
            motions[i],
            i,
            names.keys.toSet(),
          );
          final Uint8List payload = BinaryPayload.encode(
            rawKeyframes: (m['keyframes']! as List<dynamic>)
                .cast<Map<String, dynamic>>(),
            rawTimeline: (m['timeline'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>(),
            rawProps: (m['props'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>(),
          );
          totalPayloadBytes += payload.length;
          motionCount++;

          await db.into(db.exerciseMotions).insert(
            ExerciseMotionsCompanion.insert(
              exerciseId: m['motionId']! as String,
              tier: m['tier']! as String,
              view: m['view']! as String,
              loop: (m['loop'] as String?) ?? 'repeat',
              mirror: (m['mirrorForOtherSide'] as bool?) ?? false,
              stepFrames: jsonEncode(m['stepFrames'] ?? <dynamic>[]),
              highlight: jsonEncode(m['highlight'] ?? <String, dynamic>{}),
              payload: payload,
            ),
          );
        }
        await _insertMeta(db, <String, String>{
          'libraryVersion': libraryVersion,
          'schemaVersion': '${LibraryDatabase.currentSchemaVersion}',
          'builtAt': builtAt,
          'sha256': sha256,
          'count': '${records.length}',
          'flowCount': '${flows.length}',
          'motionCount': '$motionCount',
        });
      });
      await db.customStatement('VACUUM');
    } finally {
      await db.close();
    }
    for (final String suffix in <String>['-journal', '-wal', '-shm']) {
      final File f = File('${output.path}$suffix');
      if (f.existsSync()) f.deleteSync();
    }
    return LibraryBuildReport(
      exerciseCount: records.length,
      flowCount: flows.length,
      countsByCategory: counts,
      warnings: warnings,
      motionCount: motionCount,
      averagePayloadBytes: motionCount > 0
          ? totalPayloadBytes / motionCount
          : 0.0,
    );
  }

  Map<String, Object?> _validate(Object? raw, int index) {
    if (raw is! Map<String, Object?>) {
      throw LibraryBuildError('record $index is not an object');
    }
    String where() => 'record $index (${raw['id']})';
    for (final String key in <String>[
      'id',
      'name',
      'category',
      'trackingType',
    ]) {
      final Object? v = raw[key];
      if (v is! String || v.trim().isEmpty) {
        throw LibraryBuildError(
          '${where()}: "$key" must be a non-empty string',
        );
      }
    }
    if (!RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(raw['id']! as String)) {
      throw LibraryBuildError('${where()}: id is not kebab-case');
    }
    for (final String key in _stringLists) {
      final Object? v = raw[key];
      if (v != null &&
          (v is! List<Object?> || v.any((Object? e) => e is! String))) {
        throw LibraryBuildError('${where()}: "$key" must be a list of strings');
      }
    }
    if (raw['unilateral'] != null && raw['unilateral'] is! bool) {
      throw LibraryBuildError('${where()}: "unilateral" must be a boolean');
    }
    if (raw['metValue'] != null && raw['metValue'] is! num) {
      throw LibraryBuildError('${where()}: "metValue" must be a number');
    }
    for (final String key in <String>['defaultRestSec', 'defaultHoldSec']) {
      if (raw[key] != null && raw[key] is! int) {
        throw LibraryBuildError('${where()}: "$key" must be an integer');
      }
    }
    return raw;
  }

  static List<String> _list(Object? v) =>
      v == null ? const <String>[] : (v as List<Object?>).cast<String>();

  Future<void> _insertExercise(
    LibraryDatabase db,
    Map<String, Object?> r,
  ) async {
    final String id = r['id']! as String;
    final String name = r['name']! as String;
    final List<String> aliases = _list(r['aliases']);
    final String? sanskrit = r['sanskritName'] as String?;
    final List<String> primary = _list(r['primaryMuscles']);
    final List<String> secondary = _list(r['secondaryMuscles']);
    final List<String> equipment = _list(r['equipment']);

    final int seq = await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: id,
            name: name,
            nameNorm: normalizeSearchText(name),
            aliases: aliases,
            sanskritName: Value<String?>(sanskrit),
            category: r['category']! as String,
            subcategory: Value<String?>(r['subcategory'] as String?),
            trackingType: r['trackingType']! as String,
            primaryMuscles: primary,
            secondaryMuscles: secondary,
            equipment: equipment,
            difficulty: Value<String?>(r['difficulty'] as String?),
            unilateral: (r['unilateral'] as bool?) ?? false,
            mechanic: Value<String?>(r['mechanic'] as String?),
            force: Value<String?>(r['force'] as String?),
            steps: _list(r['steps']),
            tips: _list(r['tips']),
            commonMistakes: _list(r['commonMistakes']),
            safetyNotes: _list(r['safetyNotes']),
            contraindications: _list(r['contraindications']),
            metValue: Value<double?>((r['metValue'] as num?)?.toDouble()),
            defaultRestSec: Value<int?>(r['defaultRestSec'] as int?),
            defaultHoldSec: Value<int?>(r['defaultHoldSec'] as int?),
            variationOf: Value<String?>(r['variationOf'] as String?),
            tags: _list(r['tags']),
            source: Value<String?>(r['source'] as String?),
            license: Value<String?>(r['license'] as String?),
          ),
        );

    final Set<String> seen = <String>{};
    for (final String m in primary) {
      if (seen.add(m)) {
        await db
            .into(db.exerciseMuscles)
            .insert(
              ExerciseMusclesCompanion.insert(
                exerciseId: id,
                muscle: m,
                role: 'primary',
              ),
            );
      }
    }
    for (final String m in secondary) {
      if (seen.add(m)) {
        await db
            .into(db.exerciseMuscles)
            .insert(
              ExerciseMusclesCompanion.insert(
                exerciseId: id,
                muscle: m,
                role: 'secondary',
              ),
            );
      }
    }
    for (final String e in equipment.toSet()) {
      await db
          .into(db.exerciseEquipment)
          .insert(
            ExerciseEquipmentCompanion.insert(exerciseId: id, equipment: e),
          );
    }

    // Both the camelCase and the spoken form of a muscle are indexed, so
    // "hipFlexors" and "hip flex" both find it. Primary muscles only:
    // secondary ones would drown a muscle search in compound lifts (use the
    // muscle filter with includeSecondaryMuscles for those).
    final String muscles = primary
        .map((String m) {
          final String spoken = humanizeCamel(m);
          return spoken == m.toLowerCase() ? m : '$m $spoken';
        })
        .join(' ');
    final String aliasText = <String>[
      ...aliases,
      if (sanskrit != null && sanskrit.isNotEmpty) sanskrit,
    ].join(' ');
    await db.customInsert(
      'INSERT INTO ${LibraryDatabase.ftsTable}(rowid, name, aliases, muscles) '
      'VALUES (?, ?, ?, ?)',
      variables: <Variable<Object>>[
        Variable<int>(seq),
        Variable<String>(name),
        Variable<String>(aliasText),
        Variable<String>(muscles),
      ],
    );
  }

  Future<void> _insertFlow(
    LibraryDatabase db,
    Object? raw,
    int index,
    Map<String, String> names,
    List<String> warnings,
    Map<String, int> seen,
  ) async {
    if (raw is! Map<String, Object?>) {
      throw LibraryBuildError('flow $index is not an object');
    }
    for (final String key in <String>['id', 'name', 'category']) {
      if (raw[key] is! String) {
        throw LibraryBuildError('flow $index: "$key" must be a string');
      }
    }
    final String id = raw['id']! as String;
    if (seen.containsKey(id)) {
      throw LibraryBuildError('duplicate flow id "$id"');
    }
    final Object? items = raw['items'];
    if (items is! List<Object?> || items.isEmpty) {
      throw LibraryBuildError('flow "$id" has no items');
    }
    seen[id] = items.length;
    await db
        .into(db.flows)
        .insert(
          FlowsCompanion.insert(
            id: id,
            name: raw['name']! as String,
            category: raw['category']! as String,
            difficulty: Value<String?>(raw['difficulty'] as String?),
            description: (raw['description'] as String?) ?? '',
            totalDurationSec: (raw['totalDurationSec'] as num?)?.toInt() ?? 0,
            rounds: (raw['rounds'] as num?)?.toInt() ?? 1,
            tags: _list(raw['tags']),
          ),
        );
    for (int i = 0; i < items.length; i++) {
      final Object? item = items[i];
      if (item is! Map<String, Object?> ||
          item['exerciseId'] is! String ||
          item['durationSec'] is! num) {
        throw LibraryBuildError('flow "$id" item $i is malformed');
      }
      final String poseId = item['exerciseId']! as String;
      if (!names.containsKey(poseId)) {
        warnings.add('flow "$id" item $i: unknown exercise "$poseId"');
      }
      await db
          .into(db.flowSteps)
          .insert(
            FlowStepsCompanion.insert(
              flowId: id,
              position: i,
              exerciseId: poseId,
              label: Value<String?>(names[poseId]),
              holdSec: (item['durationSec']! as num).toInt(),
              transitionSec: (item['transitionSec'] as num?)?.toInt() ?? 0,
              cue: Value<String?>(item['notes'] as String?),
            ),
          );
    }
  }

  Future<void> _insertMeta(LibraryDatabase db, Map<String, String> meta) async {
    for (final MapEntry<String, String> e in meta.entries) {
      await db
          .into(db.libraryMeta)
          .insert(LibraryMetaCompanion.insert(key: e.key, value: e.value));
    }
  }

  Map<String, Object?> _validateMotion(
    Object? raw,
    int index,
    Set<String> knownExercises,
  ) {
    if (raw is! Map<String, Object?>) {
      throw LibraryBuildError('motion record $index is not a JSON object');
    }
    final Object? id = raw['motionId'];
    if (id is! String || id.isEmpty) {
      throw LibraryBuildError(
        'motion record $index has missing or invalid motionId',
      );
    }
    if (raw['schemaVersion'] != 1) {
      throw LibraryBuildError('motion "$id" schemaVersion must be 1');
    }
    if (raw['rigVersion'] != 1) {
      throw LibraryBuildError('motion "$id" rigVersion must be 1');
    }
    final Object? tier = raw['tier'];
    if (tier is! String ||
        !const <String>{'animated', 'frames', 'mapOnly'}.contains(tier)) {
      throw LibraryBuildError('motion "$id" has invalid tier "$tier"');
    }
    final Object? view = raw['view'];
    if (view is! String ||
        !const <String>{'side', 'front', 'threeQuarter', 'top'}.contains(
          view,
        )) {
      throw LibraryBuildError('motion "$id" has invalid view "$view"');
    }
    final Object? keyframes = raw['keyframes'];
    if (keyframes is! List<Object?> || keyframes.isEmpty) {
      throw LibraryBuildError('motion "$id" must have at least one keyframe');
    }
    final Object? highlight = raw['highlight'];
    if (highlight is Map<String, Object?>) {
      final Object? primary = highlight['primary'];
      if (primary is List<Object?>) {
        for (final Object? m in primary) {
          if (m is! String || !_knownMuscles.contains(m)) {
            throw LibraryBuildError(
              'unknown primary muscle "$m" in motion "$id"',
            );
          }
        }
      }
      final Object? secondary = highlight['secondary'];
      if (secondary is List<Object?>) {
        for (final Object? m in secondary) {
          if (m is! String || !_knownMuscles.contains(m)) {
            throw LibraryBuildError(
              'unknown secondary muscle "$m" in motion "$id"',
            );
          }
        }
      }
    }
    return raw;
  }
}
