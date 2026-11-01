import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/widgets/sinew_snackbar.dart';

import 'harness.dart';

void main() {
  tearDown(hideSinewSnackBar);

  testWidgets('shows the message, then leaves when its timer ends', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      Opener(
        onTap: (BuildContext c) => showSinewSnackBar(
          c,
          'Routine saved',
          duration: const Duration(seconds: 2),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Routine saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Routine saved'), findsNothing);
  });

  testWidgets('undo runs its callback once and closes the snackbar', (
    WidgetTester tester,
  ) async {
    int undone = 0;
    await pumpThemed(
      tester,
      Opener(
        onTap: (BuildContext c) =>
            showSinewUndoSnackBar(c, 'Set deleted', onUndo: () => undone++),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Set deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(undone, 1);
    expect(find.text('Set deleted'), findsNothing);
  });

  testWidgets('the action does not run if the snackbar just times out', (
    WidgetTester tester,
  ) async {
    int undone = 0;
    await pumpThemed(
      tester,
      Opener(
        onTap: (BuildContext c) => showSinewSnackBar(
          c,
          'Gone',
          actionLabel: 'Undo',
          onAction: () => undone++,
          duration: const Duration(seconds: 1),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(undone, 0);
  });

  testWidgets('the close button dismisses it', (WidgetTester tester) async {
    await pumpThemed(
      tester,
      Opener(onTap: (BuildContext c) => showSinewSnackBar(c, 'Hello')),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('a new snackbar replaces the old one', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      Opener(
        onTap: (BuildContext c) {
          showSinewSnackBar(c, 'first');
          showSinewSnackBar(c, 'second');
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('second'), findsOneWidget);
    expect(find.text('first'), findsNothing);
    hideSinewSnackBar();
  });

  testWidgets('swiping it away dismisses it', (WidgetTester tester) async {
    await pumpThemed(
      tester,
      Opener(onTap: (BuildContext c) => showSinewSnackBar(c, 'Swipe me')),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.fling(find.text('Swipe me'), const Offset(400, 0), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Swipe me'), findsNothing);
  });

  testWidgets('an error snackbar uses the error icon', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      Opener(
        onTap: (BuildContext c) =>
            showSinewSnackBar(c, 'Could not save', isError: true),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.error_rounded), findsOneWidget);
    hideSinewSnackBar();
  });

  testWidgets('lays out at 200% text', (WidgetTester tester) async {
    await pumpThemed(
      tester,
      Opener(
        onTap: (BuildContext c) => showSinewUndoSnackBar(
          c,
          'A longer message that has to wrap onto several lines',
          onUndo: () {},
        ),
      ),
      textScale: 2,
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    hideSinewSnackBar();
  });
}
