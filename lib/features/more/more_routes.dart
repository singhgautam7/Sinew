import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../about/about_screen.dart';
import '../backup/backup_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/theme_screen.dart';
import 'permissions_screen.dart';
import 'plates_screen.dart';
import 'profile_screen.dart';
import 'units_screen.dart';

// Owned by the More feature. The paths other features may link to are in
// `Routes` (lib/core/routing/router.dart); register them here.

GoRoute _page(
  String path,
  Widget screen, [
  List<RouteBase> children = const [],
]) => GoRoute(
  path: path,
  builder: (BuildContext c, GoRouterState s) => screen,
  routes: children,
);

/// Children of the More tab root (render inside the shell, nav visible).
/// Paths are relative to `Routes.more`, e.g. `'history'` for `/more/history`.
/// They match `Routes.profile`, `units`, `plates`, `backup`, `settings`,
/// `theme` (under settings), `about` and `permissions`.
final List<RouteBase> moreTabRoutes = <RouteBase>[
  _page('profile', const ProfileScreen()),
  _page('units', const UnitsScreen()),
  _page('plates', const PlatesScreen()),
  _page('backup', const BackupScreen()),
  _page('settings', const SettingsScreen(), <RouteBase>[
    _page('theme', const ThemeScreen()),
  ]),
  _page('about', const AboutScreen()),
  _page('permissions', const PermissionsScreen()),
];

/// Full-screen routes above the shell (no nav). Each sets
/// `parentNavigatorKey: rootNavigatorKey`.
final List<RouteBase> moreRootRoutes = <RouteBase>[];
