import 'package:fasomo/core/presentation/qada_pace_text.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_pace.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Localized labels for the make-up reminder settings.
extension QadaReminderText on AppLocalizations {
  /// The short name of [weekday] ([DateTime.monday] … [DateTime.sunday]).
  String weekdayName(int weekday) =>
      // 1 January 2024 was a Monday.
      DateFormat.E(localeName).format(DateTime(2024, 1, weekday));

  /// One line for the settings, e.g. "Weekly: Sat · Monthly: day 13".
  String qadaReminderSummary(QadaReminderSettings settings) {
    final weekdays = settings.weekdays.toList()..sort();
    final countdowns = settings.daysBeforeRamadan.toList()
      ..sort((a, b) => b.compareTo(a));
    final parts = [
      if (settings.paceEnabled) suggestedPace,
      if (settings.weeklyEnabled && weekdays.isNotEmpty)
        weeklySummary(weekdays.map(weekdayName).join(', ')),
      if (settings.monthlyEnabled)
        monthlySummary('${settings.monthlyHijriDay}'),
      if (settings.beforeRamadanEnabled && countdowns.isNotEmpty)
        beforeRamadanSummary(countdowns.map(daysBeforeOption).join(', ')),
    ];
    return parts.isEmpty ? qadaRemindersOff : parts.join(' · ');
  }

  /// The pace in full with the next day, e.g. "To finish before Ramadan,
  /// fast 1 make-up day a week. Next: Thursday, November 5".
  String qadaPaceDescription(QadaPace pace) => [
    qadaPaceSentence(pace.rate),
    if (pace.next case final next?)
      qadaPaceNext(DateFormat.MMMMEEEEd(localeName).format(next)),
  ].join(' ');

  /// The pace in short, e.g. "Suggested pace: 1 day a week · Next: Thu,
  /// Nov 5".
  String qadaPaceShortLine(QadaPace pace) => [
    qadaPaceLine(pace.rate),
    if (pace.next case final next?)
      qadaPaceNext(DateFormat.MMMEd(localeName).format(next)),
  ].join(' · ');
}
