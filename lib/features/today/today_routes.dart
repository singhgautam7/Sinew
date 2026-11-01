import 'package:go_router/go_router.dart';

// Owned by the Today feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

/// Children of the Today tab root (render inside the shell, nav visible).
/// Paths are relative to `Routes.today`, e.g. `'history'` for `/today/history`.
final List<RouteBase> todayTabRoutes = <RouteBase>[];

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
final List<RouteBase> todayRootRoutes = <RouteBase>[];
