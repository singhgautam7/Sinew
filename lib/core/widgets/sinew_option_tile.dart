import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One choice in a single-choice list: a short tag (`kg`), a name, an optional
/// line under it, and a check when selected. Selection is the container
/// colour plus the check, never colour alone. At least 56dp tall.
class SinewOptionTile extends StatelessWidget {
  const SinewOptionTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.tag,
    this.subtitle,
  });

  final String title;
  final String? tag;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Color fg = selected ? cs.onSecondaryContainer : cs.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? cs.secondaryContainer : cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.largeR,
          side: BorderSide(
            color: selected ? cs.secondaryContainer : cs.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Space.listItem1),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.lg,
                vertical: Space.sm,
              ),
              child: Row(
                children: <Widget>[
                  if (tag != null) ...<Widget>[
                    ExcludeSemantics(
                      child: SizedBox(
                        width: Sizes.leadingTile,
                        child: Text(
                          tag!,
                          style: tt.titleMedium!.copyWith(color: fg),
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title, style: tt.titleMedium!.copyWith(color: fg)),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: tt.bodySmall!.copyWith(
                              color: selected
                                  ? cs.onSecondaryContainer
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (selected) ...<Widget>[
                    const SizedBox(width: Space.sm),
                    Icon(Icons.check_circle_rounded, color: cs.primary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
