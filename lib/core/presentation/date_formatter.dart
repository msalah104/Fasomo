import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Localized date text. Dates are stored and computed as values; they become
/// strings only here, at render time.
extension DateText on AppLocalizations {
  String hijriMonthName(int month) => [
    hijriMonth1,
    hijriMonth2,
    hijriMonth3,
    hijriMonth4,
    hijriMonth5,
    hijriMonth6,
    hijriMonth7,
    hijriMonth8,
    hijriMonth9,
    hijriMonth10,
    hijriMonth11,
    hijriMonth12,
  ][month - 1];

  String formatHijri(HijriDate date) => hijriDate(
    '${date.day}',
    hijriMonthName(date.month),
    hijriYear('${date.year}'),
  );

  String formatGregorian(DateTime date) =>
      DateFormat.yMMMMd(localeName).format(date);
}
