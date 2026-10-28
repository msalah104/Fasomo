/// Calendar-day arithmetic on local dates, independent of time of day and
/// daylight-saving transitions.
abstract final class CalendarDays {
  /// The local midnight of [moment]'s calendar day.
  static DateTime dateOnly(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);

  /// [date] moved by [days] calendar days (negative moves backwards).
  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// Whole calendar days from [from] to [to]; negative when [to] is earlier.
  ///
  /// Computed on UTC midnights so a 23- or 25-hour DST day still counts as one.
  static int between(DateTime from, DateTime to) {
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
