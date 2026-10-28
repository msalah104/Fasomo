import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_rules.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/fast_log_rules.dart';

/// Derives streaks and totals from the set of fasted days. Pure: "today" is
/// passed in by the caller, which reads it from an injected clock.
class TrackerStats {
  const new(this._calendar);

  final FastingCalendar _calendar;

  /// The summary of [log] as of [today]. Returns empty totals when [today]
  /// is outside the supported calendar range.
  FastLogSummary summarize(FastLog log, DateTime today) {
    final fastedDays = log.fastedDays;
    final day = CalendarDays.dateOnly(today);
    final todayInfo = _calendar.dayInfo(day);
    final (current, longest) = _streaks(fastedDays, day);
    return FastLogSummary(
      fastedDays: Set.unmodifiable(fastedDays),
      makeUpDays: Set.unmodifiable(log.makeUpDays),
      missedRamadanDays: Set.unmodifiable(log.missedRamadanDays),
      qada: _qada(log, todayInfo?.hijri, day),
      canMakeUpToday:
          todayInfo != null &&
          FastLogRules.canMakeUp(date: day, hijri: todayInfo.hijri, today: day),
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

  /// Owed days per Ramadan, with the make-up fasts paying off the oldest
  /// year first.
  QadaSummary _qada(FastLog log, HijriDate? today, DateTime day) {
    final owedByYear = <int, int>{...log.extraOwed};
    for (final missed in log.missedRamadanDays) {
      if (_calendar.dayInfo(missed) case final info?) {
        owedByYear.update(info.hijri.year, (n) => n + 1, ifAbsent: () => 1);
      }
    }

    var unallocated = log.makeUpDays.length;
    final byYear = <QadaYear>[];
    for (final year in owedByYear.keys.toList()..sort()) {
      final owed = owedByYear[year]!;
      if (owed == 0) continue;
      final madeUp = unallocated < owed ? unallocated : owed;
      unallocated -= madeUp;
      byYear.add(
        QadaYear(
          hijriYear: year,
          owed: owed,
          madeUp: madeUp,
          extraOwed: log.extraOwed[year] ?? 0,
        ),
      );
    }

    return QadaSummary(
      owed: byYear.fold(0, (sum, year) => sum + year.owed),
      madeUp: log.makeUpDays.length,
      byYear: byYear,
      latestOwableYear: today == null
          ? null
          : today.month >= FastingRules.ramadan
          ? today.year
          : today.year - 1,
      daysUntilRamadan: today == null ? null : _daysUntilRamadan(today, day),
    );
  }

  int? _daysUntilRamadan(HijriDate today, DateTime day) {
    if (today.month == FastingRules.ramadan) return null;
    final year = today.month < FastingRules.ramadan
        ? today.year
        : today.year + 1;
    final ramadan = HijriMonth(year, FastingRules.ramadan);
    if (!_calendar.converter.supportsMonth(ramadan)) return null;
    final start = _calendar.converter.toGregorian(
      HijriDate(year, FastingRules.ramadan, 1),
    );
    return CalendarDays.between(day, start);
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
