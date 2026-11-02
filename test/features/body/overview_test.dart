import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/widgets/app_icon_button.dart';
import 'package:sinew/core/widgets/domain/field_row.dart';
import 'package:sinew/core/widgets/domain/silhouette_view.dart';
import 'package:sinew/core/widgets/domain/stat_card.dart';
import 'package:sinew/core/widgets/sinew_app_bar.dart';
import 'package:sinew/core/widgets/sinew_snackbar.dart';
import 'package:sinew/engines/body_stats/body_stats.dart';
import 'package:sinew/features/body/entry_screen.dart';

import 'body_harness.dart';

const Profile _male = Profile(
  sex: Sex.male,
  birthYear: 1990,
  heightCm: 178,
  activityLevel: ActivityLevel.moderate,
);

Finder _field(String name) => find.byWidgetPredicate(
  (Widget w) => w is FieldRow && w.name == name,
  description: 'FieldRow $name',
);

/// Scrolls the entry form to [name] and types [text] into its box.
Future<void> _enter(WidgetTester tester, String name, String text) async {
  await reveal(tester, _field(name), within: find.byType(EntryScreen));
  await tester.enterText(
    find.descendant(of: _field(name), matching: find.byType(TextField)),
    text,
  );
  await tester.pump();
}

Future<void> _scrollTo(WidgetTester tester, Finder f) => reveal(tester, f);

