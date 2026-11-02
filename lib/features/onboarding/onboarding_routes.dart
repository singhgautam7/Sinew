import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/router.dart';
import 'quick_profile_screen.dart';
import 'restore_screen.dart';
import 'welcome_screen.dart';

// Owned by the Onboarding feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
final List<RouteBase> onboardingRootRoutes = <RouteBase>[
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: Routes.welcome,
    builder: (BuildContext c, GoRouterState s) => const WelcomeScreen(),
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: Routes.onboardingProfile,
    builder: (BuildContext c, GoRouterState s) => const QuickProfileScreen(),
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: Routes.onboardingRestore,
    builder: (BuildContext c, GoRouterState s) =>
        const OnboardingRestoreScreen(),
  ),
];
