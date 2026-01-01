import 'package:hijri/hijri.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/hijri_utils.dart';
import '../../domain/entities/fasting_day.dart';
import '../../domain/entities/hijri_date_info.dart';

abstract class FastingLocalDataSource {
  HijriDateInfo getCurrentHijriDate(String languageCode);
  List<FastingDay> getUpcomingFastingDays(String languageCode);
}

class FastingLocalDataSourceImpl implements FastingLocalDataSource {
  final SharedPreferences sharedPreferences;

  FastingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  HijriDateInfo getCurrentHijriDate(String languageCode) {
    final hijri = HijriUtils.getCurrentHijriDate();
    final gregorian = DateTime.now();

    return HijriDateInfo(
      hijriDate: hijri,
      gregorianDate: gregorian,
      formattedHijri: HijriUtils.formatHijriDate(hijri, languageCode),
      formattedGregorian:
          HijriUtils.formatGregorianDate(gregorian, languageCode),
    );
  }

  @override
  List<FastingDay> getUpcomingFastingDays(String languageCode) {
    final today = HijriUtils.getCurrentHijriDate();
    final fastingDays = <FastingDay>[];

    // Check for upcoming white days in current month
    fastingDays.addAll(_getWhiteDays(today, languageCode));

    // Check for Monday/Thursday in the next 7 days
    fastingDays.addAll(_getMondayThursday(languageCode));

    // Check for special days
    fastingDays.addAll(_getSpecialDays(today, languageCode));

    // Sort by days until
    fastingDays.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    return fastingDays.take(5).toList(); // Return top 5 upcoming
  }

  List<FastingDay> _getWhiteDays(
      HijriCalendar currentHijri, String languageCode) {
    final fastingDays = <FastingDay>[];
    final today = DateTime.now();

    for (final day in AppConstants.whiteDays) {
      final hijriDate = HijriCalendar()
        ..hYear = currentHijri.hYear
        ..hMonth = currentHijri.hMonth
        ..hDay = day;

      final gregorianDate = hijriDate.hijriToGregorian(
          currentHijri.hYear, currentHijri.hMonth, day);

      if (gregorianDate.isAfter(today) ||
          gregorianDate.day == today.day &&
              gregorianDate.month == today.month &&
              gregorianDate.year == today.year) {
        final daysUntil = gregorianDate.difference(today).inDays;

        fastingDays.add(FastingDay(
          hijriDate: hijriDate,
          gregorianDate: gregorianDate,
          type: FastingType.whiteDays,
          title: languageCode == 'ar' ? 'الأيام البيض' : 'White Days',
          description: languageCode == 'ar'
              ? 'الأيام 13 و14 و15 من كل شهر هجري'
              : 'The 13th, 14th, and 15th of every Hijri month',
          isMandatory: false,
          daysUntil: daysUntil,
        ));
      }
    }

    return fastingDays;
  }

  List<FastingDay> _getMondayThursday(String languageCode) {
    final fastingDays = <FastingDay>[];
    final today = DateTime.now();

    for (int i = 0; i < 14; i++) {
      final date = today.add(Duration(days: i));
      if (HijriUtils.isMondayOrThursday(date)) {
        final hijriDate = HijriUtils.getHijriDate(date);

        fastingDays.add(FastingDay(
          hijriDate: hijriDate,
          gregorianDate: date,
          type: FastingType.mondayThursday,
          title: languageCode == 'ar'
              ? 'الاثنين والخميس'
              : 'Monday & Thursday',
          description: languageCode == 'ar'
              ? 'كان النبي صلى الله عليه وسلم يصوم الاثنين والخميس'
              : 'The Prophet (PBUH) used to fast on Mondays and Thursdays',
          isMandatory: false,
          daysUntil: date.difference(today).inDays,
        ));
      }
    }

    return fastingDays;
  }

  List<FastingDay> _getSpecialDays(
      HijriCalendar currentHijri, String languageCode) {
    final fastingDays = <FastingDay>[];
    final today = DateTime.now();

    // Day of Arafah (9th Dhul Hijjah)
    final arafah = HijriCalendar()
      ..hYear = currentHijri.hYear
      ..hMonth = AppConstants.dhulHijjah
      ..hDay = AppConstants.dayOfArafah;

    final arafahGregorian = arafah.hijriToGregorian(
        currentHijri.hYear, AppConstants.dhulHijjah, AppConstants.dayOfArafah);

    if (arafahGregorian.isAfter(today)) {
      fastingDays.add(FastingDay(
        hijriDate: arafah,
        gregorianDate: arafahGregorian,
        type: FastingType.arafah,
        title: languageCode == 'ar' ? 'يوم عرفة' : 'Day of Arafah',
        description: languageCode == 'ar'
            ? 'التاسع من ذي الحجة. صيام هذا اليوم يكفر ذنوب سنتين'
            : 'The 9th of Dhul Hijjah. Fasting this day expiates sins of two years',
        isMandatory: false,
        daysUntil: arafahGregorian.difference(today).inDays,
      ));
    }

    // Day of Ashura (10th Muharram)
    final ashura = HijriCalendar()
      ..hYear = currentHijri.hYear
      ..hMonth = AppConstants.muharram
      ..hDay = AppConstants.dayOfAshura;

    final ashuraGregorian = ashura.hijriToGregorian(
        currentHijri.hYear, AppConstants.muharram, AppConstants.dayOfAshura);

    if (ashuraGregorian.isAfter(today)) {
      fastingDays.add(FastingDay(
        hijriDate: ashura,
        gregorianDate: ashuraGregorian,
        type: FastingType.ashura,
        title: languageCode == 'ar' ? 'يوم عاشوراء' : 'Day of Ashura',
        description: languageCode == 'ar'
            ? 'العاشر من محرم. صيام هذا اليوم يكفر ذنوب سنة'
            : 'The 10th of Muharram. Fasting this day expiates sins of one year',
        isMandatory: false,
        daysUntil: ashuraGregorian.difference(today).inDays,
      ));
    }

    // Day of Tasua (9th Muharram)
    final tasua = HijriCalendar()
      ..hYear = currentHijri.hYear
      ..hMonth = AppConstants.muharram
      ..hDay = AppConstants.dayOfTasua;

    final tasuaGregorian = tasua.hijriToGregorian(
        currentHijri.hYear, AppConstants.muharram, AppConstants.dayOfTasua);

    if (tasuaGregorian.isAfter(today)) {
      fastingDays.add(FastingDay(
        hijriDate: tasua,
        gregorianDate: tasuaGregorian,
        type: FastingType.tasua,
        title: languageCode == 'ar' ? 'يوم تاسوعاء' : 'Day of Tasua',
        description: languageCode == 'ar'
            ? 'التاسع من محرم. يستحب صيامه مع عاشوراء'
            : 'The 9th of Muharram. Recommended to fast along with Ashura',
        isMandatory: false,
        daysUntil: tasuaGregorian.difference(today).inDays,
      ));
    }

    return fastingDays;
  }
}
