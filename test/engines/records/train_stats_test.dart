import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/engines/records/records.dart';
import 'package:sinew/engines/records/train_stats.dart';

SetEntry _set(String id, double kg, int reps, {bool pr = false}) => SetEntry(
  id: id,
  position: 0,
  weightKg: kg,
  reps: reps,
  completed: true,
  isPR: pr,
);

WorkoutSession _s(String id, DateTime at, List<SetEntry> sets) =>
    WorkoutSession(
      id: id,
      startedAt: at,
      endedAt: at.add(const Duration(hours: 1)),
      updatedAt: at,
      exercises: <SessionExercise>[
        SessionExercise(
          id: 'e$id',
          exerciseId: 'bench',
          position: 0,
          sets: sets,
        ),
      ],
    );

void main() {
  group('estimateRoutineMinutes', () {
    RoutineItem item(int sets, {int? rest}) => RoutineItem(
      id: 'i$sets',
      exerciseId: 'x',
      position: 0,
      targetSets: sets,
      restSec: rest,
    );

    test('is zero for nothing and at least 5', () {
      expect(estimateRoutineMinutes(const <RoutineItem>[]), 0);
      expect(estimateRoutineMinutes(<RoutineItem>[item(1, rest: 10)]), 5);
    });

    test('uses the default rest where an item has none', () {
      final List<RoutineItem> items = <RoutineItem>[
        item(10),
        item(10, rest: 60),
      ];
      // 10 x (40 + 90) + 10 x (40 + 60) = 2300 s, about 38 min -> 40.
      expect(estimateRoutineMinutes(items), 40);
      // 10 x (40 + 180) + 1000 = 3200 s, about 53 min -> 55.
      expect(estimateRoutineMinutes(items, defaultRestSec: 180), 55);
    });
  });

  group('record gains', () {
    test('prDetails gives the estimate and the gain over the old best', () {
      final WorkoutSession old = _s('o', DateTime(2026, 1, 1), <SetEntry>[
        _set('o1', 60, 8),
      ]);
      final WorkoutSession now = _s('n', DateTime(2026, 1, 8), <SetEntry>[
        _set('n1', 70, 8, pr: true),
        _set('n2', 50, 8),
      ]);
      final List<PrDetail> prs = prDetails(
        now,
        Records.computeRecords(<WorkoutSession>[old]),
      );
      expect(prs, hasLength(1));
      expect(prs.single.set.id, 'n1');
      expect(prs.single.e1rmKg, closeTo(70 * (1 + 8 / 30), 1e-9));
      expect(
        prs.single.e1rmDeltaKg,
        closeTo(70 * (1 + 8 / 30) - 60 * (1 + 8 / 30), 1e-9),
      );
    });

    test('no earlier estimate means no gain', () {
      final WorkoutSession now = _s('n', DateTime(2026, 1, 8), <SetEntry>[
        _set('n1', 70, 8, pr: true),
      ]);
      expect(
        prDetails(
          now,
          Records.computeRecords(const <WorkoutSession>[]),
        ).single.e1rmDeltaKg,
        isNull,
      );
    });

    test('prFlagChanges lists only the flags that differ', () {
      final List<WorkoutSession> all = <WorkoutSession>[
        _s('a', DateTime(2026, 1, 1), <SetEntry>[_set('a1', 60, 8, pr: true)]),
        _s('b', DateTime(2026, 1, 8), <SetEntry>[_set('b1', 70, 8)]),
      ];
      // a1 is the first ever set (not a PR, stale flag); b1 beats it.
      expect(prFlagChanges(all), <String, bool>{'a1': false, 'b1': true});
    });
  });

  group('history calendar', () {
    test('sessionsPerDay groups by local day; heat steps cap at four', () {
      final Map<DateTime, int> days = sessionsPerDay(<DateTime>[
        DateTime(2026, 3, 4, 8),
        DateTime(2026, 3, 4, 19),
        DateTime(2026, 3, 5, 7),
      ]);
      expect(days[DateTime(2026, 3, 4)], 2);
      expect(days[DateTime(2026, 3, 5)], 1);
      expect(heatLevel(0), 0);
      expect(heatLevel(2), 2);
      expect(heatLevel(9), 4);
    });

    test('monthGrid is Monday first with null padding', () {
      final List<List<DateTime?>> grid = monthGrid(DateTime(2026, 10));
      // 1 Oct 2026 is a Thursday.
      expect(grid.first.take(3), everyElement(isNull));
      expect(grid.first[3], DateTime(2026, 10));
      expect(grid.every((List<DateTime?> w) => w.length == 7), isTrue);
      expect(
        grid.expand((List<DateTime?> w) => w).whereType<DateTime>(),
        hasLength(31),
      );
    });
  });

  group('weekly muscles', () {
    test(
      'primary counts fully, secondary by half; heat is scaled to the top',
      () {
        final Map<String, double> load = muscleLoad(
          <String, int>{'bench': 4, 'row': 2},
          <String, ({List<String> primary, List<String> secondary})>{
            'bench': (
              primary: <String>['chest'],
              secondary: <String>['triceps'],
            ),
            'row': (primary: <String>['lats'], secondary: <String>['biceps']),
          },
        );
        expect(load, <String, double>{
          'chest': 4,
          'triceps': 2,
          'lats': 2,
          'biceps': 1,
        });
        expect(muscleHeat(load), <String, double>{
          'chest': 1,
          'triceps': 0.5,
          'lats': 0.5,
          'biceps': 0.25,
        });
        expect(topMuscles(load), <String>['chest', 'lats']);
        expect(muscleHeat(const <String, double>{}), isEmpty);
      },
    );

    test('untrainedMuscles names watched muscles with no load', () {
      expect(untrainedMuscles(<String, double>{'forearms': 1}), <String>[
        'calves',
        'glutes',
      ]);
    });
  });
}
