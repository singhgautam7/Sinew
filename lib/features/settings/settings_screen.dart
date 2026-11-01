import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/routing/router.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/units.dart';
import '../../core/widgets/domain/numeric_stepper.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_settings.dart';
import '../more/profile_form.dart';
import '../today/date_text.dart';

/// Appearance, workout and timer defaults, data and about. Ported from
/// Kuber's Settings: grouped cards of rows, one switch per behaviour.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings s = ref.watch(settingsProvider);
    final SettingsController ctl = ref.read(settingsProvider.notifier);
    final WeightUnit unit =
        ref.watch(profileProvider).value?.weightUnit ?? WeightUnit.kg;
    final double step = unit == WeightUnit.kg ? s.incrementKg : s.incrementLb;
    return Scaffold(
      appBar: const SinewAppBar(title: 'Settings', showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.xs,
          Space.screen,
          Space.bottomSafe,
        ),
        children: <Widget>[
          SinewSettingsSection(
            label: 'Appearance',
            children: <Widget>[
              SinewNavigationRow(
                icon: Icons.palette_outlined,
                label: 'Theme',
                subtitle:
                    '${familyById(s.familyId).name} · ${s.themeMode.label}',
                onTap: () => context.push(Routes.theme),
              ),
              _TextSizeRow(
                value: s.textScale,
                onChanged: (double v) => ctl.setTextScale(v),
              ),
            ],
          ),
          SinewSettingsSection(
            label: 'Workout',
            children: <Widget>[
              SinewValueRow(
                icon: Icons.hourglass_top_rounded,
                label: 'Default rest',
                subtitle: 'Between sets',
                value: DateText.clock(s.restSeconds),
                onTap: () => _editRest(context),
              ),
              SinewValueRow(
                icon: Icons.add_circle_outline_rounded,
                label: 'Weight step',
                subtitle: 'How much a tap on + adds',
                value: Units.formatWeight(
                  Units.toKg(step, unit),
                  unit,
                  maxDecimals: 2,
                ),
                onTap: () => _editStep(context, unit),
              ),
              SinewSwitchRow(
                icon: Icons.screen_lock_portrait_rounded,
                label: 'Keep screen on',
                subtitle: 'During workouts and timers',
                value: s.keepScreenOn,
                onChanged: (bool v) => ctl.setKeepScreenOn(value: v),
              ),
              SinewSwitchRow(
                icon: Icons.vibration_rounded,
                label: 'Haptics',
                subtitle: 'Set done, plate settle',
                value: s.haptics,
                onChanged: (bool v) => ctl.setHaptics(value: v),
              ),
            ],
          ),
          SinewSettingsSection(
            label: 'Timer',
            children: <Widget>[
              SinewSwitchRow(
                icon: Icons.volume_up_rounded,
                label: 'Sounds',
                subtitle: 'Beeps for countdown, work and rest',
                value: s.timerSound,
                onChanged: (bool v) => ctl.setTimerSound(value: v),
              ),
              SinewSwitchRow(
                icon: Icons.vibration_rounded,
                label: 'Timer haptics',
                subtitle: 'A buzz at each phase change',
                value: s.timerHaptic,
                onChanged: (bool v) => ctl.setTimerHaptic(value: v),
              ),
              SinewSwitchRow(
                icon: Icons.record_voice_over_rounded,
                label: 'Spoken countdown',
                subtitle: '3, 2, 1 before each phase',
                value: s.timerVoice,
                onChanged: (bool v) => ctl.setTimerVoice(value: v),
              ),
            ],
          ),
          SinewSettingsSection(
            label: 'Data',
            children: <Widget>[
              SinewNavigationRow(
                icon: Icons.backup_rounded,
                label: 'Backup and restore',
                subtitle: 'Export JSON or CSV, import a backup',
                onTap: () => context.push(Routes.backup),
              ),
              SinewNavigationRow(
                icon: Icons.straighten_rounded,
                label: 'Units',
                subtitle: 'Weight, length, distance',
                onTap: () => context.push(Routes.units),
              ),
            ],
          ),
          SinewSettingsSection(
            label: 'About',
            bottomGap: 0,
            children: <Widget>[
              SinewNavigationRow(
                icon: Icons.info_outline_rounded,
                label: 'About Sinew',
                subtitle: 'Offline promise, sources, version',
                onTap: () => context.push(Routes.about),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editRest(BuildContext context) => showSinewBottomSheet<void>(
    context: context,
    builder: (BuildContext _) => const _RestSheet(),
  );

  Future<void> _editStep(BuildContext context, WeightUnit unit) =>
      showSinewBottomSheet<void>(
        context: context,
        builder: (BuildContext _) => _StepSheet(unit: unit),
      );
}

/// A slider for the in-app text size, with a live sample line.
class _TextSizeRow extends StatelessWidget {
  const _TextSizeRow({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final int percent = (value * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.text_fields_rounded, color: cs.onSurfaceVariant),
              const SizedBox(width: Space.md),
              Expanded(child: Text('Text size', style: tt.titleMedium)),
              Text(
                '$percent%',
                style: tt.titleMedium!.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          Semantics(
            label: 'Text size',
            value: '$percent percent',
            child: Slider(
              value: value.clamp(
                AppSettings.minTextScale,
                AppSettings.maxTextScale,
              ),
              min: AppSettings.minTextScale,
              max: AppSettings.maxTextScale,
              divisions: SettingsSpec.textScaleDivisions,
              onChanged: onChanged,
            ),
          ),
          Text(
            'On top of your phone text size.',
            style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RestSheet extends ConsumerWidget {
  const _RestSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int rest = ref.watch(
      settingsProvider.select((AppSettings s) => s.restSeconds),
    );
    return SinewBottomSheet(
      title: 'Default rest',
      description: 'Between sets. Each exercise can still set its own.',
      child: Center(
        child: NumericStepper(
          value: rest.toDouble(),
          step: MoreSpec.restStep.toDouble(),
          min: AppSettings.minRestSeconds.toDouble(),
          max: AppSettings.maxRestSeconds.toDouble(),
          maxDecimals: 0,
          semanticLabel: 'Default rest',
          format: (double v) => DateText.clock(v.round()),
          onChanged: (double v) =>
              ref.read(settingsProvider.notifier).setRestSeconds(v.round()),
        ),
      ),
    );
  }
}

class _StepSheet extends ConsumerWidget {
  const _StepSheet({required this.unit});

  final WeightUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings s = ref.watch(settingsProvider);
    final bool kg = unit == WeightUnit.kg;
    final double current = kg ? s.incrementKg : s.incrementLb;
    final List<double> presets = kg
        ? SettingsSpec.kgSteps
        : SettingsSpec.lbSteps;
    return SinewBottomSheet(
      title: 'Weight step',
      description: 'How much the + and - buttons change a weight.',
      child: Wrap(
        spacing: Space.sm,
        runSpacing: Space.sm,
        children: <Widget>[
          for (final double v in presets)
            SinewChip(
              label: '${Units.trim(v)} ${Units.weightLabel(unit)}',
              selected: v == current,
              onTap: () {
                final SettingsController c = ref.read(
                  settingsProvider.notifier,
                );
                if (kg) {
                  c.setIncrementKg(v);
                } else {
                  c.setIncrementLb(v);
                }
              },
            ),
        ],
      ),
    );
  }
}
