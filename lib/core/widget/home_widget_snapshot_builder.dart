import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/widget/home_widget_copy.dart';
import 'package:fasomo/core/widget/home_widget_snapshot.dart';

/// Computes the [HomeWidgetSnapshot]. Pure and total: "today" is passed in
/// by the caller, which reads it from an injected clock.
final class HomeWidgetSnapshotBuilder {
  const new(this._calendar);

  /// How many days of entries a snapshot holds, starting today.
  static const int daysAhead = 7;

  /// How far from each day the next fasting day is looked for. Monday and
  /// Thursday alone guarantee one within any week outside the end of the
  /// supported range.
  static const int horizonDays = 30;

  final FastingCalendar _calendar;

  /// The snapshot for [today] (any time of that day) in [copy]'s language.
  HomeWidgetSnapshot build({
    required DateTime today,
    required HomeWidgetCopy copy,
  }) {
    final start = CalendarDays.dateOnly(today);
    // One pass covers every entry's look-ahead window.
    final fastingDays = _calendar.fastingDaysFrom(
      start,
      days: daysAhead + horizonDays,
    );
    final days = <HomeWidgetDay>[];
    for (var offset = 0; offset < daysAhead; offset++) {
      final info = _calendar.dayInfo(CalendarDays.addDays(start, offset));
      // The supported range ends; later days have no Hijri date either.
      if (info == null) break;
      final next = fastingDays.where(
        (day) => !day.date.isBefore(info.date),
      );
      final daysUntil = next.isEmpty
          ? null
          : CalendarDays.between(info.date, next.first.date);
      days.add(
        HomeWidgetDay(
          date: info.date,
          hijriText: copy.hijriDate(info.hijri),
          gregorianText: copy.gregorianDate(info.date),
          nextFastText: daysUntil == null || daysUntil >= horizonDays
              ? copy.noUpcomingFast
              : copy.nextFast(next.first.types.first, daysUntil: daysUntil),
          isFastingDay: info.isFastingDay,
        ),
      );
    }
    return HomeWidgetSnapshot(
      generatedFor: start,
      isRightToLeft: copy.isRightToLeft,
      days: days,
      staleText: copy.openAppToUpdate,
    );
  }
}
