import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/utils/app_localizations.dart';

/// Localized title and description for each [FastingType].
extension FastingTypeText on AppLocalizations {
  String fastingTypeTitle(FastingType type) => switch (type) {
    FastingType.ramadan => ramadan,
    FastingType.arafah => dayOfArafah,
    FastingType.ashura => dayOfAshura,
    FastingType.tasua => dayOfTasua,
    FastingType.shawwal => shawwalSixDays,
    FastingType.whiteDays => whiteDays,
    FastingType.mondayThursday => mondayThursday,
  };

  String fastingTypeDescription(FastingType type) => switch (type) {
    FastingType.ramadan => ramadanDesc,
    FastingType.arafah => arafahDesc,
    FastingType.ashura => ashuraDesc,
    FastingType.tasua => tasuaDesc,
    FastingType.shawwal => shawwalDesc,
    FastingType.whiteDays => whiteDaysDesc,
    FastingType.mondayThursday => mondayThursdayDesc,
  };
}
