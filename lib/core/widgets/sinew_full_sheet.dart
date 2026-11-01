import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon_button.dart';

/// A tall modal sheet whose body scrolls itself (virtualised lists, forms):
/// unlike `SinewBottomSheet`, [child] is not wrapped in a scroll view.
///
/// Open it with `showSinewBottomSheet`. Covers [LibrarySpec.sheetHeightFactor]
/// of the screen, moves up with the keyboard, and has a handle, a title row
/// with an optional [headerAction] and a close button, and an optional
/// [bottom] bar (a primary button).
class SinewFullSheet extends StatelessWidget {
  const SinewFullSheet({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.headerAction,
    this.bottom,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget? headerAction;
  final Widget child;
  final Widget? bottom;

  /// Replaces the default close (pop the sheet).
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final MediaQueryData mq = MediaQuery.of(context);
    final double height =
        (mq.size.height - mq.viewInsets.bottom) * LibrarySpec.sheetHeightFactor;
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: Radii.sheetR,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: Sizes.handleBand,
                child: Center(
                  child: Container(
                    width: Sizes.handleWidth,
                    height: Sizes.handleHeight,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(
                        alpha: Opacities.handle,
                      ),
                      borderRadius: Radii.fullR,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.xs,
                  Space.lg,
                  Space.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (subtitle != null)
                            Text(
                              subtitle!.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.sectionHeader,
                            ),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleLarge!.copyWith(color: cs.onSurface),
                          ),
                        ],
                      ),
                    ),
                    if (headerAction != null) ...<Widget>[
                      headerAction!,
                      const SizedBox(width: Space.xs),
                    ],
                    AppIconButton(
                      icon: Icons.close_rounded,
                      semanticLabel: 'Close',
                      onPressed: onClose ?? () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
              if (bottom != null)
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    border: Border(
                      top: BorderSide(
                        color: cs.outlineVariant,
                        width: Strokes.hairline,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    Space.screen,
                    Space.md,
                    Space.screen,
                    Space.lg +
                        (mq.viewInsets.bottom > 0 ? 0 : mq.padding.bottom),
                  ),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
