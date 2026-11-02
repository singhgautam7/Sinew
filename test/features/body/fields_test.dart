import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/widgets/app_icon_button.dart';
import 'package:sinew/core/widgets/domain/field_row.dart';

import 'body_harness.dart';

Future<List<MeasurementField>> _fields(
  WidgetTester tester,
  UserDatabase database,
) async => (await db(
  tester,
  () => measurementsOf(database).fields(includeArchived: true),
))!;

Finder _row(String name) => find.byWidgetPredicate(
  (Widget w) => w is FieldManagerRow && w.name == name,
);

final Finder _more = find.byWidgetPredicate(
  (Widget w) =>
      w is AppIconButton && w.semanticLabel.startsWith('More options'),
);

Future<void> _openEditor(WidgetTester tester, String name) async {
  await tester.tap(_row(name));
  await settle(tester);
}

void main() {
  bodyTest('lists built-in fields with a count of those shown', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.fields);
    expect(find.text('Measurement fields'), findsOneWidget);
    expect(find.text('18 of 18 shown on new entries'), findsOneWidget);
    expect(find.text('BUILT IN'), findsOneWidget);
    await reveal(tester, find.text('Add custom field'));
    expect(find.text('Add custom field'), findsOneWidget);
  });

  bodyTest('disabling a field hides it and updates the count', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.fields);

    await tester.tap(
      find.descendant(of: _row('Weight'), matching: find.byType(Switch)),
    );
    await settle(tester);
    expect(find.text('17 of 18 shown on new entries'), findsOneWidget);
    final MeasurementField weight = (await _fields(
      tester,
      database,
    )).firstWhere((MeasurementField f) => f.id == 'weight');
    expect(weight.enabled, isFalse);
  });

  bodyTest('a built-in field can be renamed but not removed', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.fields);

    await _openEditor(tester, 'Neck');
    expect(find.text('Edit field'), findsOneWidget);
    expect(find.text('BUILT IN'), findsWidgets);
    expect(find.text('UNIT'), findsNothing);
    await tester.enterText(find.byType(TextField).last, 'Neck girth');
    await tester.pump();
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.text('Neck girth'), findsOneWidget);
    expect(
      (await _fields(
        tester,
        database,
      )).firstWhere((MeasurementField f) => f.id == 'neck').name,
      'Neck girth',
    );

    await tester.tap(find.descendant(of: _row('Neck girth'), matching: _more));
    await settle(tester);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Remove'), findsNothing);
  });

  bodyTest('adds a custom field, then removes it (deleted when empty)', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.fields);

    await reveal(tester, find.text('Add custom field'));
    await tester.tap(find.text('Add custom field'));
    await settle(tester);
    expect(find.text('New field'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Wrist');
    await tester.pump();
    await tester.tap(find.text('Length'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await settle(tester);

    final List<MeasurementField> all = await _fields(tester, database);
    final MeasurementField wrist = all.firstWhere(
      (MeasurementField f) => f.name == 'Wrist',
    );
    expect(wrist.builtIn, isFalse);
    expect(wrist.position, 18);
    expect(find.text('CUSTOM'), findsOneWidget);

    await reveal(tester, _row('Wrist'));
    await tester.tap(find.descendant(of: _row('Wrist'), matching: _more));
    await settle(tester);
    await tester.tap(find.text('Remove'));
    await settle(tester);
    expect(find.text('Remove Wrist?'), findsOneWidget);
    await tester.tap(find.text('Remove').last);
    await settle(tester);
    expect(find.text('Wrist deleted'), findsOneWidget);
    expect(
      (await _fields(
        tester,
        database,
      )).any((MeasurementField f) => f.name == 'Wrist'),
      isFalse,
    );
  });

  bodyTest('removing a custom field with data archives it', (
    WidgetTester tester,
  ) async {
    final UserDatabase database = await seededDb(tester);
    await db(tester, () async {
      await measurementsOf(database).saveField(
        MeasurementField(
          id: 'custom-wrist',
          name: 'Wrist',
          unitType: MeasurementUnitType.length,
          position: 18,
          updatedAt: kToday,
        ),
      );
      await measurementsOf(database).saveEntry(
        entryOf('e1', DateTime(2026, 10, 1), <String, double>{
          'custom-wrist': 17,
        }),
      );
    });
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.fields);

    await reveal(tester, _row('Wrist'));
    await tester.tap(find.descendant(of: _row('Wrist'), matching: _more));
    await settle(tester);
    await tester.tap(find.text('Remove'));
    await settle(tester);
    expect(find.textContaining('archived instead of deleted'), findsOneWidget);
    await tester.tap(find.text('Remove').last);
    await settle(tester);
    expect(
      find.text('Wrist archived. Its past values are kept.'),
      findsOneWidget,
    );
    final MeasurementField f = (await _fields(
      tester,
      database,
    )).firstWhere((MeasurementField f) => f.id == 'custom-wrist');
    expect(f.archived, isTrue);
    expect(f.enabled, isFalse);
    expect(
      (await db(
        tester,
        () => measurementsOf(database).entries(),
      ))!.single.values['custom-wrist'],
      17,
    );
  });

  bodyTest('dragging a row saves the new order', (WidgetTester tester) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database);
    await pushRoute(tester, router, Routes.fields);

    final Finder handleBox = find.descendant(
      of: _row('Weight'),
      matching: find.byType(ReorderableDragStartListener),
    );
    expect(handleBox, findsOneWidget);
    final Offset start = tester.getCenter(handleBox);
    final TestGesture g = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 100));
    await g.moveBy(const Offset(0, 80));
    await tester.pump(const Duration(milliseconds: 100));
    await g.moveBy(const Offset(0, 80));
    await tester.pump(const Duration(milliseconds: 100));
    await g.up();
    await settle(tester);

    final List<MeasurementField> now = await _fields(tester, database);
    final List<String> order =
        (now.toList()..sort((a, b) => a.position.compareTo(b.position)))
            .map((MeasurementField f) => f.id)
            .toList();
    expect(order.first, isNot('weight'));
    expect(order.indexOf('weight'), greaterThan(0));
  });

  bodyTest('fields screen lays out at 200% text', (WidgetTester tester) async {
    final UserDatabase database = await seededDb(tester);
    final GoRouter router = await pumpBody(tester, database, textScale: 2);
    await pushRoute(tester, router, Routes.fields);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -4000));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await reveal(tester, find.text('Add custom field'));
    await tester.tap(find.text('Add custom field'));
    await settle(tester);
    expect(find.text('New field'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
