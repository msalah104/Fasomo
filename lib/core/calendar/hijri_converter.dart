import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:hijri/hijri_calendar.dart';

/// Converts between Gregorian and Hijri dates.
///
/// Conversions are only defined inside the supported range; callers check
/// [supportsGregorian] / [supportsMonth] first and report a typed failure
/// otherwise.
abstract interface class HijriConverter {
  int get minHijriYear;
  int get maxHijriYear;

  bool supportsGregorian(DateTime date);
  bool supportsMonth(HijriMonth month);

  HijriDate toHijri(DateTime date);

  /// The local midnight of the Gregorian day that [date] falls on.
  DateTime toGregorian(HijriDate date);

  int daysInMonth(HijriMonth month);
}

/// [HijriConverter] backed by the Umm al-Qura table in `package:hijri`, which
/// covers 1356 AH (14 March 1937) to 1500 AH (16 November 2077).
class UmmAlQuraHijriConverter implements HijriConverter {
  const new();

  static final DateTime _firstSupportedDay = DateTime(1937, 3, 14);
  static final DateTime _lastSupportedDay = DateTime(2077, 11, 16);

  @override
  int get minHijriYear => 1356;

  @override
  int get maxHijriYear => 1500;

  @override
  bool supportsGregorian(DateTime date) {
    final day = CalendarDays.dateOnly(date);
    return !day.isBefore(_firstSupportedDay) && !day.isAfter(_lastSupportedDay);
  }

  @override
  bool supportsMonth(HijriMonth month) =>
      month.year >= minHijriYear && month.year <= maxHijriYear;

  @override
  HijriDate toHijri(DateTime date) {
    assert(supportsGregorian(date), 'date outside the Umm al-Qura table');
    final hijri = HijriCalendar.fromDate(CalendarDays.dateOnly(date));
    return HijriDate(hijri.hYear, hijri.hMonth, hijri.hDay);
  }

  @override
  DateTime toGregorian(HijriDate date) {
    assert(
      supportsMonth(date.hijriMonth),
      'date outside the Umm al-Qura table',
    );
    return HijriCalendar().hijriToGregorian(date.year, date.month, date.day);
  }

  @override
  int daysInMonth(HijriMonth month) {
    assert(supportsMonth(month), 'month outside the Umm al-Qura table');
    return HijriCalendar().getDaysInMonth(month.year, month.month);
  }
}
