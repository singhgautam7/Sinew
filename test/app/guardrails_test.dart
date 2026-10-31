import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/ids.dart';

/// Mechanical checks for the project's hard rules, so a regression fails CI
/// instead of waiting for review.

Iterable<File> _dartFiles(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where(
      (File f) =>
          f.path.endsWith('.dart') &&
          !f.path.endsWith('.g.dart') &&
          !f.path.endsWith('.freezed.dart'),
    );

void main() {
  group('offline guarantee', () {
    test('the release manifest declares no INTERNET permission', () {
      final String manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      expect(manifest, isNot(contains('android.permission.INTERNET')));
    });

    test('no direct dependency phones home', () {
      final String pubspec = File('pubspec.yaml').readAsStringSync();
      for (final String banned in <String>[
        'http:',
        'dio:',
        'google_fonts:',
        'firebase',
        'sentry',
        'crashlytics',
        'analytics',
        'google_mobile_ads',
        'remote_config',
        'web_socket_channel',
      ]) {
        expect(
          RegExp('^\\s+$banned', multiLine: true).hasMatch(pubspec),
          isFalse,
          reason: 'pubspec lists $banned',
        );
      }
    });

    test('no code in lib/ opens a network connection', () {
      final List<RegExp> banned = <RegExp>[
        RegExp(r"import 'package:http/"),
        RegExp(r"import 'package:google_fonts/"),
        RegExp(r'\bHttpClient\b'),
        RegExp(r'\bWebSocket\b'),
        RegExp(r'\bSocket\.connect\b'),
        RegExp(r'\.network\('),
        RegExp(r'\bNetworkImage\b'),
      ];
      final List<String> hits = <String>[
        for (final File f in _dartFiles('lib'))
          for (final RegExp r in banned)
            if (r.hasMatch(f.readAsStringSync())) '${f.path}: ${r.pattern}',
      ];
      expect(hits, isEmpty);
    });
  });

  group('token rule', () {
    test('no raw colour outside lib/core/theme/palette.dart', () {
      final RegExp hex = RegExp(r'Color\(0x|Color\.fromARGB|Color\.fromRGBO');
      final List<String> hits = <String>[
        for (final File f in _dartFiles('lib'))
          if (!f.path.endsWith('core/theme/palette.dart') &&
              hex.hasMatch(f.readAsStringSync()))
            f.path,
      ];
      expect(hits, isEmpty);
    });

    test('no Colors.* outside the theme layer', () {
      final RegExp colors = RegExp(r'\bColors\.(?!transparent\b)');
      final List<String> hits = <String>[
        for (final File f in _dartFiles('lib'))
          if (!f.path.contains('core/theme/') &&
              colors.hasMatch(f.readAsStringSync()))
            f.path,
      ];
      expect(hits, isEmpty);
    });

    test('engines and models never import Flutter', () {
      final List<String> pure = <String>[
        'lib/core/models',
        'lib/core/units',
        if (Directory('lib/engines').existsSync()) 'lib/engines',
      ];
      final List<String> hits = <String>[
        for (final String dir in pure)
          for (final File f in _dartFiles(dir))
            if (f.readAsStringSync().contains("import 'package:flutter/"))
              f.path,
      ];
      expect(hits, isEmpty);
      // The library database is shared with the build tool, which runs
      // without Flutter.
      expect(
        File('lib/core/db/library/library_db.dart').readAsStringSync(),
        isNot(contains('flutter')),
      );
    });
  });

  group('copy', () {
    test('no em dashes in user-facing strings', () {
      final RegExp literal = RegExp(r"'[^'\n]*—[^'\n]*'");
      final List<String> hits = <String>[
        for (final File f in _dartFiles('lib'))
          if (literal.hasMatch(f.readAsStringSync())) f.path,
      ];
      expect(hits, isEmpty);
    });
  });

  test('ids are RFC 4122 v4 and unique', () {
    final RegExp v4 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final Set<String> seen = <String>{};
    for (int i = 0; i < 10000; i++) {
      final String id = newId();
      expect(v4.hasMatch(id), isTrue, reason: id);
      seen.add(id);
    }
    expect(seen, hasLength(10000));
  });
}
