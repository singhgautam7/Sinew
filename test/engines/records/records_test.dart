import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/engines/records/records.dart';

SetEntry _set(
  String id, {
  int position = 0,
  double? kg,
  int? reps,
  int? hold,
  double? dist,
  int? dur,
  bool completed = true,
  bool warmup = false,
}) => SetEntry(
  id: id,
  position: position,
  weightKg: kg,
  reps: reps,
  holdSec: hold,
  distanceM: dist,
  durationSec: dur,
  completed: completed,
  isWarmup: warmup,
);

WorkoutSession _session(String id, int day, List<SessionExercise> exercises) =>
    WorkoutSession(
      id: id,
      startedAt: DateTime(2026, 1, day),
      updatedAt: DateTime(2026, 1, day),
      exercises: exercises,
    );

SessionExercise _ex(
  String exerciseId,
  List<SetEntry> sets, {
  int position = 0,
}) => SessionExercise(
  id: '$exerciseId-$position',
  exerciseId: exerciseId,
  position: position,
  sets: sets,
);

void main() {
  group('epley1rm', () {
    test('formula, one rep and boundaries', () {
      // 100 * (1 + 5/30) = 116.667
      expect(Records.epley1rm(100, 5), closeTo(116.667, 0.001));
      expect(Records.epley1rm(100, 1), 100);
      // 10 reps is the last allowed: 100 * (1 + 10/30) = 133.333
      expect(Records.epley1rm(100, 10), closeTo(133.333, 0.001));
      expect(Records.epley1rm(100, 11), isNull);
      expect(Records.epley1rm(100, 0), isNull);
      expect(Records.epley1rm(100, -3), isNull);
      expect(Records.epley1rm(0, 5), isNull);
    });
  });

  group('sessionVolumeKg', () {
    test('sums weight x reps of counted sets over all exercises', () {
      final WorkoutSession s = _session('s1', 1, <SessionExercise>[
        _ex('bench', <SetEntry>[
          _set('a', kg: 100, reps: 5), // 500
          _set('b', position: 1, kg: 100, reps: 3), // 300
          _set('w', position: 2, kg: 40, reps: 10, warmup: true),
          _set('x', position: 3, kg: 100, reps: 8, completed: false),
        ]),
        _ex('squat', <SetEntry>[
          _set('c', kg: 60, reps: 10), // 600
          _set('d', position: 1, reps: 20), // bodyweight: no volume
        ], position: 1),
      ]);
      expect(Records.sessionVolumeKg(s), 1400);
    });
  });

  group('record types', () {
    final List<WorkoutSession> history = <WorkoutSession>[
      _session('s1', 1, <SessionExercise>[
        _ex('bench', <SetEntry>[
          _set('b1', kg: 80, reps: 8),
          _set('b2', position: 1, kg: 100, reps: 5),
          _set('b3', position: 2, kg: 100, reps: 3),
        ]),
        _ex('plank', <SetEntry>[_set('p1', hold: 45)], position: 1),
        _ex('run', <SetEntry>[_set('r1', dist: 5000, dur: 1500)], position: 2),
      ]),
      _session('s2', 5, <SessionExercise>[
        _ex('bench', <SetEntry>[
          _set('b4', kg: 100, reps: 6),
          _set('b5', position: 1, kg: 105, reps: 1),
        ]),
        _ex('plank', <SetEntry>[_set('p2', hold: 60)], position: 1),
        _ex('run', <SetEntry>[_set('r2', dist: 4000, dur: 2000)], position: 2),
      ]),
    ];
    final RecordBook book = Records.computeRecords(history);

    test('heaviest weight with set id and date', () {
      final RecordEntry r = book['bench']!.heaviestWeight!;
      expect(r.value, 105);
      expect(r.setId, 'b5');
      expect(r.sessionId, 's2');
      expect(r.date, DateTime(2026, 1, 5));
    });

    test('most reps at each weight', () {
      final Map<double, RecordEntry> m = book['bench']!.repsAtWeight;
      expect(m[80]!.value, 8);
      expect(m[100]!.value, 6);
      expect(m[100]!.setId, 'b4');
      expect(m[105]!.value, 1);
      expect(m.length, 3);
    });

    test('best e1RM', () {
      // 80x8 = 101.33, 100x5 = 116.67, 100x6 = 120, 105x1 = 105.
      final RecordEntry r = book['bench']!.bestE1rm!;
      expect(r.value, closeTo(120, 1e-9));
      expect(r.setId, 'b4');
    });

    test('most volume in one session', () {
      // s1: 640 + 500 + 300 = 1440; s2: 600 + 105 = 705.
      final RecordEntry r = book['bench']!.mostVolumeInSession!;
      expect(r.value, 1440);
      expect(r.sessionId, 's1');
      expect(r.setId, isNull);
    });

    test('longest hold, distance and duration', () {
      expect(book['plank']!.longestHold!.value, 60);
      expect(book['plank']!.longestHold!.setId, 'p2');
      expect(book['run']!.longestDistance!.value, 5000);
      expect(book['run']!.longestDistance!.setId, 'r1');
      expect(book['run']!.longestDuration!.value, 2000);
      expect(book['run']!.longestDuration!.setId, 'r2');
    });

    test('exercises with nothing qualifying have empty records', () {
      expect(book['bench']!.longestHold, isNull);
      expect(book['plank']!.heaviestWeight, isNull);
      expect(book['plank']!.repsAtWeight, isEmpty);
      expect(book['nope'], isNull);
    });

    test('sessions in any order give the same book', () {
      final RecordBook rev = Records.computeRecords(history.reversed.toList());
      expect(rev['bench']!.heaviestWeight!.setId, 'b5');
      expect(rev['bench']!.bestE1rm!.setId, 'b4');
    });

    test('a tie keeps the earlier set', () {
      final RecordBook b = Records.computeRecords(<WorkoutSession>[
        _session('s1', 1, <SessionExercise>[
          _ex('x', <SetEntry>[_set('first', kg: 50, reps: 5)]),
        ]),
        _session('s2', 2, <SessionExercise>[
          _ex('x', <SetEntry>[_set('second', kg: 50, reps: 5)]),
        ]),
      ]);
      expect(b['x']!.heaviestWeight!.setId, 'first');
    });
  });

  group('Epley boundary in records', () {
    test('10 reps counts, 11 reps does not', () {
      final RecordBook ten = Records.computeRecords(<WorkoutSession>[
        _session('s', 1, <SessionExercise>[
          _ex('x', <SetEntry>[_set('a', kg: 100, reps: 10)]),
        ]),
      ]);
      final RecordBook eleven = Records.computeRecords(<WorkoutSession>[
        _session('s', 1, <SessionExercise>[
          _ex('x', <SetEntry>[_set('a', kg: 100, reps: 11)]),
        ]),
      ]);
      expect(ten['x']!.bestE1rm, isNotNull);
      expect(eleven['x']!.bestE1rm, isNull);
      // The set still counts for weight and reps at weight.
      expect(eleven['x']!.heaviestWeight!.value, 100);
      expect(eleven['x']!.repsAtWeight[100]!.value, 11);
    });
  });

  group('warm-ups and incomplete sets', () {
    test('are ignored by records', () {
      final RecordBook b = Records.computeRecords(<WorkoutSession>[
        _session('s', 1, <SessionExercise>[
          _ex('x', <SetEntry>[
            _set('real', kg: 60, reps: 5),
            _set('warm', position: 1, kg: 200, reps: 5, warmup: true),
            _set('undone', position: 2, kg: 300, reps: 5, completed: false),
          ]),
        ]),
      ]);
      expect(b['x']!.heaviestWeight!.value, 60);
      expect(b['x']!.mostVolumeInSession!.value, 300);
    });

    test('are never PRs and never set a bar to beat', () {
      final Set<String> pr = Records.prSetIds(<WorkoutSession>[
        _session('s1', 1, <SessionExercise>[
          _ex('x', <SetEntry>[
            _set('first', kg: 60, reps: 5),
            _set('warm', position: 1, kg: 200, reps: 5, warmup: true),
            _set('undone', position: 2, kg: 300, reps: 5, completed: false),
          ]),
        ]),
        _session('s2', 2, <SessionExercise>[
          _ex('x', <SetEntry>[_set('next', kg: 65, reps: 5)]),
        ]),
      ]);
      expect(pr, <String>{'next'});
    });
  });

  group('prSetIds', () {
    test('first ever set is not a PR', () {
      final Set<String> pr = Records.prSetIds(<WorkoutSession>[
        _session('s1', 1, <SessionExercise>[
          _ex('x', <SetEntry>[_set('a', kg: 100, reps: 5)]),
        ]),
      ]);
      expect(pr, isEmpty);
    });

    test('marks sets chronologically within and across sessions', () {
      final Set<String> pr = Records.prSetIds(<WorkoutSession>[
        // Passed out of order on purpose.
        _session('s2', 5, <SessionExercise>[
          _ex('x', <SetEntry>[
            _set('c', kg: 100, reps: 5), // equals earlier best: not a PR
            _set('d', position: 1, kg: 100, reps: 6), // more reps: PR
            _set('e', position: 2, kg: 110, reps: 1), // heavier: PR
          ]),
        ]),
        _session('s1', 1, <SessionExercise>[
          _ex('x', <SetEntry>[
            _set('a', kg: 100, reps: 5), // first: not a PR
            _set('b', position: 1, kg: 100, reps: 5), // equal: not a PR
          ]),
        ]),
      ]);
      expect(pr, <String>{'d', 'e'});
    });

    test('hold and distance PRs', () {
      final Set<String> pr = Records.prSetIds(<WorkoutSession>[
        _session('s1', 1, <SessionExercise>[
          _ex('plank', <SetEntry>[_set('p1', hold: 30)]),
          _ex('run', <SetEntry>[_set('r1', dist: 3000)], position: 1),
        ]),
        _session('s2', 2, <SessionExercise>[
          _ex('plank', <SetEntry>[_set('p2', hold: 31)]),
          _ex('run', <SetEntry>[_set('r2', dist: 3000)], position: 1),
        ]),
        _session('s3', 3, <SessionExercise>[
          _ex('run', <SetEntry>[_set('r3', dist: 3500)]),
        ]),
      ]);
      expect(pr, <String>{'p2', 'r3'});
    });

    test('a new weight alone is not a rep PR but a heavier one is a PR', () {
      final Set<String> pr = Records.prSetIds(<WorkoutSession>[
        _session('s1', 1, <SessionExercise>[
          _ex('x', <SetEntry>[_set('a', kg: 100, reps: 5)]),
        ]),
        _session('s2', 2, <SessionExercise>[
          _ex('x', <SetEntry>[
            _set('lighter', kg: 60, reps: 10), // nothing beaten
            _set('lighter2', position: 1, kg: 60, reps: 12), // reps at 60
          ]),
        ]),
      ]);
      expect(pr, <String>{'lighter2'});
    });

    test('exercises are independent', () {
      final Set<String> pr = Records.prSetIds(<WorkoutSession>[
        _session('s1', 1, <SessionExercise>[
          _ex('a', <SetEntry>[_set('a1', kg: 100, reps: 5)]),
        ]),
        _session('s2', 2, <SessionExercise>[
          _ex('b', <SetEntry>[_set('b1', kg: 20, reps: 5)]),
        ]),
      ]);
      expect(pr, isEmpty);
    });

    test('editing a past set recomputes downstream flags', () {
      List<WorkoutSession> build(double firstKg) => <WorkoutSession>[
        _session('s1', 1, <SessionExercise>[
          _ex('x', <SetEntry>[_set('a', kg: 100, reps: 5)]),
        ]),
        _session('s2', 2, <SessionExercise>[
          _ex('x', <SetEntry>[_set('b', kg: firstKg, reps: 5)]),
        ]),
        _session('s3', 3, <SessionExercise>[
          _ex('x', <SetEntry>[_set('c', kg: 110, reps: 5)]),
        ]),
      ];
      // b = 105 beats a (100), and c = 110 beats b.
      expect(Records.prSetIds(build(105)), <String>{'b', 'c'});
      // Edit b down to 90: it is no longer a PR, c still beats a.
      expect(Records.prSetIds(build(90)), <String>{'c'});
      // Edit b up to 120: c is no longer a PR.
      expect(Records.prSetIds(build(120)), <String>{'b'});
    });
  });
}
