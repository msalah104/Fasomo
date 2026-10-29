import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:fasomo/features/tracker/domain/fast_log_rules.dart';
import 'package:fasomo/features/tracker/domain/ramadan_dates.dart';

/// Works out which days to suggest a make-up fast on, and when to count down
/// to Ramadan. Pure: "today" is passed in by the caller.
class QadaReminderPlanner {
  const new(this._calendar);

  final FastingCalendar _calendar;

  /// The occurrences for the [horizonDays] days from [today].
  ///
  /// Nothing is planned once [remaining] is zero. Suggested days skip
  /// Ramadan, the Eids, Tashreeq and days already in [fastedDays]; a day that
  /// is both a weekly and a monthly day is suggested once.
  List<ReminderOccurrence> plan({
    required QadaReminderSettings settings,
    required int remaining,
    required Set<DateTime> fastedDays,
    required DateTime today,
    required int horizonDays,
  }) {
    if (remaining <= 0) return const [];
    final timing = settings.time.timing;
    final occurrences = <ReminderOccurrence>[];

    for (var offset = 0; offset < horizonDays; offset++) {
      final info = _calendar.dayInfo(CalendarDays.addDays(today, offset));
      if (info == null) continue;
      final isWeekly =
          settings.weeklyEnabled &&
          settings.weekdays.contains(info.date.weekday);
      final isMonthly =
          settings.monthlyEnabled && info.hijri.day == settings.monthlyHijriDay;
      if (!isWeekly && !isMonthly) continue;
      if (fastedDays.contains(info.date)) continue;
      // Checked as of the day itself: only Ramadan and the forbidden days
      // are ruled out, not the future.
      if (!FastLogRules.canMakeUp(
        date: info.date,
        hijri: info.hijri,
        today: info.date,
      )) {
        continue;
      }
      occurrences.add(
        QadaOccurrence(date: info.date, timing: timing, remaining: remaining),
      );
    }

    final todayInfo = _calendar.dayInfo(today);
    final ramadan = todayInfo == null
        ? null
        : nextRamadanStart(_calendar, todayInfo.hijri);
    if (settings.beforeRamadanEnabled && ramadan != null) {
      for (final daysBefore in settings.daysBeforeRamadan) {
        final date = CalendarDays.addDays(ramadan, -daysBefore);
        final offset = CalendarDays.between(today, date);
        if (offset < 0 || offset >= horizonDays) continue;
        occurrences.add(
          RamadanCountdownOccurrence(
            date: date,
            timing: ReminderTiming(daysBefore: 0, time: timing.time),
            daysUntilRamadan: daysBefore,
            remaining: remaining,
          ),
        );
      }
    }
    return occurrences;
  }
}
