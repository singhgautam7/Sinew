import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_families.dart' show SinewPalette;
import '../../core/theme/wallpaper_seed.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_grid.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_settings.dart';

/// Mode (System, Light, Dark, AMOLED), the colour family and "Colours from
/// wallpaper". Every choice applies the moment it is made.
class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings s = ref.watch(settingsProvider);
    final SettingsController ctl = ref.read(settingsProvider.notifier);
    final Color? seed = ref.watch(wallpaperSeedProvider);
    final bool dynamicOn = s.dynamicColor && seed != null;
    final MullFamily current = dynamicOn
        ? MullFamily.fromSeed(seed)
        : familyById(s.familyId);
    final Brightness platform = MediaQuery.platformBrightnessOf(context);
    final Tone previewTone = s.toneFor(platform);

    return Scaffold(
      appBar: SinewAppBar(
        title: 'Theme',
        subtitle:
            '${dynamicOn ? 'Wallpaper' : current.name} · '
            '${s.themeMode.label}',
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.xs,
          Space.screen,
          Space.bottomSafe,
        ),
        children: <Widget>[
          const SinewSectionHeader(title: 'Mode'),
          SinewTwoColumnGrid(
            children: <Widget>[
              for (final AppThemeMode m in AppThemeMode.values)
                _ModeCard(
                  mode: m,
                  family: current,
                  selected: m == s.themeMode,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ctl.setThemeMode(m);
                  },
                ),
            ],
          ),
          const SizedBox(height: Space.section),
          const SinewSectionHeader(title: 'Colour'),
          SinewSwitchRow(
            icon: Icons.wallpaper_rounded,
            card: true,
            label: 'From your wallpaper',
            subtitle: seed == null
                ? 'Not available on this phone (Android 12 and later)'
                : 'Dynamic colour, Android 12 and later',
            value: dynamicOn,
            enabled: seed != null,
            onChanged: (bool v) => ctl.setDynamicColor(value: v),
          ),
          const SizedBox(height: Space.md),
          SinewTwoColumnGrid(
            children: <Widget>[
              for (final MullFamily f in kThemeFamilies)
                _FamilyCard(
                  family: f,
                  tone: previewTone,
                  selected: !dynamicOn && f.id == familyById(s.familyId).id,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ctl.setDynamicColor(value: false);
                    ctl.setFamily(f.id);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A mode: a mini screen in the family's colours, its name, a hint.
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.family,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final MullFamily family;
  final bool selected;
  final VoidCallback onTap;

  String get _hint => switch (mode) {
    AppThemeMode.system => 'Follows phone',
    AppThemeMode.light => 'Always light',
    AppThemeMode.dark => 'Always dark',
    AppThemeMode.amoled => 'True black',
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Semantics(
      button: true,
      selected: selected,
      label: '${mode.label} mode, $_hint',
      excludeSemantics: true,
      child: Material(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardR,
          side: BorderSide(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? MoreSpec.familyCardBorder : Strokes.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ModePreview(mode: mode, family: family),
                const SizedBox(height: Space.sm),
                Row(
                  children: <Widget>[
                    Expanded(child: Text(mode.label, style: tt.titleMedium)),
                    if (selected)
                      Icon(
                        Icons.check_circle_rounded,
                        size: IconSpec.size,
                        color: cs.primary,
                      ),
                  ],
                ),
                Text(
                  _hint,
                  style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModePreview extends StatelessWidget {
  const _ModePreview({required this.mode, required this.family});

  final AppThemeMode mode;
  final MullFamily family;

  @override
  Widget build(BuildContext context) {
    Widget half(Tone tone) {
      final ColorScheme s = AppTheme.paletteOf(family, tone).scheme;
      return Expanded(
        child: ColoredBox(
          color: s.surface,
          child: Padding(
            padding: const EdgeInsets.all(Space.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: MoreSpec.modePreviewBar,
                  width: MoreSpec.modePreviewBar * 4,
                  decoration: BoxDecoration(
                    color: s.primary,
                    borderRadius: Radii.fullR,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Container(
                  height: MoreSpec.modePreviewBar,
                  decoration: BoxDecoration(
                    color: s.surfaceContainerHigh,
                    borderRadius: Radii.fullR,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: Radii.mediumR,
        child: SizedBox(
          height: MoreSpec.modePreviewHeight,
          child: Row(
            children: switch (mode) {
              AppThemeMode.system => <Widget>[
                half(Tone.light),
                half(Tone.dark),
              ],
              AppThemeMode.light => <Widget>[half(Tone.light)],
              AppThemeMode.dark => <Widget>[half(Tone.dark)],
              AppThemeMode.amoled => <Widget>[half(Tone.amoled)],
            },
          ),
        ),
      ),
    );
  }
}

/// A colour family: three swatches from its real palette in the tone being
/// previewed, its name and a one-line blurb.
class _FamilyCard extends StatelessWidget {
  const _FamilyCard({
    required this.family,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final MullFamily family;
  final Tone tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final SinewPalette p = AppTheme.paletteOf(family, tone);
    return Semantics(
      button: true,
      selected: selected,
      label: '${family.name} theme',
      excludeSemantics: true,
      child: Material(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardR,
          side: BorderSide(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? MoreSpec.familyCardBorder : Strokes.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: MoreSpec.familyCardMinHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _Dot(p.scheme.primary),
                      const SizedBox(width: Space.xs),
                      _Dot(p.scheme.primaryContainer),
                      const SizedBox(width: Space.xs),
                      _Dot(
                        p.scheme.surfaceContainerHigh,
                        border: cs.outlineVariant,
                      ),
                      const Spacer(),
                      if (selected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: IconSpec.size,
                          color: cs.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: Space.md),
                  Text(family.name, style: tt.titleMedium),
                  Text(
                    family.blurb,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
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

class _Dot extends StatelessWidget {
  const _Dot(this.color, {this.border});

  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) => Container(
    width: MoreSpec.swatchSmall,
    height: MoreSpec.swatchSmall,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: border == null ? null : Border.all(color: border!),
    ),
  );
}
