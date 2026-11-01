import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/measurement_repository.dart';
import 'package:sinew/core/db/repositories/profile_repository.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/widgets/sinew_app_bar.dart';
import 'package:sinew/features/backup/backup_io.dart';

import '../../helpers/phase8_finders.dart';
import '../../helpers/phase8_harness.dart';

void main() {
  testWidgets('a first run opens on Welcome with both ways in', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    await pumpSinew(tester, onboarded: false);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Restore a backup'), findsOneWidget);
    expect(find.text('Works fully offline'), findsOneWidget);
    expect(currentPath(tester), Routes.welcome);
    await closeApp(tester);
  });

  testWidgets(
    'quick profile saves the profile and a first weight, then opens Today',
    (WidgetTester tester) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, onboarded: false);

      await tapText(tester, 'Get started');
      expect(currentPath(tester), Routes.onboardingProfile);

      // Imperial units, so the weight is stored as exact kilograms.
      await tapText(tester, 'lb');
      await tapText(tester, 'in');
      await tapText(tester, 'Male');
      await typeInto(tester, 'onboarding-year', '1994');
      await typeInto(tester, 'onboarding-height', '70');
      await typeInto(tester, 'onboarding-weight', '176');
      await tapText(tester, 'Continue');

      expect(currentPath(tester), Routes.today);
      expect(
        find.descendant(
          of: find.byType(SinewAppBar),
          matching: find.text('Sinew'),
        ),
        findsOneWidget,
      );
      expect(h.prefs.getBool(AppSettings.kOnboarded), isTrue);

      final Profile p = await ProfileRepository(h.db).get();
      expect(p.sex, Sex.male);
      expect(p.birthYear, 1994);
      expect(p.weightUnit, WeightUnit.lb);
      expect(p.heightCm, closeTo(70 * 2.54, 1e-9));

      final List<MeasurementEntry> entries = await MeasurementRepository(
        h.db,
      ).entries();
      expect(entries, hasLength(1));
      expect(entries.single.values['weight'], closeTo(176 * 0.45359237, 1e-9));
      await closeApp(tester);
    },
  );

  testWidgets('a bad birth year blocks Continue but Skip still works', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final Harness h = await pumpSinew(
      tester,
      onboarded: false,
      location: Routes.onboardingProfile,
    );
    await typeInto(tester, 'onboarding-year', '1850');
    expect(find.text('Enter a year like 1994.'), findsOneWidget);
    // The Continue button is disabled: tapping does nothing.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(currentPath(tester), Routes.onboardingProfile);

    await tapText(tester, 'Skip');
    expect(currentPath(tester), Routes.today);
    expect(h.prefs.getBool(AppSettings.kOnboarded), isTrue);
    expect(await MeasurementRepository(h.db).entries(), isEmpty);
    await closeApp(tester);
  });

  testWidgets('Skip all goes straight to Today without saving anything', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final Harness h = await pumpSinew(
      tester,
      onboarded: false,
      location: Routes.onboardingProfile,
    );
    await typeInto(tester, 'onboarding-height', '180');
    await tapText(tester, 'Skip all');
    expect(currentPath(tester), Routes.today);
    expect((await ProfileRepository(h.db).get()).heightCm, isNull);
    await closeApp(tester);
  });

  testWidgets('first-run restore: pick, preview, replace, into the app', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final String json = await makeBackupJson(sessions: 3);
    final Harness h = await pumpSinew(tester, onboarded: false);
    h.io.toPick = PickedTextFile(
      name: 'sinew-backup-test.json',
      text: json,
      size: json.length,
    );

    await tapText(tester, 'Restore a backup');
    expect(currentPath(tester), Routes.onboardingRestore);
    await tapText(tester, 'Choose a backup file');

    expect(find.text('sinew-backup-test.json'), findsOneWidget);
    expect(find.text('Workouts'), findsOneWidget);
    // First run has nothing to merge with: no Merge option.
    expect(find.text('Merge'), findsNothing);

    await tapText(tester, 'Replace');
    // Confirm dialog.
    expect(find.text('Replace everything?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Replace'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Backup restored'), findsOneWidget);
    await tapText(tester, 'Open Sinew');
    expect(currentPath(tester), Routes.today);
    expect(h.prefs.getBool(AppSettings.kOnboarded), isTrue);
    expect((await ProfileRepository(h.db).get()).birthYear, 1994);
    await closeApp(tester);
  });

  testWidgets('a file that is not a backup is refused and changes nothing', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    final Harness h = await pumpSinew(
      tester,
      onboarded: false,
      location: Routes.onboardingRestore,
    );
    h.io.toPick = const PickedTextFile(name: 'notes.json', text: '{"a": 1}');
    await tapText(tester, 'Choose a backup file');
    expect(find.text('Not a Sinew backup'), findsOneWidget);
    expect(find.text('Nothing on this phone was changed.'), findsOneWidget);
    expect(await MeasurementRepository(h.db).entries(), isEmpty);
    await closeApp(tester);
  });

  testWidgets('first-run screens lay out at 200% text on a 360dp phone', (
    WidgetTester tester,
  ) async {
    usePhone(tester, textScale: 2);
    await pumpSinew(tester, onboarded: false);
    expect(tester.takeException(), isNull);
    for (final String path in <String>[
      Routes.onboardingProfile,
      Routes.onboardingRestore,
    ]) {
      final BuildContext ctx = tester.element(find.byType(Scaffold).first);
      Navigator.of(ctx).popUntil((Route<dynamic> r) => r.isFirst);
      await tester.pumpAndSettle();
      await tapText(
        tester,
        path == Routes.onboardingProfile ? 'Get started' : 'Restore a backup',
      );
      expect(tester.takeException(), isNull, reason: path);
    }
    await closeApp(tester);
  });
}
