import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Section header: labelMedium caps, 0.8 tracking, onSurfaceVariant, 8 above
/// the content, optional trailing slot ([SinewSectionAction] or a note).
class SinewSectionHeader extends StatelessWidget {
  const SinewSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.inline = const <Widget>[],
    this.onTitleTap,
    this.padding = const EdgeInsets.only(bottom: Space.sectionHeaderGap),
  });

  final String title;

  /// Trailing slot.
  final Widget? trailing;

  /// Inline widgets after the title (a help glyph, a pill).
  final List<Widget> inline;
  final VoidCallback? onTitleTap;
  final EdgeInsetsGeometry padding;

  /// Minimum header height.
  static const double _minHeight = 24;

  @override
  Widget build(BuildContext context) {
    Widget head = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.sectionHeader,
            ),
          ),
        ),
        for (final Widget w in inline) ...<Widget>[
          const SizedBox(width: Space.xs + Space.xxs),
          w,
        ],
      ],
    );
    if (onTitleTap != null) {
      head = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTitleTap,
        child: head,
      );
    }
    return Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minHeight),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: head),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// The trailing labelLarge primary text action of a section header ("View
/// all", "Edit"). Keeps a 48dp tall hit area.
class SinewSectionAction extends StatelessWidget {
  const SinewSectionAction({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: IconSpec.tapTarget),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: context.text.labelLarge!.copyWith(
                color: context.cs.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card: surfaceContainer, 1dp outlineVariant, radius 20, padding 16 (hero
/// 20). Tappable when [onTap] is set.
class SinewCard extends StatelessWidget {
  const SinewCard({
    super.key,
    required this.child,
    this.padding,
    this.hero = false,
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hero;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final EdgeInsetsGeometry pad =
        padding ??
        EdgeInsets.all(hero ? Space.cardPaddingHero : Space.cardPadding);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: Radii.cardR,
      side: BorderSide(color: borderColor ?? cs.outlineVariant),
    );
    if (onTap == null) {
      return DecoratedBox(
        decoration: ShapeDecoration(
          color: color ?? cs.surfaceContainer,
          shape: shape,
        ),
        child: Padding(padding: pad, child: child),
      );
    }
    return Material(
      color: color ?? cs.surfaceContainer,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: pad, child: child),
      ),
    );
  }
}

/// Grouped list: one card, rows divided by 1dp outlineVariant (grouping over
/// boxing).
class SinewGroup extends StatelessWidget {
  const SinewGroup({
    super.key,
    required this.children,
    this.dividerInset = 0,
    this.color,
  });

  final List<Widget> children;

  /// Left inset of the dividers.
  final double dividerInset;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Material(
      color: color ?? cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.cardR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0)
              Divider(
                height: Strokes.hairline,
                thickness: Strokes.hairline,
                indent: dividerInset,
                color: cs.outlineVariant,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// List row: min 56 / 72 / 88 (title / + subtitle / + body line), padding
/// 16 / 8, a leading widget (24 icon or 40 / 48 tile), gap 16, titleMedium +
/// bodyMedium, a trailing slot. Tappable when [onTap] or [onLongPress] is set.
class SinewListRow extends StatelessWidget {
  const SinewListRow({
    super.key,
    required this.title,
    this.leading,
    this.titleTrailing,
    this.subtitle,
    this.below,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.dense = false,
    this.destructive = false,
    this.minHeight,
    this.subtitleLines = 1,
    this.titleDecoration,
  });

  final Widget? leading;
  final String title;
  final Widget? titleTrailing;
  final String? subtitle;
  final Widget? below;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// secondaryContainer fill (multi-select).
  final bool selected;
  final bool dense;
  final bool destructive;
  final double? minHeight;
  final int subtitleLines;

  /// For example line-through for completed items.
  final TextDecoration? titleDecoration;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Color titleColor = selected
        ? cs.onSecondaryContainer
        : (destructive ? cs.error : cs.onSurface);
    final Color subColor = selected
        ? cs.onSecondaryContainer
        : cs.onSurfaceVariant;
    final double h =
        minHeight ??
        (subtitle == null
            ? Space.listItem1
            : (below == null ? Space.listItem2 : Space.listItem3));

    final Widget content = Container(
      constraints: BoxConstraints(minHeight: h),
      color: selected ? cs.secondaryContainer : null,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.listRowPadH,
        vertical: Space.listRowPadV,
      ),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: Space.lg),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (dense ? tt.titleSmall : tt.titleMedium)!
                            .copyWith(
                              color: titleColor,
                              decoration: titleDecoration,
                            ),
                      ),
                    ),
                    if (titleTrailing != null) ...<Widget>[
                      const SizedBox(width: Space.sm),
                      titleTrailing!,
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: subtitleLines,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium!.copyWith(color: subColor),
                  ),
                ?below,
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: Space.md),
            trailing!,
          ],
        ],
      ),
    );
    if (onTap == null && onLongPress == null) return content;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(onTap: onTap, onLongPress: onLongPress, child: content),
    );
  }
}

/// Trailing chevron (20, onSurfaceVariant).
class SinewChevron extends StatelessWidget {
  const SinewChevron({super.key});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.chevron_right_rounded,
    size: IconSpec.glyph,
    color: context.cs.onSurfaceVariant,
  );
}

/// Container role pairs for icon tiles and pills.
enum SinewTone { secondary, primary, neutral, danger, warning, success }

/// The (container, on-container) colours of [tone] in the active theme.
(Color, Color) sinewToneColors(BuildContext context, SinewTone tone) {
  final ColorScheme cs = context.cs;
  final SinewColors c = context.colors;
  return switch (tone) {
    SinewTone.secondary => (cs.secondaryContainer, cs.onSecondaryContainer),
    SinewTone.primary => (cs.primaryContainer, cs.onPrimaryContainer),
    SinewTone.neutral => (cs.surfaceContainerHigh, cs.onSurfaceVariant),
    SinewTone.danger => (cs.errorContainer, cs.onErrorContainer),
    SinewTone.warning => (c.warningContainer, c.onWarningContainer),
    SinewTone.success => (c.successContainer, c.onSuccessContainer),
  };
}

/// 40dp icon tile, radius 12, container role + glyph 20 (decorative).
class SinewIconTile extends StatelessWidget {
  const SinewIconTile({
    super.key,
    required this.icon,
    this.tone = SinewTone.secondary,
    this.size = Sizes.tile,
    this.glyph,
    this.circle = false,
  });

  final IconData icon;
  final SinewTone tone;
  final double size;
  final double? glyph;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = sinewToneColors(context, tone);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: circle ? Radii.fullR : Radii.mediumR,
        ),
        child: Icon(icon, size: glyph ?? size / 2, color: fg),
      ),
    );
  }
}

/// Status pill: labelMedium, radius full, padding 2 / 8.
class SinewPill extends StatelessWidget {
  const SinewPill({
    super.key,
    required this.label,
    this.tone = SinewTone.secondary,
  });

  final String label;
  final SinewTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = sinewToneColors(context, tone);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.sm,
        vertical: Space.xxs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: Radii.fullR),
      child: Text(
        label,
        maxLines: 1,
        style: context.text.labelMedium!.copyWith(color: fg),
      ),
    );
  }
}
