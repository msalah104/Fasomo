import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/home/domain/entities/week_day.dart';

/// Today in both calendars, with the context Home shows around it: the length
/// of the current Hijri month and the seven days starting today.
class HijriDateInfo extends Equatable {
  const new({
    required this.hijriDate,
    required this.gregorianDate,
    required this.daysInMonth,
    required this.week,
  });

  final HijriDate hijriDate;
  final DateTime gregorianDate;

  /// 29 or 30: the length of [hijriDate]'s month.
  final int daysInMonth;

  /// Today first, then the next six days. Shorter only at the very end of the
  /// supported calendar range.
  final List<WeekDay> week;

  @override
  List<Object> get props => [hijriDate, gregorianDate, daysInMonth, week];
}
