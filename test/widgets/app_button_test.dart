import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/app_button.dart';
import 'package:sinew/core/widgets/app_icon_button.dart';

import 'harness.dart';

void main() {
  group('AppButton', () {
    testWidgets('taps through and shows its label and icon', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        AppButton(
          label: 'Start',
          icon: Icons.play_arrow_rounded,
          type: AppButtonType.primary,
          onPressed: () => taps++,
        ),
      );
      expect(find.text('Start'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      await tester.tap(find.text('Start'));
      expect(taps, 1);
    });

    testWidgets('large is 56 high, small is 40 drawn in a 48 hit area', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppButton(label: 'Large', onPressed: () {}),
            AppButton(label: 'Small', height: 40, onPressed: () {}),
          ],
        ),
      );
      expect(tester.getSize(find.byType(AppButton).first).height, 56);
      expect(tester.getSize(find.byType(AppButton).last).height, 48);
      final Finder pill = find.descendant(
        of: find.byType(AppButton).last,
        matching: find.byType(Material),
      );
      expect(tester.getSize(pill.first).height, 40);
    });

    testWidgets('the margin around a 40dp button is tappable', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        AppButton(label: 'Small', height: 40, onPressed: () => taps++),
      );
      final Rect box = tester.getRect(find.byType(AppButton));
      expect(box.height, 48);
      // 2dp inside the top edge is outside the 40dp pill, inside the target.
      await tester.tapAt(Offset(box.center.dx, box.top + 2));
      expect(taps, 1);
    });

    testWidgets('null onPressed disables it', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        const AppButton(label: 'Save', type: AppButtonType.primary),
      );
      final ColorScheme cs = AppTheme.of(Tone.light).colorScheme;
      final Text label = tester.widget(find.text('Save'));
      expect(
        label.style!.color,
        cs.onSurface.withValues(alpha: Opacities.disabled),
      );
    });

    testWidgets('loading swaps the icon for a spinner and ignores taps', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        AppButton(
          label: 'Saving',
          icon: Icons.save_rounded,
          isLoading: true,
          type: AppButtonType.primary,
          onPressed: () => taps++,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.save_rounded), findsNothing);
      await tester.tap(find.text('Saving'));
      expect(taps, 0);
    });

    testWidgets('fullWidth fills the row', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(label: 'Wide', fullWidth: true, onPressed: () {}),
        ),
      );
      expect(tester.getSize(find.byType(AppButton)).width, 360 - 32);
    });

    testWidgets('danger is tonal by default and solid when filled', (
      WidgetTester tester,
    ) async {
      final ColorScheme cs = AppTheme.of(Tone.light).colorScheme;
      Color fill() {
        final Material m = tester.widget(
          find
              .descendant(
                of: find.byType(AppButton),
                matching: find.byType(Material),
              )
              .first,
        );
        return m.color!;
      }

      await pumpThemed(
        tester,
        AppButton(
          label: 'Delete',
          type: AppButtonType.danger,
          onPressed: () {},
        ),
      );
      expect(fill(), cs.errorContainer);
      await pumpThemed(
        tester,
        AppButton(
          label: 'Delete',
          type: AppButtonType.danger,
          filled: true,
          onPressed: () {},
        ),
      );
      expect(fill(), cs.error);
    });

    testWidgets('exposes button semantics with label and enabled state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpThemed(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppButton(label: 'On', onPressed: () {}),
            const AppButton(label: 'Off'),
          ],
        ),
      );
      expect(
        tester.getSemantics(find.byType(AppButton).first),
        isSemantics(
          label: 'On',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.byType(AppButton).last),
        isSemantics(label: 'Off', isButton: true, isEnabled: false),
      );
      handle.dispose();
    });

    testWidgets('survives 200% text without overflow', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 200,
          child: AppButton(
            label: 'A fairly long button label',
            icon: Icons.add_rounded,
            fullWidth: true,
            onPressed: () {},
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('dotted draws without error', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        AppButton(label: 'Add', type: AppButtonType.dotted, onPressed: () {}),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppIconButton', () {
    testWidgets('has a 48dp target and a required semantic label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int taps = 0;
      await pumpThemed(
        tester,
        AppIconButton(
          icon: Icons.add_rounded,
          semanticLabel: 'Add set',
          onPressed: () => taps++,
        ),
      );
      expect(tester.getSize(find.byType(AppIconButton)).shortestSide, 48);
      expect(
        tester.getSemantics(find.byType(AppIconButton)),
        isSemantics(label: 'Add set', isButton: true, hasTapAction: true),
      );
      await tester.tap(find.byType(AppIconButton));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('null onPressed disables it', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        const AppIconButton(
          icon: Icons.add_rounded,
          semanticLabel: 'Add',
          onPressed: null,
        ),
      );
      final Opacity o = tester.widget(find.byType(Opacity).first);
      expect(o.opacity, Opacities.disabled);
    });

    testWidgets('badge shows its count', (WidgetTester tester) async {
      await pumpThemed(
        tester,
        AppIconButton(
          icon: Icons.filter_list_rounded,
          semanticLabel: 'Filters',
          badge: '3',
          onPressed: () {},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    });
  });
}
