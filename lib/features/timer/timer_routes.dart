import 'package:go_router/go_router.dart';

// Owned by the Timer feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

/// Children of the Timer tab root (render inside the shell, nav visible).
/// Paths are relative to `Routes.timer`, e.g. `'history'` for `/timer/history`.
final List<RouteBase> timerTabRoutes = <RouteBase>[];

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
final List<RouteBase> timerRootRoutes = <RouteBase>[];
