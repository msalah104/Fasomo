import 'package:equatable/equatable.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:hijri/hijri_calendar.dart';

class CalendarDay extends Equatable {
  const new({
    required this.hijriDate,
    required this.gregorianDate,
    required this.isToday,
    required this.isFastingDay,
    required this.fastingTypes,
  });
  final HijriCalendar hijriDate;
  final DateTime gregorianDate;
  final bool isToday;
  final bool isFastingDay;
  final List<FastingType> fastingTypes;

  @override
  List<Object?> get props => [
    hijriDate,
    gregorianDate,
    isToday,
    isFastingDay,
    fastingTypes,
  ];
}
