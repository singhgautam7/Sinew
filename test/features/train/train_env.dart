import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/db/repositories/exercise_repository.dart';
import 'package:sinew/core/db/repositories/routine_repository.dart';
import 'package:sinew/core/db/repositories/session_repository.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/features/train/train_providers.dart';
import 'package:sinew/features/train/train_routes.dart';
import 'package:sinew/features/train/train_screen.dart';

import '../../helpers/test_db.dart';

/// A clock the test moves by hand.
class FakeClock {
  FakeClock([DateTime? start])
    : ms = (start ?? DateTime(2026, 3, 4, 18)).millisecondsSinceEpoch;

  int ms;

  int call() => ms;

  void advance(Duration d) => ms += d.inMilliseconds;
}

/// Everything a Train test needs: an in-memory user DB, custom exercises
/// standing in for the library, a scripted exercise picker and a fake clock.
class TrainEnv {
  TrainEnv._(this.db, this.prefs, this.library);

  final UserDatabase db;
  final SharedPreferences prefs;
  final LibraryDatabase library;
  final FakeClock clock = FakeClock();

  /// What the exercise picker hands back next.
  List<String>? pick;

  SessionRepository get sessions => SessionRepository(db);
  RoutineRepository get routines => RoutineRepository(db);
  CustomExerciseRepository get custom => CustomExerciseRepository(db);

  static Future<TrainEnv> create() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final UserDatabase db = memoryUserDb();
    final LibraryDatabase lib = LibraryDatabase.forBuild(
      NativeDatabase.memory(),
    );
    final TrainEnv env = TrainEnv._(db, prefs, lib);
    await env.seedExercises();
    return env;
  }

  Future<void> dispose() async {
    await db.close();
    await library.close();
  }

  Future<void> seedExercises() async {
    Future<void> add(
      String id,
      String name,
      TrackingType type, {
      List<String> equipment = const <String>[],
      List<String> muscles = const <String>['chest'],
      int? rest,
    }) => custom.save(
      Exercise(
        id: id,
        name: name,
        category: 'strength',
        trackingType: type,
        primaryMuscles: muscles,
        equipment: equipment,
        defaultRestSec: rest,
        metValue: 5,
      ),
    );
    await add(
      'custom-bench',
      'Bench press',
      TrackingType.weightReps,
      equipment: <String>['barbell'],
      rest: 90,
    );
    await add(
      'custom-row',
      'Cable row',
      TrackingType.weightReps,
      equipment: <String>['cable'],
      muscles: <String>['lats'],
    );
    await add(
      'custom-pullup',
      'Pull-up',
      TrackingType.reps,
      muscles: <String>['lats'],
    );
    await add(
      'custom-plank',
      'Plank',
      TrackingType.hold,
      muscles: <String>['core'],
    );
  }

  List<Override> overrides() => <Override>[
    prefsProvider.overrideWithValue(prefs),
    userDatabaseProvider.overrideWithValue(db),
    exerciseResolverProvider.overrideWith(
      (Ref ref) async => ExerciseResolver(
        custom: ref.watch(customExerciseRepositoryProvider),
        library: LibraryRepository(library),
      ),
    ),
    trainNowMsProvider.overrideWithValue(clock.call),
    exercisePickerProvider.overrideWithValue(
      (
        BuildContext context, {
        bool multiple = true,
        Set<String> exclude = const <String>{},
        String? title,
      }) async => pick,
    ),
  ];

  /// A router with just the Train routes (no shell, no other features).
  GoRouter router(String location) => GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: location,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.train,
        builder: (BuildContext c, GoRouterState s) => const TrainScreen(),
        routes: trainTabRoutes,
      ),
      ...trainRootRoutes,
      GoRoute(
        path: Routes.library,
        builder: (BuildContext c, GoRouterState s) =>
            const Scaffold(body: Text('Library stub')),
      ),
    ],
  );

  /// Pumps the app at [location] on a 360dp phone.
  Future<void> pump(
    WidgetTester tester,
    String location, {
    double textScale = 1,
    Tone tone = Tone.light,
    double height = 780,
  }) async {
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        overrides: overrides(),
        child: MaterialApp.router(
          theme: AppTheme.of(Tone.light),
          darkTheme: AppTheme.of(Tone.dark),
          themeMode: tone == Tone.dark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: router(location),
        ),
      ),
    );
    await settle(tester);
  }

  /// Takes the app down and lets drift's close timers run.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  /// A few frames; `pumpAndSettle` would wait for the rest timer's ticker.
  Future<void> settle(WidgetTester tester, [int frames = 8]) async {
    for (int i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp).first));

  /// Saves a finished session of [exerciseId] with the given (kg, reps) sets.
  Future<WorkoutSession> seedSession({
    required String name,
    required DateTime start,
    String exerciseId = 'custom-bench',
    List<(double, int)> sets = const <(double, int)>[(60, 8)],
    String id = '',
  }) async {
    final String sid = id.isEmpty ? 's-${start.millisecondsSinceEpoch}' : id;
    final WorkoutSession s = WorkoutSession(
      id: sid,
      name: name,
      startedAt: start,
      endedAt: start.add(const Duration(minutes: 45)),
      durationSec: 2700,
      volumeKg: sets.fold<double>(
        0,
        (double a, (double, int) x) => a + x.$1 * x.$2,
      ),
      updatedAt: start,
      exercises: <SessionExercise>[
        SessionExercise(
          id: 'e-$sid',
          exerciseId: exerciseId,
          position: 0,
          sets: <SetEntry>[
            for (int i = 0; i < sets.length; i++)
              SetEntry(
                id: 'set-$sid-$i',
                position: i,
                weightKg: sets[i].$1,
                reps: sets[i].$2,
                completed: true,
                completedAt: start,
              ),
          ],
        ),
      ],
    );
    await sessions.saveTree(s);
    return s;
  }

  /// A routine of one bench press item: 3 sets of 60 kg x 8, rest 2:00.
  Future<Routine> seedRoutine({
    String id = 'r1',
    String name = 'Push',
    int restSec = 120,
  }) => routines.save(
    Routine(
      id: id,
      name: name,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      items: <RoutineItem>[
        RoutineItem(
          id: 'ri-$id',
          exerciseId: 'custom-bench',
          position: 0,
          targetSets: 3,
          targetReps: 8,
          targetWeightKg: 60,
          restSec: restSec,
        ),
      ],
    ),
  );
}
