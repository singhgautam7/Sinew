import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/ids.dart';
import '../../core/models/timer_preset.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/domain/timer_ring.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_dialogs.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_menu.dart';
import '../../core/widgets/sinew_snackbar.dart';
import '../../core/widgets/sinew_states.dart';
import '../../engines/timer/timer_engine.dart';
import 'controller/timer_presets_provider.dart';
import 'controller/timer_session.dart';
import 'data/active_timer.dart';
import 'data/timer_modes.dart';
import 'data/timer_presets.dart';
import 'widgets/name_dialog.dart';

/// The Timer tab: the nine modes, the saved presets and, while a timer is
/// running, a banner that takes you back to it.
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TimerPreset>> presets = ref.watch(
      timerPresetsProvider,
    );
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.bottomSafe),
        children: <Widget>[
          const SinewPageHeader(title: 'Timer'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _RunningBanner(),
                const _ModeGrid(),
                const SizedBox(height: Space.section),
                const SinewSectionHeader(title: 'Saved presets'),
                presets.when(
                  data: (List<TimerPreset> list) => list.isEmpty
                      ? const SinewEmptyState(
                          icon: Icons.timer_outlined,
                          title: 'No presets yet',
                          description: 'Set up a timer and choose Save preset to keep it here.',
                        )
                      : SinewGroup(
                          children: <Widget>[
                            for (final TimerPreset p in list)
                              _PresetRow(preset: p),
                          ],
                        ),
                  loading: () => const Delayed(child: SinewSkeletonCard()),
                  error: (Object e, StackTrace s) => const SinewEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Presets could not load',
                    description: 'Your timers still work. Try again later.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the run screen. Used by the banner and by Start.
void openTimerRun(BuildContext context) => context.push(Routes.timerRun);

class _RunningBanner extends ConsumerWidget {
  const _RunningBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool running = ref.watch(timerRunningProvider);
    final ActiveTimer? a = ref.watch(timerSessionProvider).value;
    if (!running || a == null) return const SizedBox.shrink();
    final TimerSnapshot s = a.run.snapshotAt(ref.read(timerNowMsProvider)());
    final String detail = s.paused ? 'Paused' : (s.step?.label ?? 'Running');
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: SinewCard(
        hero: true,
        color: context.cs.primaryContainer,
        onTap: () => openTimerRun(context),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.timer_rounded,
              size: TimerUi.bannerIcon,
              color: context.cs.onPrimaryContainer,
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Running',
                    style: context.text.labelLarge!.copyWith(
                      color: context.cs.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '${a.title}, $detail',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium!.copyWith(
                      color: context.cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.cs.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeGrid extends StatelessWidget {
  const _ModeGrid();

  @override
  Widget build(BuildContext context) {
    // Big text turns three columns into two or one so a label never clips.
    final double scale = MediaQuery.textScalerOf(context).scale(1);
    // A 360dp phone fits three columns only if "Countdown" is shorter than
    // the tile at 1x text, which it is not: below TimerHomeSpec.narrowWidth
    // there are two columns.
    final bool narrow =
        MediaQuery.sizeOf(context).width < TimerHomeSpec.narrowWidth;
    final int columns = scale <= 1.15
        ? (narrow ? 2 : TimerUi.tileColumns)
        : (scale <= 1.6 ? 2 : 1);
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < kTimerModes.length; i += columns) {
      final List<Widget> cells = <Widget>[];
      for (int c = 0; c < columns; c++) {
        final int idx = i + c;
        if (c > 0) cells.add(const SizedBox(width: TimerUi.tileGap));
        cells.add(
          Expanded(
            child: idx < kTimerModes.length
                ? _ModeTile(info: kTimerModes[idx])
                : const SizedBox.shrink(),
          ),
        );
      }
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : TimerUi.tileGap),
          child: IntrinsicHeight(child: Row(children: cells)),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.info});

  final TimerModeInfo info;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Semantics(
      button: true,
      label: '${info.label}, ${info.caption}',
      excludeSemantics: true,
      onTap: () => context.push(Routes.timerSetup(info.mode.name)),
      child: Material(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardR,
          side: BorderSide(color: cs.outlineVariant, width: Strokes.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.timerSetup(info.mode.name)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: TimerUi.tileHeight),
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(info.icon, size: IconSpec.size, color: cs.primary),
                  const SizedBox(height: Space.sm),
                  Text(
                    info.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall,
                  ),
                  Text(
                    info.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
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

class _PresetRow extends ConsumerWidget {
  const _PresetRow({required this.preset});

  final TimerPreset preset;

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    if (ref.read(timerRunningProvider)) {
      final bool ok = await showSinewConfirmDialog(
        context: context,
        title: 'Replace the running timer?',
        message: 'A timer is already running. Starting this one ends it.',
        confirmLabel: 'Replace',
        destructive: true,
      );
      if (!ok || !context.mounted) return;
    }
    await ref
        .read(timerSessionProvider.notifier)
        .start(
          configFromSteps(preset.mode, preset.steps),
          title: preset.name,
          cues: preset.cues,
          presetId: preset.id,
        );
    if (!context.mounted) return;
    openTimerRun(context);
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final String? name = await showNameDialog(
      context,
      title: 'Rename preset',
      initial: preset.name,
    );
    if (name == null || name.isEmpty) return;
    await ref
        .read(timerPresetRepositoryProvider)
        .save(preset.copyWith(name: name));
    ref.invalidate(timerPresetsProvider);
  }

  Future<void> _duplicate(WidgetRef ref) async {
    final repo = ref.read(timerPresetRepositoryProvider);
    final int count = (await repo.all()).length;
    await repo.save(
      preset.copyWith(
        id: newId(),
        name: '${preset.name} copy',
        builtIn: false,
        position: count,
      ),
    );
    ref.invalidate(timerPresetsProvider);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(timerPresetRepositoryProvider);
    await repo.delete(preset.id);
    ref.invalidate(timerPresetsProvider);
    if (!context.mounted) return;
    showSinewUndoSnackBar(
      context,
      'Deleted "${preset.name}".',
      onUndo: () async {
        await repo.save(preset);
        ref.invalidate(timerPresetsProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = context.cs;
    return SinewListRow(
      minHeight: SinewSpace.gloveTarget,
      leading: Icon(
        timerModeInfo(preset.mode).icon,
        color: cs.onSurfaceVariant,
      ),
      title: preset.name,
      subtitle: describePreset(preset),
      subtitleLines: 2,
      onTap: () => context.push(
        Routes.timerSetup(preset.mode.name, presetId: preset.id),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(
            builder: (BuildContext menuContext) => IconButton(
              tooltip: 'More for ${preset.name}',
              constraints: const BoxConstraints(
                minWidth: IconSpec.tapTarget,
                minHeight: IconSpec.tapTarget,
              ),
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () async {
                final String? choice = await showSinewMenu<String>(
                  context: menuContext,
                  entries: const <SinewMenuEntry<String>>[
                    SinewMenuEntry<String>(
                      value: 'rename',
                      label: 'Rename',
                      icon: Icons.edit_outlined,
                    ),
                    SinewMenuEntry<String>(
                      value: 'duplicate',
                      label: 'Duplicate',
                      icon: Icons.copy_rounded,
                    ),
                    SinewMenuEntry<String>(
                      value: 'delete',
                      label: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      destructive: true,
                    ),
                  ],
                );
                if (!context.mounted) return;
                switch (choice) {
                  case 'rename':
                    await _rename(context, ref);
                  case 'duplicate':
                    await _duplicate(ref);
                  case 'delete':
                    await _delete(context, ref);
                }
              },
            ),
          ),
          Semantics(
            button: true,
            label: 'Start ${preset.name}',
            excludeSemantics: true,
            onTap: () => _play(context, ref),
            child: Material(
              color: cs.primary,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _play(context, ref),
                child: SizedBox(
                  width: TimerUi.presetPlay,
                  height: TimerUi.presetPlay,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: cs.onPrimary,
                    size: IconSpec.large,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Total running time of a preset, for the screen reader and tests.
String presetTotal(TimerPreset p) {
  final int? ms = totalDurationMs(p.steps);
  return ms == null ? 'Open' : ClockText.format(ms ~/ 1000);
}
