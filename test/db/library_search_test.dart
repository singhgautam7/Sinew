import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/library/library_builder.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/db/library/search_text.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/repositories/exercise_search_service.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';

import '../helpers/test_db.dart';
import '../helpers/test_library.dart';

List<String> _ids(List<ExerciseSummary> l) =>
    l.map((ExerciseSummary s) => s.id).toList();

void main() {
  group('search text', () {
    test('normalises case, diacritics and punctuation', () {
      expect(
        normalizeSearchText('Cat-Cow (Marjaryasana)'),
        'cat cow marjaryasana',
      );
      expect(normalizeSearchText('  Crème   Brûlée '), 'creme brulee');
      expect(normalizeSearchText('45° side bend'), '45 side bend');
      expect(normalizeSearchText('---'), '');
      expect(humanizeCamel('hipFlexors'), 'hip flexors');
      expect(humanizeCamel('core'), 'core');
    });

    test(
      'FTS query: quoted prefix tokens, quotes escaped, empties dropped',
      () {
        expect(ftsMatchQuery('hip flex'), '"hip"* "flex"*');
        expect(ftsMatchQuery('  '), isNull);
        expect(ftsMatchQuery('"; DROP'), '"drop"*');
        expect(ftsMatchQuery('t-bar'), '"t"* "bar"*');
      },
    );
  });

  group('LibraryRepository search (small library)', () {
    late Directory dir;
    late LibraryDatabase db;
    late LibraryRepository repo;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('sinew_search');
      final File file = await buildTestLibrary(
        dir,
        exercises: <Map<String, Object?>>[
          exerciseJson(
            'bench-press',
            'Bench Press',
            primary: <String>['chest'],
            secondary: <String>['triceps'],
          ),
          exerciseJson('bench', 'Bench', primary: <String>['chest']),
          exerciseJson(
            'incline-bench-press',
            'Incline Bench Press',
            primary: <String>['chest'],
            equipment: <String>['barbell', 'inclineBench'],
            difficulty: 'advanced',
          ),
          exerciseJson(
            'benchmark-run',
            'Benchmark Run',
            category: 'cardio',
            trackingType: 'distanceTime',
            primary: <String>['quadriceps'],
            equipment: <String>['bodyweight'],
            difficulty: 'beginner',
          ),
          exerciseJson(
            'hip-flexor-stretch',
            'Kneeling Hip Flexor Stretch',
            category: 'mobility',
            trackingType: 'hold',
            primary: <String>['hipFlexors'],
            equipment: <String>['yogaMat'],
            difficulty: 'beginner',
          ),
          exerciseJson(
            'pushup',
            'Push-Up',
            category: 'calisthenics',
            trackingType: 'reps',
            primary: <String>['chest'],
            secondary: <String>['triceps', 'core'],
            equipment: <String>['bodyweight'],
            aliases: <String>['Press up'],
            difficulty: 'beginner',
          ),
          exerciseJson(
            'tree-pose',
            'Tree Pose',
            category: 'yoga',
            trackingType: 'hold',
            primary: <String>['glutes'],
            equipment: <String>['yogaMat'],
            sanskritName: 'Vrikshasana',
            difficulty: 'beginner',
          ),
          exerciseJson('creme', 'Crème Squat', primary: <String>['quadriceps']),
        ],
        flows: <Object?>[
          <String, Object?>{
            'id': 'sun',
            'name': 'Sun Flow',
            'category': 'yoga',
            'difficulty': 'beginner',
            'description': 'Warm up',
            'totalDurationSec': 60,
            'rounds': 2,
            'items': <Object?>[
              <String, Object?>{
                'exerciseId': 'tree-pose',
                'durationSec': 20,
                'transitionSec': 3,
                'notes': 'Breathe',
              },
              <String, Object?>{
                'exerciseId': 'gone-pose',
                'durationSec': 10,
                'transitionSec': 0,
                'notes': null,
              },
            ],
            'tags': <String>['yoga'],
          },
        ],
      );
      db = openLibrary(file);
      repo = LibraryRepository(db);
    });

    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    test('ranking: exact name, name prefix, then the rest', () async {
      final List<ExerciseSummary> hits = await repo.search(query: 'bench');
      expect(_ids(hits).take(2), <String>['bench', 'bench-press']);
      expect(
        hits.map((ExerciseSummary s) => s.id),
        containsAll(<String>['incline-bench-press', 'benchmark-run']),
      );
      // Prefix matches before the infix one.
      expect(
        _ids(hits).indexOf('incline-bench-press'),
        greaterThan(_ids(hits).indexOf('benchmark-run')),
      );
    });

    test(
      'every word must match, as a prefix; muscles and aliases are searched',
      () async {
        expect(_ids(await repo.search(query: 'hip flex')), <String>[
          'hip-flexor-stretch',
        ]);
        expect(_ids(await repo.search(query: 'hipflex')), <String>[
          'hip-flexor-stretch',
        ]);
        expect(_ids(await repo.search(query: 'press up')), contains('pushup'));
        expect(_ids(await repo.search(query: 'vriksha')), <String>[
          'tree-pose',
        ]);
        expect(_ids(await repo.search(query: 'creme')), <String>['creme']);
        expect(_ids(await repo.search(query: 'crème')), <String>['creme']);
        expect(await repo.search(query: 'zzz'), isEmpty);
      },
    );

    test('hostile input never throws', () async {
      for (final String q in <String>[
        '"',
        '""',
        'a" OR "b',
        '*',
        '(',
        'NEAR(',
        ' - ',
        "'; DROP TABLE exercises; --",
      ]) {
        await repo.search(query: q);
      }
      expect(await repo.count(), 8);
    });

    test('empty query: filters only, alphabetical', () async {
      final List<ExerciseSummary> all = await repo.search();
      expect(all.length, 8);
      expect(all.first.name, 'Bench');
      final List<String> names = all
          .map((ExerciseSummary s) => normalizeSearchText(s.name))
          .toList();
      expect(names, <String>[...names]..sort());
    });

    test('filters: AND across kinds, OR within a kind', () async {
      expect(
        _ids(
          await repo.search(
            filters: const LibraryFilters(
              categories: <String>{'yoga', 'mobility'},
            ),
          ),
        ),
        <String>['hip-flexor-stretch', 'tree-pose'],
      );
      expect(
        _ids(
          await repo.search(
            filters: const LibraryFilters(
              categories: <String>{'strength'},
              difficulties: <Difficulty>{Difficulty.advanced},
            ),
          ),
        ),
        <String>['incline-bench-press'],
      );
      expect(
        _ids(
          await repo.search(
            filters: const LibraryFilters(
              trackingTypes: <TrackingType>{
                TrackingType.hold,
                TrackingType.reps,
              },
            ),
          ),
        ),
        <String>['hip-flexor-stretch', 'pushup', 'tree-pose'],
      );
      expect(
        _ids(
          await repo.search(
            filters: const LibraryFilters(equipment: <String>{'inclineBench'}),
          ),
        ),
        <String>['incline-bench-press'],
      );
      expect(
        _ids(
          await repo.search(
            query: 'press',
            filters: const LibraryFilters(
              categories: <String>{'strength'},
              equipment: <String>{'barbell'},
            ),
          ),
        ),
        <String>['bench-press', 'incline-bench-press'],
      );
    });

    test('muscle filter: primary only unless secondary is included', () async {
      const LibraryFilters tri = LibraryFilters(muscles: <String>{'triceps'});
      expect(await repo.search(filters: tri), isEmpty);
      expect(
        _ids(
          await repo.search(
            filters: tri.copyWith(includeSecondaryMuscles: true),
          ),
        ),
        <String>['bench-press', 'pushup'],
      );
      expect(
        _ids(
          await repo.search(
            filters: const LibraryFilters(
              muscles: <String>{'glutes', 'hipFlexors'},
            ),
          ),
        ),
        <String>['hip-flexor-stretch', 'tree-pose'],
      );
    });

    test('count agrees with search; paging is stable', () async {
      expect(await repo.count(), 8);
      expect(await repo.count(query: 'bench'), 4);
      expect(
        await repo.count(
          query: 'bench',
          filters: const LibraryFilters(categories: <String>{'cardio'}),
        ),
        1,
      );
      final List<String> all = _ids(await repo.search(query: 'bench'));
      final List<String> paged = <String>[
        ..._ids(await repo.search(query: 'bench', limit: 3)),
        ..._ids(await repo.search(query: 'bench', limit: 3, offset: 3)),
      ];
      expect(paged, all);
    });

    test('summaries are light but complete', () async {
      final ExerciseSummary s = (await repo.search(query: 'push up')).single;
      expect(s.id, 'pushup');
      expect(s.category, 'calisthenics');
      expect(s.trackingType, TrackingType.reps);
      expect(s.primaryMuscles, <String>['chest']);
      expect(s.equipment, <String>['bodyweight']);
      expect(s.difficulty, Difficulty.beginner);
      expect(s.unilateral, isFalse);
    });

    test('category counts and flows', () async {
      expect(await repo.categoryCounts(), <String, int>{
        'calisthenics': 1,
        'cardio': 1,
        'mobility': 1,
        'strength': 4,
        'yoga': 1,
      });
      final List<Flow> flows = await repo.flows();
      expect(flows.single.name, 'Sun Flow');
      expect(flows.single.steps, isEmpty);
      final Flow flow = (await repo.flowById('sun'))!;
      expect(flow.difficulty, Difficulty.beginner);
      expect(flow.steps.length, 2);
      expect(flow.steps[0].label, 'Tree Pose');
      expect(flow.steps[0].holdSec, 20);
      expect(flow.steps[0].cue, 'Breathe');
      expect(flow.steps[1].label, isNull, reason: 'unknown pose has no label');
      expect(await repo.flowById('nope'), isNull);
      expect((await repo.flows(category: 'mobility')), isEmpty);
    });

    test('merged search: custom first, deduped, filters and paging', () async {
      final UserDatabase user = memoryUserDb();
      addTearDown(user.close);
      final CustomExerciseRepository custom = CustomExerciseRepository(user);
      final Exercise mine = await custom.save(
        const Exercise(
          id: '',
          name: 'My bench variation',
          category: 'strength',
          trackingType: TrackingType.weightReps,
          aliases: <String>['Garage press'],
          primaryMuscles: <String>['chest'],
          difficulty: Difficulty.intermediate,
        ),
      );
      final Exercise yoga = await custom.save(
        const Exercise(
          id: '',
          name: 'My pose',
          category: 'yoga',
          trackingType: TrackingType.hold,
        ),
      );
      final ExerciseSearchService svc = ExerciseSearchService(
        library: repo,
        custom: custom,
      );

      final List<ExerciseSummary> hits = await svc.search(query: 'bench');
      expect(hits.first.id, mine.id);
      expect(hits.first.isCustom, isTrue);
      expect(_ids(hits).skip(1), _ids(await repo.search(query: 'bench')));
      expect(_ids(await svc.search(query: 'garage')), <String>[mine.id]);
      expect(
        _ids(
          await svc.search(
            filters: const LibraryFilters(categories: <String>{'yoga'}),
          ),
        ).first,
        yoga.id,
      );
      expect(await svc.count(query: 'bench'), 5);

      final List<String> all = _ids(await svc.search(query: 'bench'));
      final List<String> paged = <String>[
        ..._ids(await svc.search(query: 'bench', limit: 2)),
        ..._ids(await svc.search(query: 'bench', limit: 2, offset: 2)),
        ..._ids(await svc.search(query: 'bench', limit: 2, offset: 4)),
      ];
      expect(paged, all);

      await custom.setArchived(mine.id, archived: true);
      expect(_ids(await svc.search(query: 'garage')), isEmpty);
    });
  });

  group('library build', () {
    test('same inputs give identical bytes', () async {
      final Directory dir = await Directory.systemTemp.createTemp('sinew_det');
      addTearDown(() => dir.delete(recursive: true));
      final List<Map<String, Object?>> data = <Map<String, Object?>>[
        exerciseJson('a', 'Alpha'),
        exerciseJson('b', 'Beta', aliases: <String>['B']),
      ];
      final File one = await buildTestLibrary(
        dir,
        fileName: 'one.sqlite',
        exercises: data,
      );
      final File two = await buildTestLibrary(
        dir,
        fileName: 'two.sqlite',
        exercises: data,
      );
      expect(await two.readAsBytes(), await one.readAsBytes());
    });

    test('invalid records fail the build with a clear error', () async {
      final Directory dir = await Directory.systemTemp.createTemp('sinew_bad');
      addTearDown(() => dir.delete(recursive: true));
      Future<void> expectBad(List<Object?> records, Pattern message) =>
          expectLater(
            buildTestLibrary(
              dir,
              exercises: records.cast<Map<String, Object?>>(),
            ),
            throwsA(
              isA<LibraryBuildError>().having(
                (LibraryBuildError e) => e.message,
                'message',
                contains(message),
              ),
            ),
          );
      await expectBad(<Object?>[
        exerciseJson('a', 'A'),
        exerciseJson('a', 'B'),
      ], 'duplicate');
      await expectBad(<Object?>[exerciseJson('Bad Id', 'A')], 'kebab');
      await expectBad(<Object?>[
        (exerciseJson('a', 'A')..['name'] = ''),
      ], 'name');
      await expectBad(<Object?>[
        (exerciseJson('a', 'A')..['primaryMuscles'] = 'chest'),
      ], 'primaryMuscles');
    });
  });

  group('real library asset', () {
    final File asset = File('assets/db/library.sqlite');
    late Directory dir;
    late LibraryDatabase db;
    late LibraryRepository repo;

    setUpAll(() async {
      dir = await Directory.systemTemp.createTemp('sinew_real');
      final File copy = await asset.copy('${dir.path}/library.sqlite');
      db = openLibrary(copy);
      repo = LibraryRepository(db);
    });

    tearDownAll(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    test('is the 2,890 exercise library with 30 flows', () async {
      expect(await repo.count(), 2890);
      expect(await repo.libraryVersion(), '1.0.0');
      expect(await db.meta('count'), '2890');
      expect(await db.meta('schemaVersion'), '2');
      expect(await db.meta('sha256'), startsWith('72fd545e'));
      expect(
        (await repo.categoryCounts()).values.fold<int>(
          0,
          (int a, int b) => a + b,
        ),
        2890,
      );
      expect((await repo.flows()).length, 30);
      final Flow sun = (await repo.flowById('surya-namaskar-a'))!;
      expect(sun.steps.first.label, isNotNull);
    });

    final List<(String, String, LibraryFilters)> cases =
        <(String, String, LibraryFilters)>[
          ('ben', 'ben', const LibraryFilters()),
          ('squat', 'squat', const LibraryFilters()),
          ('hip flex', 'hip flex', const LibraryFilters()),
          ('romanian dead', 'romanian dead', const LibraryFilters()),
          (
            'query + filters',
            'press',
            const LibraryFilters(
              categories: <String>{'strength'},
              equipment: <String>{'dumbbell'},
              muscles: <String>{'chest'},
            ),
          ),
          (
            'filter: category',
            '',
            const LibraryFilters(categories: <String>{'yoga'}),
          ),
          (
            'filter: muscle',
            '',
            const LibraryFilters(muscles: <String>{'glutes'}),
          ),
          (
            'filter: muscle+secondary',
            '',
            const LibraryFilters(
              muscles: <String>{'glutes'},
              includeSecondaryMuscles: true,
            ),
          ),
          (
            'filter: equipment',
            '',
            const LibraryFilters(equipment: <String>{'kettlebell'}),
          ),
          (
            'filter: combined',
            '',
            const LibraryFilters(
              categories: <String>{'strength', 'calisthenics'},
              difficulties: <Difficulty>{Difficulty.beginner},
              trackingTypes: <TrackingType>{TrackingType.reps},
              equipment: <String>{'bodyweight'},
            ),
          ),
          ('nothing', '', const LibraryFilters()),
        ];

    test('typical searches run under 50 ms', () async {
      final List<String> report = <String>[];
      for (final (String label, String q, LibraryFilters f) in cases) {
        // Warm-up.
        await repo.search(query: q, filters: f);
        await repo.count(query: q, filters: f);
        const int runs = 20;
        final Stopwatch sw = Stopwatch()..start();
        List<ExerciseSummary> hits = const <ExerciseSummary>[];
        for (int i = 0; i < runs; i++) {
          hits = await repo.search(query: q, filters: f);
        }
        final double searchMs = sw.elapsedMicroseconds / runs / 1000;
        sw
          ..reset()
          ..start();
        final int n = await repo.count(query: q, filters: f);
        final double countMs = sw.elapsedMicroseconds / 1000;
        report.add(
          '${label.padRight(26)} search ${searchMs.toStringAsFixed(2)} ms  count ${countMs.toStringAsFixed(2)} ms  ($n matches, ${hits.length} returned)',
        );
        expect(searchMs, lessThan(50), reason: label);
        expect(countMs, lessThan(50), reason: '$label count');
      }
      // ignore: avoid_print
      print(report.join('\n'));
    });

    test('searches return what a person expects', () async {
      expect(
        (await repo.search(query: 'ben')).first.name.toLowerCase(),
        startsWith('ben'),
      );
      expect(
        (await repo.search(query: 'squat')).first.name.toLowerCase(),
        contains('squat'),
      );
      final List<ExerciseSummary> hip = await repo.search(query: 'hip flex');
      expect(hip, isNotEmpty);
      expect(
        hip.first.primaryMuscles.contains('hipFlexors') ||
            hip.first.name.toLowerCase().contains('hip flex'),
        isTrue,
      );
      expect(
        await repo.count(
          filters: const LibraryFilters(categories: <String>{'yoga'}),
        ),
        300,
      );
    });

    test('every query plan is index-backed', () async {
      final List<(String, LibraryFilters)> plans = <(String, LibraryFilters)>[
        for (final (String _, String q, LibraryFilters f) in cases) (q, f),
      ];
      for (final (String q, LibraryFilters f) in plans) {
        final List<String> plan = await repo.explainSearch(
          query: q,
          filters: f,
        );
        for (final String step in plan) {
          final bool scan = step.startsWith('SCAN');
          final bool ok =
              !scan ||
              step.contains('USING INDEX') ||
              step.contains('USING COVERING INDEX') ||
              step.contains('VIRTUAL TABLE INDEX');
          expect(
            ok,
            isTrue,
            reason:
                'query "$q" $f has an unindexed step: $step\n${plan.join('\n')}',
          );
        }
      }
    });
  });
}
