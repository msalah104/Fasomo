import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// One cell of the Hijri month grid.
class CalendarDay extends Equatable {
  const new({
    required this.hijriDate,
    required this.gregorianDate,
    required this.isToday,
    required this.fastingTypes,
  });

  final HijriDate hijriDate;

  /// Local midnight of the Gregorian day.
  final DateTime gregorianDate;
  final bool isToday;

  /// Sorted by priority; empty on an ordinary day.
  final List<FastingType> fastingTypes;

  bool get isFastingDay => fastingTypes.isNotEmpty;

  @override
  List<Object> get props => [hijriDate, gregorianDate, isToday, fastingTypes];
}
