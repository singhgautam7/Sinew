import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/db/repositories/seed_repository.dart';
import 'core/db/seeds/measurement_seed.dart';
import 'core/db/user/user_db.dart';
import 'core/error/error_handling.dart';
import 'core/providers.dart';
import 'core/routing/router.dart';
import 'core/settings/app_settings.dart';
import 'features/timer/controller/timer_bootstrap.dart';
import 'features/timer/data/active_timer.dart';
import 'core/db/repositories/runtime_state_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  installErrorHandlers();
  // Receives what the timer's background service sends the app.
  FlutterForegroundTask.initCommunicationPort();
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
    // First run: the built-in measurement fields. Idempotent.
    await MeasurementSeed.seed(SeedRepository(userDb));
  } on Object catch (e, st) {
    debugPrint('Sinew: could not open the user database: $e\n$st');
    runApp(StartupErrorApp(error: e));
    return;
  }

  // A timer left running when the process died reopens on its run screen.
  final String initialLocation = await _initialLocation(userDb);

  runApp(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        prefsProvider.overrideWithValue(prefs),
        userDatabaseProvider.overrideWithValue(userDb),
      ],
      child: TimerBootstrap(child: SinewApp(initialLocation: initialLocation)),
    ),
  );
}

/// Where the app opens: Today, or the running timer if one was left going.
Future<String> _initialLocation(UserDatabase db) async {
  try {
    final Map<String, dynamic>? json = await RuntimeStateRepository(db)
        .read(RuntimeStateRepository.runningTimer);
    final ActiveTimer? a = ActiveTimer.fromJson(json);
    if (a != null &&
        !a.run.snapshotAt(DateTime.now().millisecondsSinceEpoch).finished) {
      return Routes.timerRun;
    }
  } on Object catch (e) {
    debugPrint('Sinew: could not look for a running timer: $e');
  }
  return Routes.today;
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
