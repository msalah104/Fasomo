import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_rules.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// One Gregorian day with its Hijri date and the fasting types that apply.
class FastingDayInfo extends Equatable {
  const new({
    required this.date,
    required this.hijri,
    required this.types,
  });

  /// Local midnight of the Gregorian day.
  final DateTime date;
  final HijriDate hijri;

  /// Sorted by [FastingType] priority; empty on an ordinary day.
  final List<FastingType> types;

  bool get isFastingDay => types.isNotEmpty;

  @override
  List<Object> get props => [date, hijri, types];
}

/// Projects [FastingRules] onto Gregorian days. Pure: "today" is always passed
/// in by the caller, which reads it from an injected clock.
class FastingCalendar {
  const new(this._converter);

  final HijriConverter _converter;

  HijriConverter get converter => _converter;

  /// The day [date] falls on, or `null` outside the supported range.
  FastingDayInfo? dayInfo(DateTime date) {
    if (!_converter.supportsGregorian(date)) return null;
    final day = CalendarDays.dateOnly(date);
    final hijri = _converter.toHijri(day);
    return FastingDayInfo(
      date: day,
      hijri: hijri,
      types: FastingRules.typesFor(hijri, day.weekday),
    );
  }

  /// The fasting days among the [days] calendar days starting at [from]
  /// (inclusive), in date order. Days outside the supported range are skipped.
  List<FastingDayInfo> fastingDaysFrom(DateTime from, {required int days}) => [
    for (var offset = 0; offset < days; offset++)
      if (dayInfo(CalendarDays.addDays(from, offset)) case final info?
          when info.isFastingDay)
        info,
  ];

  /// Every day of [month], or `null` when the month is unsupported.
  List<FastingDayInfo>? month(HijriMonth month) {
    if (!_converter.supportsMonth(month)) return null;
    final first = _converter.toGregorian(HijriDate(month.year, month.month, 1));
    final length = _converter.daysInMonth(month);
    return [
      for (var day = 1; day <= length; day++)
        _infoFor(
          HijriDate(month.year, month.month, day),
          CalendarDays.addDays(first, day - 1),
        ),
    ];
  }

  FastingDayInfo _infoFor(HijriDate hijri, DateTime date) => FastingDayInfo(
    date: date,
    hijri: hijri,
    types: FastingRules.typesFor(hijri, date.weekday),
  );
}
