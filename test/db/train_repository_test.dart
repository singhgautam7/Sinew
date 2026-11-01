import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/routine_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/training.dart';

import '../helpers/test_db.dart';

WorkoutSession _session(
  String id,
  DateTime start, {
  DateTime? end,
  List<(String, List<(double, int, {bool pr})>)> exercises =
      const <(String, List<(double, int, {bool pr})>)>[],
}) => WorkoutSession(
  id: id,
  name: 'S $id',
  startedAt: start,
  endedAt: end ?? start.add(const Duration(minutes: 40)),
  durationSec: 2400,
  updatedAt: start,
  exercises: <SessionExercise>[
    for (int i = 0; i < exercises.length; i++)
      SessionExercise(
        id: 'e-$id-$i',
        exerciseId: exercises[i].$1,
        position: i,
        sets: <SetEntry>[
          for (int j = 0; j < exercises[i].$2.length; j++)
            SetEntry(
              id: 's-$id-$i-$j',
              position: j,
              weightKg: exercises[i].$2[j].$1,
              reps: exercises[i].$2[j].$2,
              completed: true,
              isPR: exercises[i].$2[j].pr,
            ),
        ],
      ),
  ],
);

void main() {
  late UserDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = memoryUserDb();
    repo = SessionRepository(db, clock: steppingClock());
  });
  tearDown(() => db.close());

  group('per-exercise reads', () {
    setUp(() async {
      await repo.saveTree(
        _session(
          'a',
          DateTime(2026, 1, 1),
          exercises: <(String, List<(double, int, {bool pr})>)>[
            ('bench', <(double, int, {bool pr})>[(60, 8, pr: false)]),
            ('row', <(double, int, {bool pr})>[(40, 8, pr: false)]),
          ],
        ),
      );
      await repo.saveTree(
        _session(
          'b',
          DateTime(2026, 1, 8),
          exercises: <(String, List<(double, int, {bool pr})>)>[
            (
              'bench',
              <(double, int, {bool pr})>[(65, 8, pr: true), (65, 6, pr: false)],
            ),
          ],
        ),
      );
      await repo.start(name: 'running'); // active: never in history
    });

    test(
      'sessionsForExercise returns only that exercise, oldest first',
      () async {
        final List<WorkoutSession> bench = await repo.sessionsForExercise(
          'bench',
        );
        expect(bench.map((WorkoutSession s) => s.id), <String>['a', 'b']);
        expect(
          bench.first.exercises.map((SessionExercise e) => e.exerciseId),
          <String>['bench'],
        );
        expect(bench.last.exercises.single.sets, hasLength(2));
        expect(await repo.sessionsForExercise('row'), hasLength(1));
        expect(await repo.sessionsForExercise('nothing'), isEmpty);
      },
    );

    test('excludeSessionId and finishedOnly are honoured', () async {
      expect(
        (await repo.sessionsForExercise(
          'bench',
          excludeSessionId: 'a',
        )).single.id,
        'b',
      );
      final WorkoutSession active = (await repo.active())!;
      await repo.addExercise(active.id, 'bench');
      expect(await repo.sessionsForExercise('bench'), hasLength(2));
      expect(
        await repo.sessionsForExercise('bench', finishedOnly: false),
        hasLength(3),
      );
    });

    test('sessionHeaders lists dates and exercise ids without sets', () async {
      final List<SessionHeader> all = await repo.sessionHeaders();
      expect(all.map((SessionHeader h) => h.id), <String>['a', 'b']);
      expect(all.first.exerciseIds, <String>['bench', 'row']);
      final List<SessionHeader> jan = await repo.sessionHeaders(
        from: DateTime(2026, 1, 5),
        to: DateTime(2026, 2),
      );
      expect(jan.single.id, 'b');
      expect(jan.single.durationSec, 2400);
    });

    test('prCounts and completedSetCounts aggregate in SQL', () async {
      expect(await repo.prCounts(<String>['a', 'b']), <String, int>{'b': 1});
      expect(await repo.prCounts(const <String>[]), isEmpty);
      final Map<String, int> week = await repo.completedSetCounts(
        from: DateTime(2026, 1, 5),
        to: DateTime(2026, 1, 12),
      );
      expect(week, <String, int>{'bench': 2});
    });
  });

  group('writes', () {
    test('setPrFlags changes only is_pr and leaves updatedAt alone', () async {
      final WorkoutSession s = _session(
        'a',
        DateTime(2026, 1, 1),
        exercises: <(String, List<(double, int, {bool pr})>)>[
          (
            'bench',
            <(double, int, {bool pr})>[(60, 8, pr: false), (62, 8, pr: true)],
          ),
        ],
      );
      await repo.saveTree(s);
      await repo.setPrFlags(<String, bool>{'s-a-0-0': true, 's-a-0-1': false});
      final WorkoutSession back = (await repo.byId('a'))!;
      expect(back.exercises.single.sets.map((SetEntry x) => x.isPR), <bool>[
        true,
        false,
      ]);
      expect(back.exercises.single.sets.first.weightKg, 60);
      expect(back.updatedAt, s.updatedAt);
    });

    test(
      'finishWithFlags stores the tree and other sessions flags together',
      () async {
        await repo.saveTree(
          _session(
            'old',
            DateTime(2026, 1, 1),
            exercises: <(String, List<(double, int, {bool pr})>)>[
              ('bench', <(double, int, {bool pr})>[(60, 8, pr: true)]),
            ],
          ),
        );
        final WorkoutSession run = await repo.start(name: 'now');
        expect(await repo.active(), isNotNull);
        final WorkoutSession finished = _session(
          run.id,
          run.startedAt,
          exercises: <(String, List<(double, int, {bool pr})>)>[
            ('bench', <(double, int, {bool pr})>[(70, 8, pr: true)]),
          ],
        ).copyWith(volumeKg: 560);
        await repo.finishWithFlags(
          finished,
          prChanges: <String, bool>{'s-old-0-0': false},
        );
        expect(await repo.active(), isNull);
        final WorkoutSession done = (await repo.byId(run.id))!;
        expect(done.endedAt, isNotNull);
        expect(done.volumeKg, 560);
        expect(done.exercises.single.sets.single.isPR, isTrue);
        expect(
          (await repo.byId('old'))!.exercises.single.sets.single.isPR,
          isFalse,
        );
      },
    );

    test('start with exercises is all or nothing', () async {
      await repo.start(name: 'first');
      await expectLater(
        repo.start(
          name: 'second',
          exercises: <SessionExercise>[
            const SessionExercise(
              id: 'x',
              exerciseId: 'bench',
              position: 0,
              sets: <SetEntry>[SetEntry(id: 'xs', position: 0)],
            ),
          ],
        ),
        throwsA(isA<ActiveSessionExists>()),
      );
      expect((await repo.sessionHeaders(finishedOnly: false)), hasLength(1));
      expect((await repo.active())!.exercises, isEmpty);
    });

    test('start with exercises writes the whole tree at once', () async {
      final WorkoutSession s = await repo.start(
        name: 'from routine',
        source: SessionSource.routine,
        exercises: <SessionExercise>[
          const SessionExercise(
            id: 'x',
            exerciseId: 'bench',
            position: 0,
            sets: <SetEntry>[
              SetEntry(id: 'x0', position: 0, reps: 8),
              SetEntry(id: 'x1', position: 1, reps: 8),
            ],
          ),
        ],
      );
      final WorkoutSession back = (await repo.byId(s.id))!;
      expect(back.exercises.single.sets, hasLength(2));
    });

    test('upsertSets and deleteSetWith run as one transaction each', () async {
      final WorkoutSession s = await repo.start(name: 'w');
      await repo.addExercise(s.id, 'bench');
      final SessionExercise e = (await repo.byId(s.id))!.exercises.single;
      await repo.upsertSets(s.id, <(String, SetEntry)>[
        (e.id, const SetEntry(id: 'a', position: 0, reps: 5)),
        (e.id, const SetEntry(id: 'b', position: 1, reps: 6)),
      ]);
      await repo.deleteSetWith(s.id, 'a', <(String, SetEntry)>[
        (e.id, const SetEntry(id: 'b', position: 0, reps: 6)),
      ]);
      final List<SetEntry> sets = (await repo.byId(s.id))!
          .exercises
          .single
          .sets;
      expect(sets.single.id, 'b');
      expect(sets.single.position, 0);
    });

    test('updateSummary clears a blank note and keeps the effort', () async {
      await repo.saveTree(_session('a', DateTime(2026, 1, 1)));
      await repo.updateSummary('a', perceivedEffort: 7, notes: 'felt good');
      WorkoutSession s = (await repo.byId('a'))!;
      expect(s.notes, 'felt good');
      expect(s.perceivedEffort, 7);
      await repo.updateSummary('a', perceivedEffort: 7, notes: '  ');
      s = (await repo.byId('a'))!;
      expect(s.notes, isNull);
      expect(s.perceivedEffort, 7);
      expect(s.durationSec, 2400);
    });

    test('finish stores a blank note as null', () async {
      final WorkoutSession s = await repo.start(name: 'w');
      await repo.finish(s.id, endedAt: DateTime(2026, 1, 2), notes: '   ');
      expect((await repo.byId(s.id))!.notes, isNull);
    });
  });

  group('RoutineRepository', () {
    test('nextPosition follows the last routine; saveMany is atomic', () async {
      final RoutineRepository routines = RoutineRepository(
        db,
        clock: steppingClock(),
      );
      expect(await routines.nextPosition(), 0);
      Routine r(String id, int pos) => Routine(
        id: id,
        name: id,
        position: pos,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      await routines.saveMany(<Routine>[r('a', 0), r('b', 1)]);
      expect(await routines.nextPosition(), 2);
      expect(await routines.allWithItems(), hasLength(2));
    });
  });
}
