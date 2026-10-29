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
      if (settings.weeklyEnabled && weekdays.isNotEmpty)
        weeklySummary(weekdays.map(weekdayName).join(', ')),
      if (settings.monthlyEnabled)
        monthlySummary('${settings.monthlyHijriDay}'),
      if (settings.beforeRamadanEnabled && countdowns.isNotEmpty)
        beforeRamadanSummary(countdowns.map(daysBeforeOption).join(', ')),
    ];
    return parts.isEmpty ? qadaRemindersOff : parts.join(' · ');
  }
}
