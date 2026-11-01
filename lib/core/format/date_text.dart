// PURE DART. Plain-English dates without a locale package: Sinew is English
// only and offline, and "28 Oct" is the same everywhere it is shown.

abstract final class DateText {
  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String month(DateTime d) => _months[d.month - 1];

  static String monthShort(DateTime d) => month(d).substring(0, 3);

  static String weekday(DateTime d) => _weekdays[d.weekday - 1];

  static String weekdayShort(DateTime d) => weekday(d).substring(0, 3);

  /// `28 Oct`
  static String dayMonth(DateTime d) => '${d.day} ${monthShort(d)}';

  /// `28 Oct 2026`
  static String dayMonthYear(DateTime d) => '${dayMonth(d)} ${d.year}';

  /// `Friday, 31 October`
  static String full(DateTime d) => '${weekday(d)}, ${d.day} ${month(d)}';

  /// `Morning`, `Afternoon` or `Evening` for the hour of [now].
  static String partOfDay(DateTime now) {
    if (now.hour < 12) return 'Morning';
    if (now.hour < 17) return 'Afternoon';
    return 'Evening';
  }

  /// `Evening, Gautam` or just `Evening` without a name.
  static String greeting(DateTime now, String name) {
    final String part = partOfDay(now);
    final String n = name.trim();
    return n.isEmpty ? part : '$part, $n';
  }

  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whole calendar days from [from] to [to] (DST safe).
  static int daysBetween(DateTime from, DateTime to) {
    final DateTime a = DateTime.utc(from.year, from.month, from.day);
    final DateTime b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  /// `today`, `yesterday`, `19 days ago`, or the date for anything older
  /// than 60 days.
  static String ago(DateTime then, DateTime now) {
    final int days = daysBetween(then.toLocal(), now);
    if (days <= 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days <= 60) return '$days days ago';
    return dayMonthYear(then.toLocal());
  }

  /// `Wednesday` within the last week, otherwise `28 Oct`.
  static String recent(DateTime then, DateTime now) {
    final DateTime t = then.toLocal();
    final int days = daysBetween(t, now);
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return weekday(t);
    return dayMonth(t);
  }

  /// `52 min`, `1 h 05 min`, `45 s`.
  static String durationText(int seconds) {
    if (seconds < 60) return '$seconds s';
    final int minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min';
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')} min';
  }

  /// `1:30` for 90 seconds.
  static String clock(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// `31 Oct`, or `31 Oct 2025` when [date] is not in the year of [now]. Both
  /// are read in local time.
  static String dayMonthSmart(DateTime date, DateTime now) {
    final DateTime d = date.toLocal();
    return d.year == now.toLocal().year ? dayMonth(d) : dayMonthYear(d);
  }

  /// `Today, 31 Oct` for the current day, else [dayMonthSmart].
  static String dayMonthLong(DateTime date, DateTime now) {
    final String base = dayMonthSmart(date, now);
    return sameDay(date.toLocal(), now.toLocal()) ? 'Today, $base' : base;
  }

  /// `12 workouts`, `1 workout`.
  static String count(int n, String singular, [String? plural]) =>
      '$n ${n == 1 ? singular : (plural ?? '${singular}s')}';
}
