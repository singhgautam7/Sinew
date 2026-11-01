import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Visual weight of an [AppIconButton].
enum AppIconButtonKind {
  /// surfaceContainerHigh disc, onSurface glyph. The default header button.
  standard,

  /// secondaryContainer disc: an active toggle (open menu).
  tonal,

  /// primary disc, onPrimary glyph.
  filled,

  /// No disc: a quiet action inside a field or a tinted row.
  plain,

  /// errorContainer disc: Delete in a contextual header.
  danger,
}

/// Every header action is this button: a 40dp disc with a 20dp glyph centred
/// in a 48dp tap target. [semanticLabel] is required because an icon-only
/// control is invisible to a screen reader without it; it is also the tooltip
/// on long press.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.kind = AppIconButtonKind.standard,
    this.size = Sizes.iconButton,
    this.glyphSize = IconSpec.glyph,
    this.tint,
    this.badge,
    this.badgeColor,
    this.onBadgeColor,
    this.onLongPress,
    this.tooltip = true,
    super.key,
  });

  final IconData icon;

  /// Null disables the button (38% opacity).
  final VoidCallback? onPressed;
  final String semanticLabel;
  final AppIconButtonKind kind;
  final double size;
  final double glyphSize;
  final Color? tint;

  /// A count badge. Empty string draws nothing.
  final String? badge;

  /// Badge colours; default error / onError.
  final Color? badgeColor;
  final Color? onBadgeColor;
  final VoidCallback? onLongPress;

  /// Show [semanticLabel] as a plain tooltip on long-press.
  final bool tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final bool disabled = onPressed == null;
    final (Color bg, Color fg) = switch (kind) {
      AppIconButtonKind.standard => (cs.surfaceContainerHigh, cs.onSurface),
      AppIconButtonKind.tonal => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
      ),
      AppIconButtonKind.filled => (cs.primary, cs.onPrimary),
      AppIconButtonKind.plain => (Colors.transparent, cs.onSurfaceVariant),
      AppIconButtonKind.danger => (cs.errorContainer, cs.onErrorContainer),
    };
    final double target = size < IconSpec.tapTarget ? IconSpec.tapTarget : size;
    final bool hasBadge = badge != null && badge!.isNotEmpty;

    Widget button = SizedBox(
      width: target,
      height: target,
      child: Center(
        child: Opacity(
          opacity: disabled ? Opacities.disabled : 1,
          child: Material(
            color: bg,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              onLongPress: onLongPress,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(icon, size: glyphSize, color: tint ?? fg),
              ),
            ),
          ),
        ),
      ),
    );

    // The Stack stays mounted whenever the caller styles a badge, so removing
    // it can animate too.
    if (hasBadge || badgeColor != null) {
      button = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          button,
          Positioned(
            top: Sizes.badgeInset,
            right: Sizes.badgeInset,
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: Motion.of(context, Motion.segment),
                switchInCurve: Motion.spring,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: !hasBadge
                    ? const SizedBox.shrink(key: ValueKey<String>('no-badge'))
                    : Container(
                        key: ValueKey<String?>(badge),
                        constraints: const BoxConstraints(
                          minWidth: Sizes.badge,
                        ),
                        height: Sizes.badge,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.xs,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badgeColor ?? cs.error,
                          borderRadius: Radii.fullR,
                        ),
                        child: Text(
                          badge!,
                          style: context.text.labelSmall!.copyWith(
                            color: onBadgeColor ?? cs.onError,
                            height: 1.1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      );
    }

    if (tooltip && onLongPress == null) {
      button = Tooltip(
        message: semanticLabel,
        triggerMode: TooltipTriggerMode.longPress,
        child: button,
      );
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onPressed,
      onLongPress: onLongPress,
      child: button,
    );
  }
}
