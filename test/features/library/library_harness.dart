import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/features/library/library_routes.dart';

import '../../helpers/test_db.dart';

/// The real bundled library, opened in-process (a background isolate would
/// not advance under the widget tester's fake clock).
class RealLibrary {
  RealLibrary._(this.dir, this.db);

  final Directory dir;
  final LibraryDatabase db;

  static RealLibrary open() {
    final Directory dir = Directory.systemTemp.createTempSync('sinew_lib_ui');
    final File copy = File('assets/db/library.sqlite')
        .copySync('${dir.path}/library.sqlite');
    return RealLibrary._(dir, LibraryDatabase.forBuild(NativeDatabase(copy)));
  }

  Future<void> close() async {
    await db.close();
    dir.deleteSync(recursive: true);
  }
}

/// Everything a Library screen test needs: the real library, an in-memory
/// user database and prefs.
class LibraryEnv {
  LibraryEnv._(this.library, this.userDb, this.prefs);

  final RealLibrary library;
  final UserDatabase userDb;
  final SharedPreferences prefs;

  static Future<LibraryEnv> create() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return LibraryEnv._(RealLibrary.open(), memoryUserDb(), prefs);
  }

  List<Override> get overrides => <Override>[
    prefsProvider.overrideWithValue(prefs),
    userDatabaseProvider.overrideWithValue(userDb),
    libraryRepositoryProvider.overrideWith(
      (Ref ref) async => LibraryRepository(library.db),
    ),
  ];

  LibraryRepository get repo => LibraryRepository(library.db);

  CustomExerciseRepository get custom => CustomExerciseRepository(userDb);

  Future<void> dispose() async {
    await userDb.close();
    await library.close();
  }
}

void usePhone(WidgetTester tester, {double textScale = 1}) {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Pumps the library routes at [location] with stub pages for the routes
/// other features own.
Future<void> pumpLibraryRoute(
  WidgetTester tester,
  LibraryEnv env,
  String location, {
  double textScale = 1,
}) async {
  usePhone(tester, textScale: textScale);
  final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: location,
    routes: <RouteBase>[
      ...libraryRootRoutes,
      GoRoute(
        path: '/train/exercise/:id',
        builder: (BuildContext c, GoRouterState s) =>
            Scaffold(body: Text('history ${s.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/timer/setup/:mode',
        builder: (BuildContext c, GoRouterState s) => Scaffold(
          body: Text(
            'timer ${s.pathParameters['mode']} ${s.uri.queryParameters['flow']}',
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: env.overrides,
      child: MaterialApp.router(
        theme: AppTheme.of(Tone.light),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A themed app with a button that runs [onTap] with its own context.
Future<void> pumpOpener(
  WidgetTester tester,
  LibraryEnv env,
  void Function(BuildContext context) onTap, {
  double textScale = 1,
}) async {
  usePhone(tester, textScale: textScale);
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: env.overrides,
      child: MaterialApp(
        theme: AppTheme.of(Tone.light),
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => onTap(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Types into the first text field and waits out the search debounce.
Future<void> typeQuery(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).first, text);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pumpAndSettle();
}

/// A widget test with its own [LibraryEnv]. The tree is unmounted and the
/// streams given a moment to wind down before the databases close, so no
/// timer outlives the test.
void libraryTest(
  String description,
  Future<void> Function(WidgetTester tester, LibraryEnv env) body,
) {
  testWidgets(description, (WidgetTester tester) async {
    final LibraryEnv env = await LibraryEnv.create();
    try {
      await body(tester, env);
    } finally {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await env.dispose();
    }
  });
}

/// Every vertical scrollable on screen (text fields scroll horizontally).
Finder get vScroll => find.byWidgetPredicate(
  (Widget w) => w is Scrollable && w.axis == Axis.vertical,
);
