import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/db/user/user_db.dart';
import 'core/error/error_handling.dart';
import 'core/providers.dart';
import 'core/settings/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  installErrorHandlers();
  _registerFontLicences();

  // Open only what the first frame needs: settings decide the theme (read
  // synchronously from here on, so no flash), the user database backs every
  // tab. The exercise library opens lazily on first use.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final UserDatabase userDb = UserDatabase();
  try {
    // Forces the open and the migration now, where a failure can be shown,
    // rather than inside the first screen that reads.
    await userDb.customSelect('SELECT 1').get();
  } on Object catch (e, st) {
    debugPrint('Sinew: could not open the user database: $e\n$st');
    runApp(StartupErrorApp(error: e));
    return;
  }

  runApp(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        prefsProvider.overrideWithValue(prefs),
        userDatabaseProvider.overrideWithValue(userDb),
      ],
      child: const SinewApp(),
    ),
  );
}

/// Bundled fonts are OFL; their licences appear on the licences page.
void _registerFontLicences() {
  for (final (String family, String file) in <(String, String)>[
    ('Inter', 'assets/fonts/Inter-OFL.txt'),
    ('JetBrains Mono', 'assets/fonts/JetBrainsMono-OFL.txt'),
    ('Instrument Serif', 'assets/fonts/InstrumentSerif-OFL.txt'),
  ]) {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(<String>[
        family,
      ], await rootBundle.loadString(file));
    });
  }
}
