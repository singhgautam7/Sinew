import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/measurement.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/domain/field_row.dart';
import '../../core/widgets/domain/silhouette_view.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_error_state.dart';
import '../../core/widgets/sinew_chips.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_scrubber.dart';
import '../../core/widgets/sinew_states.dart';
import '../../engines/silhouette/silhouette_engine.dart';
import 'body_format.dart';
import 'body_model.dart';
import 'body_providers.dart';

/// Two dates side by side: the older shape as a faint outline, the newer one
/// drawn solid and morphing as the scrubber moves, with a table of changes.
class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  int _from = 0;
  double? _pos;
  bool _scrubbing = false;

  // Per-entry geometry and values, rebuilt only when the data changes.
  BodyOverview? _cacheFor;
  List<MeasurementEntry> _asc = const <MeasurementEntry>[];
  List<SilhouetteGeometry> _geos = const <SilhouetteGeometry>[];
  List<Map<String, DatedValue>> _vals = const <Map<String, DatedValue>>[];

  void _prepare(BodyOverview o) {
    if (identical(_cacheFor, o)) return;
    _cacheFor = o;
    _asc = o.entries.reversed.toList();
    final double? h = o.input.heightCm;
    _geos = <SilhouetteGeometry>[
      for (final MeasurementEntry e in _asc)
        geometryAsOf(
          o.fields,
          o.entries,
          o.profile,
          upTo: e.date,
          heightOverrideCm: h,
        ),
    ];
    _vals = <Map<String, DatedValue>>[
      for (final MeasurementEntry e in _asc)
        valuesAsOf(o.entries, upTo: e.date),
    ];
    _from = _from.clamp(0, math.max(0, _asc.length - 1));
    _pos = (_pos ?? (_asc.length - 1).toDouble()).clamp(
      0,
      math.max(0, _asc.length - 1).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<BodyOverview> async = ref.watch(bodyOverviewProvider);
    final BodyOverview? o = async.value;
    if (o == null) {
      return Scaffold(
        appBar: const SinewAppBar(title: 'Compare', showBack: true),
        body: async.hasError
            ? SinewErrorState(
                title: 'Could not load your entries',
                description: 'Nothing was lost. Try again.',
                onRetry: () => ref.invalidate(bodyOverviewProvider),
              )
            : const Delayed(child: SinewLoader()),
      );
    }
    final List<MeasurementEntry> withValues = o.entries
        .where((MeasurementEntry e) => e.values.isNotEmpty)
        .toList();
    if (withValues.length < 2) {
      return Scaffold(
        appBar: const SinewAppBar(title: 'Compare', showBack: true),
        body: SinewEmptyState(
          icon: Icons.compare_rounded,
          title: 'Two entries to compare',
          description:
              'Add at least two dated entries and you can slide between '
              'them to see how your shape changed.',
          actionLabel: 'Add entry',
          onAction: () => context.push(Routes.newEntry),
        ),
      );
    }
    _prepare(o);

    final int n = _asc.length;
    final double pos = _pos!;
    final int lo = pos.floor().clamp(0, n - 1);
    final int hi = pos.ceil().clamp(0, n - 1);
    final int toIndex = pos.round().clamp(0, n - 1);
    final SilhouetteGeometry fromGeo = _geos[_from];
    final SilhouetteGeometry toGeo = lo == hi
        ? _geos[lo]
        : SilhouetteGeometry.lerp(_geos[lo], _geos[hi], pos - lo);

    final DateTime now = o.now;
    final String fromLabel = bodyDateLabel(_asc[_from].date, now);
    final String toLabel = bodyDateLabel(_asc[toIndex].date, now);

    final Map<String, DatedValue> a = _vals[_from];
    final Map<String, DatedValue> b = _vals[toIndex];
    final List<MeasurementField> tableFields = <MeasurementField>[
      for (final MeasurementField f in o.liveFields)
        if (a.containsKey(f.id) || b.containsKey(f.id)) f,
    ];

    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    return Scaffold(
      appBar: const SinewAppBar(title: 'Compare', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.sm,
            Space.screen,
            Space.xxxl,
          ),
          children: <Widget>[
            Wrap(
              spacing: Space.md,
              runSpacing: Space.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('From', style: tt.labelLarge),
                    const SizedBox(width: Space.sm),
                    Flexible(
                      child: SinewDropdownChip<int>(
                        shrink: true,
                        value: _from,
                        options: <SinewDropdownOption<int>>[
                          for (int i = 0; i < n; i++)
                            SinewDropdownOption<int>(
                              i,
                              bodyDateLabel(_asc[i].date, now),
                            ),
                        ],
                        onChanged: (int i) => setState(() => _from = i),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('To', style: tt.labelLarge),
                    const SizedBox(width: Space.sm),
                    Text(
                      toLabel,
                      style: tt.titleMedium!.copyWith(color: cs.primary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Space.md),
            SizedBox(
              height: BodySpec.compareSilhouetteHeight,
              child: SilhouetteView(
                geometry: toGeo,
                compareGeometry: fromGeo,
                animate: !_scrubbing,
                semanticLabel:
                    'Body silhouette on $toLabel, compared with $fromLabel',
              ),
            ),
            SinewScrubber(
              value: pos,
              max: (n - 1).toDouble(),
              semanticLabel: 'Compare date',
              semanticValue: toLabel,
              startLabel: bodyDateLabel(_asc.first.date, now),
              endLabel: bodyDateLabel(_asc.last.date, now),
              onChanged: (double v) => setState(() {
                _scrubbing = true;
                _pos = v;
              }),
              onChangeEnd: (double v) => setState(() {
                _scrubbing = false;
                _pos = v.roundToDouble();
              }),
            ),
            Text(
              'Drag to morph between the two dates. A shape trend, not a '
              'scan.',
              textAlign: TextAlign.center,
              style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: Space.section),
            _Table(
              fields: tableFields,
              fromValues: a,
              toValues: b,
              fromLabel: fromLabel,
              toLabel: toLabel,
              overview: o,
            ),
          ],
        ),
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({
    required this.fields,
    required this.fromValues,
    required this.toValues,
    required this.fromLabel,
    required this.toLabel,
    required this.overview,
  });

  final List<MeasurementField> fields;
  final Map<String, DatedValue> fromValues;
  final Map<String, DatedValue> toValues;
  final String fromLabel;
  final String toLabel;
  final BodyOverview overview;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    final TextStyle head = tt.labelMedium!.copyWith(color: cs.onSurfaceVariant);
    Widget cell(String text, double width, TextStyle style) => SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.end,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );

    final bool wide = MediaQuery.textScalerOf(context).scale(1) <= 1.3;
    Widget rowFor(MeasurementField f) {
      final FieldUnit unit = fieldUnitFor(f, overview.profile);
      final DatedValue? a = fromValues[f.id];
      final DatedValue? b = toValues[f.id];
      final String av = a == null ? '–' : unit.format(a.value);
      final String bv = b == null ? '–' : unit.format(b.value);
      final String change = a == null || b == null
          ? '–'
          : signedDisplayDelta(unit, b.value - a.value);
      final String spoken =
          '${f.name}: $fromLabel $av, $toLabel $bv, change $change ${unit.label}';
      return Semantics(
        container: true,
        excludeSemantics: true,
        label: spoken,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.listRowPadH,
            vertical: Space.md,
          ),
          child: wide
              ? Row(
                  children: <Widget>[
                    Expanded(child: Text(f.name, style: tt.bodyLarge)),
                    cell(av, BodySpec.tableValueWidth, tt.bodyMedium!),
                    cell(bv, BodySpec.tableValueWidth, tt.bodyMedium!),
                    cell(
                      change,
                      BodySpec.tableDeltaWidth,
                      tt.titleSmall!.copyWith(color: cs.primary),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(f.name, style: tt.bodyLarge),
                    Text(
                      '$av  →  $bv ${unit.label}   ($change)',
                      style: tt.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SinewSectionHeader(title: 'Changes'),
        if (wide)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.listRowPadH,
              vertical: Space.xs,
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: Text('FIELD', style: head)),
                cell(fromLabel.toUpperCase(), BodySpec.tableValueWidth, head),
                cell(toLabel.toUpperCase(), BodySpec.tableValueWidth, head),
                cell('CHANGE', BodySpec.tableDeltaWidth, head),
              ],
            ),
          ),
        SinewGroup(children: <Widget>[for (final f in fields) rowFor(f)]),
      ],
    );
  }
}
