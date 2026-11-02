/// Canonical encodings shared by every backup section, so dates and choices
/// read the same in every part of the file whatever the device's locale.
abstract final class BackupValues {
  static final RegExp _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// [day] as `yyyy-MM-dd`, with ASCII digits.
  static String date(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  /// The local midnight [raw] names as `yyyy-MM-dd`, or `null` when it is
  /// not a real calendar date (2026-02-31 included).
  static DateTime? parseDate(Object? raw) {
    if (raw is! String) return null;
    final match = _datePattern.firstMatch(raw);
    if (match == null) return null;
    final [year, month, day] = [
      for (var group = 1; group <= 3; group++) int.parse(match.group(group)!),
    ];
    final date = DateTime(year, month, day);
    return date.month == month && date.day == day ? date : null;
  }

  /// Every value of [raw] as a date, or `null` when [raw] is not a list of
  /// dates.
  static Set<DateTime>? parseDates(Object? raw) {
    if (raw is! List<Object?>) return null;
    final dates = <DateTime>{};
    for (final value in raw) {
      final date = parseDate(value);
      if (date == null) return null;
      dates.add(date);
    }
    return dates;
  }

  /// [days] sorted and encoded, so equal sets always encode the same.
  static List<String> dates(Iterable<DateTime> days) => [
    for (final day in days.toList()..sort()) date(day),
  ];

  /// The value of [values] named [raw], or `null` when there is none.
  static T? byName<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String) return null;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}
