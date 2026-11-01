import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'sinew_list.dart';

/// A settings section: a caps label over a bordered card of rows, with
/// section gap below. Rows are [SinewSettingsTile] / [SinewSwitchRow] /
/// [SinewNavigationRow] / [SinewValueRow]; dividers are drawn between them.
class SinewSettingsSection extends StatelessWidget {
  const SinewSettingsSection({
    super.key,
    required this.label,
    required this.children,
    this.bottomGap = Space.section,
  });

  final String label;
  final List<Widget> children;

  /// Space under the card.
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SinewSectionHeader(title: label),
          SinewSettingsCard(children: children),
        ],
      ),
    );
  }
}

/// The bordered card around a column of settings rows.
class SinewSettingsCard extends StatelessWidget {
  const SinewSettingsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SinewGroup(children: children);
}

/// One settings row: plain 24 icon, titleMedium label with an optional
/// subtitle, an optional trailing widget (chevron, value, switch). At least
/// 56 high, and it grows with large text instead of clipping.
class SinewSettingsTile extends StatelessWidget {
  const SinewSettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.labelTag,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Shown right after the label (a "Beta" pill).
  final Widget? labelTag;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Widget row = Container(
      constraints: const BoxConstraints(minHeight: Space.listItem1),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.md,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: IconSpec.size, color: cs.onSurfaceVariant),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        label,
                        style: tt.titleMedium!.copyWith(color: cs.onSurface),
                      ),
                    ),
                    if (labelTag case final Widget tag) ...<Widget>[
                      const SizedBox(width: Space.sm),
                      tag,
                    ],
                  ],
                ),
                if (subtitle case final String s)
                  Text(
                    s,
                    style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Space.sm),
          if (trailing case final Widget t) t,
        ],
      ),
    );
    return Opacity(
      opacity: enabled ? 1 : Opacities.disabled,
      child: onTap == null
          ? row
          : Semantics(
              button: true,
              enabled: enabled,
              child: InkWell(onTap: enabled ? onTap : null, child: row),
            ),
    );
  }
}

/// A settings row with a switch. The whole row toggles; the switch is the
/// state indicator and carries the row's label for TalkBack. With [card] the
/// row draws its own bordered card (for use in a form, outside a section).
class SinewSwitchRow extends StatelessWidget {
  const SinewSwitchRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
    this.card = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final bool card;

  @override
  Widget build(BuildContext context) {
    final Widget tile = MergeSemantics(
      child: SinewSettingsTile(
        icon: icon,
        label: label,
        subtitle: subtitle,
        enabled: enabled,
        onTap: () => onChanged(!value),
        trailing: ExcludeSemantics(
          child: IgnorePointer(
            child: Switch(
              value: value,
              onChanged: enabled ? (bool _) {} : null,
            ),
          ),
        ),
      ),
    );
    final Widget semantic = Semantics(
      toggled: value,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? () => onChanged(!value) : null,
      child: tile,
    );
    return card ? SinewGroup(children: <Widget>[semantic]) : semantic;
  }
}

/// A settings row that opens another screen or sheet: label, optional
/// subtitle, chevron.
class SinewNavigationRow extends StatelessWidget {
  const SinewNavigationRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.labelTag,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? labelTag;

  @override
  Widget build(BuildContext context) => SinewSettingsTile(
    icon: icon,
    label: label,
    subtitle: subtitle,
    labelTag: labelTag,
    onTap: onTap,
    trailing: const SinewChevron(),
  );
}

/// A settings row that shows its current value on the right (a unit, a
/// theme name) and opens a picker: label, value text, chevron.
class SinewValueRow extends StatelessWidget {
  const SinewValueRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  /// Null shows the value without a chevron (read only).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return SinewSettingsTile(
      icon: icon,
      label: label,
      subtitle: subtitle,
      onTap: onTap,
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * _valueMaxFraction,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium!.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            if (onTap != null) ...<Widget>[
              const SizedBox(width: Space.xs),
              const SinewChevron(),
            ],
          ],
        ),
      ),
    );
  }

  /// The value never takes more than this share of the row.
  static const double _valueMaxFraction = 0.4;
}
