import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/body/body_routes.dart';
import '../../features/body/body_screen.dart';
import '../../features/library/library_routes.dart';
import '../../features/more/debug_screen.dart';
import '../../features/more/more_routes.dart';
import '../../features/more/more_screen.dart';
import '../../features/onboarding/onboarding_routes.dart';
import '../../features/timer/timer_routes.dart';
import '../../features/timer/timer_screen.dart';
import '../../features/today/today_routes.dart';
import '../../features/today/today_screen.dart';
import '../../features/train/train_routes.dart';
import '../../features/train/train_screen.dart';
import 'app_shell.dart';

/// Every path in the app: the contract between features. Screens navigate by
/// these names, never by a string literal. Each feature registers its own
/// `GoRoute`s in `features/<feature>/<feature>_routes.dart`; paths it exposes
/// to other features are listed here so a link never breaks.
abstract final class Routes {
  // ── Tabs ────────────────────────────────────────────────────────────────
  static const String today = '/today';
  static const String train = '/train';
  static const String timer = '/timer';
  static const String body = '/body';
  static const String more = '/more';

  // ── First run (root, no nav) ────────────────────────────────────────────
  static const String welcome = '/welcome';
  static const String onboardingProfile = '/welcome/profile';
  static const String onboardingRestore = '/welcome/restore';

  // ── Global search (root) ────────────────────────────────────────────────
  static const String search = '/search';

  // ── Train (inside the Train tab) ────────────────────────────────────────
  static const String newRoutine = '/train/routine/new';
  static String routine(String id) => '/train/routine/$id';
  static const String history = '/train/history';
  static String session(String id) => '/train/history/$id';
  static String exerciseHistory(String exerciseId) =>
      '/train/exercise/$exerciseId';

  /// The active workout (root, nav hidden). Resumes the active session.
  static const String workout = '/workout';
  static String workoutSummary(String sessionId) =>
      '/workout/summary/$sessionId';

  // ── Library (root) ──────────────────────────────────────────────────────
  static const String library = '/library';
  static String exercise(String id) => '/library/exercise/$id';
  static String flow(String id) => '/library/flow/$id';
  static const String newCustomExercise = '/library/custom/new';
  static String editCustomExercise(String id) => '/library/custom/$id';

  // ── Timer ───────────────────────────────────────────────────────────────
  /// Setup for a mode (`TimerMode.name`), optionally from a saved preset.
  static String timerSetup(String mode, {String? presetId, String? flowId}) {
    final Map<String, String> q = <String, String>{
      'preset': ?presetId,
      'flow': ?flowId,
    };
    return Uri(
      path: '/timer/setup/$mode',
      queryParameters: q.isEmpty ? null : q,
    ).toString();
  }

  /// The running timer (root, nav hidden).
  static const String timerRun = '/timer-run';

  // ── Body ────────────────────────────────────────────────────────────────
  static const String newEntry = '/body/entry/new';
  static String entry(String id) => '/body/entry/$id';
  static const String fields = '/body/fields';
  static String progress(String fieldId) => '/body/progress/$fieldId';
  static const String compare = '/body/compare';

  // ── More ────────────────────────────────────────────────────────────────
  static const String profile = '/more/profile';
  static const String units = '/more/units';
  static const String plates = '/more/plates';
  static const String backup = '/more/backup';
  static const String settings = '/more/settings';
  static const String theme = '/more/settings/theme';
  static const String about = '/more/about';
  static const String permissions = '/more/permissions';
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
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

GoRouter buildRouter({String initialLocation = Routes.today}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    observers: <NavigatorObserver>[appRouteObserver],
    initialLocation: initialLocation,
    routes: <RouteBase>[
      // Each tab keeps its own navigation stack and scroll position. A tab's
      // child routes render inside the shell (nav visible).
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell shell,
        ) => AppShell(shell: shell),
        branches: <StatefulShellBranch>[
          _branch(Routes.today, const TodayScreen(), todayTabRoutes),
          _branch(Routes.train, const TrainScreen(), trainTabRoutes),
          _branch(Routes.timer, const TimerScreen(), timerTabRoutes),
          _branch(Routes.body, const BodyScreen(), bodyTabRoutes),
          _branch(Routes.more, const MoreScreen(), moreTabRoutes),
        ],
      ),
      // Full-screen routes above the shell (no nav). Every one of these sets
      // `parentNavigatorKey: rootNavigatorKey`.
      ...onboardingRootRoutes,
      ...todayRootRoutes,
      ...trainRootRoutes,
      ...libraryRootRoutes,
      ...timerRootRoutes,
      ...bodyRootRoutes,
      ...moreRootRoutes,
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: Routes.debug,
        builder: (BuildContext c, GoRouterState s) => const DebugScreen(),
      ),
    ],
  );
}

StatefulShellBranch _branch(
  String path,
  Widget screen,
  List<RouteBase> children,
) => StatefulShellBranch(
  routes: <RouteBase>[
    GoRoute(
      path: path,
      builder: (BuildContext c, GoRouterState s) => screen,
      routes: children,
    ),
  ],
);
