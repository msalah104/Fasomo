import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

/// Formats dates for display in the given language.
abstract final class DateFormatter {
  static String hijri(HijriDate date, String languageCode) {
    final monthNames = languageCode == 'ar'
        ? AppConstants.arabicMonthNames
        : AppConstants.englishMonthNames;
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  static String gregorian(DateTime date, String languageCode) =>
      DateFormat.yMMMMd(languageCode).format(date);
}
