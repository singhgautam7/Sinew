import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/app.dart';
import 'package:sinew/core/db/library/library_installer.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/routing/nav_visibility.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/widgets/sinew_app_bar.dart';
import 'package:sinew/core/widgets/sinew_nav_pill.dart';
import 'package:sinew/core/theme/wallpaper_seed.dart';

import '../helpers/test_db.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final SharedPreferences p = await SharedPreferences.getInstance();
  final UserDatabase db = memoryUserDb();
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        prefsProvider.overrideWithValue(p),
        userDatabaseProvider.overrideWithValue(db),
        seedSourceProvider.overrideWithValue(() async => null),
        libraryRepositoryProvider.overrideWith(
          (Ref ref) async =>
              throw const LibraryAssetMissing(LibraryInstaller.assetDb),
        ),
      ],
      child: const SinewApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void _usePhone(WidgetTester tester, {double textScale = 1}) {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  testWidgets('boots on Today and switches tabs', (WidgetTester tester) async {
    _usePhone(tester);
    await _pumpApp(tester);
    expect(find.text('Today'), findsWidgets);

    for (final TabSpec tab in kTabs) {
      await tester.tap(find.byKey(ValueKey<String>('nav-${tab.label}')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          // A tab's landing page uses the app bar or the large page header.
          of: find.byWidgetPredicate(
            (Widget w) => w is SinewAppBar || w is SinewPageHeader,
          ),
          matching: find.text(tab.label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('every tab lays out at 200% text on a 360dp phone', (
    WidgetTester tester,
  ) async {
    _usePhone(tester, textScale: 2);
    await _pumpApp(tester);
    for (int i = 0; i < kTabs.length; i++) {
      final TabSpec tab = kTabs[i];
      await tester.tap(find.byKey(ValueKey<String>('nav-${tab.label}')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab.label);
    }
  });

  testWidgets('debug screen reports the library as not bundled yet', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    await _pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey<String>('nav-More')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Debug'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Arrives in Phase 2'), findsOneWidget);
    expect(find.text('v${UserDatabase.currentSchemaVersion}'), findsWidgets);
  });

  testWidgets('a stored dark theme applies on the first frame', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    await _pumpApp(
      tester,
      prefs: <String, Object>{AppSettings.kMode: AppThemeMode.dark.name},
    );
    final BuildContext ctx = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });

  testWidgets('the pill shows the selected label and hides on demand', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    await _pumpApp(tester);
    expect(find.byType(SinewNavPill), findsOneWidget);
    // Only the selected tab shows its label inside the pill.
    expect(
      find.descendant(
        of: find.byType(SinewNavPill),
        matching: find.text('Today'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(SinewNavPill),
        matching: find.text('Train'),
      ),
      findsNothing,
    );

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(SinewApp)),
    );
    container
        .read(navHideReasonsProvider.notifier)
        .hide(NavHideReason.activeWorkout);
    await tester.pumpAndSettle();
    expect(find.byType(SinewNavPill), findsNothing);

    container
        .read(navHideReasonsProvider.notifier)
        .show(NavHideReason.activeWorkout);
    await tester.pumpAndSettle();
    expect(find.byType(SinewNavPill), findsOneWidget);
  });

  testWidgets('back on another tab returns to the first tab', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    await _pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey<String>('nav-Body')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(SinewAppBar),
        matching: find.text('Body'),
      ),
      findsOneWidget,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(SinewAppBar),
        matching: find.text('Today'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('re-tapping the current tab keeps it on screen', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    await _pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey<String>('nav-Today')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(SinewAppBar),
        matching: find.text('Today'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the pill drops its label at 200% text but keeps five tabs', (
    WidgetTester tester,
  ) async {
    _usePhone(tester, textScale: 2);
    await _pumpApp(tester);
    expect(
      find.descendant(
        of: find.byType(SinewNavPill),
        matching: find.byType(Text),
      ),
      findsNothing,
    );
    for (final TabSpec tab in kTabs) {
      expect(find.byKey(ValueKey<String>('nav-${tab.label}')), findsOneWidget);
    }
  });

  testWidgets('the debug screen lays out at 200% text', (
    WidgetTester tester,
  ) async {
    _usePhone(tester, textScale: 2);
    await _pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey<String>('nav-More')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Debug'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
