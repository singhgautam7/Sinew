import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'date_text.dart';

/// Seven days, a filled disc for each day with a workout and a ring on today.
/// Colour is never the only cue: the disc also carries a check, and every day
/// has a spoken label.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.counts,
    required this.todayIndex,
    required this.now,
    required this.mondayFirst,
  }) : assert(counts.length == 7);

  /// Sessions per day, first day of the week first.
  final List<int> counts;
  final int todayIndex;
  final DateTime now;
  final bool mondayFirst;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final DateTime today = DateText.dayOf(now);
    final DateTime start = DateTime(
      today.year,
      today.month,
      today.day - todayIndex,
    );
    return Row(
      children: <Widget>[
        for (int i = 0; i < 7; i++)
          Expanded(
            child: _Day(
              date: DateTime(start.year, start.month, start.day + i),
              count: counts[i],
              isToday: i == todayIndex,
              colors: cs,
            ),
          ),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.date,
    required this.count,
    required this.isToday,
    required this.colors,
  });

  final DateTime date;
  final int count;
  final bool isToday;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final bool done = count > 0;
    final String spoken =
        '${DateText.weekday(date)}${isToday ? ', today' : ''}, '
        '${done ? DateText.count(count, 'workout') : 'no workout'}';
    return Semantics(
      label: spoken,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: TodaySpec.dayCell,
            height: TodaySpec.dayCell,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? colors.primary : colors.surfaceContainerHigh,
              border: Border.all(
                color: isToday ? colors.primary : colors.outlineVariant,
                width: isToday ? TodaySpec.dayCellRing : Strokes.hairline,
              ),
            ),
            child: done
                ? Icon(
                    Icons.check_rounded,
                    size: IconSpec.small,
                    color: colors.onPrimary,
                  )
                : null,
          ),
          const SizedBox(height: Space.xs),
          Text(
            DateText.weekday(date).substring(0, 1),
            style: context.text.labelMedium!.copyWith(
              color: isToday ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
