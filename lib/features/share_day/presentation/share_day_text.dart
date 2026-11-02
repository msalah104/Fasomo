import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/features/share_day/presentation/shareable_fasting_day.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';

/// Localized text of a shared fasting day.
extension ShareDayText on AppLocalizations {
  /// "Fasting tomorrow: Day of Arafah"; just the type for a past day.
  String shareHeadline(ShareableFastingDay day) {
    final type = fastingTypeTitle(day.type);
    return day.daysUntil < 0 ? type : shareDayHeadline(day.daysUntil, type);
  }

  /// The text sent along with the image.
  String shareMessage(ShareableFastingDay day) => shareDayText(
    shareHeadline(day),
    formatHijri(day.hijriDate),
    formatGregorian(day.gregorianDate),
    appName,
  );
}
