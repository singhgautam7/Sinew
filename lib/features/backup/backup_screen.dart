import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_settings.dart';
import '../../core/format/date_text.dart';
import 'export_sheet.dart';
import 'restore_panel.dart';

/// One line for the last backup, shared by More and this screen.
String lastBackupLine(DateTime? last, DateTime now) {
  if (last == null) return 'No backup yet';
  return 'Last backup ${DateText.dayMonth(last.toLocal())}';
}

/// Backup and restore: export JSON or CSV, import a backup. No automatic or
/// cloud backup: a copy exists only when the person makes one.
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime? last = ref.watch(lastBackupAtProvider);
    final DateTime now = DateTime.now();
    final bool remind = ref.watch(shouldRemindBackupProvider).value ?? false;
    final ColorScheme cs = context.cs;
    return Scaffold(
      appBar: const SinewAppBar(title: 'Backup and restore', showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.xs,
          Space.screen,
          Space.bottomSafe,
        ),
        children: <Widget>[
          SinewCard(
            color: remind ? context.colors.warningContainer : null,
            child: Row(
              children: <Widget>[
                SinewIconTile(
                  icon: Icons.history_rounded,
                  tone: remind ? SinewTone.warning : SinewTone.secondary,
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lastBackupLine(last, now),
                        style: context.text.titleMedium,
                      ),
                      Text(
                        last == null
                            ? 'Everything lives on this phone. Save a copy '
                                  'now and then.'
                            : DateText.ago(last, now),
                        style: context.text.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.section),
          SinewSettingsSection(
            label: 'Import / export',
            children: <Widget>[
              SinewNavigationRow(
                icon: Icons.data_object_rounded,
                label: 'Export backup (JSON)',
                subtitle: 'Everything, can be restored',
                onTap: () => showExportSheet(context),
              ),
              SinewNavigationRow(
                icon: Icons.table_view_rounded,
                label: 'Export CSV',
                subtitle: 'Workouts and measurements, for a spreadsheet',
                onTap: () =>
                    showExportSheet(context, initial: ExportFormat.csv),
              ),
              SinewNavigationRow(
                icon: Icons.download_rounded,
                label: 'Import a backup',
                subtitle: 'Replace or merge with what is here',
                onTap: () => showImportSheet(context),
              ),
            ],
          ),
          Text(
            'Backups are plain files you keep. Sinew never sends them '
            'anywhere, and there is no automatic or cloud backup.',
            style: context.text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The import sheet: the restore flow in a bottom sheet.
Future<void> showImportSheet(BuildContext context) =>
    showSinewBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => SinewBottomSheet(
        title: 'Import a backup',
        child: RestorePanel(onDone: () => Navigator.of(sheetContext).pop()),
      ),
    );
