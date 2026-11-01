import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_option_tile.dart';
import '../../core/widgets/sinew_states.dart';
import '../today/date_text.dart';
import 'backup_io.dart';
import 'backup_service.dart';

enum _Step { idle, reading, preview, rejected, restoring, done }

/// The restore flow in one widget: pick a backup file, check it, show what
/// is inside, restore it (Replace or Merge), and report what changed.
///
/// Used by Backup and restore (both modes) and by first-run Restore (Replace
/// only). Nothing is written until the person confirms, and a file that
/// fails the checks changes nothing.
class RestorePanel extends ConsumerStatefulWidget {
  const RestorePanel({
    super.key,
    this.allowMerge = true,
    this.doneLabel = 'Done',
    required this.onDone,
  });

  /// Offer Merge next to Replace. First run has nothing to merge with.
  final bool allowMerge;

  /// The button after a successful restore.
  final String doneLabel;
  final VoidCallback onDone;

  @override
  ConsumerState<RestorePanel> createState() => _RestorePanelState();
}

class _RestorePanelState extends ConsumerState<RestorePanel> {
  _Step _step = _Step.idle;
  PickedTextFile? _file;
  BackupPreview? _preview;
  BackupFailure? _error;
  RestoreMode _mode = RestoreMode.merge;
  RestoreSummary? _summary;

  @override
  void initState() {
    super.initState();
    if (!widget.allowMerge) _mode = RestoreMode.replace;
  }

  Future<void> _pick() async {
    setState(() => _step = _Step.reading);
    final PickedTextFile? file;
    try {
      file = await ref.read(backupFileIoProvider).pickText();
    } on Object {
      if (!mounted) return;
      setState(() {
        _step = _Step.rejected;
        _error = const CorruptBackup('That file could not be opened.');
      });
      return;
    }
    if (!mounted) return;
    if (file == null) {
      setState(() => _step = _Step.idle);
      return;
    }
    final BackupParseResult result = ref
        .read(backupServiceProvider)
        .parse(file.text);
    setState(() {
      _file = file;
      switch (result) {
        case ParsedBackup(:final BackupPreview preview):
          _preview = preview;
          _step = _Step.preview;
        case RejectedBackup(:final BackupFailure error):
          _error = error;
          _step = _Step.rejected;
      }
    });
  }

  Future<void> _restore() async {
    final BackupPreview preview = _preview!;
    final bool replace = _mode == RestoreMode.replace;
    final bool ok = await showSinewConfirmDialog(
      context: context,
      title: replace ? 'Replace everything?' : 'Merge this backup?',
      message: replace
          ? 'Everything on this phone is deleted and replaced by the backup. '
                'This cannot be undone.'
          : 'Anything new in the backup is added. Where both have the same '
                'item, the newer copy is kept. Nothing is deleted.',
      confirmLabel: replace ? 'Replace' : 'Merge',
      destructive: replace,
    );
    if (!ok || !mounted) return;
    setState(() => _step = _Step.restoring);
    try {
      final RestoreSummary summary = await ref
          .read(backupServiceProvider)
          .restore(preview, mode: _mode);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _step = _Step.done;
      });
    } on BackupFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _step = _Step.rejected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Motion.of(context, Motion.fast),
      alignment: Alignment.topCenter,
      child: switch (_step) {
        _Step.idle => _Idle(onPick: _pick, allowMerge: widget.allowMerge),
        _Step.reading || _Step.restoring => const Padding(
          padding: EdgeInsets.symmetric(vertical: Space.xl),
          child: SinewLoader(),
        ),
        _Step.rejected => _Rejected(error: _error!, onPick: _pick),
        _Step.preview => _Preview(
          file: _file!,
          preview: _preview!,
          mode: _mode,
          allowMerge: widget.allowMerge,
          onMode: (RestoreMode m) => setState(() => _mode = m),
          onPickOther: _pick,
          onRestore: _restore,
        ),
        _Step.done => _Done(
          summary: _summary!,
          label: widget.doneLabel,
          onDone: widget.onDone,
        ),
      },
    );
  }
}

class _Idle extends StatelessWidget {
  const _Idle({required this.onPick, required this.allowMerge});

  final VoidCallback onPick;
  final bool allowMerge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Pick a Sinew backup (a .json file) from your phone or a folder you '
          'synced yourself. Nothing is uploaded.',
          style: context.text.bodyMedium!.copyWith(
            color: context.cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.lg),
        AppButton(
          label: 'Choose a backup file',
          icon: Icons.folder_open_rounded,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: onPick,
        ),
      ],
    );
  }
}

class _Rejected extends StatelessWidget {
  const _Rejected({required this.error, required this.onPick});

  final BackupFailure error;
  final VoidCallback onPick;

