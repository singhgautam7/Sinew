import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/widgets/sinew_states.dart';

import 'harness.dart';

void main() {
  group('SinewEmptyState', () {
    testWidgets('shows icon, title, description and the action', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        SinewEmptyState(
          icon: Icons.fitness_center_rounded,
          title: 'No routines yet',
          description: 'Build one to start a workout in a tap.',
          actionLabel: 'New routine',
          onAction: () => taps++,
        ),
      );
      expect(find.text('No routines yet'), findsOneWidget);
      expect(
        find.text('Build one to start a workout in a tap.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
      await tester.tap(find.text('New routine'));
      expect(taps, 1);
    });

    testWidgets('without an action it shows no button', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SinewEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No results',
          description: 'Try a different search.',
        ),
      );
      expect(find.byType(TextButton), findsNothing);
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('the decorative icon is hidden from TalkBack', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpThemed(
        tester,
        const SinewEmptyState(
          icon: Icons.inbox_rounded,
          title: 'Nothing here',
          description: 'Come back later.',
        ),
      );
      expect(find.bySemanticsLabel('Nothing here'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('lays out at 200% text in a short space', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SingleChildScrollView(
          child: SinewEmptyState(
            icon: Icons.inbox_rounded,
            title: 'No measurements yet',
            description: 'Add your first entry to see trends over time.',
            actionLabel: 'Add entry',
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('SinewSkeleton', () {
    testWidgets('pulses while animations are on', (WidgetTester tester) async {
      await pumpThemed(tester, const SinewSkeleton(width: 100, height: 16));
      await tester.pump(const Duration(milliseconds: 600));
      final Opacity o = tester.widget(find.byType(Opacity));
      expect(o.opacity, lessThan(1));
    });

    testWidgets('holds still under reduced motion', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SinewSkeleton(width: 100, height: 16),
        disableAnimations: true,
      );
      await tester.pump(const Duration(milliseconds: 600));
      final Opacity o = tester.widget(find.byType(Opacity));
      expect(o.opacity, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('row and card variants build', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SinewSkeletonRow(),
            SinewSkeletonRow(thumbnail: false),
            SinewSkeletonCard(lines: 4),
          ],
        ),
      );
      expect(find.byType(SinewSkeleton), findsNWidgets(3 + 2 + 4));
      expect(tester.getSize(find.byType(SinewSkeletonRow).first).height, 72);
      expect(tester.takeException(), isNull);
    });
  });

  group('Delayed', () {
    testWidgets('renders nothing for 250 ms, then its child', (
      WidgetTester tester,
    ) async {
      await pumpThemed(tester, const Delayed(child: Text('spinner')));
      expect(find.text('spinner'), findsNothing);
      await tester.pump(const Duration(milliseconds: 249));
      expect(find.text('spinner'), findsNothing);
      await tester.pump(const Duration(milliseconds: 2));
      expect(find.text('spinner'), findsOneWidget);
    });

    testWidgets('a load that finishes first never shows it', (
      WidgetTester tester,
    ) async {
      bool loading = true;
      late StateSetter set;
      await pumpThemed(
        tester,
        StatefulBuilder(
          builder: (BuildContext c, StateSetter s) {
            set = s;
            return loading
                ? const Delayed(child: Text('spinner'))
                : const Text('loaded');
          },
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      set(() => loading = false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('spinner'), findsNothing);
      expect(find.text('loaded'), findsOneWidget);
    });

    testWidgets('a custom delay is honoured', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        const Delayed(delay: Duration(seconds: 1), child: Text('late')),
      );
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('late'), findsNothing);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('late'), findsOneWidget);
    });
  });

  testWidgets('SinewLoader shows its label and a spinner', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      Opener(
        onTap: (BuildContext c) => showDialog<void>(
          context: c,
          builder: (_) => const SinewLoader(label: 'Restoring backup'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Restoring backup'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
