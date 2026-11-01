import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/configs.dart';
import 'package:sinew/core/widgets/sinew_app_bar.dart';
import 'package:sinew/core/widgets/sinew_chips.dart';
import 'package:sinew/core/widgets/sinew_extended_fab.dart';
import 'package:sinew/core/widgets/sinew_form.dart';
import 'package:sinew/core/widgets/sinew_list.dart';
import 'package:sinew/core/widgets/sinew_menu.dart';
import 'package:sinew/core/widgets/sinew_segmented_control.dart';

import 'harness.dart';

void main() {
  group('SinewSegmentedControl', () {
    testWidgets('selecting a segment reports its value; check on selected', (
      WidgetTester tester,
    ) async {
      String selected = 'a';
      late StateSetter set;
      await pumpThemed(
        tester,
        StatefulBuilder(
          builder: (BuildContext c, StateSetter s) {
            set = s;
            return SinewSegmentedControl<String>(
              values: const <String>['a', 'b', 'c'],
              labels: const <String>['Routines', 'History', 'Library'],
              selected: selected,
              onSelected: (String v) => s(() => selected = v),
            );
          },
        ),
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(selected, 'b');
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      set(() {});
    });

    testWidgets('no check for four or more segments', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SinewSegmentedControl<int>(
          values: const <int>[0, 1, 2, 3],
          labels: const <String>['S', 'L', 'D', 'A'],
          selected: 1,
          onSelected: (int _) {},
        ),
      );
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('a disabled control ignores taps', (WidgetTester tester) async {
      int calls = 0;
      await pumpThemed(
        tester,
        SinewSegmentedControl<int>(
          values: const <int>[0, 1],
          labels: const <String>['One', 'Two'],
          selected: 0,
          enabled: false,
          onSelected: (int _) => calls++,
        ),
      );
      await tester.tap(find.text('Two'));
      expect(calls, 0);
    });

    testWidgets('segments are buttons with selected state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpThemed(
        tester,
        SinewSegmentedControl<int>(
          values: const <int>[0, 1],
          labels: const <String>['One', 'Two'],
          selected: 1,
          onSelected: (int _) {},
        ),
      );
      expect(
        tester.getSemantics(find.text('Two')),
        isSemantics(label: 'Two', isButton: true, isSelected: true),
      );
      handle.dispose();
    });

    testWidgets('lays out three segments at 200% text on 360dp', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Padding(
          padding: const EdgeInsets.all(20),
          child: SinewSegmentedControl<int>(
            values: const <int>[0, 1, 2],
            labels: const <String>['Routines', 'History', 'Library'],
            selected: 0,
            onSelected: (int _) {},
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('SinewChip', () {
    testWidgets('selected shows a check and the tonal fill', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SinewChip(label: 'Strength', selected: true),
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(tester.getSize(find.byType(SinewChip)).height, 32);
    });

    testWidgets('unselected has no check and taps through', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(tester, SinewChip(label: 'Yoga', onTap: () => taps++));
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      await tester.tap(find.text('Yoga'));
      expect(taps, 1);
    });

    testWidgets('disabled ignores taps', (WidgetTester tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        SinewChip(label: 'Pilates', enabled: false, onTap: () => taps++),
      );
      await tester.tap(find.text('Pilates'));
      expect(taps, 0);
    });

    testWidgets('dropdown arrow, badge and delete', (
      WidgetTester tester,
    ) async {
      int deleted = 0;
      await pumpThemed(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SinewChip(label: 'Muscle', dropdown: true, badge: '2'),
            SinewChip(
              label: 'Barbell',
              selected: true,
              onDeleted: () => deleted++,
            ),
          ],
        ),
      );
      expect(find.byIcon(Icons.arrow_drop_down_rounded), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(deleted, 1);
    });

    testWidgets('dropdown chip picks from an anchored menu', (
      WidgetTester tester,
    ) async {
      String value = 'week';
      late StateSetter set;
      await pumpThemed(
        tester,
        StatefulBuilder(
          builder: (BuildContext c, StateSetter s) {
            set = s;
            return SinewDropdownChip<String>(
              value: value,
              options: const <SinewDropdownOption<String>>[
                SinewDropdownOption<String>('week', 'Week'),
                SinewDropdownOption<String>('month', 'Month'),
              ],
              onChanged: (String v) => s(() => value = v),
            );
          },
        ),
      );
      expect(find.text('Week'), findsOneWidget);
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(find.text('Month'), findsOneWidget);
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(value, 'month');
      expect(find.text('Month'), findsOneWidget);
      set(() {});
    });
  });

  group('showSinewMenu', () {
    testWidgets('returns the picked value and marks the selected row', (
      WidgetTester tester,
    ) async {
      String? picked;
      await pumpThemed(
        tester,
        Builder(
          builder: (BuildContext anchor) => TextButton(
            onPressed: () async {
              picked = await showSinewMenu<String>(
                context: anchor,
                entries: const <SinewMenuEntry<String>>[
                  SinewMenuEntry<String>.header('Sort'),
                  SinewMenuEntry<String>(
                    value: 'name',
                    label: 'Name',
                    selected: true,
                    icon: Icons.sort_by_alpha_rounded,
                  ),
                  SinewMenuEntry<String>(value: 'date', label: 'Date'),
                  SinewMenuEntry<String>.divider(),
                  SinewMenuEntry<String>(
                    value: 'del',
                    label: 'Delete',
                    destructive: true,
                  ),
                ],
              );
            },
            child: const Text('menu'),
          ),
        ),
      );
      await tester.tap(find.text('menu'));
      await tester.pumpAndSettle();
      expect(find.text('SORT'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();
      expect(picked, 'date');
    });

    testWidgets('dismissing returns null', (WidgetTester tester) async {
      String? picked = 'unset';
      await pumpThemed(
        tester,
        Builder(
          builder: (BuildContext anchor) => TextButton(
            onPressed: () async {
              picked = await showSinewMenu<String>(
                context: anchor,
                entries: const <SinewMenuEntry<String>>[
                  SinewMenuEntry<String>(value: 'a', label: 'A'),
                ],
              );
            },
            child: const Text('menu'),
          ),
        ),
      );
      await tester.tap(find.text('menu'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 700));
      await tester.pumpAndSettle();
      expect(picked, isNull);
    });
  });

  group('SinewAppBar', () {
    testWidgets('title, subtitle and a working back button', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  appBar: SinewAppBar(
                    title: 'Edit routine',
                    subtitle: 'Upper body A',
                    showBack: true,
                  ),
                ),
              ),
            ),
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('Edit routine'), findsOneWidget);
      expect(find.text('Upper body A'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Edit routine'), findsNothing);
    });

    testWidgets('overflow: info first, destructive last after a divider', (
      WidgetTester tester,
    ) async {
      int deleted = 0;
      await pumpThemed(
        tester,
        Scaffold(
          appBar: SinewAppBar(
            title: 'Train',
            infoConfig: const SinewInfoConfig(
              title: 'About routines',
              description: 'Routines are templates.',
            ),
            overflowConfig: SinewOverflowConfig(
              items: <SinewOverflowItem>[
                SinewOverflowItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete all',
                  isDestructive: true,
                  onTap: () => deleted++,
                ),
                SinewOverflowItem(
                  icon: Icons.sort_rounded,
                  label: 'Sort',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        scaffold: false,
      );
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      final double how = tester.getTopLeft(find.text('How it works')).dy;
      final double sort = tester.getTopLeft(find.text('Sort')).dy;
      final double del = tester.getTopLeft(find.text('Delete all')).dy;
      expect(how, lessThan(sort));
      expect(sort, lessThan(del));
      await tester.tap(find.text('Delete all'));
      await tester.pumpAndSettle();
      expect(deleted, 1);
    });

    testWidgets('How it works opens the info sheet', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const Scaffold(
          appBar: SinewAppBar(
            title: 'Body',
            infoConfig: SinewInfoConfig(
              title: 'About body stats',
              description: 'Derived from your measurements.',
            ),
          ),
        ),
        scaffold: false,
      );
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('How it works'));
      await tester.pumpAndSettle();
      expect(find.text('About body stats'), findsOneWidget);
    });

    testWidgets('icon buttons carry labels for TalkBack', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpThemed(
        tester,
        Scaffold(
          appBar: SinewAppBar(
            title: 'Library',
            showBack: true,
            search: SinewHeaderSearch(
              controller: TextEditingController(),
              onChanged: (String _) {},
              hint: 'Search exercises',
            ),
            overflowConfig: SinewOverflowConfig(
              items: <SinewOverflowItem>[
                SinewOverflowItem(
                  icon: Icons.sort_rounded,
                  label: 'Sort',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        scaffold: false,
      );
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.bySemanticsLabel('Search exercises'), findsOneWidget);
      expect(find.bySemanticsLabel('More options'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('search opens a pill, reports edits and clears on close', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      final List<String> seen = <String>[];
      await pumpThemed(
        tester,
        Scaffold(
          appBar: SinewAppBar(
            title: 'Library',
            search: SinewHeaderSearch(
              controller: controller,
              onChanged: seen.add,
            ),
          ),
        ),
        scaffold: false,
      );
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'bench');
      expect(seen.last, 'bench');
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(controller.text, isEmpty);
      expect(seen.last, '');
      expect(find.text('Library'), findsOneWidget);
    });

    testWidgets('lays out at 200% text with every slot', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Scaffold(
          appBar: SinewAppBar(
            title: 'A long screen title for testing',
            subtitle: 'And a subtitle',
            showBack: true,
            actions: <Widget>[
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            ],
            overflowConfig: SinewOverflowConfig(
              items: <SinewOverflowItem>[
                SinewOverflowItem(
                  icon: Icons.sort_rounded,
                  label: 'Sort',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        scaffold: false,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('SinewPageHeader shows a large title and subtitle', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SinewPageHeader(title: 'Evening, Gautam', subtitle: 'Rest day'),
      );
      expect(find.text('Evening, Gautam'), findsOneWidget);
      expect(find.text('Rest day'), findsOneWidget);
      final TextStyle style = tester
          .widget<Text>(find.text('Evening, Gautam'))
          .style!;
      expect(style.fontSize, 28);
      expect(style.fontWeight, FontWeight.w700);
    });
  });

  group('list widgets', () {
    testWidgets('list row sizes by content and taps through', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SinewListRow(title: 'One line'),
            const SinewListRow(title: 'Two', subtitle: 'sub'),
            SinewListRow(
              title: 'Three',
              subtitle: 'sub',
              below: const Text('below'),
              trailing: const SinewChevron(),
              onTap: () => taps++,
            ),
          ],
        ),
      );
      final List<double> h = <double>[
        for (final Type _ in <Type>[SinewListRow, SinewListRow, SinewListRow])
          0,
      ];
      final List<Element> rows = find.byType(SinewListRow).evaluate().toList();
      for (int i = 0; i < rows.length; i++) {
        h[i] = (rows[i].renderObject! as RenderBox).size.height;
      }
      expect(h[0], greaterThanOrEqualTo(56));
      expect(h[1], greaterThanOrEqualTo(72));
      expect(h[2], greaterThanOrEqualTo(88));
      await tester.tap(find.text('Three'));
      expect(taps, 1);
    });

    testWidgets('group draws dividers between rows only', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SinewGroup(
          children: <Widget>[
            SinewListRow(title: 'A'),
            SinewListRow(title: 'B'),
            SinewListRow(title: 'C'),
          ],
        ),
      );
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('section header uppercases and shows the action', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        SinewSectionHeader(
          title: 'Recent',
          trailing: SinewSectionAction(label: 'View all', onTap: () => taps++),
        ),
      );
      expect(find.text('RECENT'), findsOneWidget);
      await tester.tap(find.text('View all'));
      expect(taps, 1);
    });

    testWidgets('card, pill and icon tile build for every tone', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Wrap(
          children: <Widget>[
            for (final SinewTone t in SinewTone.values) ...<Widget>[
              SinewPill(label: t.name, tone: t),
              SinewIconTile(icon: Icons.bolt_rounded, tone: t),
            ],
            const SinewCard(child: Text('card')),
          ],
        ),
      );
      expect(find.byType(SinewPill), findsNWidgets(SinewTone.values.length));
      expect(tester.takeException(), isNull);
    });
  });

  group('forms', () {
    testWidgets('number field keeps digits and one decimal point only', (
      WidgetTester tester,
    ) async {
      final TextEditingController c = TextEditingController();
      await pumpThemed(
        tester,
        SinewTextField.number(label: 'Weight', controller: c, suffixText: 'kg'),
      );
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'a1b2.5c');
      expect(c.text, '12.5');
    });

    testWidgets('integer field refuses a decimal point', (
      WidgetTester tester,
    ) async {
      final TextEditingController c = TextEditingController();
      await pumpThemed(
        tester,
        SinewTextField.number(label: 'Reps', controller: c, decimal: false),
      );
      await tester.enterText(find.byType(TextField), '8.5');
      expect(c.text, '85');
    });

    testWidgets('error text and the optional marker show', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SinewTextField(
          label: 'Name',
          optional: true,
          controller: TextEditingController(),
          errorText: 'Required',
        ),
      );
      expect(find.text('Required'), findsOneWidget);
      expect(find.textContaining('optional'), findsOneWidget);
    });

    testWidgets('the info glyph is a labelled 48dp button', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        SinewTextField(
          label: 'Body fat',
          controller: TextEditingController(),
          onInfo: () => taps++,
        ),
      );
      final Finder glyph = find.byIcon(Icons.info_outline_rounded);
      expect(glyph, findsOneWidget);
      await tester.tap(glyph);
      expect(taps, 1);
    });

    testWidgets('picker row shows value over label and taps through', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        SinewPickerRow(
          leading: const Icon(Icons.timer_rounded),
          label: 'Rest',
          value: '90 s',
          onTap: () => taps++,
        ),
      );
      expect(find.text('90 s'), findsOneWidget);
      expect(find.text('Rest'), findsOneWidget);
      await tester.tap(find.text('90 s'));
      expect(taps, 1);
      expect(
        tester.getSize(find.byType(SinewPickerRow)).height,
        greaterThanOrEqualTo(72),
      );
    });

    testWidgets('callout shows each tone', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final SinewCalloutTone t in SinewCalloutTone.values)
              SinewCallout.text('note ${t.name}', tone: t),
          ],
        ),
      );
      expect(find.byType(SinewCallout), findsNWidgets(4));
    });

    testWidgets('form section joins children with a gap and a caps heading', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SinewFormSection(
          label: 'Details',
          children: <Widget>[Text('one'), Text('two')],
        ),
      );
      expect(find.text('DETAILS'), findsOneWidget);
      expect(find.text('one'), findsOneWidget);
    });
  });

  group('SinewExtendedFab', () {
    testWidgets('shows icon and label, and taps', (WidgetTester tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        Scaffold(
          floatingActionButtonLocation: sinewFabLocation,
          floatingActionButton: SinewExtendedFab(
            icon: Icons.add_rounded,
            label: 'New routine',
            onPressed: () => taps++,
          ),
        ),
        scaffold: false,
      );
      expect(find.text('New routine'), findsOneWidget);
      expect(tester.getSize(find.byType(SinewExtendedFab)).height, 56);
      await tester.tap(find.text('New routine'));
      expect(taps, 1);
    });

    testWidgets('sits at the end edge, 22 above the 56dp pill', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Scaffold(
          floatingActionButtonLocation: sinewFabLocation,
          floatingActionButton: SinewExtendedFab(
            icon: Icons.add_rounded,
            label: 'Add entry',
            onPressed: () {},
          ),
        ),
        scaffold: false,
      );
      final Rect r = tester.getRect(find.byType(SinewExtendedFab));
      expect(780 - r.bottom, 22 + 56 + 22);
      expect(360 - r.right, 20);
    });

    testWidgets('without the pill it sits at the pill offset', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Scaffold(
          floatingActionButtonLocation: sinewFabLocationFull,
          floatingActionButton: SinewExtendedFab(
            icon: Icons.add_rounded,
            label: 'Add entry',
            onPressed: () {},
          ),
        ),
        scaffold: false,
      );
      expect(780 - tester.getRect(find.byType(SinewExtendedFab)).bottom, 22);
    });

    testWidgets('hides while scrolling down and returns on scrolling up', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SinewFabScrollWatcher(
          child: Scaffold(
            floatingActionButton: SinewExtendedFab(
              icon: Icons.add_rounded,
              label: 'Add entry',
              onPressed: () {},
            ),
            body: ListView(
              children: <Widget>[
                for (int i = 0; i < 60; i++)
                  SizedBox(height: 60, child: Text('row $i')),
              ],
            ),
          ),
        ),
        scaffold: false,
      );
      expect(sinewFabVisible.value, isTrue);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(sinewFabVisible.value, isFalse);
      await tester.drag(find.byType(ListView), const Offset(0, 120));
      await tester.pumpAndSettle();
      expect(sinewFabVisible.value, isTrue);
    });
  });

  group('theme extensions on a widget', () {
    testWidgets('context.cs / colors / accents / text resolve', (
      WidgetTester tester,
    ) async {
      late BuildContext captured;
      await pumpThemed(
        tester,
        Builder(
          builder: (BuildContext c) {
            captured = c;
            return const SizedBox();
          },
        ),
      );
      expect(captured.cs.primary, captured.colors.primary);
      expect(captured.accents.plates, isNotEmpty);
      expect(captured.text.bodyMedium!.fontFamily, 'Inter');
      expect(captured.timerNumeral.fontSize, 150);
      expect(captured.mono.fontFamily, 'JetBrainsMono');
      expect(captured.serifAccent.fontStyle, FontStyle.italic);
      expect(captured.sectionHeader.letterSpacing, 0.8);
    });

    testWidgets('AMOLED scaffolds on black', (WidgetTester tester) async {
      await pumpThemed(tester, const SizedBox(), tone: Tone.amoled);
      final Scaffold sc = tester.widget(find.byType(Scaffold));
      final BuildContext ctx = tester.element(find.byType(Scaffold));
      expect(Theme.of(ctx).scaffoldBackgroundColor, const Color(0xFF000000));
      expect(sc, isNotNull);
    });
  });
}
