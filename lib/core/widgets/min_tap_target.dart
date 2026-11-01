import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// Gives a control that is drawn smaller than 48dp a 48dp tall hit area.
///
/// The visual child keeps its size and its own ink; the outer box only catches
/// taps in the margin around it. Used by buttons and segmented controls drawn
/// at 40dp (the design's size) so the touch target rule still holds.
class MinTapTarget extends StatelessWidget {
  const MinTapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minHeight = IconSpec.tapTarget,
  });

  final Widget child;

  /// Null leaves the margin inert (a disabled control).
  final VoidCallback? onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        excludeFromSemantics: true,
        onTap: onTap,
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      ),
    );
  }
}
