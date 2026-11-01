import 'package:go_router/go_router.dart';

// Owned by the More feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

/// Children of the More tab root (render inside the shell, nav visible).
/// Paths are relative to `Routes.more`, e.g. `'history'` for `/more/history`.
final List<RouteBase> moreTabRoutes = <RouteBase>[];

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
final List<RouteBase> moreRootRoutes = <RouteBase>[];
