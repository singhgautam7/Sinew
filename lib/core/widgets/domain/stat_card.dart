import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../../engines/body_stats/stat_result.dart';
import '../../theme/app_theme.dart';
import '../app_button.dart';
import '../app_icon_button.dart';
import '../sinew_list.dart';
import '../sinew_states.dart';

/// Plain words for a stat input: "waist", "activity level".
String statInputLabel(StatInput input) => switch (input) {
  StatInput.weight => 'weight',
  StatInput.height => 'height',
  StatInput.age => 'age',
  StatInput.sex => 'sex',
  StatInput.waist => 'waist',
  StatInput.neck => 'neck',
  StatInput.hips => 'hips',
  StatInput.bodyFat => 'body fat',
  StatInput.activityLevel => 'activity level',
};

/// "waist", "waist and neck", "weight, height and age".
String describeStatInputs(List<StatInput> inputs) {
  final List<String> words = inputs.map(statInputLabel).toList();
  if (words.isEmpty) return '';
  if (words.length == 1) return words.first;
  return '${words.sublist(0, words.length - 1).join(', ')} and ${words.last}';
}

/// The sentence a locked card shows: "Add your waist and neck to see this."
String lockedStatMessage(List<StatInput> missing) =>
    'Add your ${describeStatInputs(missing)} to see this.';

/// Which way a value moved since the last entry.
enum StatTrend { up, down, flat }

/// A change against the previous value, already formatted by the caller
/// ("-1.0 kg").
@immutable
class StatDelta {
  const StatDelta(this.text, {this.trend = StatTrend.flat});

  final String text;
  final StatTrend trend;
}

