import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/library/library_db.dart';
import '../../core/db/library/library_installer.dart';
import '../../core/db/repositories/exercise_repository.dart';
import '../../core/db/user/user_db.dart';
import '../../core/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/wallpaper_seed.dart';

/// Library status for the debug screen: count and version, or why not.
final FutureProvider<({int count, String? version})> _libraryStatusProvider =
    FutureProvider.autoDispose<({int count, String? version})>((Ref ref) async {
      final LibraryRepository repo = await ref.watch(
        libraryRepositoryProvider.future,
      );
      return (count: await repo.count(), version: await repo.libraryVersion());
    });

/// Developer view: schema versions, library status and the theme switches,
/// so the scaffold can be checked on a device. Phase 2 adds library counts
/// per category and a stats calculator here.
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
      appBar: AppBar(title: const Text('Debug')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: Space.sm),
          children: <Widget>[
            const _Header('Databases'),
            const ListTile(
              title: Text('User database schema'),
              trailing: Text('v${UserDatabase.currentSchemaVersion}'),
            ),
            const ListTile(
              title: Text('Library schema'),
              trailing: Text('v${LibraryDatabase.currentSchemaVersion}'),
            ),
            ListTile(
              title: const Text('Exercise library'),
              subtitle: Text(switch (library) {
                // Checked first: an error can arrive while still loading.
                AsyncValue(:final Object error) when library.hasError =>
                  error is LibraryAssetMissing
                      ? 'Not bundled yet. Arrives in Phase 2.'
                      : 'Could not open: $error',
                AsyncData(:final ({int count, String? version}) value) =>
                  '${value.count} exercises, version ${value.version ?? '?'}',
                _ => 'Opening…',
              }),
            ),
            const _Header('Theme'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: SegmentedButton<ThemeMode>(
                segments: const <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                  ),
                ],
                selected: <ThemeMode>{settings.themeMode},
                onSelectionChanged: (Set<ThemeMode> s) =>
                    ctrl.setThemeMode(s.single),
              ),
            ),
            SwitchListTile(
              title: const Text('True black in dark mode'),
              value: settings.amoled,
              onChanged: (bool v) => ctrl.setAmoled(value: v),
            ),
            SwitchListTile(
              title: const Text('Colours from wallpaper'),
              subtitle: Text(
                seed == null
                    ? 'No wallpaper colour on this device; using Sinew green.'
                    : 'Wallpaper seed available.',
              ),
              value: settings.dynamicColor,
              onChanged: (bool v) => ctrl.setDynamicColor(value: v),
            ),
            const _Header('Tokens'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: <Widget>[
                  for (final (String name, Color color) in <(String, Color)>[
                    ('primary', context.colors.primary),
                    ('primaryContainer', context.colors.primaryContainer),
                    ('tertiary', context.colors.tertiary),
                    ('success', context.colors.success),
                    ('warning', context.colors.warning),
                    ('danger', context.colors.danger),
                    ('surfaceContainer', context.colors.surfaceContainer),
                  ])
                    Chip(
                      avatar: CircleAvatar(backgroundColor: color),
                      label: Text(name),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Space.lg, Space.xl, Space.lg, Space.sm),
    child: Text(
      label,
      style: context.text.labelLarge?.copyWith(color: context.colors.primary),
    ),
  );
}
