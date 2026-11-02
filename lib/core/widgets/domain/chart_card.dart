import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../sinew_list.dart';
import '../sinew_segmented_control.dart';
import '../sinew_states.dart';

/// One dated value. Values arrive in display units (the caller converts).
@immutable
class ChartPoint {
  const ChartPoint(this.date, this.value);

  final DateTime date;
  final double value;
}

/// A named line.
@immutable
class ChartSeries {
  const ChartSeries({required this.label, required this.points, this.color});

  final String label;
  final List<ChartPoint> points;

  /// Null takes the primary colour for the first line and
  /// `accents.series[0]` for the second.
  final Color? color;
}

/// The range selector's choices.
enum ChartRange {
  month1('1M', 'one month'),
  month3('3M', 'three months'),
  month6('6M', 'six months'),
  year1('1Y', 'one year'),
  all('All', 'all time');

  const ChartRange(this.label, this.spoken);

  final String label;
  final String spoken;
}

/// A horizontal guide such as a goal or the 0.5 waist-to-height line.
@immutable
class ChartReference {
  const ChartReference({required this.value, this.label});

  final double value;
  final String? label;
}

/// A line chart in a card: title, latest value and change on top, the chart,
/// and a 1M / 3M / 6M / 1Y / All selector.
///
/// The card draws what it is given. The caller picks the points for the
/// selected range, converts them to display units and formats the headline
/// ([latestLabel], [deltaLabel]); the card never filters or computes. Without
/// [latestLabel] the last point is formatted with [valueFormat].
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.primary,
    this.subtitle,
    this.secondary,
    this.latestLabel,
    this.deltaLabel,
    this.range,
    this.ranges = ChartRange.values,
    this.onRangeChanged,
    this.reference,
    this.valueFormat,
    this.emptyMessage = 'No entries yet',
    this.height = ChartSpec.height,
  }) : loading = false;

  /// The skeleton shown while the series loads.
  const ChartCard.loading({
    super.key,
    required this.title,
    this.height = ChartSpec.height,
  }) : primary = const ChartSeries(label: '', points: <ChartPoint>[]),
       subtitle = null,
       secondary = null,
       latestLabel = null,
       deltaLabel = null,
       range = null,
       ranges = const <ChartRange>[],
       onRangeChanged = null,
       reference = null,
       valueFormat = null,
       emptyMessage = '',
       loading = true;

  final String title;
  final String? subtitle;
  final ChartSeries primary;
  final ChartSeries? secondary;
  final String? latestLabel;

  /// "-8.0 cm since 12 Jan".
  final String? deltaLabel;

  /// The selected range; the selector is hidden when null.
  final ChartRange? range;
  final List<ChartRange> ranges;
  final ValueChanged<ChartRange>? onRangeChanged;
  final ChartReference? reference;

  /// Formats a y value on the axis and in the tooltip. Defaults to one
  /// trimmed decimal.
  final String Function(double value)? valueFormat;
  final String emptyMessage;
  final double height;
  final bool loading;

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _defaultFormat(double v) {
    final String s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  String _fmt(double v) => (valueFormat ?? _defaultFormat)(v);

  static String _day(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// The text summary a screen reader gets in place of the plot.
  String summary() {
    final List<ChartPoint> pts = primary.points;
    final StringBuffer b = StringBuffer('$title chart');
    if (pts.isEmpty) {
      b.write('. $emptyMessage');
      return b.toString();
    }
    final String latest = latestLabel ?? _fmt(pts.last.value);
    b.write('. Latest $latest');
    if (deltaLabel != null) b.write(', $deltaLabel');
    b
      ..write('. ${pts.length} ${pts.length == 1 ? 'entry' : 'entries'}')
      ..write(' from ${_day(pts.first.date)} to ${_day(pts.last.date)}');
    if (secondary != null && secondary!.points.isNotEmpty) {
      b.write('. Also ${secondary!.label}');
    }
    if (range != null) b.write('. Showing ${range!.spoken}');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    if (loading) {
      return Semantics(
        label: 'Loading $title',
        excludeSemantics: true,
        child: SinewCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title, style: tt.titleSmall),
              const SizedBox(height: ChartSpec.headerGap),
              SinewSkeleton(height: height),
            ],
          ),
        ),
      );
    }
    final List<ChartPoint> pts = primary.points;
    final bool empty = pts.isEmpty;
    final String? latest = empty ? null : latestLabel ?? _fmt(pts.last.value);

    final Widget header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: tt.titleSmall),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
            ],
          ),
        ),
        if (latest != null) ...<Widget>[
          const SizedBox(width: Space.md),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  latest,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleLarge,
                ),
                if (deltaLabel != null)
                  Text(
                    deltaLabel!,
                    textAlign: TextAlign.end,
                    style: tt.labelMedium!.copyWith(color: cs.primary),
                  ),
              ],
            ),
          ),
        ],
      ],
    );

    final Widget plot = SizedBox(
      height: height,
      child: empty
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.show_chart_rounded,
                    size: IconSpec.glyph,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: Space.sm),
                  Flexible(
                    child: Text(
                      emptyMessage,
                      style: tt.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ExcludeSemantics(child: _Plot(card: this)),
    );

    final List<Widget> legend = <Widget>[
      if (secondary != null && secondary!.points.isNotEmpty) ...<Widget>[
        _LegendDot(color: primary.color ?? cs.primary, label: primary.label),
        _LegendDot(
          color: secondary!.color ?? context.accents.series.first,
          label: secondary!.label,
        ),
      ],
    ];

    return Semantics(
      container: true,
      label: summary(),
      explicitChildNodes: true,
      child: SinewCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ExcludeSemantics(child: header),
            const SizedBox(height: ChartSpec.headerGap),
            plot,
            if (legend.isNotEmpty) ...<Widget>[
              const SizedBox(height: ChartSpec.headerGap),
              ExcludeSemantics(
                child: Wrap(
                  spacing: Space.lg,
                  runSpacing: Space.xs,
                  children: legend,
                ),
              ),
            ],
            if (range != null && ranges.isNotEmpty) ...<Widget>[
              const SizedBox(height: Space.md),
              SinewSegmentedControl<ChartRange>(
                values: ranges,
                labels: ranges.map((ChartRange r) => r.label).toList(),
                selected: range!,
                onSelected: (ChartRange r) => onRangeChanged?.call(r),
                enabled: onRangeChanged != null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: Space.sm,
          height: Space.sm,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: Space.xs + Space.xxs),
        Flexible(
          child: Text(
            label,
            style: context.text.labelMedium!.copyWith(
              color: context.cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// The fl_chart plot, styled after Kuber's line chart: 1dp outlineVariant
/// gridlines, no vertical lines, 2.5 round lines, a soft area under the
/// first line.
class _Plot extends StatelessWidget {
  const _Plot({required this.card});

  final ChartCard card;

  static const double _msPerDay = 24 * 60 * 60 * 1000;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final ChartSeries first = card.primary;
    final ChartSeries? second =
        card.secondary != null && card.secondary!.points.isNotEmpty
        ? card.secondary
        : null;
    final List<ChartPoint> all = <ChartPoint>[
      ...first.points,
      ...?second?.points,
    ];

    DateTime minDate = all.first.date;
    DateTime maxDate = all.first.date;
    double minY = all.first.value;
    double maxY = all.first.value;
    for (final ChartPoint p in all) {
      if (p.date.isBefore(minDate)) minDate = p.date;
      if (p.date.isAfter(maxDate)) maxDate = p.date;
      minY = math.min(minY, p.value);
      maxY = math.max(maxY, p.value);
    }
    final ChartReference? ref = card.reference;
    if (ref != null) {
      minY = math.min(minY, ref.value);
      maxY = math.max(maxY, ref.value);
    }
    final double spanY = maxY - minY == 0 ? 2 : maxY - minY;
    minY -= spanY * ChartSpec.padRatio;
    maxY += spanY * ChartSpec.padRatio;
    final double yStep = (maxY - minY) / ChartSpec.gridLines;

    double xOf(DateTime d) => d.difference(minDate).inMilliseconds / _msPerDay;
    final double maxX = math.max(xOf(maxDate), 1);
    DateTime dateAt(double x) =>
        minDate.add(Duration(milliseconds: (x * _msPerDay).round()));
    final bool shortSpan = maxX <= 62;

    String xLabel(double x) {
      final DateTime d = dateAt(x);
      return shortSpan
          ? ChartCard._day(d)
          : '${ChartCard._months[d.month - 1]} ${d.year % 100}';
    }

    final Color c1 = first.color ?? cs.primary;
    final Color c2 = second?.color ?? context.accents.series.first;
    final TextStyle axis = tt.labelSmall!.copyWith(color: cs.onSurfaceVariant);

    LineChartBarData line(
      ChartSeries s,
      Color color, {
      required bool area,
      required double width,
    }) {
      final List<ChartPoint> pts = s.points.toList()
        ..sort((ChartPoint a, ChartPoint b) => a.date.compareTo(b.date));
      final List<FlSpot> spots = <FlSpot>[
        for (final ChartPoint p in pts) FlSpot(xOf(p.date), p.value),
      ];
      final bool dense = spots.length > _denseFrom;
      return LineChartBarData(
        spots: spots,
        isCurved: false,
        color: color,
        barWidth: width,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (FlSpot spot, LineChartBarData data) =>
              !dense || spot == spots.last,
          getDotPainter: (FlSpot spot, double p, LineChartBarData d, int i) {
            final bool last = spot == spots.last;
            return FlDotCirclePainter(
              radius: last ? ChartSpec.lastDotRadius : ChartSpec.dotRadius,
              color: color,
              strokeWidth: last ? ChartSpec.dotRing : 0,
              strokeColor: cs.surfaceContainer,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: area,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              color.withValues(alpha: ChartSpec.areaTop),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      );
    }

    final Duration anim = Motion.reduced(context)
        ? Duration.zero
        : Motion.containerTransform;

    return RepaintBoundary(
      child: LineChart(
        duration: anim,
        curve: Motion.decelerate,
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: yStep,
            getDrawingHorizontalLine: (double _) =>
                FlLine(color: cs.outlineVariant, strokeWidth: Strokes.hairline),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: ChartSpec.leftReserved,
                interval: yStep,
                getTitlesWidget: (double v, TitleMeta meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(card._fmt(v), style: axis, maxLines: 1),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: ChartSpec.bottomReserved,
                interval: maxX / (ChartSpec.maxXLabels - 1),
                getTitlesWidget: (double v, TitleMeta meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(xLabel(v), style: axis, maxLines: 1),
                ),
              ),
            ),
          ),
          extraLinesData: ref == null
              ? null
              : ExtraLinesData(
                  horizontalLines: <HorizontalLine>[
                    HorizontalLine(
                      y: ref.value,
                      color: cs.onSurfaceVariant,
                      strokeWidth: Strokes.hairline,
                      dashArray: <int>[
                        ChartSpec.referenceDashOn.round(),
                        ChartSpec.referenceDashOff.round(),
                      ],
                      label: ref.label == null
                          ? null
                          : HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              style: axis,
                              labelResolver: (HorizontalLine _) => ref.label!,
                            ),
                    ),
                  ],
                ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot _) => cs.inverseSurface,
              fitInsideHorizontally: true,
              getTooltipItems: (List<LineBarSpot> spots) => <LineTooltipItem?>[
                for (final LineBarSpot s in spots)
                  LineTooltipItem(
                    '${card._fmt(s.y)}\n${ChartCard._day(dateAt(s.x))}',
                    tt.labelMedium!.copyWith(color: cs.onInverseSurface),
                  ),
              ],
            ),
          ),
          lineBarsData: <LineChartBarData>[
            line(first, c1, area: true, width: ChartSpec.lineWidth),
            if (second != null)
              line(
                second,
                c2,
                area: false,
                width: ChartSpec.secondaryLineWidth,
              ),
          ],
        ),
      ),
    );
  }

  /// Above this many points only the last one wears a dot.
  static const int _denseFrom = 31;
}
