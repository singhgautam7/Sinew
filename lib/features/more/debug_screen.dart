import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/library/library_db.dart';
import '../../core/db/library/library_installer.dart';
import '../../core/db/repositories/exercise_repository.dart';
import '../../core/db/user/user_db.dart';
import '../../core/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/wallpaper_seed.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_segmented_control.dart';
import '../../core/widgets/sinew_settings.dart';
import 'debug_library_section.dart';

/// Library status for the debug screen: count and version, or why not.
final FutureProvider<({int count, String? version})> _libraryStatusProvider =
    FutureProvider.autoDispose<({int count, String? version})>((Ref ref) async {
      final LibraryRepository repo = await ref.watch(
        libraryRepositoryProvider.future,
      );
      return (count: await repo.count(), version: await repo.libraryVersion());
    });

/// Developer view: schema versions, library status and the theme switches,
/// so the scaffold can be checked on a device.
class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsProvider);
    final SettingsController ctrl = ref.read(settingsProvider.notifier);
    final AsyncValue<({int count, String? version})> library = ref.watch(
      _libraryStatusProvider,
    );
    final Color? seed = ref.watch(wallpaperSeedProvider);

    return Scaffold(
      appBar: const SinewAppBar(title: 'Debug', showBack: true),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.sm,
            Space.screen,
            Space.xl,
          ),
          children: <Widget>[
            SinewSettingsSection(
              label: 'Databases',
              children: <Widget>[
                const SinewSettingsTile(
                  icon: Icons.storage_rounded,
                  label: 'User database schema',
                  trailing: Text('v${UserDatabase.currentSchemaVersion}'),
                ),
                const SinewSettingsTile(
                  icon: Icons.library_books_outlined,
                  label: 'Library schema',
                  trailing: Text('v${LibraryDatabase.currentSchemaVersion}'),
                ),
                SinewSettingsTile(
                  icon: Icons.fitness_center_rounded,
                  label: 'Exercise library',
                  subtitle: switch (library) {
                    // Checked first: an error can arrive while still loading.
                    AsyncValue(:final Object error) when library.hasError =>
                      error is LibraryAssetMissing
                          ? 'Not bundled yet. Arrives in Phase 2.'
                          : 'Could not open: $error',
                    AsyncData(:final ({int count, String? version}) value) =>
                      '${value.count} exercises, version ${value.version ?? '?'}',
                    _ => 'Opening...',
                  },
                ),
              ],
            ),
            const DebugLibrarySection(),
            SinewSettingsSection(
              label: 'Theme',
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: SinewSegmentedControl<AppThemeMode>(
                    values: AppThemeMode.values,
                    labels: <String>[
                      for (final AppThemeMode m in AppThemeMode.values) m.label,
                    ],
                    selected: settings.themeMode,
                    onSelected: ctrl.setThemeMode,
                  ),
                ),
                SinewSwitchRow(
                  icon: Icons.wallpaper_rounded,
                  label: 'Colours from wallpaper',
                  subtitle: seed == null
                      ? 'No wallpaper colour on this device; using the family below.'
                      : 'Wallpaper seed available.',
                  value: settings.dynamicColor,
                  onChanged: (bool v) => ctrl.setDynamicColor(value: v),
                ),
              ],
            ),
            SinewSettingsSection(
              label: 'Family',
              children: <Widget>[
                for (final MullFamily f in kThemeFamilies)
                  SinewSettingsTile(
                    icon: f.id == settings.familyId
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    label: f.name,
                    subtitle: f.blurb,
                    onTap: () => ctrl.setFamily(f.id),
                    trailing: _FamilyDot(family: f),
                  ),
              ],
            ),
            const _SectionLabel('Roles'),
            const _RoleStrip(),
            const SizedBox(height: Space.xl),
            const _SectionLabel('Accents'),
            const _AccentStrip(),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Space.sectionHeaderGap),
    child: Text(label.toUpperCase(), style: context.sectionHeader),
  );
}

/// A family's dark primary, as a small dot.
class _FamilyDot extends StatelessWidget {
  const _FamilyDot({required this.family});

  final MullFamily family;

  static const double _size = 20;

  @override
  Widget build(BuildContext context) {
    final Color c = family.palette(dark: true).scheme.primary;
    return ExcludeSemantics(
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) => Semantics(
    label: name,
    child: Tooltip(
      message: name,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: Radii.mediumR,
          border: Border.all(color: context.cs.outlineVariant),
        ),
      ),
    ),
  );
}

/// The Sinew role map as swatches.
class _RoleStrip extends StatelessWidget {
  const _RoleStrip();

  @override
  Widget build(BuildContext context) {
    final SinewColors c = context.colors;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: <Widget>[
        for (final (String, Color) e in <(String, Color)>[
          ('primary', c.primary),
          ('primaryContainer', c.primaryContainer),
          ('secondaryContainer', c.secondaryContainer),
          ('tertiary', c.tertiary),
          ('success', c.success),
          ('warning', c.warning),
          ('danger', c.danger),
          ('surface', c.surface),
          ('surfaceContainer', c.surfaceContainer),
          ('surfaceContainerHigh', c.surfaceContainerHigh),
          ('outline', c.outline),
          ('onSurface', c.onSurface),
          ('onSurfaceVariant', c.onSurfaceVariant),
        ])
          _Swatch(e.$1, e.$2),
      ],
    );
  }
}

/// Plates, phases, heat and series as swatches.
class _AccentStrip extends StatelessWidget {
  const _AccentStrip();

  @override
  Widget build(BuildContext context) {
    final SinewAccents a = context.accents;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: <Widget>[
        for (final MapEntry<double, PlateColor> e in a.plates.entries)
          _Swatch('plate ${e.key}', e.value.fill),
        for (final SinewPhase p in SinewPhase.values)
          _Swatch('phase ${p.name}', a.phase(p).field),
        _Swatch('muscle primary', a.musclePrimary),
        _Swatch('muscle secondary', a.muscleSecondary),
        for (int i = 0; i < a.heat.length; i++) _Swatch('heat $i', a.heat[i]),
        for (int i = 0; i < a.series.length; i++)
          _Swatch('series $i', a.series[i]),
      ],
    );
  }
}
