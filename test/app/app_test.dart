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
import 'package:sinew/core/settings/app_settings.dart';
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
      await tester.tap(find.widgetWithText(NavigationDestination, tab.label));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
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
      await tester.tap(find.byType(NavigationDestination).at(i));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab.label);
    }
  });

  testWidgets('debug screen reports the library as not bundled yet', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    await _pumpApp(tester);
    await tester.tap(find.widgetWithText(NavigationDestination, 'More'));
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
      prefs: <String, Object>{AppSettings.kMode: ThemeMode.dark.name},
    );
    final BuildContext ctx = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });
}
