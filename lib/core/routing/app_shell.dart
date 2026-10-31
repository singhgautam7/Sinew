import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

/// The scaffold around the five tabs.
///
/// PLACEHOLDER NAV (Phase 1): a stock [NavigationBar] so the routing skeleton
/// can be exercised. Phase 3 replaces it with the house floating pill
/// (icon-only tabs, the active one expanding into icon + label, hidden during
/// an active workout or running timer).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (int i) =>
            // Re-tapping the current tab returns it to its root.
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: <NavigationDestination>[
          for (final TabSpec t in kTabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}
