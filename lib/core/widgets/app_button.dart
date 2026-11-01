import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'min_tap_target.dart';

enum AppButtonType {
  /// Filled (primary / onPrimary).
  primary,

  /// Tonal (secondaryContainer).
  normal,

  /// Outlined (1dp outlineVariant).
  outline,

  /// Danger tonal (errorContainer); [AppButton.filled] makes it solid error.
  danger,

  /// Dashed outline, low emphasis.
  dotted,
}

/// The one button: stadium, 40 high (padding 16, labelLarge) or 56 high
/// (padding 24, titleMedium), icon 20 with an 8 gap. Disabled = onSurface
/// 12% fill / 38% content. A 40 high button still has a 48dp hit area.
///
/// Types: primary, normal (tonal), outline, danger (tonal, or solid with
/// `filled`), dotted. `isLoading` swaps the icon for a spinner and disables
/// the tap. `fullWidth` stretches it.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.normal,
    this.icon,
    this.iconAfterLabel = false,
    this.horizontalPadding,
    this.fullWidth = false,
    this.width,
    this.height = Sizes.buttonLarge,
    this.isLoading = false,
    this.filled = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool iconAfterLabel;
  final bool fullWidth;
  final double? width;

  /// Snaps to the two spec sizes: >= 48 renders 56, below that 40.
  final double height;
  final bool isLoading;

  /// Overrides the side padding (24 for 56 buttons, 16 otherwise).
  final double? horizontalPadding;

  /// For [AppButtonType.danger] only: a solid error fill (high-stakes
  /// confirms) instead of the default danger-tonal container.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool large = height >= IconSpec.tapTarget;
    final double h = large ? Sizes.buttonLarge : Sizes.buttonSmall;
    final bool disabled = onPressed == null || isLoading;

    var (Color bg, Color fg, BorderSide side) = switch (type) {
      AppButtonType.primary => (cs.primary, cs.onPrimary, BorderSide.none),
      AppButtonType.normal => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
        BorderSide.none,
      ),
      AppButtonType.outline => (
        Colors.transparent,
        cs.onSurface,
        BorderSide(color: cs.outlineVariant),
      ),
      AppButtonType.danger =>
        filled
            ? (cs.error, cs.onError, BorderSide.none)
            : (cs.errorContainer, cs.onErrorContainer, BorderSide.none),
      AppButtonType.dotted => (
        Colors.transparent,
        cs.onSurfaceVariant,
        BorderSide.none,
      ),
    };
    if (disabled && !isLoading) {
      bg = type == AppButtonType.outline || type == AppButtonType.dotted
          ? Colors.transparent
          : cs.onSurface.withValues(alpha: Opacities.disabledFill);
      fg = cs.onSurface.withValues(alpha: Opacities.disabled);
      if (type == AppButtonType.outline) {
        side = BorderSide(
          color: cs.onSurface.withValues(alpha: Opacities.disabledFill),
        );
      }
    }

    final TextStyle textStyle =
        (large ? theme.textTheme.titleMedium : theme.textTheme.labelLarge)!
            .copyWith(color: fg);
    final Icon iconWidget = Icon(icon, size: IconSpec.glyph, color: fg);

    final Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isLoading)
          SizedBox(
            width: IconSpec.glyph,
            height: IconSpec.glyph,
            child: CircularProgressIndicator(
              strokeWidth: Strokes.spinnerSmall,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else if (icon != null && !iconAfterLabel) ...<Widget>[
          iconWidget,
          const SizedBox(width: Space.sm),
        ],
        if (isLoading) const SizedBox(width: Space.sm),
        Flexible(
          child: Text(
            label,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (!isLoading && icon != null && iconAfterLabel) ...<Widget>[
          const SizedBox(width: Space.sm),
          iconWidget,
        ],
      ],
    );

    Widget button = ConstrainedBox(
      constraints: BoxConstraints(minHeight: h),
      child: Material(
        color: bg,
        shape: StadiumBorder(side: side),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          child: Padding(
            // 24 side padding for 56 buttons, unless a caller fixed a narrow
            // width.
            padding: EdgeInsets.symmetric(
              horizontal:
                  horizontalPadding ??
                  (large &&
                          (width == null || width! >= Sizes.buttonWideThreshold)
                      ? Sizes.buttonPadLarge
                      : Sizes.buttonPadSmall),
            ),
            child: Center(widthFactor: 1, heightFactor: 1, child: content),
          ),
        ),
      ),
    );

    if (type == AppButtonType.dotted) {
      button = CustomPaint(
        foregroundPainter: _DashedBorderPainter(color: cs.outline),
        child: button,
      );
    }

    Widget sized = SizedBox(
      width: fullWidth ? double.infinity : width,
      height: h,
      child: button,
    );
    if (!large) {
      sized = MinTapTarget(onTap: disabled ? null : onPressed, child: sized);
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      excludeSemantics: true,
      onTap: disabled ? null : onPressed,
      child: sized,
    );
  }
}

/// Paints a dashed stadium border, used by [AppButtonType.dotted].
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = Strokes.hairline
      ..style = PaintingStyle.stroke;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(size.height / 2),
    );
    final Path path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final double next = (dist + Sizes.dashLength)
            .clamp(0, metric.length)
            .toDouble();
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + Sizes.dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color;
}
