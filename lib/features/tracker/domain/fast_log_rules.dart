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
}
