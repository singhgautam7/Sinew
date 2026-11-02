import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A setup row: an optional phase-colour dot, a label with an optional
/// caption, and a control (a stepper) on the right.
///
/// With big text the control drops under the label instead of squeezing it,
/// so nothing overflows at 200% on a narrow phone.
class LabelledRow extends StatelessWidget {
  const LabelledRow({
    super.key,
    required this.label,
    required this.control,
    this.caption,
    this.dot,
  });

  final String label;
  final String? caption;
  final Color? dot;
  final Widget control;

  /// Text scale above which the control stacks under the label.
  static const double stackAbove = 1.3;

  @override
  Widget build(BuildContext context) {
    final bool stacked = MediaQuery.textScalerOf(context).scale(1) > stackAbove;
    final Widget labels = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: context.text.titleMedium),
        if (caption != null)
          Text(
            caption!,
            style: context.text.bodySmall!.copyWith(
              color: context.cs.onSurfaceVariant,
            ),
          ),
      ],
    );
    final Widget? dotWidget = dot == null
        ? null
        : Container(
            width: TimerUi.fieldDot,
            height: TimerUi.fieldDot,
            decoration: BoxDecoration(
              color: dot,
              borderRadius: BorderRadius.circular(Radii.extraSmall),
            ),
          );
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: SinewSpace.gloveTarget),
      child: Padding(
        padding: const EdgeInsets.only(
          left: Space.lg,
          right: Space.sm,
          top: Space.xs,
          bottom: Space.xs,
        ),
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: Space.sm),
                    child: Row(
                      children: <Widget>[
                        ?dotWidget,
                        if (dotWidget != null) const SizedBox(width: Space.md),
                        Expanded(child: labels),
                      ],
                    ),
                  ),
                  Align(alignment: Alignment.centerRight, child: control),
                ],
              )
            : Row(
                children: <Widget>[
                  ?dotWidget,
                  if (dotWidget != null) const SizedBox(width: Space.md),
                  Expanded(child: labels),
                  control,
                ],
              ),
      ),
    );
  }
}
