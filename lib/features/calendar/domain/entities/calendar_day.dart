import 'package:equatable/equatable.dart';
import 'package:hijri/hijri.dart';

import '../../../home/domain/entities/fasting_day.dart';

class CalendarDay extends Equatable {
  final HijriCalendar hijriDate;
  final DateTime gregorianDate;
  final bool isToday;
  final bool isFastingDay;
  final List<FastingType> fastingTypes;

  const CalendarDay({
    required this.hijriDate,
    required this.gregorianDate,
    required this.isToday,
    required this.isFastingDay,
    required this.fastingTypes,
  });

  @override
  List<Object?> get props => [
        hijriDate,
        gregorianDate,
        isToday,
        isFastingDay,
        fastingTypes,
      ];
}
