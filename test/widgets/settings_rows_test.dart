import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/widgets/sinew_settings.dart';

import 'harness.dart';

void main() {
  testWidgets('a section shows its caps label and its rows', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      SinewSettingsSection(
        label: 'Appearance',
        children: <Widget>[
          SinewNavigationRow(
            icon: Icons.palette_outlined,
            label: 'Theme',
            onTap: () {},
          ),
          const SinewValueRow(
            icon: Icons.straighten_rounded,
            label: 'Units',
            value: 'Metric',
          ),
        ],
      ),
    );
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('Metric'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  group('SinewSwitchRow', () {
    testWidgets('tapping anywhere on the row toggles', (
      WidgetTester tester,
    ) async {
      bool value = false;
      late StateSetter set;
      await pumpThemed(
        tester,
        StatefulBuilder(
          builder: (BuildContext c, StateSetter s) {
            set = s;
            return SinewSwitchRow(
              icon: Icons.vibration_rounded,
              label: 'Haptics',
              subtitle: 'Buzz on set complete',
              value: value,
              onChanged: (bool v) => s(() => value = v),
            );
          },
        ),
      );
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      await tester.tap(find.text('Haptics'));
      await tester.pump();
      expect(value, isTrue);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      await tester.tap(find.text('Buzz on set complete'));
      await tester.pump();
      expect(value, isFalse);
      set(() {});
    });

    testWidgets('a disabled row does not toggle', (WidgetTester tester) async {
      int calls = 0;
      await pumpThemed(
        tester,
        SinewSwitchRow(
          icon: Icons.lock_outline_rounded,
          label: 'Locked',
          value: false,
          enabled: false,
          onChanged: (bool _) => calls++,
        ),
      );
      await tester.tap(find.text('Locked'));
      expect(calls, 0);
    });

    testWidgets('exposes one toggle node with its label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpThemed(
        tester,
        SinewSwitchRow(
          icon: Icons.vibration_rounded,
          label: 'Haptics',
          value: true,
          onChanged: (bool _) {},
        ),
      );
      expect(
        tester.getSemantics(find.byType(SinewSwitchRow)),
        isSemantics(label: 'Haptics', hasToggledState: true, isToggled: true),
      );
      handle.dispose();
    });
  });

  testWidgets('a navigation row taps through and shows a chevron', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await pumpThemed(
      tester,
      SinewNavigationRow(
        icon: Icons.backup_outlined,
        label: 'Backup',
        subtitle: 'Last backup 3 days ago',
        onTap: () => taps++,
      ),
    );
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    expect(find.text('Last backup 3 days ago'), findsOneWidget);
    await tester.tap(find.text('Backup'));
    expect(taps, 1);
  });

  group('SinewValueRow', () {
    testWidgets('shows the value and opens on tap', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        SinewValueRow(
          icon: Icons.scale_rounded,
          label: 'Weight unit',
          value: 'kg',
          onTap: () => taps++,
        ),
      );
      expect(find.text('kg'), findsOneWidget);
      await tester.tap(find.text('Weight unit'));
      expect(taps, 1);
    });

    testWidgets('without onTap it is read only: no chevron', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SinewValueRow(
          icon: Icons.info_outline_rounded,
          label: 'Version',
          value: '1.0',
        ),
      );
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    testWidgets('a long value ellipsizes instead of overflowing', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        const SinewValueRow(
          icon: Icons.palette_outlined,
          label: 'Theme family',
          value: 'A very long family name that cannot fit in the row',
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('rows are at least 56dp tall and keep 48dp targets', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      SinewNavigationRow(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () {},
      ),
    );
    expect(
      tester.getSize(find.byType(SinewSettingsTile)).height,
      greaterThanOrEqualTo(56),
    );
  });
}
