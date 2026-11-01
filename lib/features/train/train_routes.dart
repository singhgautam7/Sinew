import 'package:go_router/go_router.dart';

// Owned by the Train feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

/// Children of the Train tab root (render inside the shell, nav visible).
/// Paths are relative to `Routes.train`, e.g. `'history'` for `/train/history`.
final List<RouteBase> trainTabRoutes = <RouteBase>[];

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
final List<RouteBase> trainRootRoutes = <RouteBase>[];
