import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/platform/platform_channel.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/features/about/about_screen.dart';
import 'package:sinew/features/about/attributions.dart';

import '../../helpers/phase8_finders.dart';
import '../../helpers/phase8_harness.dart';

void _fakeVersion(String? version) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SinewPlatform.channel, (MethodCall call) async {
        return call.method == 'appVersion' ? version : null;
      });
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SinewPlatform.channel, null),
  );
}

void main() {
  test('the attributions in code match specs/data/ATTRIBUTIONS.md', () {
    final String file = File('specs/data/ATTRIBUTIONS.md').readAsStringSync();
    expect(kAttributionsMarkdown.trim(), file.trim());
  });

  test('version labels', () {
    expect(versionLabel('1.2.3+45'), 'Version 1.2.3 (45)');
    expect(versionLabel('1.2.3'), 'Version 1.2.3');
    expect(versionLabel(null), 'Version unknown');
    expect(versionLabel(''), 'Version unknown');
  });

  testWidgets('shows the version from the platform, not from Dart', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    _fakeVersion('1.2.3+45');
    await pumpSinew(tester, location: Routes.about);
    await reveal(tester, find.byKey(const ValueKey<String>('about-version')));
    expect(find.text('Version 1.2.3 (45)'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('states the offline promise and credits the data and fonts', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    _fakeVersion('0.1.0+1');
    await pumpSinew(tester, location: Routes.about);
    expect(find.textContaining('makes no network requests'), findsOneWidget);
    expect(find.textContaining('collects nothing'), findsOneWidget);

    // Every source in the markdown file is rendered, with its licence.
    await reveal(tester, find.text('1. Free Exercise DB'));
    expect(find.textContaining('yuhonas/free-exercise-db'), findsOneWidget);
    expect(find.textContaining('The Unlicense'), findsOneWidget);
    await reveal(tester, find.text('2. Hasan Emir Yıldırım Exercise Dataset'));
    expect(find.textContaining('MIT License'), findsOneWidget);
    await reveal(
      tester,
      find.text('3. Adult Compendium of Physical Activities'),
    );

    await reveal(tester, find.textContaining('Inter, JetBrains Mono and'));
    expect(find.textContaining('Instrument Serif'), findsWidgets);
    expect(find.textContaining('SIL Open Font License'), findsOneWidget);
    await reveal(tester, find.text('Open-source licences'));
    await closeApp(tester);
  });

  testWidgets('the licences row opens Flutter\'s licence page', (
    WidgetTester tester,
  ) async {
    usePhone(tester);
    _fakeVersion('0.1.0+1');
    await pumpSinew(tester, location: Routes.about);
    await tapText(tester, 'Open-source licences');
    expect(find.byType(LicensePage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await closeApp(tester);
  });

  testWidgets('lays out at 200% text on a 360dp phone', (
    WidgetTester tester,
  ) async {
    usePhone(tester, textScale: 2);
    _fakeVersion('0.1.0+1');
    await pumpSinew(tester, location: Routes.about);
    expect(tester.takeException(), isNull);
    for (int i = 0; i < 12; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    await closeApp(tester);
  });
}