void main() {
  bodyTest('no data shows the empty state and locked stats', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await pumpBody(tester, database);

    expect(find.text('Body'), findsWidgets);
    expect(find.text('Your shape, over time'), findsOneWidget);
    expect(find.text('Add first entry'), findsOneWidget);
    expect(find.text('Add entry'), findsOneWidget);
    // BMI is locked and says exactly what it needs.
    expect(
      find.text(
        lockedStatMessage(const <StatInput>[
          StatInput.weight,
          StatInput.height,
        ]),
      ),
      findsOneWidget,
    );
    await _scrollTo(tester, find.text('Waist to height'));
    expect(
      find.text(
        lockedStatMessage(const <StatInput>[StatInput.waist, StatInput.height]),
      ),
      findsOneWidget,
    );
    expect(find.text('LATEST MEASUREMENTS'), findsNothing);
  });

  bodyTest('a locked profile input sends you to the profile', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    // Weight and waist are logged; height is not, so BMI needs the profile.
    await db(
      tester,
      () => measurementsOf(database).saveEntry(
        entryOf('e1', DateTime(2026, 10, 30), <String, double>{
          'weight': 80,
          'waist': 90,
        }),
      ),
    );
    await pumpBody(tester, database);
    expect(
      find.text(lockedStatMessage(const <StatInput>[StatInput.height])),
      findsWidgets,
    );
    await tester.tap(find.text('Open profile').first);
    await settle(tester);
    expect(find.text('Profile screen'), findsOneWidget);
  });

  bodyTest('adding an entry fills BMI and body fat from BodyStats', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database, profile: _male);
    await tester.tap(find.text('Add entry'));
    await settle(tester);
    expect(find.text('New entry'), findsOneWidget);

    await _enter(tester, 'Weight', '78.4');
    await _enter(tester, 'Neck', '39');
    await _enter(tester, 'Waist', '84');
    await _enter(tester, 'Hips', '98');
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(router.state.uri.path, Routes.body);

    final BodyStatsInput input = BodyStatsInput(
      now: kToday,
      weightKg: 78.4,
      heightCm: 178,
      waistCm: 84,
      neckCm: 39,
      hipsCm: 98,
      sex: Sex.male,
      birthYear: 1990,
      activityLevel: ActivityLevel.moderate,
    );
    final double bmi = BodyStats.bmi(input).valueOrNull!;
    final double bf = BodyStats.bodyFat(input).valueOrNull!.primary;
    expect(find.text(bmi.toStringAsFixed(1)), findsOneWidget);
    expect(find.textContaining('Healthy weight'), findsWidgets);
    await _scrollTo(tester, find.text('Body fat'));
    expect(find.text(bf.toStringAsFixed(1)), findsOneWidget);
    expect(find.text('Estimate, US Navy method'), findsOneWidget);
    // The saved values are listed under Latest measurements.
    await _scrollTo(tester, find.text('LATEST MEASUREMENTS'));
    expect(find.text('Waist'), findsWidgets);
    expect(find.text('84 cm'), findsOneWidget);
  });

  bodyTest('inches and pounds convert on input and save metric', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(
      tester,
      database,
      profile: _male.copyWith(
        lengthUnit: LengthUnit.inch,
        weightUnit: WeightUnit.lb,
      ),
    );
    await pushRoute(tester, router, Routes.newEntry);
    await _enter(tester, 'Weight', '176');
    await _enter(tester, 'Waist', '33');
    await tester.tap(find.text('Save'));
    await settle(tester);

    final entries = (await db(
      tester,
      () => measurementsOf(database).entries(),
    ))!;
    expect(entries, hasLength(1));
    expect(entries.single.values['weight'], closeTo(176 * 0.45359237, 1e-9));
    expect(entries.single.values['waist'], closeTo(33 * 2.54, 1e-9));
    // Shown back in the user's units.
    await _scrollTo(tester, find.text('LATEST MEASUREMENTS'));
    expect(find.text('176 lb'), findsOneWidget);
    expect(find.text('33 in'), findsOneWidget);
  });

  bodyTest('only filled values are stored and an empty save is refused', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.newEntry);
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(
      find.text('Add at least one value to save this entry'),
      findsOneWidget,
    );
    expect(await db(tester, () => measurementsOf(database).entries()), isEmpty);

    hideSinewSnackBar();
    await tester.pump();
    await _enter(tester, 'Chest', '101');
    await tester.tap(find.text('Save'));
    await settle(tester);
    final entries = (await db(
      tester,
      () => measurementsOf(database).entries(),
    ))!;
    expect(entries.single.values, <String, double>{'chest': 101});
  });

  bodyTest('editing an entry shows its values and delete offers undo', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await db(tester, () async {
      await measurementsOf(database).saveEntry(
        entryOf('old', DateTime(2026, 10, 24), <String, double>{'waist': 85}),
      );
      await measurementsOf(database).saveEntry(
        entryOf('recent', DateTime(2026, 10, 30), <String, double>{
          'waist': 84,
        }),
      );
    });
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.entry('recent'));
    expect(find.text('Edit entry'), findsOneWidget);
    // The previous entry shows as the grey hint.
    expect(find.text('85'), findsOneWidget);
    expect(find.text('84'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate((Widget w) => w is SinewOverflowButton).first,
    );
    await settle(tester);
    await tester.tap(find.text('Delete entry'));
    await settle(tester);
    await tester.tap(find.text('Delete').last);
    await settle(tester);
    expect(
      (await db(
        tester,
        () => measurementsOf(database).entries(),
      ))!.map((e) => e.id),
      <String>['old'],
    );
    expect(find.text('Entry deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(
      (await db(tester, () => measurementsOf(database).entries()))!.length,
      2,
    );
  });

  bodyTest('tapping a silhouette level opens its region sheet', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await db(tester, () async {
      await measurementsOf(database).saveEntry(
        entryOf('a', DateTime(2026, 10, 24), <String, double>{
          'waist': 85,
          'chest': 100,
          'hips': 99,
        }),
      );
      await measurementsOf(database).saveEntry(
        entryOf('b', DateTime(2026, 10, 30), <String, double>{
          'waist': 84,
          'chest': 101,
          'hips': 98,
        }),
      );
    });
    await pumpBody(tester, database, profile: _male);
    final SilhouetteView view = tester.widget(find.byType(SilhouetteView));
    expect(view.onLevelTap, isNotNull);
    view.onLevelTap!(BodyAnchor.waist);
    await settle(tester);
    expect(find.text('84 cm'), findsWidgets);
    expect(find.text('See all entries'), findsOneWidget);
    expect(find.text('Add waist'), findsOneWidget);
    await tester.tap(find.text('See all entries'));
    await settle(tester);
    expect(find.text('Progress'), findsWidgets);
  });

  bodyTest('stat info explains the formula and the cut-offs', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await db(
      tester,
      () => measurementsOf(database).saveEntry(
        entryOf('a', DateTime(2026, 10, 30), <String, double>{'weight': 78.4}),
      ),
    );
    await pumpBody(
      tester,
      database,
      profile: _male.copyWith(bmiCutoffs: BmiCutoffs.asian),
    );
    final Finder info = find.byWidgetPredicate(
      (Widget w) => w is AppIconButton && w.semanticLabel == 'About BMI',
    );
    await reveal(tester, info);
    await tester.tap(info);
    await settle(tester);
    expect(find.text('About BMI'), findsOneWidget);
    expect(find.text('Asian cut-offs'), findsOneWidget);
    expect(
      find.textContaining('weight (kg) divided by height (m) squared'),
      findsOneWidget,
    );
  });

  bodyTest('overview lays out at 200% text on a 360dp phone', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await db(
      tester,
      () => measurementsOf(database).saveEntry(
        entryOf('a', DateTime(2026, 10, 30), <String, double>{
          'weight': 78.4,
          'waist': 84,
          'neck': 39,
          'hips': 98,
          'bicep-left': 34,
          'bicep-right': 33.5,
        }),
      ),
    );
    await pumpBody(tester, database, textScale: 2, profile: _male);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  bodyTest('empty overview lays out at 200% text', (WidgetTester tester) async {
    final UserDatabase database = await seededDb(tester);
    await pumpBody(tester, database, textScale: 2);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  bodyTest('entry screen lays out at 200% text with every field', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database, textScale: 2);
    await pushRoute(tester, router, Routes.newEntry);
    expect(tester.takeException(), isNull);
    await tester.drag(
      find
          .descendant(
            of: find.byType(EntryScreen),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, -6000),
    );
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Note'), findsWidgets);
  });
}
