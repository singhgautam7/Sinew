import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/router.dart';
import 'custom_exercise_screen.dart';
import 'exercise_detail_screen.dart';
import 'flow_detail_screen.dart';
import 'library_screen.dart';

// Owned by the Library feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
final List<RouteBase> libraryRootRoutes = <RouteBase>[
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: Routes.library,
    builder: (BuildContext c, GoRouterState s) => const LibraryScreen(),
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: '/library/exercise/:id',
    builder: (BuildContext c, GoRouterState s) =>
        ExerciseDetailScreen(exerciseId: s.pathParameters['id']!),
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: '/library/flow/:id',
    builder: (BuildContext c, GoRouterState s) =>
        FlowDetailScreen(flowId: s.pathParameters['id']!),
  ),
  // `new` must come before `:id`.
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: Routes.newCustomExercise,
    builder: (BuildContext c, GoRouterState s) => const CustomExerciseScreen(),
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: '/library/custom/:id',
    builder: (BuildContext c, GoRouterState s) =>
        CustomExerciseScreen(exerciseId: s.pathParameters['id']!),
  ),
];
