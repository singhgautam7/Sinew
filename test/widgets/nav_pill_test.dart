import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/widgets/sinew_nav_pill.dart';

import 'harness.dart';

const List<String> _labels = <String>[
  'Today',
  'Train',
  'Timer',
  'Body',
  'More',
];

Widget _bar({
  int index = 0,
  bool hidden = false,
  ValueChanged<int>? onSelect,
  List<String> labels = _labels,
}) => Align(
  alignment: Alignment.bottomCenter,
  child: SinewNavBar(
    labels: labels,
    index: index,
    hidden: hidden,
    onSelect: onSelect ?? (int _) {},
  ),
);

Finder _inPill(Finder f) =>
    find.descendant(of: find.byType(SinewNavPill), matching: f);

void main() {
  testWidgets('shows the label of the selected tab only', (
    WidgetTester tester,
  ) async {
    await pumpThemed(tester, _bar(index: 2), scaffold: false);
    expect(_inPill(find.text('Timer')), findsOneWidget);
    for (final String other in <String>['Today', 'Train', 'Body', 'More']) {
      expect(_inPill(find.text(other)), findsNothing);
    }
  });

  testWidgets('tapping a tab reports its index', (WidgetTester tester) async {
    final List<int> picked = <int>[];
    await pumpThemed(tester, _bar(onSelect: picked.add), scaffold: false);
    await tester.tap(find.byKey(const ValueKey<String>('nav-Body')));
    await tester.tap(find.byKey(const ValueKey<String>('nav-More')));
    await tester.tap(find.byKey(const ValueKey<String>('nav-Today')));
    expect(picked, <int>[3, 4, 0]);
  });

  testWidgets('the indicator follows the selection', (
    WidgetTester tester,
  ) async {
    int index = 0;
    late StateSetter set;
    await pumpThemed(
      tester,
      StatefulBuilder(
        builder: (BuildContext c, StateSetter s) {
          set = s;
          return _bar(index: index, onSelect: (int i) => s(() => index = i));
        },
      ),
      scaffold: false,
    );
    await tester.tap(find.byKey(const ValueKey<String>('nav-Train')));
    await tester.pumpAndSettle();
    expect(index, 1);
    expect(_inPill(find.text('Train')), findsOneWidget);
    expect(_inPill(find.text('Today')), findsNothing);
    set(() {});
  });

  testWidgets(
    'hides and shows with the hidden flag, and is removed when hidden',
    (WidgetTester tester) async {
      bool hidden = false;
      late StateSetter set;
      await pumpThemed(
        tester,
        StatefulBuilder(
          builder: (BuildContext c, StateSetter s) {
            set = s;
            return _bar(hidden: hidden);
          },
        ),
        scaffold: false,
      );
      expect(find.byType(SinewNavPill), findsOneWidget);

      set(() => hidden = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      // Mid-animation it is still there but fading.
      expect(find.byType(SinewNavPill), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(SinewNavPill), findsNothing);

      set(() => hidden = false);
      await tester.pumpAndSettle();
      expect(find.byType(SinewNavPill), findsOneWidget);
    },
  );

  testWidgets('reduced motion hides without a slide', (
    WidgetTester tester,
  ) async {
    bool hidden = false;
    late StateSetter set;
    await pumpThemed(
      tester,
      StatefulBuilder(
        builder: (BuildContext c, StateSetter s) {
          set = s;
          return _bar(hidden: hidden);
        },
      ),
      scaffold: false,
      disableAnimations: true,
    );
    final double before = tester.getTopLeft(find.byType(SinewNavPill)).dy;
    set(() => hidden = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 45));
    expect(tester.getTopLeft(find.byType(SinewNavPill)).dy, before);
    await tester.pumpAndSettle();
    expect(find.byType(SinewNavPill), findsNothing);
  });

  testWidgets('each tab is a button with its label and selected state', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpThemed(tester, _bar(index: 1), scaffold: false);
    for (int i = 0; i < _labels.length; i++) {
      expect(
        tester.getSemantics(find.byKey(ValueKey<String>('nav-${_labels[i]}'))),
        isSemantics(
          label: _labels[i],
          isButton: true,
          isSelected: i == 1,
          hasTapAction: true,
        ),
        reason: _labels[i],
      );
    }
    handle.dispose();
  });

  testWidgets('every tab has a 48dp tall hit area', (
    WidgetTester tester,
  ) async {
    await pumpThemed(tester, _bar(), scaffold: false);
    for (final String l in _labels) {
      expect(
        tester.getSize(find.byKey(ValueKey<String>('nav-$l'))).height,
        greaterThanOrEqualTo(48),
        reason: l,
      );
    }
  });

  testWidgets('geometry: 56 tall, 40 drawn indicators, 48 wide hit areas', (
    WidgetTester tester,
  ) async {
    await pumpThemed(tester, _bar(index: 0), scaffold: false);
    expect(tester.getSize(find.byType(SinewNavPill)).height, 56);
    for (final String l in <String>['Train', 'Timer', 'Body', 'More']) {
      final Finder item = find.byKey(ValueKey<String>('nav-$l'));
      // The hit area (the whole item) is at least 48 x 48 ...
      expect(tester.getSize(item).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(item).height, greaterThanOrEqualTo(48));
      // ... and the drawn indicator inside it is still 40.
      final Finder drawn = find.descendant(
        of: item,
        matching: find.byType(AnimatedContainer),
      );
      expect(tester.getSize(drawn).width, 40);
      expect(tester.getSize(drawn).height, 40);
    }
  });

  testWidgets('a tap in the slop beside an idle indicator still selects it', (
    WidgetTester tester,
  ) async {
    final List<int> picked = <int>[];
    await pumpThemed(tester, _bar(onSelect: picked.add), scaffold: false);
    final Rect r = tester.getRect(
      find.byKey(const ValueKey<String>('nav-Train')),
    );
    await tester.tapAt(Offset(r.left + 2, r.center.dy));
    expect(picked, <int>[1]);
  });

  testWidgets('the label drops at large text and the pill never overflows', (
    WidgetTester tester,
  ) async {
    await pumpThemed(tester, _bar(index: 0), scaffold: false, textScale: 2);
    expect(_inPill(find.byType(Text)), findsNothing);
    expect(tester.takeException(), isNull);
    // Still five tabs.
    for (final String l in _labels) {
      expect(find.byKey(ValueKey<String>('nav-$l')), findsOneWidget);
    }
  });

  testWidgets('five tabs with a label fit a 360dp phone', (
    WidgetTester tester,
  ) async {
    await pumpThemed(tester, _bar(index: 3), scaffold: false);
    expect(
      tester.getSize(find.byType(SinewNavPill)).width,
      lessThanOrEqualTo(360 - 24),
    );
    expect(_inPill(find.text('Body')), findsOneWidget);
  });

  testWidgets('glyphs paint without error for all five and an extra index', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      Wrap(
        children: <Widget>[
          for (int i = 0; i < 6; i++)
            SinewNavGlyph(index: i, color: Colors.black),
        ],
      ),
    );
    expect(find.byType(SinewNavGlyph), findsNWidgets(6));
    expect(tester.takeException(), isNull);
  });
}