  String get _title => switch (error) {
    CorruptBackup() => 'This backup is damaged',
    NotASinewBackup() => 'Not a Sinew backup',
    BackupFromNewerVersion() => 'Made by a newer Sinew',
    RestoreFailed() => 'The restore did not finish',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SinewCallout(
          tone: SinewCalloutTone.error,
          icon: Icons.error_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_title, style: context.text.titleMedium),
              const SizedBox(height: Space.xs),
              Text(error.message, style: context.text.bodyMedium),
              const SizedBox(height: Space.xs),
              Text(
                'Nothing on this phone was changed.',
                style: context.text.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        AppButton(
          label: 'Choose another file',
          type: AppButtonType.outline,
          fullWidth: true,
          onPressed: onPick,
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.file,
    required this.preview,
    required this.mode,
    required this.allowMerge,
    required this.onMode,
    required this.onPickOther,
    required this.onRestore,
  });

  final PickedTextFile file;
  final BackupPreview preview;
  final RestoreMode mode;
  final bool allowMerge;
  final ValueChanged<RestoreMode> onMode;
  final VoidCallback onPickOther;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final BackupPreview p = preview;
    final List<(String, String)> rows = <(String, String)>[
      ('Workouts', '${p.sessions}'),
      ('Routines', '${p.routines}'),
      ('Custom exercises', '${p.customExercises}'),
      ('Measurement entries', '${p.measurementEntries}'),
      ('Measurement fields', '${p.measurementFields}'),
      ('Timer presets', '${p.timerPresets}'),
      if (p.hasProfile) ('Profile', 'Included'),
      if (p.hasPlateInventory) ('Plates and bars', 'Included'),
      if (p.settings > 0) ('Settings', '${p.settings}'),
    ];
    final DateTime? first = p.firstSessionAt?.toLocal();
    final DateTime? last = p.lastSessionAt?.toLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SinewCard(
          child: Row(
            children: <Widget>[
              const SinewIconTile(icon: Icons.description_outlined),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      file.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium,
                    ),
                    Text(
                      'Made ${DateText.dayMonthYear(p.exportedAt.toLocal())}'
                      '${file.size == null ? '' : ' · ${_size(file.size!)}'}',
                      style: context.text.bodySmall!.copyWith(
                        color: context.cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded, color: context.cs.primary),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        SinewGroup(
          children: <Widget>[
            for (final (String k, String v) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.lg,
                  vertical: Space.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(child: Text(k, style: context.text.bodyLarge)),
                    const SizedBox(width: Space.md),
                    Text(
                      v,
                      style: context.text.titleMedium!.copyWith(
                        color: context.cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (first != null && last != null) ...<Widget>[
          const SizedBox(height: Space.sm),
          Text(
            'Workouts from ${DateText.dayMonthYear(first)} to '
            '${DateText.dayMonthYear(last)}.',
            style: context.text.bodySmall!.copyWith(
              color: context.cs.onSurfaceVariant,
            ),
          ),
        ],
        if (allowMerge) ...<Widget>[
          const SizedBox(height: Space.xl),
          const SinewFieldLabel('How to restore'),
          const SizedBox(height: Space.sm),
          SinewOptionTile(
            title: 'Merge',
            subtitle:
                'Add what is new. Where both have the same item, the newer '
                'copy wins. Nothing is deleted.',
            selected: mode == RestoreMode.merge,
            onTap: () => onMode(RestoreMode.merge),
          ),
          const SizedBox(height: Space.sm),
          SinewOptionTile(
            title: 'Replace',
            subtitle:
                'Delete everything on this phone and use the backup instead.',
            selected: mode == RestoreMode.replace,
            onTap: () => onMode(RestoreMode.replace),
          ),
        ],
        const SizedBox(height: Space.xl),
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                label: 'Choose another',
                type: AppButtonType.outline,
                fullWidth: true,
                onPressed: onPickOther,
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: AppButton(
                label: mode == RestoreMode.replace ? 'Replace' : 'Merge',
                type: mode == RestoreMode.replace
                    ? AppButtonType.danger
                    : AppButtonType.primary,
                fullWidth: true,
                onPressed: onRestore,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} kB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

String _sectionName(String key, int n) => switch (key) {
  'sessions' => n == 1 ? 'workout' : 'workouts',
  'routines' => n == 1 ? 'routine' : 'routines',
  'customExercises' => n == 1 ? 'custom exercise' : 'custom exercises',
  'measurementEntries' => n == 1 ? 'measurement entry' : 'measurement entries',
  'measurementFields' => n == 1 ? 'measurement field' : 'measurement fields',
  'timerPresets' => n == 1 ? 'timer preset' : 'timer presets',
  'profile' => 'profile',
  'plateInventory' => 'plates and bars',
  _ => key,
};

class _Done extends StatelessWidget {
  const _Done({
    required this.summary,
    required this.label,
    required this.onDone,
  });

  final RestoreSummary summary;
  final String label;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final List<String> wrote = <String>[
      for (final MapEntry<String, int> e in summary.written.entries)
        if (e.key != 'tombstones' && e.value > 0)
          '${e.value} ${_sectionName(e.key, e.value)}',
    ];
    final List<String> kept = <String>[
      for (final MapEntry<String, int> e in summary.kept.entries)
        if (e.key != 'tombstones' && e.value > 0)
          '${e.value} ${_sectionName(e.key, e.value)}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SinewCallout(
          tone: SinewCalloutTone.success,
          icon: Icons.check_circle_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                summary.mode == RestoreMode.replace
                    ? 'Backup restored'
                    : 'Backup merged',
                style: context.text.titleMedium,
              ),
              const SizedBox(height: Space.xs),
              Text(
                wrote.isEmpty
                    ? 'Nothing needed to change.'
                    : 'Added or updated: ${wrote.join(', ')}.',
                style: context.text.bodyMedium,
              ),
              if (kept.isNotEmpty)
                Text(
                  'Kept the newer copy of: ${kept.join(', ')}.',
                  style: context.text.bodyMedium,
                ),
              if (summary.settingsApplied > 0)
                Text(
                  '${summary.settingsApplied} settings applied.',
                  style: context.text.bodyMedium,
                ),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        AppButton(
          label: label,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: onDone,
        ),
      ],
    );
  }
}
