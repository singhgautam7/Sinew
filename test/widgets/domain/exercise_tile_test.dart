import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/library_types.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/exercise_tile.dart';
import 'package:sinew/core/widgets/domain/muscle_map.dart';
import 'package:sinew/core/widgets/sinew_states.dart';

import '../harness.dart';

const ExerciseSummary _bench = ExerciseSummary(
  id: 'barbell-bench-press',
  name: 'Barbell bench press',
  category: 'strength',
  trackingType: TrackingType.weightReps,
  primaryMuscles: <String>['chest', 'triceps'],
  equipment: <String>['barbell', 'bench'],
  difficulty: Difficulty.intermediate,
);

const ExerciseSummary _custom = ExerciseSummary(
  id: 'custom-wrist-curl',
  name: 'My wrist curl',
  category: 'strength',
  trackingType: TrackingType.reps,
  primaryMuscles: <String>['forearms'],
  isCustom: true,
);

void main() {
  group('helpers', () {
    test('prettyVocab', () {
      expect(prettyVocab('strength'), 'Strength');
      expect(prettyVocab('smithMachine'), 'Smith machine');
      expect(prettyVocab('hiit'), 'HIIT');
      expect(prettyVocab('body-weight'), 'Body weight');
      expect(prettyVocab(''), '');
    });

    test('every tracking type has a glyph and words', () {
      for (final TrackingType t in TrackingType.values) {
        expect(trackingTypeIcon(t), isA<IconData>());
        expect(trackingTypeWords(t), isNotEmpty);
      }
    });

    test('metaLine joins category, first equipment and difficulty', () {
      expect(
        ExerciseTile.metaLine(_bench),
        'Strength · Barbell · Intermediate',
      );
      expect(ExerciseTile.metaLine(_custom), 'Strength');
    });
  });

  group('ExerciseTile', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets(
        'shows name, meta line and the map thumbnail in ${tone.name}',
        (WidgetTester tester) async {
          await pumpThemed(
            tester,
            const ExerciseTile(exercise: _bench),
            tone: tone,
          );
          expect(find.text('Barbell bench press'), findsOneWidget);
          expect(
            find.text('Strength · Barbell · Intermediate'),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
          final Finder map = find.byType(MuscleMap);
          expect(map, findsOneWidget);
          expect(tester.getSize(map), const Size(48, 48));
          expect(tester.widget<MuscleMap>(map).fit, MuscleMapFit.crop);
          expect(tester.widget<MuscleMap>(map).primary, _bench.primaryMuscles);
          expect(find.text('Custom'), findsNothing);
        },
      );
    }

    testWidgets('secondary muscles and sex reach the thumbnail', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const ExerciseTile(
          exercise: _bench,
          secondaryMuscles: <String>['shoulders'],
          sex: Sex.female,
        ),
      );
      final MuscleMap m = tester.widget<MuscleMap>(find.byType(MuscleMap));
      expect(m.secondary, <String>['shoulders']);
      expect(m.sex, Sex.female);
    });

    testWidgets('a custom exercise wears the Custom badge', (
      WidgetTester tester,
    ) async {
      await pumpThemed(tester, const ExerciseTile(exercise: _custom));
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('tap and long press', (WidgetTester tester) async {
      int taps = 0;
      int longs = 0;
      await pumpThemed(
        tester,
        ExerciseTile(
          exercise: _bench,
          onTap: () => taps++,
          onLongPress: () => longs++,
        ),
      );
      await tester.tap(find.text('Barbell bench press'));
      await tester.longPress(find.text('Barbell bench press'));
      expect(taps, 1);
      expect(longs, 1);
    });

    testWidgets('the add button is a 48dp target that reports a press', (
      WidgetTester tester,
    ) async {
      int adds = 0;
      int rowTaps = 0;
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(
        tester,
        ExerciseTile(
          exercise: _bench,
          onTap: () => rowTaps++,
          trailing: ExerciseAddButton(onPressed: () => adds++),
        ),
      );
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      final Size s = tester.getSize(find.byType(ExerciseAddButton));
      expect(s.width, greaterThanOrEqualTo(48));
      expect(s.height, greaterThanOrEqualTo(48));
      expect(find.bySemanticsLabel(RegExp('Add exercise')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add_rounded));
      expect(adds, 1);
      expect(rowTaps, 0);
      h.dispose();
    });

    testWidgets('multi-select shows the check and the selected fill', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const Column(
          children: <Widget>[
            ExerciseTile(
              exercise: _bench,
              selected: true,
              trailing: ExerciseSelectMark(selected: true),
            ),
            ExerciseTile(
              exercise: _custom,
              trailing: ExerciseSelectMark(selected: false),
            ),
          ],
        ),
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byType(ExerciseSelectMark), findsNWidgets(2));
    });

    testWidgets('TalkBack hears the name, meta, tracking and muscles', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(tester, ExerciseTile(exercise: _bench, onTap: () {}));
      expect(
        find.bySemanticsLabel(
          RegExp(
            r'Worked: chest, triceps.*Barbell bench press'
            r'.*Tracked by weight and reps.*Strength',
            dotAll: true,
          ),
        ),
        findsOneWidget,
      );
      h.dispose();
    });

    testWidgets('a tile with no muscles still draws', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const ExerciseTile(
          exercise: ExerciseSummary(
            id: 'x',
            name: 'Foam roll',
            category: 'mobility',
            trackingType: TrackingType.time,
          ),
        ),
      );
      expect(find.text('Foam roll'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('200% text on a 360dp phone does not overflow', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ExerciseTile(
                exercise: const ExerciseSummary(
                  id: 'long',
                  name: 'Downward dog · Adho Mukha Svanasana with a very long name',
                  category: 'yoga',
                  trackingType: TrackingType.hold,
                  primaryMuscles: <String>['hamstrings', 'shoulders'],
                  equipment: <String>['yogaMat'],
                  difficulty: Difficulty.beginner,
                  isCustom: true,
                ),
                trailing: ExerciseAddButton(onPressed: () {}),
              ),
              const ExerciseTile(exercise: _bench),
            ],
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('ExerciseTileSkeleton', () {
    testWidgets('is a skeleton row, labelled while loading', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(tester, const ExerciseTileSkeleton());
      expect(find.byType(SinewSkeletonRow), findsOneWidget);
      expect(find.bySemanticsLabel('Loading exercise'), findsOneWidget);
      h.dispose();
    });

    testWidgets('renders under reduced motion', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        const ExerciseTileSkeleton(),
        disableAnimations: true,
        tone: Tone.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
