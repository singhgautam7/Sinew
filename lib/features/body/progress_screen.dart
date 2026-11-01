import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/measurement.dart';
import '../../core/models/profile.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/units.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/domain/chart_card.dart';
import '../../core/widgets/domain/field_row.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_states.dart';
import '../../engines/body_stats/body_stats.dart';
import 'body_format.dart';
import 'body_model.dart';
import 'body_providers.dart';

/// One value of a field on a day, with the entry it came from.
class FieldPointRow {
  const FieldPointRow({
    required this.entryId,
    required this.date,
    required this.value,
    this.change,
  });

  final String entryId;
  final DateTime date;
  final double value;

  /// Against the next older value of the same field.
  final double? change;
}

/// A field's values, newest first, each with its change against the older one.
List<FieldPointRow> fieldPointRows(
  String fieldId,
  List<MeasurementEntry> entriesNewestFirst,
) {
  final List<MeasurementEntry> have = <MeasurementEntry>[
    for (final MeasurementEntry e in entriesNewestFirst)
      if (e.values.containsKey(fieldId)) e,
  ];
  return <FieldPointRow>[
    for (int i = 0; i < have.length; i++)
      FieldPointRow(
        entryId: have[i].id,
        date: have[i].date,
        value: have[i].values[fieldId]!,
        change: i + 1 < have.length
            ? have[i].values[fieldId]! - have[i + 1].values[fieldId]!
            : null,
      ),
  ];
}

/// The first date a range includes, or null for all time.
DateTime? rangeStart(ChartRange range, DateTime now) {
  final int? days = switch (range) {
    ChartRange.month1 => BodySpec.daysMonth,
    ChartRange.month3 => BodySpec.daysQuarter,
    ChartRange.month6 => BodySpec.daysHalfYear,
    ChartRange.year1 => BodySpec.daysYear,
    ChartRange.all => null,
  };
  return days == null ? null : dayOf(now).subtract(Duration(days: days));
}

