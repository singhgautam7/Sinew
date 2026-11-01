import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sinew/app.dart';

/// Builds [f] if it is below the fold, then scrolls it into view.
Future<void> reveal(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      150,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(f);
  await tester.pump();
}

/// Types [text] into the text field inside the widget with [key].
Future<void> typeInto(WidgetTester tester, String key, String text) async {
  final Finder field = find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(TextField),
  );
  await reveal(tester, field);
  await tester.enterText(field, text);
  await tester.pump();
}

/// Scrolls [finder] into view and taps it.
Future<void> tapText(WidgetTester tester, String text) async {
  final Finder f = find.text(text).first;
  await reveal(tester, f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// The router's current path.
String currentPath(WidgetTester tester) {
  final BuildContext ctx = tester.element(find.byType(Navigator).first);
  return GoRouter.of(
    ctx,
  ).routerDelegate.currentConfiguration.last.matchedLocation;
}

/// The root container, for reading providers.
ProviderContainer rootContainer(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(SinewApp)));
