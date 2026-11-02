import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/widgets/app_button.dart';
import 'package:sinew/core/widgets/sinew_chips.dart';
import 'package:sinew/core/widgets/sinew_extended_fab.dart';
import 'package:sinew/core/widgets/sinew_segmented_control.dart';
import 'package:sinew/core/widgets/sinew_snackbar.dart';
import 'package:sinew/core/widgets/sinew_states.dart';

import 'harness.dart';

void main() {
  group('200% text on a 360dp phone', () {
    testWidgets('chips grow instead of overflowing, hit area stays 48', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const Wrap(
          spacing: 8,
          children: <Widget>[
            SinewChip(label: 'Strength', selected: true),
            SinewChip(label: 'Equipment', dropdown: true, badge: '3'),
            SinewChip(label: 'Dumbbell', icon: Icons.add, shrink: true),
          ],
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      for (final Element e in find.byType(SinewChip).evaluate()) {
        expect(tester.getSize(find.byWidget(e.widget)).height, 48);
      }
    });

    testWidgets('a deletable chip shows its text and a 48dp remove target', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SinewChip(label: 'Yoga', selected: true, onDeleted: () {}),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      final Finder remove = find.bySemanticsLabel('Remove Yoga');
      expect(remove, findsOneWidget);
      final Size s = tester.getSize(remove);
      expect(s.width, greaterThanOrEqualTo(48));
      expect(s.height, greaterThanOrEqualTo(48));
    });

    testWidgets('buttons wrap their label, never clip it', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppButton(
              label: 'Start an empty workout',
              fullWidth: true,
              type: AppButtonType.primary,
              onPressed: () {},
            ),
            AppButton(
              label: 'Start an empty workout',
              type: AppButtonType.outline,
              height: 40,
              fullWidth: true,
              onPressed: () {},
            ),
          ],
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      final Iterable<Text> texts = tester.widgetList<Text>(
        find.text('Start an empty workout'),
      );
      for (final Text t in texts) {
        expect(t.maxLines, greaterThanOrEqualTo(2));
      }
      // The wrapped label made the button taller than its 56 design height.
      expect(
        tester.getSize(find.byType(AppButton).first).height,
        greaterThan(56),
      );
    });

    testWidgets('segmented control shows full labels', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SinewSegmentedControl<int>(
          values: const <int>[0, 1],
          labels: const <String>['Kilograms', 'Pounds'],
          selected: 0,
          onSelected: (int _) {},
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      for (final Text t in tester.widgetList<Text>(find.text('Kilograms'))) {
        expect(t.maxLines, 2);
      }
    });

    testWidgets('the extended FAB collapses to its icon with a label', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SinewExtendedFab(
          icon: Icons.add_rounded,
          label: 'Create your own exercise',
          onPressed: () {},
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Create your own exercise'), findsNothing);
      expect(find.byTooltip('Create your own exercise'), findsOneWidget);
      expect(find.bySemanticsLabel('Create your own exercise'), findsOneWidget);
      expect(tester.getSize(find.byType(Material).last).width, 56);
    });

    testWidgets('the extended FAB keeps its label at normal text', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SinewExtendedFab(
          icon: Icons.add_rounded,
          label: 'New routine',
          onPressed: () {},
        ),
      );
      expect(find.text('New routine'), findsOneWidget);
    });
  });

  group('semantics', () {
    testWidgets('the chip remove action is a separate reachable node', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int removed = 0;
      int tapped = 0;
      await pumpThemed(
        tester,
        SinewChip(
          label: 'Yoga',
          selected: true,
          onTap: () => tapped++,
          onDeleted: () => removed++,
        ),
      );
      final SemanticsNode node = tester.getSemantics(
        find.bySemanticsLabel('Remove Yoga'),
      );
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      tester.semantics.tap(find.semantics.byLabel('Remove Yoga'));
      await tester.pump();
      expect(removed, 1);
      expect(tapped, 0);
      // The chip itself is still its own node.
      expect(find.bySemanticsLabel('Yoga'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('tapping the chip remove icon removes, not selects', (
      WidgetTester tester,
    ) async {
      int removed = 0;
      int tapped = 0;
      await pumpThemed(
        tester,
        SinewChip(
          label: 'Yoga',
          selected: true,
          onTap: () => tapped++,
          onDeleted: () => removed++,
        ),
      );
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(removed, 1);
      expect(tapped, 0);
    });
  });

  group('reduced motion', () {
    testWidgets('the snackbar slide uses the short reduced duration', (
      WidgetTester tester,
    ) async {
      addTearDown(hideSinewSnackBar);
      await pumpThemed(
        tester,
        Opener(onTap: (BuildContext c) => showSinewSnackBar(c, 'Saved')),
        disableAnimations: true,
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      // 90 ms fade, so fully in well before the normal 220 ms.
      await tester.pump(const Duration(milliseconds: 100));
      final Opacity o = tester.widget<Opacity>(
        find
            .ancestor(of: find.text('Saved'), matching: find.byType(Opacity))
            .first,
      );
      expect(o.opacity, 1);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('skeletons share one pulse and hold still when reduced', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const Column(
          children: <Widget>[
            SinewSkeletonRow(),
            SinewSkeletonRow(),
            SinewSkeletonRow(),
          ],
        ),
      );
      // Many bars, one FadeTransition per bar, one controller (no Opacity).
      expect(find.byType(SinewSkeletonPulse), findsNWidgets(3));
      expect(
        find.descendant(
          of: find.byType(SinewSkeleton),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
      expect(find.byType(FadeTransition), findsWidgets);
    });
  });
}
