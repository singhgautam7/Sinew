import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format/number_text.dart';
import '../../core/models/enums.dart';
import '../../core/models/measurement.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/units.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/configs.dart';
import '../../core/widgets/domain/field_row.dart';
import '../../core/widgets/domain/silhouette_view.dart';
import '../../core/widgets/domain/stat_card.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_extended_fab.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_marker_bar.dart';
import '../../core/widgets/sinew_states.dart';
import '../../engines/body_stats/body_stats.dart';
import '../../engines/silhouette/silhouette_engine.dart';
import 'body_format.dart';
import 'body_model.dart';
import 'body_providers.dart';
import 'region_sheet.dart';
import 'stat_info.dart';

/// The Body tab: the silhouette, the stat cards (locked ones say what they
/// need) and the latest measurements with their change.
class BodyScreen extends ConsumerWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BodyOverview> overview = ref.watch(bodyOverviewProvider);
    return Scaffold(
      floatingActionButton: SinewExtendedFab(
        icon: Icons.add_rounded,
        label: 'Add entry',
        onPressed: () => context.push(Routes.newEntry),
      ),
      floatingActionButtonLocation: sinewFabLocation,
      body: overview.when(
        data: (BodyOverview o) => _Content(overview: o),
        loading: () => const Delayed(child: _Loading()),
        error: (Object e, StackTrace _) => Column(
          children: <Widget>[
            const _Header(overview: null),
            Expanded(
              child: SinewErrorState(
                title: 'Could not load your measurements',
                description: 'Nothing was lost. Try again.',
                onRetry: () => ref.invalidate(bodyOverviewProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.overview});

  final BodyOverview? overview;

  @override
  Widget build(BuildContext context) {
    final BodyOverview? o = overview;
    final bool hasData = o?.hasData ?? false;
    return SinewPageHeader(
      title: 'Body',
      actions: <Widget>[
        if ((o?.entries.length ?? 0) >= 2)
          AppIconButton(
            icon: Icons.compare_rounded,
            semanticLabel: 'Compare dates',
            kind: AppIconButtonKind.plain,
            onPressed: () => context.push(Routes.compare),
          ),
        if (hasData)
          AppIconButton(
            icon: Icons.show_chart_rounded,
            semanticLabel: 'Progress charts',
            kind: AppIconButtonKind.plain,
            onPressed: () => context.push(
              Routes.progress(
                o!.latest.containsKey(BodyFieldIds.weight)
                    ? BodyFieldIds.weight
                    : o.latest.keys.first,
              ),
            ),
          ),
      ],
      infoConfig: const SinewInfoConfig(
        title: 'About Body',
        description:
            'Log measurements now and then. Stats appear when their inputs '
            'exist, and say what is missing when they do not. The outline '
            'is a shape trend drawn from your numbers, not a body scan.',
      ),
      overflowConfig: SinewOverflowConfig(
        items: <SinewOverflowItem>[
          SinewOverflowItem(
            icon: Icons.compare_rounded,
            label: 'Compare dates',
            onTap: () => context.push(Routes.compare),
          ),
          SinewOverflowItem(
            icon: Icons.tune_rounded,
            label: 'Measurement fields',
            onTap: () => context.push(Routes.fields),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: Space.bottomSafe),
      children: const <Widget>[
        _Header(overview: null),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Space.screen),
          child: Column(
            children: <Widget>[
              SinewSkeletonCard(
                lines: 4,
                height: BodySpec.overviewSilhouetteHeight,
              ),
              SizedBox(height: Space.cardGap),
              StatCard<double>.loading(label: 'BMI'),
              SizedBox(height: Space.cardGap),
              StatCard<double>.loading(label: 'Maintenance calories'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.overview});

  final BodyOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BodyOverview o = overview;
    return ListView(
      padding: const EdgeInsets.only(bottom: SinewExtendedFab.clearance),
      children: <Widget>[
        _Header(overview: o),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ShapeCard(overview: o),
              const SizedBox(height: Space.section),
              const SinewSectionHeader(title: 'Stats'),
              _Stats(overview: o),
              if (o.hasData) ...<Widget>[
                const SizedBox(height: Space.section),
                const SinewSectionHeader(title: 'Latest measurements'),
                _LatestList(overview: o),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Silhouette ──────────────────────────────────────────────────────────────

class _ShapeCard extends StatelessWidget {
  const _ShapeCard({required this.overview});

  final BodyOverview overview;

  @override
  Widget build(BuildContext context) {
    final BodyOverview o = overview;
    final LengthUnit unit = o.profile.lengthUnit;
    final Widget silhouette = SizedBox(
      height: BodySpec.overviewSilhouetteHeight,
      child: SilhouetteView(
        geometry: o.geometry,
        hasData: o.hasData,
        onLevelTap: o.hasData
            ? (BodyAnchor a) =>
                  showBodyRegionSheet(context, anchor: a, overview: o)
            : null,
        levelValueText: (SilhouetteLevel l) =>
            Units.formatLength(l.valueCm, unit),
      ),
    );
    return SinewCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (o.hasData) ...<Widget>[
            Text('Shape trend', style: context.text.titleMedium),
            const SizedBox(height: Space.sm),
            silhouette,
            const SizedBox(height: Space.sm),
            Text(
              'Tap a level to see its measurements. A shape trend, not a '
              'body scan.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall!.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
            ),
          ] else ...<Widget>[
            silhouette,
            const SizedBox(height: Space.lg),
            Text(
              'Your shape, over time',
              textAlign: TextAlign.center,
              style: context.text.titleLarge,
            ),
            const SizedBox(height: Space.xs),
            Text(
              'Add a few measurements and this outline redraws from them. '
              'It is a shape trend, not a body scan.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium!.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Space.lg),
            Align(
              child: AppButton(
                label: 'Add first entry',
                icon: Icons.add_rounded,
                type: AppButtonType.primary,
                onPressed: () => context.push(Routes.newEntry),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stats ───────────────────────────────────────────────────────────────────

String _kcal(double v) => NumberText.thousands(v);

String _activityLabel(ActivityLevel l) => switch (l) {
  ActivityLevel.sedentary => 'Sedentary',
  ActivityLevel.light => 'Light',
  ActivityLevel.moderate => 'Moderate',
  ActivityLevel.veryActive => 'Very active',
  ActivityLevel.extraActive => 'Extra active',
};

String _bmiCategoryLabel(BmiCategory c) => switch (c) {
  BmiCategory.underweight => 'Underweight',
  BmiCategory.normal => 'Healthy weight',
  BmiCategory.overweight => 'Overweight',
  BmiCategory.obese => 'Obese',
};

/// Measurement inputs are fixed by adding an entry; the rest live in the
/// profile.
const Set<StatInput> _measurementInputs = <StatInput>{
  StatInput.weight,
  StatInput.waist,
  StatInput.neck,
  StatInput.hips,
  StatInput.bodyFat,
};

class _Stats extends ConsumerWidget {
  const _Stats({required this.overview});

  final BodyOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BodyOverview o = overview;
    final BodyStatsInput i = o.input;
    final WeightUnit wu = o.profile.weightUnit;
    final String wl = Units.weightLabel(wu);
    final String cutoffName = o.profile.bmiCutoffs == BmiCutoffs.asian
        ? 'Asian'
        : 'WHO';

    VoidCallback? lockedAction(List<StatInput> missing) => () {
      if (missing.any(_measurementInputs.contains)) {
        context.push(Routes.newEntry);
      } else {
        context.push(Routes.profile);
      }
    };
    String lockedLabel(List<StatInput> missing) =>
        missing.any(_measurementInputs.contains)
        ? 'Add measurements'
        : 'Open profile';

    Widget card<T>({
      required String label,
      required StatResult<T> result,
      required String Function(T) format,
      required BodyStatKind kind,
      String? unit,
      String? category,
      String? caption,
      Widget? footer,
    }) {
      final List<StatInput> missing = switch (result) {
        MissingInputs<T>() => result.missing,
        InvalidInputs<T>() => result.invalid,
        StatValue<T>() => const <StatInput>[],
      };
      return Padding(
        padding: const EdgeInsets.only(bottom: Space.cardGap),
        child: StatCard<T>(
          label: label,
          result: result,
          format: format,
          unit: unit,
          category: category,
          caption: caption,
          footer: footer,
          onInfo: () => showSinewInfoSheet(context, statInfoConfig(kind, o)),
          onLockedAction: lockedAction(missing),
          lockedActionLabel: lockedLabel(missing),
        ),
      );
    }

    final StatResult<double> bmi = BodyStats.bmi(i);
    final StatResult<BodyFat> bodyFat = BodyStats.bodyFat(i);
    final BodyFat? bf = bodyFat.valueOrNull;
    final StatResult<double> lean = BodyStats.leanBodyMass(i);

    String? bfCaption;
    if (bf != null) {
      if (bf.primaryIsLogged) {
        bfCaption = bf.navyEstimate == null
            ? 'Logged by you'
            : 'Logged by you. US Navy estimate '
                  '${bf.navyEstimate!.toStringAsFixed(1)}%';
      } else {
        bfCaption = 'Estimate, US Navy method';
      }
    }

    final StatResult<double> tdee = BodyStats.tdee(i);
    final StatResult<double> wth = BodyStats.waistToHeight(i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        card<double>(
          label: 'BMI',
          kind: BodyStatKind.bmi,
          result: bmi,
          format: (double v) => v.toStringAsFixed(BodySpec.valueDecimals),
          category: bmi.valueOrNull == null
              ? null
              : '${_bmiCategoryLabel(BodyStats.bmiCategory(bmi.valueOrNull!, i.cutoffs))}'
                    ' · $cutoffName',
        ),
        card<HealthyWeightRange>(
          label: 'Healthy weight range',
          kind: BodyStatKind.healthyWeight,
          result: BodyStats.healthyWeightRange(i),
          format: (HealthyWeightRange r) =>
              '${Units.trim(Units.fromKg(r.minKg, wu), maxDecimals: 1)} to '
              '${Units.trim(Units.fromKg(r.maxKg, wu), maxDecimals: 1)}',
          unit: wl,
          caption: 'From the $cutoffName healthy BMI band',
        ),
        card<double>(
          label: 'Resting energy (BMR)',
          kind: BodyStatKind.bmr,
          result: BodyStats.bmr(i),
          format: _kcal,
          unit: 'kcal/day',
          caption: i.sex == null && i.weightKg != null
              ? 'Set your sex in Profile for a sharper figure'
              : null,
        ),
        card<double>(
          label: 'Maintenance calories',
          kind: BodyStatKind.tdee,
          result: tdee,
          format: _kcal,
          unit: 'kcal/day',
          caption: 'Estimate. Adjust from real results.',
          footer: tdee is StatValue<double>
              ? Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Wrap(
                    spacing: Space.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        'Activity',
                        style: context.text.bodyMedium!.copyWith(
                          color: context.cs.onSurfaceVariant,
                        ),
                      ),
                      SinewDropdownChip<ActivityLevel>(
                        value: o.profile.activityLevel,
                        options: <SinewDropdownOption<ActivityLevel>>[
                          for (final ActivityLevel l in ActivityLevel.values)
                            SinewDropdownOption<ActivityLevel>(
                              l,
                              _activityLabel(l),
                            ),
                        ],
                        onChanged: (ActivityLevel l) => ref
                            .read(profileRepositoryProvider)
                            .save(o.profile.copyWith(activityLevel: l)),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        card<double>(
          label: 'Waist to height',
          kind: BodyStatKind.waistToHeight,
          result: wth,
          format: (double v) => v.toStringAsFixed(BodySpec.ratioDecimals),
          caption: 'Marker at ${Units.trim(kWaistToHeightMarker)}',
          footer: wth is StatValue<double>
              ? SinewMarkerBar(
                  value: wth.value,
                  min: BodySpec.ratioMin,
                  max: BodySpec.ratioMax,
                  marker: kWaistToHeightMarker,
                  height: BodySpec.ratioBarHeight,
                  markerWidth: BodySpec.ratioMarkerWidth,
                  markerHeight: BodySpec.ratioMarkerHeight,
                  semanticLabel:
                      'Waist to height ${wth.value.toStringAsFixed(BodySpec.ratioDecimals)}, '
                      'marker at ${Units.trim(kWaistToHeightMarker)}',
                )
              : null,
        ),
        card<double>(
          label: 'Waist to hip',
          kind: BodyStatKind.waistToHip,
          result: BodyStats.waistToHip(i),
          format: (double v) => v.toStringAsFixed(BodySpec.ratioDecimals),
        ),
        card<BodyFat>(
          label: 'Body fat',
          kind: BodyStatKind.bodyFat,
          result: bodyFat,
          format: (BodyFat b) =>
              b.primary.toStringAsFixed(BodySpec.valueDecimals),
          unit: '%',
          caption: bfCaption,
        ),
        card<double>(
          label: 'Lean body mass',
          kind: BodyStatKind.leanMass,
          result: lean,
          format: (double kg) =>
              Units.trim(Units.fromKg(kg, wu), maxDecimals: 1),
          unit: wl,
        ),
      ],
    );
  }
}

// ── Latest measurements ─────────────────────────────────────────────────────

class _LatestList extends StatelessWidget {
  const _LatestList({required this.overview});

  final BodyOverview overview;

  @override
  Widget build(BuildContext context) {
    final BodyOverview o = overview;
    final List<MeasurementField> withData = <MeasurementField>[
      for (final MeasurementField f in o.liveFields)
        if (o.latest.containsKey(f.id)) f,
    ];
    final List<Widget> rows = <Widget>[];
    for (final FormRowSpec r in groupFormRows(withData)) {
      if (r.isPair) {
        final MeasurementField l = r.left!;
        final MeasurementField rt = r.right!;
        final FieldUnit unit = fieldUnitFor(l, o.profile);
        final LatestValue lv = o.latest[l.id]!;
        final LatestValue rv = o.latest[rt.id]!;
        rows.add(
          _LatestRow(
            title: '${pairName(l, rt)} L / R',
            value:
                '${unit.format(lv.value)} / ${unit.format(rv.value)} '
                '${unit.label}',
            delta: null,
            spoken:
                '${pairName(l, rt)}, left ${formatFieldValue(unit, lv.value)}, '
                'right ${formatFieldValue(unit, rv.value)}',
            onTap: () => context.push(Routes.progress(l.id)),
          ),
        );
      } else {
        final MeasurementField f = r.field!;
        final FieldUnit unit = fieldUnitFor(f, o.profile);
        final LatestValue v = o.latest[f.id]!;
        final double? d = v.delta;
        rows.add(
          _LatestRow(
            title: f.name,
            value: formatFieldValue(unit, v.value),
            delta: d == null ? null : signedDisplayDelta(unit, d),
            spoken:
                '${f.name}, ${formatFieldValue(unit, v.value)}'
                '${d == null ? '' : ', change ${signedDisplayDelta(unit, d)}'}',
            onTap: () => context.push(Routes.progress(f.id)),
          ),
        );
      }
    }
    return SinewGroup(children: rows);
  }
}

class _LatestRow extends StatelessWidget {
  const _LatestRow({
    required this.title,
    required this.value,
    required this.delta,
    required this.spoken,
    required this.onTap,
  });

  final String title;
  final String value;
  final String? delta;
  final String spoken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    return Semantics(
      label: '$spoken. Opens progress',
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: Space.listItem1),
          padding: const EdgeInsets.symmetric(
            horizontal: Space.listRowPadH,
            vertical: Space.md,
          ),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(title, style: tt.bodyLarge)),
              const SizedBox(width: Space.md),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      value,
                      textAlign: TextAlign.end,
                      style: tt.titleMedium,
                    ),
                    if (delta != null)
                      Text(
                        delta!,
                        style: tt.bodySmall!.copyWith(
                          color: context.cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
