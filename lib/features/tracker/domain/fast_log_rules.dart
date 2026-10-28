import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_rules.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';

/// Which days the fasting log accepts. Pure and total.
abstract final class FastLogRules {
  /// Why [date] (Hijri [hijri]) cannot be marked as fasted on [today], or
  /// `null` when it can: any day up to today on which fasting is allowed.
  static TrackerFailure? whyNotLoggable({
    required DateTime date,
    required HijriDate hijri,
    required DateTime today,
  }) {
    if (CalendarDays.between(today, date) > 0) {
      return const FutureDayNotLoggable();
    }
    if (FastingRules.isForbidden(hijri)) return const ForbiddenDayNotLoggable();
    return null;
  }

  static bool canLog({
    required DateTime date,
    required HijriDate hijri,
    required DateTime today,
  }) => whyNotLoggable(date: date, hijri: hijri, today: today) == null;

  /// Why [date] cannot be a make-up fast, or `null` when it can: any
  /// loggable day outside Ramadan.
  static TrackerFailure? whyNotMakeUp({
    required DateTime date,
    required HijriDate hijri,
    required DateTime today,
  }) {
    if (whyNotLoggable(date: date, hijri: hijri, today: today)
        case final failure?) {
      return failure;
    }
    if (hijri.month == FastingRules.ramadan) return const RamadanDayNotMakeUp();
    return null;
  }

  static bool canMakeUp({
    required DateTime date,
    required HijriDate hijri,
    required DateTime today,
  }) => whyNotMakeUp(date: date, hijri: hijri, today: today) == null;

  /// Why [date] cannot be marked as a missed Ramadan day, or `null` when it
  /// can: a Ramadan day up to today.
  static TrackerFailure? whyNotMissed({
    required DateTime date,
    required HijriDate hijri,
    required DateTime today,
  }) {
    if (CalendarDays.between(today, date) > 0) {
      return const FutureDayNotLoggable();
    }
    if (hijri.month != FastingRules.ramadan) return const NotARamadanDay();
    return null;
  }

  static bool canMarkMissed({
    required DateTime date,
    required HijriDate hijri,
    required DateTime today,
  }) => whyNotMissed(date: date, hijri: hijri, today: today) == null;
}
