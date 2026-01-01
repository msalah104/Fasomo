import 'package:hijri/hijri.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/hijri_utils.dart';
import '../../../home/domain/entities/fasting_day.dart';
import '../../domain/entities/calendar_day.dart';

abstract class CalendarLocalDataSource {
  List<CalendarDay> getHijriMonth(int month, int year);
}

class CalendarLocalDataSourceImpl implements CalendarLocalDataSource {
  @override
  List<CalendarDay> getHijriMonth(int month, int year) {
    final today = DateTime.now();
    final todayHijri = HijriUtils.getCurrentHijriDate();
    final calendarDays = <CalendarDay>[];

    final daysInMonth = HijriCalendar().getDaysInMonth(year, month);

    for (int day = 1; day <= daysInMonth; day++) {
      final hijriDate = HijriCalendar()
        ..hYear = year
        ..hMonth = month
        ..hDay = day;

      final gregorianDate = hijriDate.hijriToGregorian(year, month, day);

      final isToday = todayHijri.hYear == year &&
          todayHijri.hMonth == month &&
          todayHijri.hDay == day;

      final fastingTypes = _getFastingTypes(hijriDate, gregorianDate, month);

      calendarDays.add(CalendarDay(
        hijriDate: hijriDate,
        gregorianDate: gregorianDate,
        isToday: isToday,
        isFastingDay: fastingTypes.isNotEmpty,
        fastingTypes: fastingTypes,
      ));
    }

    return calendarDays;
  }

  List<FastingType> _getFastingTypes(
      HijriCalendar hijri, DateTime gregorian, int month) {
    final types = <FastingType>[];

    // Check for White Days
    if (HijriUtils.isWhiteDay(hijri.hDay)) {
      types.add(FastingType.whiteDays);
    }

    // Check for Monday/Thursday
    if (HijriUtils.isMondayOrThursday(gregorian)) {
      types.add(FastingType.mondayThursday);
    }

    // Check for Ramadan
    if (month == AppConstants.ramadan) {
      types.add(FastingType.ramadan);
    }

    // Check for Day of Arafah
    if (HijriUtils.isArafah(hijri)) {
      types.add(FastingType.arafah);
    }

    // Check for Ashura
    if (HijriUtils.isAshura(hijri)) {
      types.add(FastingType.ashura);
    }

    // Check for Tasua
    if (HijriUtils.isTasua(hijri)) {
      types.add(FastingType.tasua);
    }

    return types;
  }
}
