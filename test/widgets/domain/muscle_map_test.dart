import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/muscle_map.dart';
import 'package:sinew/core/widgets/domain/muscle_map_data.dart';

import '../harness.dart';

MuscleFigurePainter _painter(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((CustomPaint p) => p.painter)
      .whereType<MuscleFigurePainter>()
      .first;
}

SemanticsNode? _nodeLabelled(WidgetTester tester, String label) {
  SemanticsNode? found;
  bool visit(SemanticsNode n) {
    if (n.label == label) {
      found = n;
      return false;
    }
    n.visitChildren(visit);
    return found == null;
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return found;
}

SinewAccents _accents(Tone tone) =>
    AppTheme.of(tone).extension<SinewAccents>()!;

void main() {
  group('muscle id to region mapping', () {
    test('all 22 library muscle ids are handled', () {
      final Map<String, dynamic> vocab = jsonDecode(
        File('specs/data/schema/vocab.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final List<String> ids = (vocab['muscles'] as List<dynamic>)
          .map(
            (dynamic e) =>
                e is String ? e : (e as Map<String, dynamic>)['id'] as String,
          )
          .toList();
      expect(ids, hasLength(22));
      for (final String id in ids) {
        if (id == kFullBodyMuscle) continue;
        expect(kMuscleRegions.containsKey(id), isTrue, reason: id);
      }
    });

    test('there are 15 regions and each is reachable', () {
      expect(MuscleRegion.values, hasLength(15));
      final Set<MuscleRegion> reached = <MuscleRegion>{
        for (final Set<MuscleRegion> s in kMuscleRegions.values) ...s,
      };
      expect(reached, MuscleRegion.values.toSet());
    });

    test('mapping examples', () {
      expect(regionsForMuscle('quadriceps'), <MuscleRegion>{
        MuscleRegion.quads,
      });
      expect(regionsForMuscle('core'), <MuscleRegion>{MuscleRegion.abs});
      expect(regionsForMuscle('rearDeltoids'), <MuscleRegion>{
        MuscleRegion.shoulders,
      });
      expect(regionsForMuscle('rhomboids'), <MuscleRegion>{MuscleRegion.traps});
      expect(regionsForMuscle('tibialis'), <MuscleRegion>{MuscleRegion.calves});
      expect(regionsForMuscle('abductors'), <MuscleRegion>{
        MuscleRegion.glutes,
      });
    });

    test('neck and hip flexors are body, not muscles', () {
      expect(regionsForMuscle('neck'), isEmpty);
      expect(regionsForMuscle('hipFlexors'), isEmpty);
      expect(regionsForMuscle('unknown-muscle'), isEmpty);
    });

    test('fullBody tints every region', () {
      expect(regionsForMuscle('fullBody'), MuscleRegion.values.toSet());
    });

    test('region ids round trip to a library id', () {
      for (final MuscleRegion r in MuscleRegion.values) {
        expect(regionsForMuscle(r.muscleId), contains(r), reason: r.name);
      }
    });
  });

  group('crop side', () {
    test('the side with more primary muscles wins', () {
      expect(
        cropSideFor(<String>['triceps', 'lats'], <String>['chest']),
        MuscleMapSide.back,
      );
      expect(
        cropSideFor(<String>['chest', 'biceps'], <String>['hamstrings']),
        MuscleMapSide.front,
      );
      expect(
        cropSideFor(<String>['glutes', 'hamstrings'], <String>[]),
        MuscleMapSide.back,
      );
    });

    test('a primary counts twice a secondary', () {
      expect(
        cropSideFor(<String>['chest'], <String>['triceps', 'lats']),
        MuscleMapSide.front,
      );
    });

    test('nothing worked shows the front', () {
      expect(cropSideFor(<String>[], <String>[]), MuscleMapSide.front);
    });
  });

  group('describe', () {
    test('primary and secondary', () {
      expect(
        MuscleMap.describe(
          primary: <String>['chest', 'triceps'],
          secondary: <String>['shoulders'],
        ),
        'Worked: chest, triceps; also shoulders',
      );
    });

    test('camel case ids are spoken as words', () {
      expect(
        MuscleMap.describe(primary: <String>['lowerBack', 'rearDeltoids']),
        'Worked: lower back, rear deltoids',
      );
    });

    test('secondary only and none', () {
      expect(
        MuscleMap.describe(secondary: <String>['calves']),
        'Also worked: calves',
      );
      expect(MuscleMap.describe(), 'Muscle map. None marked');
    });

    test('heat names the most trained', () {
      expect(
        MuscleMap.describe(
          heat: <String, double>{'chest': 0.9, 'lats': 0.2, 'core': 0.5},
        ),
        'Muscle map. Most trained: chest, core, lats',
      );
    });
  });

  group('MuscleMap widget', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets('renders both sides in ${tone.name}', (
        WidgetTester tester,
      ) async {
        await pumpThemed(
          tester,
          const SizedBox(
            width: 300,
            height: 400,
            child: MuscleMap(
              primary: <String>['chest'],
              secondary: <String>['shoulders'],
            ),
          ),
          tone: tone,
        );
        expect(find.text('Front'), findsOneWidget);
        expect(find.text('Back'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('has a TalkBack label', (WidgetTester tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(
        tester,
        const SizedBox(
          width: 300,
          height: 400,
          child: MuscleMap(
            primary: <String>['chest', 'triceps'],
            secondary: <String>['shoulders'],
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Worked: chest, triceps; also shoulders'),
        findsOneWidget,
      );
      h.dispose();
    });

    testWidgets('colours primary, secondary and idle regions', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 200,
          height: 400,
          child: MuscleMap(
            primary: <String>['chest'],
            secondary: <String>['rearDeltoids'],
            view: MuscleMapView.front,
          ),
        ),
      );
      final SinewAccents a = _accents(Tone.light);
      final MuscleFigurePainter p = _painter(tester);
      expect(p.fills[MuscleRegion.chest], a.musclePrimary);
      expect(p.fills[MuscleRegion.shoulders], a.muscleSecondary);
      expect(p.fills.containsKey(MuscleRegion.quads), isFalse);
      expect(p.idle, a.muscleIdle);
    });

    testWidgets('fullBody tints everything with the secondary colour', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 200,
          height: 400,
          child: MuscleMap(
            primary: <String>['quadriceps'],
            secondary: <String>['fullBody'],
            view: MuscleMapView.front,
          ),
        ),
      );
      final SinewAccents a = _accents(Tone.light);
      final MuscleFigurePainter p = _painter(tester);
      expect(p.fills[MuscleRegion.quads], a.musclePrimary);
      expect(p.fills[MuscleRegion.chest], a.muscleSecondary);
      expect(p.fills.length, MuscleRegion.values.length);
    });

    testWidgets('a tint replaces the primary colour', (
      WidgetTester tester,
    ) async {
      const Color tint = Color(0xFF123456);
      await pumpThemed(
        tester,
        const SizedBox(
          width: 200,
          height: 400,
          child: MuscleMap(
            primary: <String>['chest'],
            secondary: <String>['biceps'],
            view: MuscleMapView.front,
            tint: tint,
          ),
        ),
      );
      final MuscleFigurePainter p = _painter(tester);
      expect(p.fills[MuscleRegion.chest], tint);
      expect(p.fills[MuscleRegion.biceps], isNot(tint));
    });

    testWidgets('heat mode uses the five heat steps', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 200,
          height: 400,
          child: MuscleMap(
            heat: <String, double>{'chest': 1, 'quadriceps': 0.1, 'lats': 0},
            primary: <String>['calves'],
            view: MuscleMapView.front,
          ),
        ),
      );
      final SinewAccents a = _accents(Tone.light);
      final MuscleFigurePainter p = _painter(tester);
      expect(p.fills[MuscleRegion.chest], a.heat.last);
      expect(p.fills[MuscleRegion.quads], a.heat.first);
      expect(p.fills.containsKey(MuscleRegion.lats), isFalse);
      expect(p.fills.containsKey(MuscleRegion.calves), isFalse);
    });

    testWidgets('crop shows the side with more primary muscles', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 48,
          height: 48,
          child: MuscleMap(
            primary: <String>['lats', 'triceps'],
            secondary: <String>['chest'],
            fit: MuscleMapFit.crop,
            showLabels: false,
          ),
        ),
      );
      final MuscleFigurePainter back = _painter(tester);
      expect(
        back.geometry.regions.containsKey(MuscleRegion.lats),
        isTrue,
        reason: 'back view',
      );
      expect(back.viewRect.width, back.viewRect.height);
      expect(back.viewRect.width, lessThan(kMapViewBox.height));

      await pumpThemed(
        tester,
        const SizedBox(
          width: 48,
          height: 48,
          child: MuscleMap(
            primary: <String>['chest', 'biceps'],
            secondary: <String>['lats'],
            fit: MuscleMapFit.crop,
          ),
        ),
      );
      final MuscleFigurePainter front = _painter(tester);
      expect(front.geometry.regions.containsKey(MuscleRegion.chest), isTrue);
      expect(front.geometry.regions.containsKey(MuscleRegion.lats), isFalse);
    });

    testWidgets('crop zooms to the worked area and uses the sex base', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 48,
          height: 48,
          child: MuscleMap(
            primary: <String>['quadriceps'],
            fit: MuscleMapFit.crop,
            sex: Sex.female,
          ),
        ),
      );
      final MuscleFigurePainter p = _painter(tester);
      final Rect quads = p.geometry.regions[MuscleRegion.quads]!.bounds;
      expect(p.viewRect.contains(quads.topLeft), isTrue);
      expect(p.viewRect.contains(quads.bottomRight), isTrue);
      expect(
        identical(
          p.geometry,
          MuscleMapGeometry.of(female: true, side: MuscleMapSide.front),
        ),
        isTrue,
      );
    });

    testWidgets('tapping a region reports its library muscle id', (
      WidgetTester tester,
    ) async {
      final List<String> taps = <String>[];
      // 208 x 484 is the 104 x 242 view box at 2x.
      await pumpThemed(
        tester,
        SizedBox(
          width: 208,
          height: 484,
          child: MuscleMap(
            view: MuscleMapView.front,
            showLabels: false,
            onRegionTap: taps.add,
          ),
        ),
        size: const Size(400, 600),
      );
      final Offset origin = tester.getTopLeft(find.byType(MuscleMap));
      Offset at(double x, double y) => origin + Offset((x - 8) * 2, y * 2);
      await tester.tapAt(at(51, 55)); // chest
      await tester.tapAt(at(55, 75)); // abs
      await tester.tapAt(at(47, 150)); // quads
      expect(taps, <String>['chest', 'core', 'quadriceps']);
    });

    testWidgets('a tap just off a small region still finds one', (
      WidgetTester tester,
    ) async {
      final List<String> taps = <String>[];
      await pumpThemed(
        tester,
        SizedBox(
          width: 208,
          height: 484,
          child: MuscleMap(
            view: MuscleMapView.front,
            showLabels: false,
            onRegionTap: taps.add,
          ),
        ),
        size: const Size(400, 600),
      );
      final Offset origin = tester.getTopLeft(find.byType(MuscleMap));
      await tester.tapAt(origin + const Offset((61 - 8) * 2, 128 * 2));
      expect(taps, hasLength(1));
    });

    testWidgets('tappable regions are 48dp semantics targets', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(
        tester,
        SizedBox(
          width: 208,
          height: 484,
          child: MuscleMap(
            view: MuscleMapView.front,
            showLabels: false,
            onRegionTap: (String _) {},
          ),
        ),
        size: const Size(400, 600),
      );
      final SemanticsNode node = _nodeLabelled(tester, 'Adductors')!;
      expect(node.rect.width, greaterThanOrEqualTo(48));
      expect(node.rect.height, greaterThanOrEqualTo(48));
      h.dispose();
    });

    testWidgets('200% text on a 360dp phone does not overflow', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 328,
          height: 420,
          child: MuscleMap(primary: <String>['chest']),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      // Unbounded height too.
      await pumpThemed(
        tester,
        const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: MuscleMap(primary: <String>['chest']),
          ),
        ),
        textScale: 2,
        scaffold: false,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
