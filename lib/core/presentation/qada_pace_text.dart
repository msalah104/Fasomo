import 'package:fasomo/core/notifications/qada_pace_rate.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';

/// Localized text for the suggested make-up pace, shared by the
/// notifications and the tracker screens.
extension QadaPaceText on AppLocalizations {
  /// The full sentence, e.g. "To finish before Ramadan, fast 1 make-up day
  /// a week."
  String qadaPaceSentence(QadaPaceRate pace) => switch (pace) {
    PerWeekPace(:final daysPerWeek) => qadaPaceWeekly(daysPerWeek),
    EveryDayPace() => qadaPaceEveryDay,
    NotEnoughDaysPace(:final availableDays) => qadaPaceNotEnough(
      availableDays,
    ),
  };

  /// A short line, e.g. "Suggested pace: 1 day a week".
  String qadaPaceLine(QadaPaceRate pace) => switch (pace) {
    PerWeekPace(:final daysPerWeek) => qadaPaceLineWeekly(daysPerWeek),
    EveryDayPace() => qadaPaceLineEveryDay,
    NotEnoughDaysPace(:final availableDays) => qadaPaceLineNotEnough(
      availableDays,
    ),
  };
}
