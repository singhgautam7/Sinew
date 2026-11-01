import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/settings/app_settings.dart';

import '../../helpers/phase8_finders.dart';
import '../../helpers/phase8_harness.dart';

void main() {
  group('Settings', () {
    testWidgets('switches persist to preferences', (WidgetTester tester) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.settings);

      await tapText(tester, 'Haptics');
      expect(h.prefs.getBool(AppSettings.kHaptics), isFalse);

      await tapText(tester, 'Keep screen on');
      expect(h.prefs.getBool(AppSettings.kKeepScreenOn), isFalse);
      await tapText(tester, 'Spoken countdown');
      expect(h.prefs.getBool(AppSettings.kTimerVoice), isTrue);
      await tapText(tester, 'Sounds');
      expect(h.prefs.getBool(AppSettings.kTimerSound), isFalse);
      await tapText(tester, 'Timer haptics');
      expect(h.prefs.getBool(AppSettings.kTimerHaptic), isFalse);
      await closeApp(tester);
    });

    testWidgets('default rest and weight step are editable', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.settings);
      expect(find.text('2:00'), findsOneWidget);

      await tapText(tester, 'Default rest');
      await tester.tap(find.byKey(const ValueKey<String>('stepper-plus')));
      await tester.pumpAndSettle();
      expect(h.prefs.getInt(AppSettings.kRestSeconds), 135);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('2:15'), findsOneWidget);

      await tapText(tester, 'Weight step');
      await tapText(tester, '5 kg');
      expect(h.prefs.getDouble(AppSettings.kIncrementKg), 5.0);
      await closeApp(tester);
    });

    testWidgets('text size slider changes and stores the scale', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.settings);
      expect(find.text('100%'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(300, 0));
      await tester.pumpAndSettle();
      final double? stored = h.prefs.getDouble(AppSettings.kTextScale);
      expect(stored, isNotNull);
      expect(stored, closeTo(AppSettings.maxTextScale, 1e-9));
      expect(find.text('130%'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('rows lead to Theme, Backup and About', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      await pumpSinew(tester, location: Routes.settings);
      await tapText(tester, 'Theme');
      expect(currentPath(tester), Routes.theme);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tapText(tester, 'Backup and restore');
      expect(currentPath(tester), Routes.backup);
      await closeApp(tester);
    });

    testWidgets('lays out at 200% text on a 360dp phone', (
      WidgetTester tester,
    ) async {
      usePhone(tester, textScale: 2);
      await pumpSinew(tester, location: Routes.settings);
      expect(tester.takeException(), isNull);
      for (int i = 0; i < 6; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await tester.binding.handlePopRoute();
      await closeApp(tester);
    });

    test('settings defaults, clamping and bad values', () {
      expect(const AppSettings().restSeconds, 120);
      expect(const AppSettings().incrementKg, 2.5);
      expect(const AppSettings().incrementLb, 5);
      expect(const AppSettings().timerVoice, isFalse);
      expect(const AppSettings().haptics, isTrue);
    });
  });

  group('Theme', () {
    testWidgets('mode switches apply instantly and persist', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.theme);
      Brightness shown() =>
          Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

      await tapText(tester, 'Dark');
      expect(shown(), Brightness.dark);
      expect(h.prefs.getString(AppSettings.kMode), 'dark');

      await tapText(tester, 'AMOLED');
      expect(shown(), Brightness.dark);
      expect(h.prefs.getString(AppSettings.kMode), 'amoled');
      final Color bg = Theme.of(tester.element(find.byType(Scaffold).first))
          .scaffoldBackgroundColor;
      expect(bg, const Color(0xFF000000));

      await tapText(tester, 'Light');
      expect(shown(), Brightness.light);
      expect(h.prefs.getString(AppSettings.kMode), 'light');
      await closeApp(tester);
    });

    testWidgets('choosing a family changes the theme and turns dynamic off', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.theme);
      Color primary() =>
          Theme.of(tester.element(find.byType(Scaffold).first))
              .colorScheme
              .primary;
      final Color before = primary();

      await tapText(tester, 'Ember');
      expect(h.prefs.getString(AppSettings.kFamily), 'ember');
      expect(h.prefs.getBool(AppSettings.kDynamic), isFalse);
      expect(primary(), isNot(before));
      await closeApp(tester);
    });

    testWidgets('wallpaper colours can be switched on where available', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      final Harness h = await pumpSinew(
        tester,
        location: Routes.theme,
        prefs: <String, Object>{AppSettings.kDynamic: false},
        wallpaper: const Color(0xFF3366CC),
      );
      await tapText(tester, 'From your wallpaper');
      expect(h.prefs.getBool(AppSettings.kDynamic), isTrue);
      await closeApp(tester);
    });

    testWidgets('the wallpaper row is disabled without a wallpaper seed', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      await pumpSinew(tester, location: Routes.theme);
      expect(
        find.text('Not available on this phone (Android 12 and later)'),
        findsOneWidget,
      );
      await closeApp(tester);
    });

    testWidgets('lays out at 200% text on a 360dp phone', (
      WidgetTester tester,
    ) async {
      usePhone(tester, textScale: 2);
      await pumpSinew(tester, location: Routes.theme);
      expect(tester.takeException(), isNull);
      for (int i = 0; i < 10; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await closeApp(tester);
    });
  });
}
