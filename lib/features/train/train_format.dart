import '../../core/models/enums.dart';
import '../../core/units/units.dart';

// PURE DART. Display strings for the Train feature. Formatting only: no sums,
// no records (those come from the engines).

const List<String> _weekdays = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _months = <String>[
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

String weekdayShort(DateTime d) => _weekdays[d.weekday - 1];

String monthShort(DateTime d) => _months[d.month - 1];

/// "Tue 28 Oct".
String formatDay(DateTime d) => '${weekdayShort(d)} ${d.day} ${monthShort(d)}';

/// "18:10".
String formatClock(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// "Tue 28 Oct · 18:10 to 19:02".
String formatSessionWhen(DateTime start, DateTime? end) => end == null
    ? '${formatDay(start)} · ${formatClock(start)}'
    : '${formatDay(start)} · ${formatClock(start)} to ${formatClock(end)}';

/// "52 min", "1 h 05 min", "40 s".
String formatMinutes(int seconds) {
  final int s = seconds < 0 ? 0 : seconds;
  if (s < 60) return '$s s';
  final int h = s ~/ 3600;
  final int m = (s % 3600) ~/ 60;
  if (h == 0) return '$m min';
  return '$h h ${m.toString().padLeft(2, '0')} min';
}

/// Elapsed clock for the workout header: "24:18", "1:02:03".
String formatElapsed(int seconds) {
  final int s = seconds < 0 ? 0 : seconds;
  final int h = s ~/ 3600;
  final int m = (s % 3600) ~/ 60;
  final int sec = s % 60;
  final String ss = sec.toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
  return '$m:$ss';
}

/// "4,820 kg" with thousands separators, in the user's unit.
String formatVolume(double kg, WeightUnit unit) {
  final double v = Units.fromKg(kg, unit);
  final String whole = v.round().toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    final int left = whole.length - i;
    out.write(whole[i]);
    if (left > 1 && left % 3 == 1) out.write(',');
  }
  return '$out ${Units.weightLabel(unit)}';
}

/// The Monday at 00:00 of the week holding [d].
DateTime weekStart(DateTime d) {
  final DateTime day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// "This week", "Last week" or "20 Oct to 26 Oct" for the week starting at
/// [start], relative to [now].
String weekLabel(DateTime start, DateTime now) {
  final DateTime thisWeek = weekStart(now);
  final int diff = thisWeek.difference(start).inDays;
  if (diff == 0) return 'This week';
  if (diff == 7) return 'Last week';
  final DateTime end = start.add(const Duration(days: 6));
  return '${start.day} ${monthShort(start)} to ${end.day} ${monthShort(end)}';
}

/// "today", "yesterday", "3 days ago", "2 weeks ago".
String formatAgo(DateTime then, DateTime now) {
  final DateTime a = DateTime(then.year, then.month, then.day);
  final DateTime b = DateTime(now.year, now.month, now.day);
  final int days = b.difference(a).inDays;
  if (days <= 0) return 'today';
  if (days == 1) return 'yesterday';
  if (days < 14) return '$days days ago';
  if (days < 60) return '${days ~/ 7} weeks ago';
  return '${days ~/ 30} months ago';
}

String plural(int n, String one, [String? many]) =>
    '$n ${n == 1 ? one : (many ?? '${one}s')}';
