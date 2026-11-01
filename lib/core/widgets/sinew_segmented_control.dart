import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'min_tap_target.dart';

/// A segmented button: 40 high (with a 48dp hit area), stadium, 1dp outline
/// dividers; the selected segment takes secondaryContainer with a check (no
/// check for 4 or more segments). Fills the width unless [compact].
class SinewSegmentedControl<T> extends StatelessWidget {
  const SinewSegmentedControl({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    this.showCheck = true,
    this.compact = false,
  }) : assert(values.length == labels.length);

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onSelected;
  final bool enabled;

  /// Draw the check on the selected segment (never for 4+ segments).
  final bool showCheck;

  /// Hug content (in-card toggles) instead of filling the width.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;

    // The outline is a foreground decoration so the selected segment's fill
    // sits inside it instead of painting over the stadium edge.
    // Minimum height, so large text grows the control instead of clipping.
    final Widget bar = Container(
      constraints: const BoxConstraints(minHeight: Sizes.segmented),
      decoration: const BoxDecoration(borderRadius: Radii.fullR),
      foregroundDecoration: BoxDecoration(
        borderRadius: Radii.fullR,
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: List<Widget>.generate(values.length, (int i) {
            final bool isSelected = values[i] == selected;
            final Color fg = isSelected
                ? cs.onSecondaryContainer
                : cs.onSurface.withValues(
                    alpha: enabled ? 1.0 : Opacities.disabled,
                  );
            final Widget segment = Semantics(
              button: true,
              selected: isSelected,
              enabled: enabled,
              label: labels[i],
              excludeSemantics: true,
              onTap: enabled ? () => onSelected(values[i]) : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? () => onSelected(values[i]) : null,
                child: AnimatedContainer(
                  duration: Motion.of(context, Motion.segment),
                  curve: Motion.curveOf(context, Motion.decelerate),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (enabled
                              ? cs.secondaryContainer
                              : cs.onSurface.withValues(
                                  alpha: Opacities.disabledFill,
                                ))
                        : Colors.transparent,
                    border: i == 0
                        ? null
                        : Border(left: BorderSide(color: cs.outline)),
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? Space.md + Space.xxs : Space.sm,
                    vertical: Space.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (isSelected &&
                          showCheck &&
                          values.length <
                              Sizes.segmentedNoCheckFrom) ...<Widget>[
                        Icon(
                          Icons.check_rounded,
                          size: IconSpec.small,
                          color: fg,
                        ),
                        const SizedBox(width: Space.xs + Space.xxs),
                      ],
                      Flexible(
                        child: Text(
                          labels[i],
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelLarge?.copyWith(color: fg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            return compact ? segment : Expanded(child: segment);
          }),
        ),
      ),
    );
    return MinTapTarget(child: bar);
  }
}
