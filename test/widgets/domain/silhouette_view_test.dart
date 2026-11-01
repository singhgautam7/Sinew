import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/silhouette_view.dart';
import 'package:sinew/engines/silhouette/silhouette_engine.dart';

import '../harness.dart';

const Map<BodyAnchor, double> _full = <BodyAnchor, double>{
  BodyAnchor.neck: 38,
  BodyAnchor.shoulders: 118,
  BodyAnchor.chest: 100,
  BodyAnchor.upperArm: 33,
  BodyAnchor.forearm: 28,
  BodyAnchor.waist: 84,
  BodyAnchor.hips: 98,
  BodyAnchor.thigh: 56,
  BodyAnchor.calf: 37,
};

SilhouetteGeometry _geo({
  Map<BodyAnchor, double> m = _full,
  double? height = 178,
  Sex? sex,
}) => buildSilhouette(
  SilhouetteInput(measurements: m, heightCm: height, sex: sex),
);

SilhouettePainter _painter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((CustomPaint p) => p.painter)
    .whereType<SilhouettePainter>()
    .first;

SemanticsNode? _nodeLabelled(WidgetTester tester, Pattern label) {
  SemanticsNode? found;
  bool visit(SemanticsNode n) {
    if (label is RegExp ? label.hasMatch(n.label) : n.label == label) {
      found = n;
      return false;
    }
    n.visitChildren(visit);
    return found == null;
  }

  visit(tester.binding.rootPipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

Widget _view(
  SilhouetteGeometry g, {
  bool hasData = true,
  SilhouetteGeometry? compare,
  ValueChanged<BodyAnchor>? onTap,
  bool animate = true,
  BodyAnchor? highlight,
  bool markers = false,
}) => SizedBox(
  width: 240,
  height: 424,
  child: SilhouetteView(
    geometry: g,
    hasData: hasData,
    compareGeometry: compare,
    onLevelTap: onTap,
    animate: animate,
    highlight: highlight,
    showLevelLabels: markers,
  ),
);

void main() {
  group('SilhouetteView', () {
    for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
      testWidgets('draws full, partial and empty states in ${tone.name}', (
        WidgetTester tester,
      ) async {
        await pumpThemed(
          tester,
          Row(
            children: <Widget>[
              SizedBox(
                width: 100,
                height: 200,
                child: SilhouetteView(geometry: _geo()),
              ),
              SizedBox(
                width: 100,
                height: 200,
                child: SilhouetteView(
                  geometry: _geo(
                    m: const <BodyAnchor, double>{
                      BodyAnchor.waist: 88,
                      BodyAnchor.hips: 100,
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                height: 200,
                child: SilhouetteView(
                  geometry: _geo(m: const <BodyAnchor, double>{}, height: null),
                  hasData: false,
                ),
              ),
            ],
          ),
          tone: tone,
          size: const Size(400, 600),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('wraps the painter in a repaint boundary', (
      WidgetTester tester,
    ) async {
      await pumpThemed(tester, _view(_geo()));
      expect(
        find.ancestor(
          of: find.byType(CustomPaint),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
    });

    testWidgets('summarises measured and estimated for TalkBack', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(
        tester,
        _view(
          _geo(
            m: const <BodyAnchor, double>{
              BodyAnchor.waist: 88,
              BodyAnchor.hips: 100,
            },
          ),
        ),
      );
      expect(
        _nodeLabelled(tester, RegExp('2 of 9 measurements.*7 estimated')),
        isNotNull,
      );
      h.dispose();
    });

    testWidgets('the empty state says it is all estimated', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(
        tester,
        _view(_geo(m: const <BodyAnchor, double>{}), hasData: false),
      );
      expect(_nodeLabelled(tester, RegExp('No measurements yet')), isNotNull);
      h.dispose();
    });

    test('describe counts only the nine core levels', () {
      expect(
        SilhouetteView.describe(_geo()),
        'Body silhouette. 9 of 9 measurements drawn from your data, 0 estimated',
      );
      expect(
        SilhouetteView.describe(
          _geo(m: <BodyAnchor, double>{..._full, BodyAnchor.aboveNavel: 90}),
          comparing: true,
        ),
        endsWith('Compared with an earlier date'),
      );
    });

    testWidgets('morphs between geometries, ending exactly on the new one', (
      WidgetTester tester,
    ) async {
      final SilhouetteGeometry a = _geo();
      final SilhouetteGeometry b = _geo(
        m: <BodyAnchor, double>{..._full, BodyAnchor.waist: 70},
      );
      await pumpThemed(tester, _view(a));
      expect(identical(_painter(tester).geometry, a), isTrue);

      await pumpThemed(tester, _view(b));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));
      final SilhouetteGeometry mid = _painter(tester).geometry;
      expect(identical(mid, a), isFalse);
      expect(identical(mid, b), isFalse);

      // The point that moved most.
      int k = 0;
      double best = 0;
      for (int i = 0; i < a.torso.points.length; i++) {
        final double d = (a.torso.points[i].x - b.torso.points[i].x).abs();
        if (d > best) {
          best = d;
          k = i;
        }
      }
      final double x0 = a.torso.points[k].x;
      final double x1 = b.torso.points[k].x;
      final double xm = mid.torso.points[k].x;
      expect(xm, inExclusiveRange(x0 < x1 ? x0 : x1, x0 < x1 ? x1 : x0));

      await tester.pump(const Duration(milliseconds: 400));
      expect(identical(_painter(tester).geometry, b), isTrue);
    });

    testWidgets('a morph started mid-way continues from where it was', (
      WidgetTester tester,
    ) async {
      final SilhouetteGeometry a = _geo();
      final SilhouetteGeometry b = _geo(
        m: <BodyAnchor, double>{..._full, BodyAnchor.waist: 70},
      );
      final SilhouetteGeometry c = _geo(
        m: <BodyAnchor, double>{..._full, BodyAnchor.waist: 100},
      );
      await pumpThemed(tester, _view(a));
      await pumpThemed(tester, _view(b));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final double before = _painter(tester).geometry.torso.points[100].x;
      await pumpThemed(tester, _view(c));
      await tester.pump();
      final double after = _painter(tester).geometry.torso.points[100].x;
      expect((after - before).abs(), lessThan(0.01));
      await tester.pumpAndSettle();
      expect(identical(_painter(tester).geometry, c), isTrue);
    });

    testWidgets('reduced motion jumps to the end state', (
      WidgetTester tester,
    ) async {
      final SilhouetteGeometry a = _geo();
      final SilhouetteGeometry b = _geo(
        m: <BodyAnchor, double>{..._full, BodyAnchor.waist: 70},
      );
      await pumpThemed(tester, _view(a), disableAnimations: true);
      await pumpThemed(tester, _view(b), disableAnimations: true);
      await tester.pump();
      expect(identical(_painter(tester).geometry, b), isTrue);
    });

    testWidgets('animate false jumps too', (WidgetTester tester) async {
      final SilhouetteGeometry a = _geo();
      final SilhouetteGeometry b = _geo(
        m: <BodyAnchor, double>{..._full, BodyAnchor.waist: 70},
      );
      await pumpThemed(tester, _view(a, animate: false));
      await pumpThemed(tester, _view(b, animate: false));
      await tester.pump();
      expect(identical(_painter(tester).geometry, b), isTrue);
    });

    testWidgets('draws the comparison outline behind', (
      WidgetTester tester,
    ) async {
      final SilhouetteGeometry older = _geo(
        m: <BodyAnchor, double>{..._full, BodyAnchor.waist: 92},
      );
      await pumpThemed(tester, _view(_geo(), compare: older));
      expect(identical(_painter(tester).compare, older), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('highlight and level labels paint without error', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        _view(_geo(), highlight: BodyAnchor.waist, markers: true),
      );
      expect(_painter(tester).highlight, BodyAnchor.waist);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a level reports its anchor', (
      WidgetTester tester,
    ) async {
      final List<BodyAnchor> taps = <BodyAnchor>[];
      await pumpThemed(
        tester,
        _view(_geo(), onTap: taps.add),
        size: const Size(300, 600),
      );
      final Offset origin = tester.getTopLeft(find.byType(SilhouetteView));
      // Canvas units are dp at this size: x 120 is the body axis and the
      // waist is at 40% of the 400 high figure below the 12 inset.
      await tester.tapAt(origin + const Offset(120, 12 + 0.40 * 400));
      await tester.tapAt(origin + const Offset(120, 12 + 0.80 * 400));
      await tester.tapAt(
        origin + const Offset(120 + 0.15 * 400, 12 + 0.40 * 400),
      );
      expect(taps, <BodyAnchor>[
        BodyAnchor.waist,
        BodyAnchor.calf,
        BodyAnchor.forearm,
      ]);
    });

    testWidgets('a tap far from any level does nothing', (
      WidgetTester tester,
    ) async {
      final List<BodyAnchor> taps = <BodyAnchor>[];
      await pumpThemed(
        tester,
        _view(_geo(), onTap: taps.add),
        size: const Size(300, 600),
      );
      final Offset origin = tester.getTopLeft(find.byType(SilhouetteView));
      await tester.tapAt(origin + const Offset(120, 12 + 0.95 * 400));
      expect(taps, isEmpty);
    });

    testWidgets('levels are 48dp semantics targets when tappable', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await pumpThemed(
        tester,
        SizedBox(
          width: 240,
          height: 424,
          child: SilhouetteView(
            geometry: _geo(),
            onLevelTap: (BodyAnchor _) {},
            levelValueText: (SilhouetteLevel l) => '${l.valueCm.round()} cm',
          ),
        ),
        size: const Size(300, 600),
      );
      final SemanticsNode? waist = _nodeLabelled(
        tester,
        'Waist, 84 cm, measured',
      );
      expect(waist, isNotNull);
      expect(waist!.rect.height, greaterThanOrEqualTo(48));
      h.dispose();
    });

    testWidgets('fits a narrow box and 200% text without overflow', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 120,
          height: 300,
          child: SilhouetteView(geometry: _geo(), showLevelLabels: true),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await pumpThemed(
        tester,
        SingleChildScrollView(child: SilhouetteView(geometry: _geo())),
        scaffold: false,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
