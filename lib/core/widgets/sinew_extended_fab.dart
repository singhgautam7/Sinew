import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Bottom offset shared with the nav pill: the system inset, but never less
/// than [Sizes.navBottomMin].
double sinewNavBottom(BuildContext context) {
  final double inset = MediaQuery.viewPaddingOf(context).bottom;
  return inset > Sizes.navBottomMin ? inset : Sizes.navBottomMin;
}

/// Shared visibility for the extended FAB: scrolling content down hides it,
/// scrolling up (or reaching the top) shows it again. Driven by
/// [SinewFabScrollWatcher] above the navigator, so screens need no wiring.
final ValueNotifier<bool> sinewFabVisible = ValueNotifier<bool>(true);

/// Listens to every vertical scroll in the app and updates [sinewFabVisible].
class SinewFabScrollWatcher extends StatelessWidget {
  const SinewFabScrollWatcher({super.key, required this.child});

  final Widget child;

  /// Scroll deltas smaller than this are ignored (jitter).
  static const double _threshold = 2;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification n) {
        // Driven by the real scroll delta (drag and fling), not the
        // UserScrollNotification direction, which flips at the end of many
        // upward drags.
        if (n is ScrollUpdateNotification && n.metrics.axis == Axis.vertical) {
          final double delta = n.scrollDelta ?? 0;
          if (n.metrics.extentBefore <= 0 || delta < -_threshold) {
            sinewFabVisible.value = true;
          } else if (delta > _threshold) {
            sinewFabVisible.value = false;
          }
        }
        return false;
      },
      child: child,
    );
  }
}

/// The create action of a screen ("New routine", "Add entry"): an extended FAB
/// in primaryContainer, 56 high, radius 16, an icon and a label, 20 from the
/// end edge. On a tab screen it floats above the nav pill (22 clear of it);
/// on a screen without the pill set `aboveNav` to false and it sits at the
/// pill's own bottom offset. It slides away while scrolling down and back on
/// scrolling up, and holds still under reduced motion.
///
/// Use as `Scaffold.floatingActionButton` with the matching location:
/// [sinewFabLocation] (above the pill) or [sinewFabLocationFull] (no pill).
/// Lists should leave [SinewExtendedFab.clearance] of bottom padding so the
/// last row clears it.
class SinewExtendedFab extends StatefulWidget {
  const SinewExtendedFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  /// Bottom padding a list needs on a tab screen so its last item clears the
  /// FAB: nav offset + pill + gap + FAB.
  static const double clearance =
      Sizes.navBottomMin + Sizes.navPillHeight + Sizes.fabNavGap + Sizes.fab;

  @override
  State<SinewExtendedFab> createState() => _SinewExtendedFabState();
}

class _SinewExtendedFabState extends State<SinewExtendedFab> {
  @override
  void initState() {
    super.initState();
    // A newly opened screen always starts with its FAB showing.
    sinewFabVisible.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final bool reduced = Motion.reduced(context);
    return ValueListenableBuilder<bool>(
      valueListenable: sinewFabVisible,
      builder: (BuildContext context, bool visible, Widget? child) =>
          AnimatedSlide(
            offset: visible || reduced ? Offset.zero : const Offset(0, 2),
            duration: Motion.of(context, Motion.fabSlide),
            curve: visible ? Motion.decelerate : Motion.accelerate,
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: Motion.of(context, Motion.fabFade),
              child: IgnorePointer(ignoring: !visible, child: child),
            ),
          ),
      child: Semantics(
        button: true,
        label: widget.label,
        excludeSemantics: true,
        onTap: widget.onPressed,
        child: Material(
          color: cs.primaryContainer,
          shape: const RoundedRectangleBorder(borderRadius: Radii.largeR),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            child: Container(
              height: Sizes.fab,
              padding: const EdgeInsets.only(
                left: Sizes.fabPadLeft,
                right: Sizes.fabPadRight,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    widget.icon,
                    size: IconSpec.size,
                    color: cs.onPrimaryContainer,
                  ),
                  const SizedBox(width: Sizes.fabGap),
                  Text(
                    widget.label,
                    style: context.text.labelLarge!.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// End edge, above the nav pill: for tab screens.
const FloatingActionButtonLocation sinewFabLocation = _SinewFabLocation(
  aboveNav: true,
);

/// End edge, at the pill's bottom offset: for screens without the pill.
const FloatingActionButtonLocation sinewFabLocationFull = _SinewFabLocation(
  aboveNav: false,
);

class _SinewFabLocation extends FloatingActionButtonLocation {
  const _SinewFabLocation({required this.aboveNav});

  final bool aboveNav;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry g) {
    final double inset = g.minViewPadding.bottom;
    final double bottom = inset > Sizes.navBottomMin
        ? inset
        : Sizes.navBottomMin;
    final double lift = aboveNav ? Sizes.navPillHeight + Sizes.fabNavGap : 0;
    // End edge: the right in LTR, the left in RTL.
    final double x = g.textDirection == TextDirection.rtl
        ? Space.screen
        : g.scaffoldSize.width -
              g.floatingActionButtonSize.width -
              Space.screen;
    final double y =
        g.contentBottom - g.floatingActionButtonSize.height - bottom - lift;
    return Offset(x, y);
  }
}
