import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/routing/router.dart';
import 'data/timer_modes.dart';
import 'run/timer_run_screen.dart';
import 'setup/timer_setup_screen.dart';

/// Children of the Timer tab root (render inside the shell, nav visible).
/// Paths are relative to `Routes.timer`. The Timer has none: setup, like the
/// run screen, covers the whole screen (the frames show no nav there).
final List<RouteBase> timerTabRoutes = <RouteBase>[];

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
///
/// `/timer/setup/:mode` is `Routes.timerSetup(mode)`; the optional
/// `?preset=<id>` loads a saved preset and `?flow=<id>` loads a library yoga
/// flow into the Yoga flow setup.
final List<RouteBase> timerRootRoutes = <RouteBase>[
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: '/timer/setup/:mode',
    builder: (BuildContext context, GoRouterState state) {
      final TimerMode? mode = timerModeFromName(state.pathParameters['mode']);
      if (mode == null) {
        // A bad link: show the home rather than an error.
        return const _BackToTimer();
      }
      return TimerSetupScreen(
        key: ValueKey<String>(state.uri.toString()),
        mode: mode,
        presetId: state.uri.queryParameters['preset'],
        flowId: state.uri.queryParameters['flow'],
      );
    },
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: Routes.timerRun,
    builder: (BuildContext context, GoRouterState state) =>
        const TimerRunScreen(),
  ),
];

class _BackToTimer extends StatelessWidget {
  const _BackToTimer();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(Routes.timer);
    });
    return const SizedBox.shrink();
  }
}
