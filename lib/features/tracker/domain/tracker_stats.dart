import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';

/// Derives streaks and totals from the set of fasted days. Pure: "today" is
/// passed in by the caller, which reads it from an injected clock.
class TrackerStats {
  const new(this._calendar);

  final FastingCalendar _calendar;

  /// The summary of [fastedDays] (local midnights) as of [today]. Returns
  /// empty totals when [today] is outside the supported calendar range.
  FastLogSummary summarize(Set<DateTime> fastedDays, DateTime today) {
    final day = CalendarDays.dateOnly(today);
    final todayInfo = _calendar.dayInfo(day);
    final (current, longest) = _streaks(fastedDays, day);
    return FastLogSummary(
      fastedDays: Set.unmodifiable(fastedDays),
      currentStreak: current,
      longestStreak: longest,
      month: todayInfo == null
          ? PeriodTotals.empty
          : _totals(
              _calendar.month(todayInfo.hijri.hijriMonth) ?? const [],
              fastedDays,
              day,
            ),
      year: todayInfo == null
          ? PeriodTotals.empty
          : _totals(
              [
                for (var month = 1; month <= todayInfo.hijri.month; month++)
                  ...?_calendar.month(HijriMonth(todayInfo.hijri.year, month)),
              ],
              fastedDays,
              day,
            ),
    );
  }

  /// Walks every fasting day from the first fasted day to [today]. A fasted
  /// day extends the run; a missed day before today ends it.
  (int current, int longest) _streaks(
    Set<DateTime> fastedDays,
    DateTime today,
  ) {
    if (fastedDays.isEmpty) return (0, 0);
    final first = fastedDays.reduce((a, b) => a.isBefore(b) ? a : b);
    final days = CalendarDays.between(first, today);

    var run = 0;
    var longest = 0;
    for (var offset = 0; offset <= days; offset++) {
      final info = _calendar.dayInfo(CalendarDays.addDays(first, offset));
      if (info == null || !info.isFastingDay) continue;
      if (fastedDays.contains(info.date)) {
        run++;
        if (run > longest) longest = run;
      } else if (offset < days) {
        run = 0;
      }
    }
    return (run, longest);
  }

  PeriodTotals _totals(
    List<FastingDayInfo> period,
    Set<DateTime> fastedDays,
    DateTime today,
  ) {
    final due = <FastingType, int>{};
    final fasted = <FastingType, int>{};
    var dueDays = 0;
    var fastedCount = 0;
    for (final info in period) {
      if (!info.isFastingDay || info.date.isAfter(today)) continue;
      final isFasted = fastedDays.contains(info.date);
      dueDays++;
      if (isFasted) fastedCount++;
      for (final type in info.types) {
        due.update(type, (n) => n + 1, ifAbsent: () => 1);
        if (isFasted) fasted.update(type, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    return PeriodTotals(
      fastedDays: fastedCount,
      dueDays: dueDays,
      byType: [
        for (final type in FastingType.values)
          if (due[type] case final count?)
            TypeTotal(type: type, fasted: fasted[type] ?? 0, due: count),
      ],
    );
  }
}
