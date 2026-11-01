import 'package:go_router/go_router.dart';

// Owned by the Body feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

/// Children of the Body tab root (render inside the shell, nav visible).
/// Paths are relative to `Routes.body`, e.g. `'history'` for `/body/history`.
final List<RouteBase> bodyTabRoutes = <RouteBase>[];

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
final List<RouteBase> bodyRootRoutes = <RouteBase>[];