/// A field's metric history over time, a range chip, entries and a way to the
/// entry that holds each value.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  late String _fieldId = widget.fieldId;
  ChartRange _range = ChartRange.all;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<BodyOverview> async = ref.watch(bodyOverviewProvider);
    final BodyOverview? o = async.value;
    if (o == null) {
      return Scaffold(
        appBar: const SinewAppBar(title: 'Progress', showBack: true),
        body: async.hasError
            ? SinewErrorState(
                title: 'Could not load progress',
                description: 'Nothing was lost. Try again.',
                onRetry: () => ref.invalidate(bodyOverviewProvider),
              )
            : const Delayed(child: SinewLoader()),
      );
    }
    final MeasurementField? field = o.fieldById(_fieldId);
    if (field == null) {
      return const Scaffold(
        appBar: SinewAppBar(title: 'Progress', showBack: true),
        body: SinewEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Field not found',
          description: 'It may have been removed.',
        ),
      );
    }
    final Profile profile = o.profile;
    final FieldUnit unit = fieldUnitFor(field, profile);
    final List<FieldPointRow> rows = fieldPointRows(field.id, o.entries);
    final DateTime? start = rangeStart(_range, o.now);
    final List<FieldPointRow> inRange = <FieldPointRow>[
      for (final FieldPointRow r in rows)
        if (start == null || !r.date.isBefore(start)) r,
    ];
    final List<ChartPoint> points = <ChartPoint>[
      for (final FieldPointRow r in inRange.reversed)
        ChartPoint(r.date, unit.toDisplay(r.value)),
    ];

    String? latest;
    String? deltaLabel;
    if (rows.isNotEmpty) {
      latest = formatFieldValue(unit, rows.first.value);
      if (inRange.length >= 2) {
        final FieldPointRow first = inRange.last;
        final double d = inRange.first.value - first.value;
        deltaLabel =
            '${signedDisplayDelta(unit, d)} ${unit.label} since '
            '${bodyDateLabel(first.date, o.now)}';
      }
    }

    ChartReference? reference;
    if (field.id == BodyFieldIds.waist) {
      final double? h = o.input.heightCm;
      if (h != null && h > 0) {
        reference = ChartReference(
          value: unit.toDisplay(h * kWaistToHeightMarker),
          label: '0.5 of height',
        );
      }
    }

    final List<MeasurementField> chipFields = <MeasurementField>[
      for (final MeasurementField f in o.liveFields)
        if (f.id == field.id || o.latest.containsKey(f.id)) f,
    ];

    return Scaffold(
      appBar: SinewAppBar(
        title: 'Progress',
        showBack: true,
        actions: <Widget>[
          AppButton(
            label: 'Compare',
            icon: Icons.compare_rounded,
            type: AppButtonType.outline,
            height: Sizes.buttonSmall,
            onPressed: () => context.push(Routes.compare),
          ),
        ],
      ),
      body: SafeArea(
        // A sliver builder: a long history builds only the rows on screen.
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.sm,
                Space.screen,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  if (chipFields.length > 1)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          for (final MeasurementField f in chipFields)
                            Padding(
                              padding: const EdgeInsets.only(right: Space.sm),
                              child: SinewChip(
                                label: f.name,
                                selected: f.id == field.id,
                                onTap: () => setState(() => _fieldId = f.id),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: Space.lg),
                  ChartCard(
                    title: field.name,
                    subtitle: rows.isEmpty
                        ? null
                        : '${rows.length} '
                              '${rows.length == 1 ? 'entry' : 'entries'}',
                    primary: ChartSeries(label: field.name, points: points),
                    latestLabel: latest,
                    deltaLabel: deltaLabel,
                    range: _range,
                    onRangeChanged: (ChartRange r) =>
                        setState(() => _range = r),
                    reference: reference,
                    valueFormat: (double v) =>
                        Units.trim(v, maxDecimals: unit.decimals),
                    emptyMessage: rows.isEmpty
                        ? 'No ${field.name.toLowerCase()} entries yet'
                        : 'No entries in this range',
                  ),
                  const SizedBox(height: Space.section),
                  if (rows.isEmpty)
                    Align(
                      child: AppButton(
                        label: 'Add ${field.name.toLowerCase()}',
                        icon: Icons.add_rounded,
                        type: AppButtonType.primary,
                        onPressed: () => context.push(
                          '${Routes.newEntry}?field=${field.id}',
                        ),
                      ),
                    )
                  else
                    const SinewSectionHeader(title: 'Entries'),
                ]),
              ),
            ),
            if (rows.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  0,
                  Space.screen,
                  Space.xxxl,
                ),
                sliver: SliverList.builder(
                  itemCount: rows.length,
                  itemBuilder: (BuildContext context, int i) => _RowShell(
                    isTop: i == 0,
                    isBottom: i == rows.length - 1,
                    child: _EntryRow(row: rows[i], unit: unit, now: o.now),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One row of the entries list as a slice of a grouped card: the card's fill,
/// border and corners, with a hairline between rows.
class _RowShell extends StatelessWidget {
  const _RowShell({
    required this.isTop,
    required this.isBottom,
    required this.child,
  });

  final bool isTop;
  final bool isBottom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    const Radius r = Radius.circular(Radii.card);
    return Material(
      color: cs.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isTop ? r : Radius.zero,
          bottom: isBottom ? r : Radius.zero,
        ),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: child,
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.row, required this.unit, required this.now});

  final FieldPointRow row;
  final FieldUnit unit;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    final String date = bodyDateLabel(row.date, now);
    final String value = formatFieldValue(unit, row.value);
    final String? change = row.change == null
        ? null
        : signedDisplayDelta(unit, row.change!);
    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          '$date, $value${change == null ? '' : ', change $change'}. '
          'Opens the entry',
      onTap: () => context.push(Routes.entry(row.entryId)),
      child: SinewListRow(
        title: date,
        onTap: () => context.push(Routes.entry(row.entryId)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(value, style: tt.titleMedium),
            if (change != null)
              Text(
                change,
                style: tt.bodySmall!.copyWith(
                  color: context.cs.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
