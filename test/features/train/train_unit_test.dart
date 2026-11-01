import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/features/train/history_screen.dart';
import 'package:sinew/features/train/routine_style.dart';
import 'package:sinew/features/train/train_format.dart';
import 'package:sinew/features/train/train_records.dart';

WorkoutSession _session(String id, DateTime start, List<SetEntry> sets) =>
    WorkoutSession(
      id: id,
      startedAt: start,
      endedAt: start.add(const Duration(hours: 1)),
      updatedAt: start,
      exercises: <SessionExercise>[
        SessionExercise(
          id: 'e$id',
          exerciseId: 'bench',
          position: 0,
          sets: sets,
        ),
      ],
    );

SetEntry _set(String id, double kg, int reps, {bool pr = false}) => SetEntry(
  id: id,
  position: 0,
  weightKg: kg,
  reps: reps,
  completed: true,
  isPR: pr,
);

void main() {
  group('formatting', () {
    test('minutes, elapsed and volume', () {
      expect(formatMinutes(30), '30 s');
      expect(formatMinutes(52 * 60), '52 min');
      expect(formatMinutes(65 * 60), '1 h 05 min');
      expect(formatElapsed(24 * 60 + 18), '24:18');
      expect(formatElapsed(3723), '1:02:03');
      expect(formatVolume(4820, WeightUnit.kg), '4,820 kg');
      expect(formatVolume(1000, WeightUnit.lb), '2,205 lb');
      expect(formatVolume(0, WeightUnit.kg), '0 kg');
    });

    test('days and weeks', () {
      expect(formatDay(DateTime(2025, 10, 28)), 'Tue 28 Oct');
      expect(formatClock(DateTime(2025, 10, 28, 8, 5)), '08:05');
      expect(weekStart(DateTime(2025, 10, 31, 14)), DateTime(2025, 10, 27));
      final DateTime now = DateTime(2025, 10, 31);
      expect(weekLabel(DateTime(2025, 10, 27), now), 'This week');
      expect(weekLabel(DateTime(2025, 10, 20), now), 'Last week');
      expect(weekLabel(DateTime(2025, 10, 6), now), '6 Oct to 12 Oct');
      expect(formatAgo(DateTime(2025, 10, 28), now), '3 days ago');
      expect(formatAgo(DateTime(2025, 10, 30), now), 'yesterday');
      expect(plural(1, 'set'), '1 set');
      expect(plural(2, 'set'), '2 sets');
    });

    test('no em dashes in user-facing strings', () {
      for (final String s in <String>[
        formatSessionWhen(
          DateTime(2025, 10, 28, 18, 10),
          DateTime(2025, 10, 28, 19, 2),
        ),
        weekLabel(DateTime(2025, 9, 1), DateTime(2025, 10, 31)),
      ]) {
        expect(s.contains('—'), isFalse);
      }
    });
  });

  group('history grouping', () {
    test('groups by Monday week, newest first', () {
      final List<WorkoutSession> list = <WorkoutSession>[
        _session('a', DateTime(2025, 10, 31, 9), <SetEntry>[]),
        _session('b', DateTime(2025, 10, 27, 9), <SetEntry>[]),
        _session('c', DateTime(2025, 10, 26, 9), <SetEntry>[]),
      ];
      final List<HistoryWeek> weeks = groupByWeek(list);
      expect(weeks, hasLength(2));
      expect(weeks.first.start, DateTime(2025, 10, 27));
      expect(weeks.first.sessions.map((WorkoutSession s) => s.id), <String>[
        'a',
        'b',
      ]);
      expect(weeks.last.sessions.single.id, 'c');
    });
  });

  group('routine style', () {
    test('round trips and falls back', () {
      const RoutineStyle s = RoutineStyle(
        iconKey: 'bolt',
        colorValue: 0xFF22C55E,
        useMap: false,
      );
      final RoutineStyle back = RoutineStyle.fromJsonString(
        '{"v":1,"icon":"bolt","color":${0xFF22C55E},"map":false}',
      );
      expect(back, s);
      expect(RoutineStyle.fromJsonString(null), RoutineStyle.fallback);
      expect(RoutineStyle.fromJsonString('not json'), RoutineStyle.fallback);
      // A newer build's payload is ignored, not guessed at.
      expect(
        RoutineStyle.fromJsonString('{"v":9,"icon":"bolt"}'),
        RoutineStyle.fallback,
      );
      // An icon this build does not know falls back to the default icon.
      expect(
        RoutineStyle.fromJsonString('{"v":1,"icon":"nope"}').iconKey,
        RoutineStyle.defaultIcon,
      );
      expect(routineStyleKey('abc'), 'routine.style.abc');
    });

    test('muscles rank by how often they are trained', () {
      Exercise e(String id, List<String> p, List<String> s) => Exercise(
        id: id,
        name: id,
        category: 'strength',
        trackingType: TrackingType.weightReps,
        primaryMuscles: p,
        secondaryMuscles: s,
      );
      final m = routineMuscles(
        <String>['a', 'b', 'c'],
        <String, Exercise>{
          'a': e('a', <String>['chest'], <String>['triceps']),
          'b': e('b', <String>['lats'], <String>['biceps', 'chest']),
          'c': e('c', <String>['chest'], <String>[]),
        },
      );
      expect(m.primary, <String>['chest', 'lats']);
      // chest is already primary, so only the arms remain.
      expect(m.secondary.toSet(), <String>{'triceps', 'biceps'});
    });
  });

  group('PR flags', () {
    test(
      'withPrFlags sets and clears, keeping the instance when unchanged',
      () {
        final WorkoutSession s = _session('x', DateTime(2025, 1, 1), <SetEntry>[
          _set('s1', 60, 8, pr: true),
          _set('s2', 60, 8),
        ]);
        expect(identical(withPrFlags(s, <String>{'s1'}), s), isTrue);
        final WorkoutSession flipped = withPrFlags(s, <String>{'s2'});
        expect(flipped.exercises.single.sets[0].isPR, isFalse);
        expect(flipped.exercises.single.sets[1].isPR, isTrue);
      },
    );

    test('an open set is never a record', () {
      final WorkoutSession s = _session('x', DateTime(2025, 1, 1), <SetEntry>[
        const SetEntry(id: 'o', position: 0, weightKg: 90, reps: 5),
      ]);
      expect(identical(withPrFlags(s, <String>{'o'}), s), isTrue);
    });
  });
}
