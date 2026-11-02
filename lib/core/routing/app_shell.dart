import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/sinew_nav_pill.dart';
import 'nav_visibility.dart';
import 'router.dart';

/// The scaffold around the five tabs: the page, and the floating nav pill over
/// it (edge to edge, no bottom bar slot).
///
/// - Tapping another tab switches to it; tapping the current tab returns it to
///   its root and scrolls it back to the top.
/// - Back on any tab but the first goes to the first tab; back on the first
///   tab leaves the app.
/// - The pill hides (slide and fade, cross-fade under reduced motion) while
///   [navHiddenProvider] is true, and while the keyboard is open.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static final List<String> _labels = <String>[
    for (final TabSpec t in kTabs) t.label,
  ];

  void _onSelect(int index) {
    if (index == shell.currentIndex) {
      _scrollTabToTop(index);
      // Back to the tab's root if something was pushed on it.
      shell.goBranch(index, initialLocation: true);
      return;
    }
    shell.goBranch(index);
  }

  /// Re-tapping the active tab scrolls it back to the top: the outermost
  /// vertical scroll view of the branch's topmost route, whichever controller
  /// it uses. Runs only on the tap.
  void _scrollTabToTop(int index) {
    final BuildContext? nav =
        shell.route.branches[index].navigatorKey.currentContext;
    if (nav == null) return;
    // Each route wraps its page in a PrimaryScrollController; the last one
    // found is the route on top.
    Element? route;
    void findRoute(Element e) {
      if (e.widget is PrimaryScrollController) {
        route = e;
        return;
      }
      e.visitChildren(findRoute);
    }

    nav.visitChildElements(findRoute);
    ScrollPosition? pos;
    void findScrollable(Element e) {
      if (pos != null) return;
      if (e is StatefulElement && e.state is ScrollableState) {
        final ScrollableState s = e.state as ScrollableState;
        if (axisDirectionToAxis(s.axisDirection) == Axis.vertical) {
          pos = s.position;
          return;
        }
      }
      e.visitChildren(findScrollable);
    }

    route?.visitChildren(findScrollable);
    final ScrollPosition? p = pos;
    if (p == null || p.pixels <= p.minScrollExtent) return;
    // Going back up lays out every row on the way, so never jump: longer trips
    // get more frames and an even-speed curve keeps the rows per frame small.
    final double screens = (p.pixels - p.minScrollExtent) / p.viewportDimension;
    if (Motion.reduced(nav)) {
      p.jumpTo(p.minScrollExtent);
      return;
    }
    final int ms =
        (Motion.scrollTopBaseMs + screens * Motion.scrollTopPerScreenMs)
            .clamp(Motion.scrollTopBaseMs, Motion.scrollTopMaxMs)
            .round();
    p.animateTo(
      p.minScrollExtent,
      duration: Duration(milliseconds: ms),
      curve: Motion.scrollTop,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool navHidden = ref.watch(navHiddenProvider);
    final bool keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final int current = shell.currentIndex;

    // PopScope(canPop: false) on every tab but the first signals the
    // navigation system that this route handles back itself.
    return PopScope(
      canPop: current == 0,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) return;
        if (current != 0) shell.goBranch(0);
      },
      child: Scaffold(
        backgroundColor: context.cs.surface,
        body: Stack(
          children: <Widget>[
            Positioned.fill(child: shell),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SinewNavBar(
                labels: _labels,
                index: current,
                onSelect: _onSelect,
                hidden: navHidden || keyboardOpen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
