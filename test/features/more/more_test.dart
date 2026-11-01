import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/plate_inventory_repository.dart';
import 'package:sinew/core/db/repositories/profile_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/plate_inventory.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/routing/router.dart';

import '../../helpers/phase8_finders.dart';
import '../../helpers/phase8_harness.dart';

Finder _plus(String plateKey) => find.descendant(
  of: find.byKey(ValueKey<String>(plateKey)),
  matching: find.byKey(const ValueKey<String>('stepper-plus')),
);

Future<void> _tapPlus(WidgetTester tester, String plateKey) async {
  await reveal(tester, _plus(plateKey));
  await tester.tap(_plus(plateKey));
  await tester.pumpAndSettle();
}

void main() {
  group('More', () {
    testWidgets('lists every section and opens its pages', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      await pumpSinew(tester, location: Routes.more);
      expect(find.text('Your profile'), findsOneWidget);
      for (final String row in <String>[
        'Plates and bars',
        'Units',
        'Backup and restore',
        'Export CSV',
        'Settings',
        'Theme',
      ]) {
        await reveal(tester, find.text(row));
        expect(find.text(row), findsOneWidget, reason: row);
      }
      // Debug is offered in debug builds only; tests are debug builds.
      await reveal(tester, find.text('Debug'));
      expect(find.text('Debug'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, 1500));
      await tester.pump();
      await tapText(tester, 'Units');
      expect(currentPath(tester), Routes.units);
      await closeApp(tester);
    });

    testWidgets('profile row and backup row say where things stand', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      await pumpSinew(
        tester,
        location: Routes.more,
        prefs: <String, Object>{
          'backup.lastAt': DateTime.utc(2026, 10, 12, 9).toIso8601String(),
          'app.userName': 'Gautam',
        },
        seed: (UserDatabase db) => ProfileRepository(db)
            .save(const Profile(sex: Sex.male, heightCm: 178, birthYear: 1994)),
      );
      expect(find.text('Gautam'), findsOneWidget);
      expect(find.text('Male · 178 cm · born 1994'), findsOneWidget);
      expect(find.text('Last backup 12 Oct'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('a long time without a backup shows a reminder line', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      await pumpSinew(
        tester,
        location: Routes.more,
        seed: (UserDatabase db) async {
          final SessionRepository repo = SessionRepository(db);
          for (int i = 0; i < 10; i++) {
            final WorkoutSession s = await repo.start(
              startedAt: DateTime(2026, 1, 1 + i),
            );
            await repo.finish(
              s.id,
              endedAt: DateTime(2026, 1, 1 + i, 1),
              durationSec: 3600,
            );
          }
        },
      );
      expect(find.text('Not backed up yet. Save a copy.'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('lays out at 200% text on a 360dp phone', (
      WidgetTester tester,
    ) async {
      usePhone(tester, textScale: 2);
      await pumpSinew(tester, location: Routes.more);
      expect(tester.takeException(), isNull);
      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await closeApp(tester);
    });
  });

  group('Profile and Units', () {
    testWidgets('profile fields persist as you type', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.profile);
      await tapText(tester, 'Female');
      await typeInto(tester, 'profile-year', '1990');
      await typeInto(tester, 'profile-height', '165.5');
      await tapText(tester, 'Very active');
      await tapText(tester, 'Asian');
      await typeInto(tester, 'profile-name', 'Sam');

      final Profile p = await ProfileRepository(h.db).get();
      expect(p.sex, Sex.female);
      expect(p.birthYear, 1990);
      expect(p.heightCm, 165.5);
      expect(p.activityLevel, ActivityLevel.veryActive);
      expect(p.bmiCutoffs, BmiCutoffs.asian);
      expect(h.prefs.getString('app.userName'), 'Sam');
      expect(
        find.textContaining('Only used for estimates'),
        findsOneWidget,
        reason: 'sex explains that it only affects estimates',
      );

      // Clearing a field clears it.
      await typeInto(tester, 'profile-height', '');
      expect((await ProfileRepository(h.db).get()).heightCm, isNull);
      await closeApp(tester);
    });

    testWidgets('units save to the profile and change the height unit', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      final Harness h = await pumpSinew(
        tester,
        location: Routes.units,
        seed: (UserDatabase db) =>
            ProfileRepository(db).save(const Profile(heightCm: 177.8)),
      );
      await tapText(tester, 'Pounds');
      await tapText(tester, 'Inches');
      await tapText(tester, 'Miles');
      await tapText(tester, 'Sunday');
      final Profile p = await ProfileRepository(h.db).get();
      expect(p.weightUnit, WeightUnit.lb);
      expect(p.lengthUnit, LengthUnit.inch);
      expect(p.distanceUnit, DistanceUnit.mi);
      expect(h.prefs.getBool('app.weekStartsMonday'), isFalse);
      // Stored metric height is untouched by a unit change.
      expect(p.heightCm, 177.8);

      await goTo(tester, Routes.profile);
      // 177.8 cm shown in inches.
      expect(find.text('70'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('profile and units lay out at 200% text', (
      WidgetTester tester,
    ) async {
      usePhone(tester, textScale: 2);
      await pumpSinew(tester, location: Routes.profile);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -900));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });
  });

  group('Plates and bars', () {
    testWidgets('editing plate counts persists and moves the heaviest load', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.plates);
      expect(find.text('Heaviest you can load: 255 kg'), findsOneWidget);

      // 25 kg plates: 2 owned -> 4 owned adds a second pair.
      await _tapPlus(tester, 'plate-25');
      await _tapPlus(tester, 'plate-25');
      await reveal(tester, find.text('Heaviest you can load: 305 kg'));
      expect(find.text('Heaviest you can load: 305 kg'), findsOneWidget);

      final PlateInventory inv = await PlateInventoryRepository(h.db).get();
      expect(
        inv.plates.firstWhere((PlateStock s) => s.weightKg == 25).count,
        4,
      );
      await closeApp(tester);
    });

    testWidgets('adds, edits and deletes a bar', (WidgetTester tester) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.plates);
      Future<List<Bar>> bars() async =>
          (await PlateInventoryRepository(h.db).get()).bars;

      await tapText(tester, 'Add bar');
      await typeInto(tester, 'bar-name', 'Trap bar');
      await typeInto(tester, 'bar-weight', '25');
      await tapButton(tester, 'Save');
      expect((await bars()).map((Bar b) => b.name), contains('Trap bar'));
      expect(
        (await bars()).firstWhere((Bar b) => b.name == 'Trap bar').weightKg,
        25,
      );

      await tapText(tester, 'Trap bar');
      await typeInto(tester, 'bar-weight', '30');
      await tapButton(tester, 'Save');
      expect(
        (await bars()).firstWhere((Bar b) => b.name == 'Trap bar').weightKg,
        30,
      );

      await tapText(tester, 'Trap bar');
      await tapButton(tester, 'Delete');
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        (await bars()).map((Bar b) => b.name),
        isNot(contains('Trap bar')),
      );
      await closeApp(tester);
    });

    testWidgets('pound plates are stored as exact kilograms', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.plates);
      await tapText(tester, 'Pounds');
      expect(find.text('45 lb'), findsOneWidget);
      await _tapPlus(tester, 'plate-20.4117');
      final PlateInventory inv = await PlateInventoryRepository(h.db).get();
      expect(inv.unit, WeightUnit.lb);
      final PlateStock lb45 = inv.plates.firstWhere(
        (PlateStock s) => (s.weightKg - 45 * 0.45359237).abs() < 1e-9,
      );
      expect(lb45.count, 1);
      await closeApp(tester);
    });

    testWidgets('machine step is saved', (WidgetTester tester) async {
      usePhone(tester);
      final Harness h = await pumpSinew(tester, location: Routes.plates);
      final Finder plus = find.descendant(
        of: find.byKey(const ValueKey<String>('machine-step')),
        matching: find.byKey(const ValueKey<String>('stepper-plus')),
      );
      await reveal(tester, plus);
      await tester.tap(plus);
      await tester.pumpAndSettle();
      expect((await PlateInventoryRepository(h.db).get()).machineStepKg, 5.5);
      await closeApp(tester);
    });

    testWidgets('lays out at 200% text on a 360dp phone', (
      WidgetTester tester,
    ) async {
      usePhone(tester, textScale: 2);
      await pumpSinew(tester, location: Routes.plates);
      expect(tester.takeException(), isNull);
      for (int i = 0; i < 8; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await tapText(tester, 'Add bar');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });
  });

  group('Permissions', () {
    testWidgets('says there is no internet permission', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      await pumpSinew(tester, location: Routes.permissions);
      expect(find.text('No internet permission'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Foreground service'), findsOneWidget);
      await reveal(tester, find.text('Vibration'));
      expect(find.text('Vibration'), findsOneWidget);
      await reveal(tester, find.text('Keep screen awake'));
      await reveal(tester, find.textContaining('Internet, location'));
      await closeApp(tester);
    });

    testWidgets('lays out at 200% text', (WidgetTester tester) async {
      usePhone(tester, textScale: 2);
      await pumpSinew(tester, location: Routes.permissions);
      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });
  });
}
