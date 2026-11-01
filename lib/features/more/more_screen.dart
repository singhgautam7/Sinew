import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/profile.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/units.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_settings.dart';
import '../backup/backup_screen.dart';
import '../backup/export_sheet.dart';
import 'profile_form.dart';

/// One line under Profile: what is filled in, or an invitation to fill it.
String profileSummary(Profile p) {
  final List<String> bits = <String>[
    if (p.sex != null) sexLabel(p.sex),
    if (p.heightCm != null)
      Units.formatLength(p.heightCm!, p.lengthUnit, maxDecimals: 0),
    if (p.birthYear != null) 'born ${p.birthYear}',
  ];
  return bits.isEmpty
      ? 'Add your height and birth year for BMI and calories'
      : bits.join(' · ');
}

/// The last tab: you, training setup, data and the app.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Profile profile = ref.watch(profileProvider).value ?? const Profile();
    final AppSettings settings = ref.watch(settingsProvider);
    final DateTime? last = ref.watch(lastBackupAtProvider);
    final bool remind = ref.watch(shouldRemindBackupProvider).value ?? false;
    final String backupLine = last != null
        ? lastBackupLine(last, DateTime.now())
        : (remind
              ? 'Not backed up yet. Save a copy.'
              : 'Export JSON or CSV, import a backup');
    final MullFamily family = familyById(settings.familyId);

    return Scaffold(
      appBar: SinewAppBar(
        title: 'More',
        actions: <Widget>[
          AppIconButton(
            icon: Icons.search_rounded,
            semanticLabel: 'Search',
            onPressed: () => context.push(Routes.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.xs,
          Space.screen,
          Space.bottomSafe,
        ),
        children: <Widget>[
          SinewCard(
            onTap: () => context.push(Routes.profile),
            child: Row(
              children: <Widget>[
                const SinewIconTile(
                  icon: Icons.person_rounded,
                  tone: SinewTone.primary,
                  circle: true,
                  size: Sizes.buttonLarge,
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        settings.userName.isEmpty
                            ? 'Your profile'
                            : settings.userName,
                        style: context.text.titleMedium,
                      ),
                      Text(
                        profileSummary(profile),
                        style: context.text.bodyMedium!.copyWith(
                          color: context.cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SinewChevron(),
              ],
            ),
          ),
          const SizedBox(height: Space.section),
          SinewSettingsSection(
            label: 'Training',
            children: <Widget>[
              SinewNavigationRow(
                icon: Icons.fitness_center_rounded,
                label: 'Plates and bars',
                subtitle: 'For drawing and rounding loads',
                onTap: () => context.push(Routes.plates),
              ),
              SinewNavigationRow(
                icon: Icons.straighten_rounded,
                label: 'Units',
                subtitle:
                    '${Units.weightLabel(profile.weightUnit)}, '
                    '${Units.lengthLabel(profile.lengthUnit)}, '
                    '${Units.distanceLabel(profile.distanceUnit)}',
                onTap: () => context.push(Routes.units),
              ),
              SinewNavigationRow(
                icon: Icons.tune_rounded,
                label: 'Measurement fields',
                subtitle: 'Choose what you track',
                onTap: () => context.push(Routes.fields),
              ),
            ],
          ),
          SinewSettingsSection(
            label: 'Data',
            children: <Widget>[
              SinewNavigationRow(
                icon: remind ? Icons.backup_outlined : Icons.backup_rounded,
                label: 'Backup and restore',
                subtitle: backupLine,
                onTap: () => context.push(Routes.backup),
              ),
              SinewNavigationRow(
                icon: Icons.table_view_rounded,
                label: 'Export CSV',
                subtitle: 'Workouts and measurements',
                onTap: () =>
                    showExportSheet(context, initial: ExportFormat.csv),
              ),
            ],
          ),
          SinewSettingsSection(
            label: 'App',
            children: <Widget>[
              SinewNavigationRow(
                icon: Icons.settings_rounded,
                label: 'Settings',
                subtitle: 'Workout, timer, sounds',
                onTap: () => context.push(Routes.settings),
              ),
              SinewNavigationRow(
                icon: Icons.palette_outlined,
                label: 'Theme',
                subtitle: '${family.name} · ${settings.themeMode.label}',
                onTap: () => context.push(Routes.theme),
              ),
              SinewNavigationRow(
                icon: Icons.shield_outlined,
                label: 'Permissions',
                subtitle: 'What Sinew can and cannot do',
                onTap: () => context.push(Routes.permissions),
              ),
              SinewNavigationRow(
                icon: Icons.info_outline_rounded,
                label: 'About Sinew',
                subtitle: 'Offline promise, sources, version',
                onTap: () => context.push(Routes.about),
              ),
              if (kDebugMode)
                SinewNavigationRow(
                  icon: Icons.bug_report_outlined,
                  label: 'Debug',
                  subtitle: 'Databases, library and theme',
                  onTap: () => context.push(Routes.debug),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
