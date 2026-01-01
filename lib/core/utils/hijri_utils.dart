import 'package:hijri/hijri.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class HijriUtils {
  static HijriCalendar getCurrentHijriDate() {
    return HijriCalendar.now();
  }

  static HijriCalendar getHijriDate(DateTime date) {
    return HijriCalendar.fromDate(date);
  }

  static String formatHijriDate(HijriCalendar hijri, String languageCode) {
    final monthNames = languageCode == 'ar'
        ? AppConstants.arabicMonthNames
        : AppConstants.englishMonthNames;

    return '${hijri.hDay} ${monthNames[hijri.hMonth - 1]} ${hijri.hYear}';
  }

  static String formatGregorianDate(DateTime date, String languageCode) {
    final format = languageCode == 'ar'
        ? DateFormat('d MMMM yyyy', 'ar')
        : DateFormat('d MMMM yyyy', 'en');
    return format.format(date);
  }

  static bool isWhiteDay(int day) {
    return AppConstants.whiteDays.contains(day);
  }

  static bool isMondayOrThursday(DateTime date) {
    return AppConstants.mondayThursdayWeekdays.contains(date.weekday);
  }

  static bool isArafah(HijriCalendar hijri) {
    return hijri.hMonth == AppConstants.dhulHijjah &&
        hijri.hDay == AppConstants.dayOfArafah;
  }

  static bool isAshura(HijriCalendar hijri) {
    return hijri.hMonth == AppConstants.muharram &&
        hijri.hDay == AppConstants.dayOfAshura;
  }

  static bool isTasua(HijriCalendar hijri) {
    return hijri.hMonth == AppConstants.muharram &&
        hijri.hDay == AppConstants.dayOfTasua;
  }

  static bool isRamadan(HijriCalendar hijri) {
    return hijri.hMonth == AppConstants.ramadan;
  }

  static int daysUntil(HijriCalendar targetHijri) {
    final today = HijriCalendar.now();
    final todayGregorian = DateTime(today.hYear, today.hMonth, today.hDay);
    final targetGregorian =
        DateTime(targetHijri.hYear, targetHijri.hMonth, targetHijri.hDay);

    return targetGregorian.difference(todayGregorian).inDays;
  }

  static List<HijriCalendar> getMonthDates(int month, int year) {
    final dates = <HijriCalendar>[];
    final daysInMonth = HijriCalendar()
        .getDaysInMonth(year, month);

    for (int day = 1; day <= daysInMonth; day++) {
      dates.add(HijriCalendar()
        ..hYear = year
        ..hMonth = month
        ..hDay = day);
    }

    return dates;
  }
}
