import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/widgets/app_button.dart';
import 'package:sinew/core/widgets/configs.dart';
import 'package:sinew/core/widgets/icon_color_picker_sheet.dart';
import 'package:sinew/core/widgets/sinew_bottom_sheet.dart';
import 'package:sinew/core/widgets/sinew_dialogs.dart';

import 'harness.dart';

void main() {
  group('SinewBottomSheet', () {
    testWidgets('shows handle, title, description, body and pinned actions', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showSinewBottomSheet<void>(
            context: c,
            builder: (_) => SinewBottomSheet(
              title: 'Rest timer',
              subtitle: 'Workout',
              description: 'Counts down between sets',
              actions: AppButton(
                label: 'Save',
                fullWidth: true,
                onPressed: () {},
              ),
              child: const Text('body content'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Rest timer'), findsOneWidget);
      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('Counts down between sets'), findsOneWidget);
      expect(find.text('body content'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      // The handle is 32x4.
      final Finder handle = find.byWidgetPredicate(
        (Widget w) =>
            w is Container &&
            w.constraints?.maxWidth == 32 &&
            w.constraints?.maxHeight == 4,
      );
      expect(handle, findsOneWidget);
    });

    testWidgets('the close button dismisses it', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showSinewBottomSheet<void>(
            context: c,
            builder: (_) =>
                const SinewBottomSheet(title: 'Sheet', child: Text('x')),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsNothing);
    });

    testWidgets('a long body scrolls and the header stays', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showSinewBottomSheet<void>(
            context: c,
            builder: (_) => SinewBottomSheet(
              title: 'Long',
              child: Column(
                children: <Widget>[for (int i = 0; i < 40; i++) Text('row $i')],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.drag(find.text('row 3'), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Long'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out at 200% text', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showSinewBottomSheet<void>(
            context: c,
            builder: (_) => SinewBottomSheet(
              title: 'A reasonably long sheet title',
              description: 'And a description that wraps',
              actions: AppButton(
                label: 'Done',
                fullWidth: true,
                onPressed: () {},
              ),
              child: const Text('content'),
            ),
          ),
        ),
        textScale: 2,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Info sheet', () {
    testWidgets('renders the config and closes on Done', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showSinewInfoSheet(
            c,
            const SinewInfoConfig(
              title: 'Body fat',
              description: 'Estimated with the US Navy method.',
              items: <SinewInfoItem>[
                SinewInfoItem(
                  icon: Icons.straighten_rounded,
                  title: 'Needs neck and waist',
                  description: 'Add both to see a value.',
                ),
              ],
              exampleBlock: SinewInfoExampleBlock(
                label: 'Example',
                sentence: 'For a 180 cm man',
                rows: <SinewInfoExampleRow>[
                  SinewInfoExampleRow('Waist', '85 cm'),
                  SinewInfoExampleRow('Result', '16.4 %', highlight: true),
                ],
                after: 'An estimate only.',
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Body fat'), findsOneWidget);
      expect(find.text('Estimated with the US Navy method.'), findsOneWidget);
      expect(find.text('Needs neck and waist'), findsOneWidget);
      expect(find.text('EXAMPLE'), findsOneWidget);
      expect(find.text('16.4 %'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Body fat'), findsNothing);
    });
  });

  group('showSinewConfirmDialog', () {
    Future<bool?> run(
      WidgetTester tester, {
      required bool destructive,
      required String tap,
    }) async {
      bool? result;
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) async {
            result = await showSinewConfirmDialog(
              context: c,
              title: 'Delete routine?',
              message: 'This cannot be undone.',
              confirmLabel: 'Delete',
              destructive: destructive,
            );
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete routine?'), findsOneWidget);
      await tester.tap(find.text(tap));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('confirm returns true', (WidgetTester tester) async {
      expect(await run(tester, destructive: true, tap: 'Delete'), isTrue);
    });

    testWidgets('cancel returns false', (WidgetTester tester) async {
      expect(await run(tester, destructive: false, tap: 'Cancel'), isFalse);
    });

    testWidgets('a destructive confirm is a solid danger button', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showSinewConfirmDialog(
            context: c,
            title: 'Discard?',
            message: 'Gone.',
            confirmLabel: 'Discard',
            destructive: true,
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final AppButton b = tester.widget(
        find.widgetWithText(AppButton, 'Discard'),
      );
      expect(b.type, AppButtonType.danger);
      expect(b.filled, isTrue);
    });
  });

  group('icon and colour picker', () {
    const Map<String, IconData> icons = <String, IconData>{
      'dumbbell': Icons.fitness_center_rounded,
      'timer': Icons.timer_rounded,
      'heart': Icons.favorite_rounded,
    };

    testWidgets('picks stay local until Done, then are reported', (
      WidgetTester tester,
    ) async {
      SinewIconColor? done;
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showIconColorPicker(
            context: c,
            icons: icons,
            initial: const SinewIconColor(iconKey: 'dumbbell'),
            onDone: (SinewIconColor v) => done = v,
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Choose icon'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.timer_rounded));
      await tester.pump();

      await tester.tap(find.text('Colour'));
      await tester.pumpAndSettle();
      expect(find.text('Choose colour'), findsOneWidget);
      expect(find.text('VIBRANT'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<int>(0xFF8B5CF6)));
      await tester.pump();

      expect(done, isNull);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(done, isNotNull);
      expect(done!.iconKey, 'timer');
      expect(done!.colorValue, 0xFF8B5CF6);
    });

    testWidgets('closing discards the picks', (WidgetTester tester) async {
      SinewIconColor? done;
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showIconColorPicker(
            context: c,
            icons: icons,
            initial: const SinewIconColor(iconKey: 'dumbbell'),
            onDone: (SinewIconColor v) => done = v,
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(done, isNull);
    });

    testWidgets('extra tabs append after Icon and Colour', (
      WidgetTester tester,
    ) async {
      SinewIconColor? done;
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showIconColorPicker(
            context: c,
            icons: icons,
            initial: const SinewIconColor(iconKey: 'dumbbell'),
            onDone: (SinewIconColor v) => done = v,
            extraTabs: <SinewPickerTab>[
              SinewPickerTab(
                id: 'muscle',
                label: 'Muscle map',
                title: 'Choose muscles',
                builder:
                    (
                      BuildContext context,
                      SinewIconColor v,
                      ValueChanged<SinewIconColor> on,
                    ) => TextButton(
                      onPressed: () => on(
                        v.copyWith(extra: <String, Object?>{'muscle': 'chest'}),
                      ),
                      child: const Text('pick chest'),
                    ),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Icon'), findsOneWidget);
      expect(find.text('Colour'), findsOneWidget);
      await tester.tap(find.text('Muscle map'));
      await tester.pumpAndSettle();
      expect(find.text('Choose muscles'), findsOneWidget);
      await tester.tap(find.text('pick chest'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(done!.extra['muscle'], 'chest');
    });

    testWidgets('icon search filters the grid', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        Opener(
          onTap: (BuildContext c) => showIconColorPicker(
            context: c,
            icons: icons,
            initial: const SinewIconColor(iconKey: 'dumbbell'),
            onDone: (SinewIconColor _) {},
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'hea');
      await tester.pump();
      expect(find.byIcon(Icons.timer_rounded), findsNothing);
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(find.text('No icons match'), findsOneWidget);
    });
  });
}
