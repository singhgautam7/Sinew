import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/body/body_screen.dart';
import '../../features/more/debug_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/timer/timer_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/train/train_screen.dart';
import 'app_shell.dart';

/// Every path in the app. Screens navigate by these names, never by a string
/// literal.
abstract final class Routes {
  static const String today = '/today';
  static const String train = '/train';
  static const String timer = '/timer';
  static const String body = '/body';
  static const String more = '/more';
  static const String debug = '/more/debug';
}

/// One destination of the bottom nav, in order.
@immutable
class TabSpec {
  const TabSpec(this.path, this.label, this.icon, this.selectedIcon);

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Expected tabs per the contract; confirmed against the handoff in Phase 3.
const List<TabSpec> kTabs = <TabSpec>[
  TabSpec(Routes.today, 'Today', Icons.wb_sunny_outlined, Icons.wb_sunny),
  TabSpec(
    Routes.train,
    'Train',
    Icons.fitness_center_outlined,
    Icons.fitness_center,
  ),
  TabSpec(Routes.timer, 'Timer', Icons.timer_outlined, Icons.timer),
  TabSpec(
    Routes.body,
    'Body',
    Icons.accessibility_new_outlined,
    Icons.accessibility_new,
  ),
  TabSpec(Routes.more, 'More', Icons.more_horiz, Icons.more_horiz),
];

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter({String initialLocation = Routes.today}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: <RouteBase>[
      // Each tab keeps its own navigation stack and scroll position.
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell shell,
        ) => AppShell(shell: shell),
        branches: <StatefulShellBranch>[
          _branch(Routes.today, const TodayScreen()),
          _branch(Routes.train, const TrainScreen()),
          _branch(Routes.timer, const TimerScreen()),
          _branch(Routes.body, const BodyScreen()),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.more,
                builder: (BuildContext c, GoRouterState s) =>
                    const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      // Full-screen routes sit above the shell (no bottom nav).
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: Routes.debug,
        builder: (BuildContext c, GoRouterState s) => const DebugScreen(),
      ),
    ],
  );
}

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: <RouteBase>[
    GoRoute(path: path, builder: (BuildContext c, GoRouterState s) => screen),
  ],
);
