import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// Which fasting types apply to a day. Pure and total.
abstract final class FastingRules {
  static const int muharram = 1;
  static const int ramadan = 9;
  static const int shawwal = 10;
  static const int dhulHijjah = 12;

  static const List<int> whiteDays = [13, 14, 15];

  /// The types for the day [hijri], which falls on Gregorian [weekday]
  /// ([DateTime.monday] … [DateTime.sunday]), sorted by [FastingType] priority.
  ///
  /// Returns an empty list for ordinary days and for the days on which fasting
  /// is forbidden: Eid al-Fitr (1 Shawwal), Eid al-Adha and the days of
  /// Tashreeq (10–13 Dhul Hijjah). During Ramadan only [FastingType.ramadan]
  /// is returned, since the obligatory fast replaces every voluntary one.
  static List<FastingType> typesFor(HijriDate hijri, int weekday) {
    if (isForbidden(hijri)) return const [];
    if (hijri.month == ramadan) return const [FastingType.ramadan];

    return [
      if (hijri.month == dhulHijjah && hijri.day == 9) FastingType.arafah,
      if (hijri.month == muharram && hijri.day == 10) FastingType.ashura,
      if (hijri.month == muharram && hijri.day == 9) FastingType.tasua,
      // The six days may be any days of Shawwal after Eid.
      if (hijri.month == shawwal) FastingType.shawwal,
      if (whiteDays.contains(hijri.day)) FastingType.whiteDays,
      if (weekday == DateTime.monday || weekday == DateTime.thursday)
        FastingType.mondayThursday,
    ];
  }

  /// Whether fasting on [hijri] is forbidden (the two Eids and Tashreeq).
  static bool isForbidden(HijriDate hijri) =>
      (hijri.month == shawwal && hijri.day == 1) ||
      (hijri.month == dhulHijjah && hijri.day >= 10 && hijri.day <= 13);
}
