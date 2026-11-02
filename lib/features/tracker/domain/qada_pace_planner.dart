import 'dart:math' as math;

import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/ramadan_dates.dart';
import 'package:fasomo/core/notifications/qada_pace_rate.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_pace.dart';
import 'package:fasomo/features/tracker/domain/fast_log_rules.dart';

/// Works out the suggested make-up pace: from the days owed and the days
/// left before the next Ramadan, how many make-up days a week it takes, and
/// which days. Pure and total: "today" is passed in by the caller.
///
/// - Days are planned from tomorrow (a make-up fast needs its intention
///   from the night before) up to the day before Ramadan.
/// - Only days a make-up fast is allowed on count: never Ramadan, an Eid or
///   Tashreeq, nor a day already fasted.
/// - Mondays and Thursdays come first, since a make-up fast on a Sunnah day
///   counts for both.
/// - With more days owed than available, every available day is suggested
///   and the rate says so honestly.
class QadaPacePlanner {
  const new(this._calendar);

  final FastingCalendar _calendar;

  /// The most days a week a [PerWeekPace] asks for; seven is every day.
  static const int _maxPerWeek = DateTime.daysPerWeek - 1;

  /// The pace for [remaining] days owed as of [today], or `null` when
  /// nothing is owed or the next Ramadan is outside the supported calendar.
  QadaPace? plan({
    required int remaining,
    required Set<DateTime> fastedDays,
    required DateTime today,
  }) {
    if (remaining <= 0) return null;
    final todayInfo = _calendar.dayInfo(today);
    if (todayInfo == null) return null;
    final ramadan = nextRamadanStart(_calendar, todayInfo.hijri);
    if (ramadan == null) return null;

    final first = CalendarDays.addDays(todayInfo.date, 1);
    final window = math.max(0, CalendarDays.between(first, ramadan));
    final available = _availableDays(first, window, fastedDays);
    final rate = rateFor(
      owed: remaining,
      availableDays: available.length,
      windowDays: window,
    );
    return QadaPace(
      rate: rate,
      days: switch (rate) {
        PerWeekPace(:final daysPerWeek) => _spread(
          available,
          first: first,
          perWeek: daysPerWeek,
          owed: remaining,
        ),
        EveryDayPace() || NotEnoughDaysPace() => available,
      },
      owed: remaining,
      availableDays: available.length,
      ramadanStart: ramadan,
    );
  }

  /// The pace for [owed] days with [availableDays] allowed days in a window
  /// of [windowDays] calendar days. Spreads over the whole window, so a
  /// week with an Eid in it doesn't raise the pace.
  static QadaPaceRate rateFor({
    required int owed,
    required int availableDays,
    required int windowDays,
  }) {
    if (owed > availableDays) return NotEnoughDaysPace(availableDays);
    if (owed == availableDays) return const EveryDayPace();
    // Less than a week left: the whole balance falls in this one week.
    final perWeek = windowDays < DateTime.daysPerWeek
        ? owed
        : (owed * DateTime.daysPerWeek / windowDays).ceil();
    return PerWeekPace(perWeek.clamp(1, _maxPerWeek));
  }

  List<DateTime> _availableDays(
    DateTime first,
    int window,
    Set<DateTime> fastedDays,
  ) => [
    for (var offset = 0; offset < window; offset++)
      if (_calendar.dayInfo(CalendarDays.addDays(first, offset))
          case final info?
          when !fastedDays.contains(info.date) &&
              // Checked as of the day itself: only Ramadan and the forbidden
              // days are ruled out, not the future.
              FastLogRules.canMakeUp(
                date: info.date,
                hijri: info.hijri,
                today: info.date,
              ))
        info.date,
  ];

  /// Up to [perWeek] days in each week counted from [first], Mondays and
  /// Thursdays first, until [owed] are chosen. Should a week come up short
  /// (an Eid in it), the rest come from the days left, earliest first.
  static List<DateTime> _spread(
    List<DateTime> available, {
    required DateTime first,
    required int perWeek,
    required int owed,
  }) {
    final weeks = <int, List<DateTime>>{};
    for (final day in available) {
      final week = CalendarDays.between(first, day) ~/ DateTime.daysPerWeek;
      weeks.putIfAbsent(week, () => []).add(day);
    }
    final chosen = <DateTime>{};
    for (final week in weeks.values) {
      if (chosen.length == owed) break;
      chosen.addAll(
        _sunnahFirst(week).take(math.min(perWeek, owed - chosen.length)),
      );
    }
    chosen.addAll(
      available.where((d) => !chosen.contains(d)).take(owed - chosen.length),
    );
    return chosen.toList()..sort();
  }

  static List<DateTime> _sunnahFirst(List<DateTime> days) => [
    ...days.where(_isMondayOrThursday),
    ...days.where((d) => !_isMondayOrThursday(d)),
  ];

  static bool _isMondayOrThursday(DateTime day) =>
      day.weekday == DateTime.monday || day.weekday == DateTime.thursday;
}
