import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_rules.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// The first day of the next Ramadan that hasn't started by [today]: this
/// year's before Ramadan, next year's from Ramadan on. `null` past the
/// supported calendar range.
DateTime? nextRamadanStart(FastingCalendar calendar, HijriDate today) {
  final year = today.month < FastingRules.ramadan ? today.year : today.year + 1;
  if (!calendar.converter.supportsMonth(
    HijriMonth(year, FastingRules.ramadan),
  )) {
    return null;
  }
  return calendar.converter.toGregorian(
    HijriDate(year, FastingRules.ramadan, 1),
  );
}
