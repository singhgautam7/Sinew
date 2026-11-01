import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/router.dart';
import 'compare_screen.dart';
import 'entry_screen.dart';
import 'fields_screen.dart';
import 'progress_screen.dart';

// Owned by the Body feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

/// Children of the Body tab root (render inside the shell, nav visible).
/// Paths are relative to `Routes.body`.
final List<RouteBase> bodyTabRoutes = <RouteBase>[
  GoRoute(
    path: 'fields',
    builder: (BuildContext c, GoRouterState s) => const FieldsScreen(),
  ),
  GoRoute(
    path: 'progress/:fieldId',
    builder: (BuildContext c, GoRouterState s) =>
        ProgressScreen(fieldId: s.pathParameters['fieldId']!),
  ),
];

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
final List<RouteBase> bodyRootRoutes = <RouteBase>[
  // `new` is declared before `:id` so it is not read as an entry id.
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: Routes.newEntry,
    builder: (BuildContext c, GoRouterState s) =>
        EntryScreen(focusFieldId: s.uri.queryParameters['field']),
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: '${Routes.body}/entry/:id',
    builder: (BuildContext c, GoRouterState s) =>
        EntryScreen(entryId: s.pathParameters['id']),
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: Routes.compare,
    builder: (BuildContext c, GoRouterState s) => const CompareScreen(),
  ),
];
