import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_segmented_control.dart';
import '../../core/widgets/sinew_snackbar.dart';
import 'backup_io.dart';
import 'backup_service.dart';
import 'csv_export.dart';

enum ExportFormat { json, csv }

/// The Export sheet: JSON (the whole app, can be restored) or CSV (for a
/// spreadsheet, read-only), saved where the person chooses or shared.
/// Nothing is uploaded by Sinew.
Future<void> showExportSheet(
  BuildContext context, {
  ExportFormat initial = ExportFormat.json,
}) => showSinewBottomSheet<void>(
  context: context,
  builder: (BuildContext _) => _ExportSheet(initial: initial),
);

class _ExportSheet extends ConsumerStatefulWidget {
  const _ExportSheet({required this.initial});

  final ExportFormat initial;

  @override
  ConsumerState<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<_ExportSheet> {
  late ExportFormat _format = widget.initial;
  bool _measurements = true;
  bool _sets = true;
  bool _busy = false;

  bool get _canExport => _format == ExportFormat.json || _measurements || _sets;

  /// Builds the files for the chosen format. JSON is not marked as backed up
  /// here: only a save or share that went through counts.
  Future<
    ({
      List<({String name, Uint8List bytes, String mimeType})> files,
      BackupFile? backup,
    })
  >
  _build() async {
    if (_format == ExportFormat.json) {
      final BackupFile b = await ref
          .read(backupServiceProvider)
          .export(markBackedUp: false);
      return (
        files: <({String name, Uint8List bytes, String mimeType})>[
          (
            name: b.fileName,
            bytes: Uint8List.fromList(utf8.encode(b.contents)),
            mimeType: 'application/json',
          ),
        ],
        backup: b,
      );
    }
    final CsvExportService csv = await ref.read(
      csvExportServiceProvider.future,
    );
    final List<CsvFile> made = <CsvFile>[
      if (_measurements) await csv.measurementsCsv(),
      if (_sets) await csv.setsCsv(),
    ];
    return (
      files: <({String name, Uint8List bytes, String mimeType})>[
        for (final CsvFile f in made)
          (
            name: f.fileName,
            bytes: Uint8List.fromList(utf8.encode(f.contents)),
            mimeType: 'text/csv',
          ),
      ],
      backup: null,
    );
  }

  Future<void> _run({required bool share}) async {
    if (_busy || !_canExport) return;
    setState(() => _busy = true);
    final BackupFileIo io = ref.read(backupFileIoProvider);
    try {
      final built = await _build();
      bool done = share;
      if (share) {
        await io.share(built.files);
      } else {
        done = true;
        for (final f in built.files) {
          final bool saved = await io.save(
            fileName: f.name,
            bytes: f.bytes,
            mimeType: f.mimeType,
          );
          if (!saved) done = false;
        }
      }
      if (done && built.backup != null) {
        await ref
            .read(backupServiceProvider)
            .markBackedUp(built.backup!.exportedAt);
      }
      if (!mounted) return;
      if (done) {
        showSinewSnackBar(
          context,
          built.backup != null
              ? 'Backup ${share ? 'shared' : 'saved'}'
              : 'Export ${share ? 'shared' : 'saved'}',
        );
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        showSinewSnackBar(
          context,
          'The export did not finish. Nothing was changed.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    return SinewBottomSheet(
      title: 'Export',
      description: 'You pick where the file goes. Sinew never uploads it.',
      actions: Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              label: 'Share',
              icon: Icons.ios_share_rounded,
              type: AppButtonType.outline,
              fullWidth: true,
              onPressed: _busy || !_canExport ? null : () => _run(share: true),
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: AppButton(
              label: 'Save',
              icon: Icons.save_alt_rounded,
              type: AppButtonType.primary,
              fullWidth: true,
              isLoading: _busy,
              onPressed: _busy || !_canExport ? null : () => _run(share: false),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SinewSegmentedControl<ExportFormat>(
            values: ExportFormat.values,
            labels: const <String>['JSON backup', 'CSV'],
            selected: _format,
            onSelected: (ExportFormat f) => setState(() => _format = f),
          ),
          const SizedBox(height: Space.md),
          if (_format == ExportFormat.json)
            Text(
              'Everything in Sinew: workouts, routines, custom exercises, '
              'measurements, timer presets, plates and your settings. '
              'It can be restored later.',
              style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            )
          else ...<Widget>[
            Text(
              'For spreadsheets. Values are metric (kg, cm, metres, '
              'seconds). A CSV cannot be restored into Sinew.',
              style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: Space.md),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: <Widget>[
                SinewChip(
                  label: CsvExportService.measurementsFileName,
                  selected: _measurements,
                  onTap: () => setState(() => _measurements = !_measurements),
                ),
                SinewChip(
                  label: CsvExportService.setsFileName,
                  selected: _sets,
                  onTap: () => setState(() => _sets = !_sets),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
