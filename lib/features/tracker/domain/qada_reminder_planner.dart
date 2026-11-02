import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/ramadan_dates.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:fasomo/features/tracker/domain/fast_log_rules.dart';
import 'package:fasomo/features/tracker/domain/qada_pace_planner.dart';

/// Works out which days to suggest a make-up fast on, and when to count down
/// to Ramadan. Pure: "today" is passed in by the caller.
class QadaReminderPlanner {
  const new(this._calendar, this._pace);

  final FastingCalendar _calendar;
  final QadaPacePlanner _pace;

  /// The occurrences for the [horizonDays] days from [today].
  ///
  /// Nothing is planned once [remaining] is zero. Suggested days skip
  /// Ramadan, the Eids, Tashreeq and days already in [fastedDays]; a day
  /// that is a pace, weekly or monthly day more than once is suggested once,
  /// as a pace day.
  List<ReminderOccurrence> plan({
    required QadaReminderSettings settings,
    required int remaining,
    required Set<DateTime> fastedDays,
    required DateTime today,
    required int horizonDays,
  }) {
    if (remaining <= 0) return const [];
    final pace = settings.paceEnabled
        ? _paceDays(remaining, fastedDays, today, horizonDays, settings.time)
        : const <QadaOccurrence>[];
    final paceDates = {for (final o in pace) o.date};
    return [
      ...pace,
      for (final occurrence in _suggestedDays(
        settings,
        remaining,
        fastedDays,
        today,
        horizonDays,
      ))
        if (!paceDates.contains(occurrence.date)) occurrence,
      ..._countdowns(settings, remaining, today, horizonDays),
    ];
  }

  /// The days the suggested pace plans inside the horizon. Planned up to
  /// Ramadan and re-planned on every sync, so it adapts to the balance.
  List<QadaOccurrence> _paceDays(
    int remaining,
    Set<DateTime> fastedDays,
    DateTime today,
    int horizonDays,
    QadaReminderTime time,
  ) {
    final pace = _pace.plan(
      remaining: remaining,
      fastedDays: fastedDays,
      today: today,
    );
    if (pace == null) return const [];
    return [
      for (final date in pace.days)
        if (CalendarDays.between(today, date) < horizonDays)
          QadaOccurrence(
            date: date,
            timing: time.timing,
            remaining: remaining,
            pace: pace.rate,
          ),
    ];
  }

  /// The weekly and monthly days.
  List<QadaOccurrence> _suggestedDays(
    QadaReminderSettings settings,
    int remaining,
    Set<DateTime> fastedDays,
    DateTime today,
    int horizonDays,
  ) => [
    for (var offset = 0; offset < horizonDays; offset++)
      if (_calendar.dayInfo(CalendarDays.addDays(today, offset))
          case final info?
          when ((settings.weeklyEnabled &&
                      settings.weekdays.contains(info.date.weekday)) ||
                  (settings.monthlyEnabled &&
                      info.hijri.day == settings.monthlyHijriDay)) &&
              !fastedDays.contains(info.date) &&
              // Checked as of the day itself: only Ramadan and the forbidden
              // days are ruled out, not the future.
              FastLogRules.canMakeUp(
                date: info.date,
                hijri: info.hijri,
                today: info.date,
              ))
        QadaOccurrence(
          date: info.date,
          timing: settings.time.timing,
          remaining: remaining,
        ),
  ];

  List<RamadanCountdownOccurrence> _countdowns(
    QadaReminderSettings settings,
    int remaining,
    DateTime today,
    int horizonDays,
  ) {
    final todayInfo = _calendar.dayInfo(today);
    final ramadan = todayInfo == null
        ? null
        : nextRamadanStart(_calendar, todayInfo.hijri);
    if (!settings.beforeRamadanEnabled || ramadan == null) return const [];
    return [
      for (final daysBefore in settings.daysBeforeRamadan)
        if (CalendarDays.addDays(ramadan, -daysBefore) case final date
            when CalendarDays.between(today, date) >= 0 &&
                CalendarDays.between(today, date) < horizonDays)
          RamadanCountdownOccurrence(
            date: date,
            timing: ReminderTiming(
              daysBefore: 0,
              time: settings.time.timing.time,
            ),
            daysUntilRamadan: daysBefore,
            remaining: remaining,
          ),
    ];
  }
}
