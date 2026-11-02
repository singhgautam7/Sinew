import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/router.dart';
import 'exercise_history_screen.dart';
import 'history_screen.dart';
import 'routine_editor_screen.dart';
import 'session_detail_screen.dart';
import 'workout_screen.dart';
import 'workout_summary_screen.dart';

// Owned by the Train feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

/// Children of the Train tab root (render inside the shell, nav visible
/// unless the screen hides it). Paths are relative to `Routes.train`.
final List<RouteBase> trainTabRoutes = <RouteBase>[
  // `routine/new` is matched before `routine/:id`.
  GoRoute(
    path: 'routine/new',
    builder: (BuildContext c, GoRouterState s) => const RoutineEditorScreen(),
  ),
  GoRoute(
    path: 'routine/:id',
    builder: (BuildContext c, GoRouterState s) =>
        RoutineEditorScreen(routineId: s.pathParameters['id']),
  ),
  GoRoute(
    path: 'history',
    builder: (BuildContext c, GoRouterState s) => const HistoryScreen(),
  ),
  GoRoute(
    path: 'history/:id',
    builder: (BuildContext c, GoRouterState s) =>
        SessionDetailScreen(sessionId: s.pathParameters['id']!),
  ),
  GoRoute(
    path: 'exercise/:id',
    builder: (BuildContext c, GoRouterState s) =>
        ExerciseHistoryScreen(exerciseId: s.pathParameters['id']!),
  ),
];

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
///
/// `Routes.workout` takes an optional `?routine=<id>`: when no workout is
/// running it starts that routine, otherwise it just resumes.
final List<RouteBase> trainRootRoutes = <RouteBase>[
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: Routes.workout,
    builder: (BuildContext c, GoRouterState s) =>
        WorkoutScreen(startRoutineId: s.uri.queryParameters['routine']),
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: '/workout/summary/:id',
    builder: (BuildContext c, GoRouterState s) =>
        WorkoutSummaryScreen(sessionId: s.pathParameters['id']!),
  ),
];
