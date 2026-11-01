import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sinew/core/db/repositories/measurement_repository.dart';
import 'package:sinew/core/db/repositories/profile_repository.dart';
import 'package:sinew/core/db/repositories/seed_repository.dart';
import 'package:sinew/core/db/seeds/measurement_seed.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/sinew_snackbar.dart';
import 'package:sinew/features/body/body_providers.dart';
import 'package:sinew/features/body/body_routes.dart';
import 'package:sinew/features/body/body_screen.dart';

import '../../helpers/test_db.dart';

/// The day every Body test treats as today.
final DateTime kToday = DateTime(2026, 10, 31);

/// An in-memory database with the built-in fields seeded.
Future<UserDatabase> seededDb(WidgetTester tester) async {
  final UserDatabase db = memoryUserDb();
  addTearDown(db.close);
  await tester.runAsync(() => MeasurementSeed.seed(SeedRepository(db)));
  return db;
}

MeasurementEntry entryOf(
  String id,
  DateTime date,
  Map<String, double> values,
) => MeasurementEntry(
  id: id,
  date: date,
  values: values,
  updatedAt: date.add(const Duration(hours: 1)),
);

/// Runs [body] on the real async zone (database calls need it).
Future<T?> db<T>(WidgetTester tester, Future<T> Function() body) =>
    tester.runAsync(body);

/// Pumps the Body routes in a router, starting at [initial].
Future<GoRouter> pumpBody(
  WidgetTester tester,
  UserDatabase database, {
  String initial = Routes.body,
  double textScale = 1,
  Profile? profile,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (profile != null) {
    await tester.runAsync(() => ProfileRepository(database).save(profile));
  }
  final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initial,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.body,
        builder: (BuildContext c, GoRouterState s) => const BodyScreen(),
        routes: bodyTabRoutes,
      ),
      ...bodyRootRoutes,
      GoRoute(
        path: Routes.profile,
        builder: (BuildContext c, GoRouterState s) =>
            const Scaffold(body: Text('Profile screen')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        userDatabaseProvider.overrideWithValue(database),
        bodyNowProvider.overrideWithValue(kToday),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.of(Tone.light),
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: child!,
        ),
      ),
    ),
  );
  await settle(tester);
  return router;
}

/// Lets queries, streams and the Delayed loading gate resolve.
Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }
}

MeasurementRepository measurementsOf(UserDatabase database) =>
    MeasurementRepository(database);

/// Pushes [path] on [router] and lets the screen load.
Future<void> pushRoute(
  WidgetTester tester,
  GoRouter router,
  String path,
) async {
  unawaited(router.push<void>(path));
  await settle(tester);
}

/// A widget test that unmounts the screen at the end, so the database's
/// stream clean-up timers fire before the framework checks for stray timers.
void bodyTest(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (WidgetTester tester) async {
    await body(tester);
    hideSinewSnackBar();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });
}

/// Scrolls [target] fully into view inside the first scrollable (of [within]
/// when given). `scrollUntilVisible` alone stops once the row is built.
Future<void> reveal(
  WidgetTester tester,
  Finder target, {
  Finder? within,
}) async {
  final Finder scrollable =
      (within == null
              ? find.byType(Scrollable)
              : find.descendant(of: within, matching: find.byType(Scrollable)))
          .first;
  await tester.scrollUntilVisible(target, 200, scrollable: scrollable);
  await tester.ensureVisible(target);
  await tester.pump();
}