/// A body stat: a value with its unit, an optional category chip, delta and
/// badges, an info button, and three other states.
///
/// - **Locked** ([MissingInputs]): dashed card, lock glyph, "Add your waist
///   and neck to see this." and an action button ([onLockedAction]).
/// - **Invalid** ([InvalidInputs]): the same card naming the values to check.
/// - **Loading**: [StatCard.loading], a skeleton.
///
/// The card renders the engine's [StatResult]; it never computes. [format]
/// turns the engine value into text in the user's units. [footer] is a slot
/// under the value for a scale such as the BMI band. [compact] is the
/// two-line card for Today.
class StatCard<T> extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required StatResult<T> this.result,
    required String Function(T value) this.format,
    this.unit,
    this.category,
    this.categoryTone = SinewTone.secondary,
    this.delta,
    this.caption,
    this.footer,
    this.onInfo,
    this.onTap,
    this.onLockedAction,
    this.lockedActionLabel = 'Add measurements',
    this.compact = false,
  });

  /// The loading skeleton.
  const StatCard.loading({super.key, required this.label, this.compact = false})
    : result = null,
      format = null,
      unit = null,
      category = null,
      categoryTone = SinewTone.secondary,
      delta = null,
      caption = null,
      footer = null,
      onInfo = null,
      onTap = null,
      onLockedAction = null,
      lockedActionLabel = '';

  final String label;
  final StatResult<T>? result;
  final String Function(T value)? format;
  final String? unit;

  /// A chip beside the value: "Normal", "Healthy weight".
  final String? category;
  final SinewTone categoryTone;
  final StatDelta? delta;

  /// A line under the value: "Estimate, US Navy method".
  final String? caption;
  final Widget? footer;

  /// Shows an info button; the caller opens the info sheet.
  final VoidCallback? onInfo;
  final VoidCallback? onTap;

  /// The locked card's button. Without it the card shows no button.
  final VoidCallback? onLockedAction;
  final String lockedActionLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final StatResult<T>? r = result;
    if (r == null) return _Loading(label: label, compact: compact);
    return switch (r) {
      StatValue<T>() => _filled(context, r),
      MissingInputs<T>() => _Locked(
        label: label,
        message: lockedStatMessage(r.missing),
        short: 'Needs ${describeStatInputs(r.missing)}',
        icon: Icons.lock_outline_rounded,
        actionLabel: lockedActionLabel,
        onAction: onLockedAction,
        onInfo: onInfo,
        compact: compact,
      ),
      InvalidInputs<T>() => _Locked(
        label: label,
        message:
            'Check your ${describeStatInputs(r.invalid)}. '
            'These values cannot give a result.',
        short: 'Check ${describeStatInputs(r.invalid)}',
        icon: Icons.error_outline_rounded,
        actionLabel: 'Review measurements',
        onAction: onLockedAction,
        onInfo: onInfo,
        compact: compact,
      ),
    };
  }

  Widget _filled(BuildContext context, StatValue<T> v) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final String text = format!(v.value);
    final Widget value = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (compact ? tt.titleLarge : tt.headlineLarge)!.copyWith(
              color: cs.onSurface,
            ),
          ),
        ),
        if (unit != null) ...<Widget>[
          const SizedBox(width: StatSpec.valueGap),
          Flexible(
            child: Text(
              unit!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );

    final List<Widget> chips = <Widget>[
      if (category != null) SinewPill(label: category!, tone: categoryTone),
      if (v.approximate)
        const SinewPill(label: 'Approximate', tone: SinewTone.neutral),
      if (v.estimated)
        const SinewPill(label: 'Estimate', tone: SinewTone.neutral),
      if (delta != null) _DeltaText(delta: delta!),
    ];

    final Widget head = Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: (compact ? tt.labelMedium : tt.titleSmall)!.copyWith(
              color: compact ? cs.onSurfaceVariant : cs.onSurface,
            ),
          ),
        ),
        if (onInfo != null && !compact)
          _InfoButton(label: label, onTap: onInfo!),
      ],
    );

    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        head,
        SizedBox(height: compact ? Space.xs : StatSpec.gap / 2),
        value,
        if (chips.isNotEmpty && !compact) ...<Widget>[
          const SizedBox(height: StatSpec.gap),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: chips,
          ),
        ],
        if (footer != null && !compact) ...<Widget>[
          const SizedBox(height: StatSpec.gap),
          footer!,
        ],
        if (caption != null && !compact) ...<Widget>[
          const SizedBox(height: StatSpec.gap / 2),
          Text(
            caption!,
            style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      child: SinewCard(
        onTap: onTap,
        padding: EdgeInsets.all(compact ? Space.md : Space.cardPadding),
        child: SizedBox(width: double.infinity, child: body),
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The 48dp button hangs into the card padding so the row stays tight.
    return Transform.translate(
      offset: const Offset(Space.md, 0),
      child: SizedBox(
        height: Sizes.glyphSlot,
        child: OverflowBox(
          maxHeight: IconSpec.tapTarget,
          child: AppIconButton(
            icon: Icons.info_outline_rounded,
            kind: AppIconButtonKind.plain,
            semanticLabel: 'About $label',
            glyphSize: Sizes.infoGlyph,
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}

class _DeltaText extends StatelessWidget {
  const _DeltaText({required this.delta});

  final StatDelta delta;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final IconData? icon = switch (delta.trend) {
      StatTrend.up => Icons.arrow_upward_rounded,
      StatTrend.down => Icons.arrow_downward_rounded,
      StatTrend.flat => null,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: IconSpec.tiny, color: cs.onSurfaceVariant),
          const SizedBox(width: Space.xs),
        ],
        Flexible(
          child: Text(
            delta.text,
            style: context.text.labelMedium!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// The locked and invalid card: dashed outline on the page colour, a glyph,
/// what is missing, and an action.
class _Locked extends StatelessWidget {
  const _Locked({
    required this.label,
    required this.message,
    required this.short,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    required this.onInfo,
    required this.compact,
  });

  final String label;
  final String message;
  final String short;
  final IconData icon;
  final String actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onInfo;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: (compact ? tt.labelMedium : tt.titleSmall)!.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            if (onInfo != null && !compact)
              _InfoButton(label: label, onTap: onInfo!),
            Semantics(
              label: 'Locked',
              child: Icon(
                icon,
                size: StatSpec.lockGlyph,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? Space.xs : StatSpec.gap),
        Text(
          compact ? short : message,
          maxLines: compact ? 2 : null,
          overflow: compact ? TextOverflow.ellipsis : null,
          style: (compact ? tt.bodySmall : tt.bodyMedium)!.copyWith(
            color: cs.onSurface,
          ),
        ),
        if (onAction != null && !compact) ...<Widget>[
          const SizedBox(height: StatSpec.gap),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: actionLabel,
              icon: Icons.add_rounded,
              type: AppButtonType.normal,
              height: Sizes.buttonSmall,
              onPressed: onAction,
            ),
          ),
        ],
      ],
    );
    final Widget card = CustomPaint(
      foregroundPainter: _DashedCardPainter(color: cs.outline),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? Space.md : Space.cardPadding),
        decoration: BoxDecoration(color: cs.surface, borderRadius: Radii.cardR),
        child: content,
      ),
    );
    return Semantics(
      container: true,
      child: compact && onAction != null
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: card,
            )
          : card,
    );
  }
}

class _DashedCardPainter extends CustomPainter {
  const _DashedCardPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(Radii.card),
        ),
      );
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = Strokes.hairline
      ..color = color;
    for (final PathMetric m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(
          m.extractPath(d, math.min(d + Sizes.dashLength, m.length)),
          paint,
        );
        d += Sizes.dashLength + Sizes.dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCardPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Loading $label',
      excludeSemantics: true,
      child: SinewCard(
        padding: EdgeInsets.all(compact ? Space.md : Space.cardPadding),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FractionallySizedBox(
              widthFactor: StatSpec.skeletonLabelWidth,
              child: SinewSkeleton(
                height: StatSpec.skeletonLabel,
                borderRadius: Radii.extraSmall,
              ),
            ),
            SizedBox(height: StatSpec.gap),
            FractionallySizedBox(
              widthFactor: StatSpec.skeletonValueWidth,
              child: SinewSkeleton(
                height: StatSpec.skeletonValue,
                borderRadius: Radii.extraSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
