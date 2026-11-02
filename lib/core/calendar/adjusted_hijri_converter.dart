import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';

/// A [HijriConverter] that moves every date of [_base] by the user's
/// [HijriOffset], so the calendar, the fasting rules and the reminders all
/// shift together.
///
/// With an offset of `n` days, the Gregorian day `g` has the Hijri date the
/// base table gives `g + n`, and the inverse moves back by `n`. Month lengths
/// are unchanged, and the supported Gregorian range moves with the offset so
/// that [supportsGregorian] still guards [toHijri] exactly.
///
/// Day arithmetic uses calendar fields ([CalendarDays.addDays]), never a
/// [Duration], so a 23- or 25-hour daylight-saving day still counts as one.
final class AdjustedHijriConverter implements HijriConverter {
  const new(this._base, this._offsets);

  final HijriConverter _base;
  final HijriOffsetSource _offsets;

  int get _days => _offsets.hijriOffset.days;

  @override
  int get minHijriYear => _base.minHijriYear;

  @override
  int get maxHijriYear => _base.maxHijriYear;

  @override
  bool supportsGregorian(DateTime date) =>
      _base.supportsGregorian(CalendarDays.addDays(date, _days));

  @override
  bool supportsMonth(HijriMonth month) => _base.supportsMonth(month);

  @override
  HijriDate toHijri(DateTime date) =>
      _base.toHijri(CalendarDays.addDays(date, _days));

  @override
  DateTime toGregorian(HijriDate date) =>
      CalendarDays.addDays(_base.toGregorian(date), -_days);

  @override
  int daysInMonth(HijriMonth month) => _base.daysInMonth(month);
}
