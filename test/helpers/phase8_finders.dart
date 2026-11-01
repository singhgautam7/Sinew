import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sinew/app.dart';
import 'package:sinew/core/widgets/app_button.dart';

bool _exists(Finder f) {
  try {
    return f.evaluate().isNotEmpty;
  } on StateError {
    return false;
  }
}

/// Builds [f] if it is off screen (scrolling down, then up), then brings it
/// into view.
Future<void> reveal(WidgetTester tester, Finder f) async {
  if (!_exists(f)) {
    final Finder scrollable = find.byType(Scrollable).first;
    try {
      await tester.scrollUntilVisible(
        f,
        150,
        scrollable: scrollable,
        maxScrolls: 30,
      );
    } on StateError {
      await tester.scrollUntilVisible(
        f,
        -150,
        scrollable: scrollable,
        maxScrolls: 60,
      );
    }
  }
  await tester.ensureVisible(f.first);
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
  final Finder all = find.text(text);
  await reveal(tester, all);
  await tester.tap(all.first);
  await tester.pumpAndSettle();
}

/// Taps the [AppButton] labelled [label] (not a tile or a title that shares
/// the text).
Future<void> tapButton(WidgetTester tester, String label) async {
  final Finder all = find.widgetWithText(AppButton, label);
  await reveal(tester, all);
  await tester.tap(all.first);
  await tester.pumpAndSettle();
}

/// The router's current path.
String currentPath(WidgetTester tester) {
  final BuildContext ctx = tester.element(find.byType(Navigator).first);
  return GoRouter.of(ctx)
      .routerDelegate
      .currentConfiguration
      .last
      .matchedLocation;
}

/// The root container, for reading providers.
ProviderContainer rootContainer(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(SinewApp)));

/// Navigates with `go` and waits for the new screen.
Future<void> goTo(WidgetTester tester, String path) async {
  final BuildContext ctx = tester.element(find.byType(Navigator).first);
  GoRouter.of(ctx).go(path);
  await tester.pumpAndSettle();
}
