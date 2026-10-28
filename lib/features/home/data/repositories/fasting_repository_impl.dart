import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';

class FastingRepositoryImpl implements FastingRepository {
  const new({required this.calendar, required this.clock});

  /// How far ahead to look. Monday/Thursday alone guarantee several fasting
  /// days in any 30-day window.
  static const int horizonDays = 30;

  final FastingCalendar calendar;
  final Clock clock;

  @override
  Result<HijriDateInfo, CalendarFailure> getCurrentHijriDate() {
    final today = calendar.dayInfo(clock.now());
    if (today == null) return Err(_outOfRange());
    return Ok(HijriDateInfo(hijriDate: today.hijri, gregorianDate: today.date));
  }

  @override
  Result<List<FastingDay>, CalendarFailure> getUpcomingFastingDays({
    int limit = 5,
  }) {
    final today = CalendarDays.dateOnly(clock.now());
    if (!calendar.converter.supportsGregorian(today)) return Err(_outOfRange());

    final days = calendar
        .fastingDaysFrom(today, days: horizonDays)
        .take(limit)
        .map(
          (info) => FastingDay(
            hijriDate: info.hijri,
            gregorianDate: info.date,
            types: info.types,
            daysUntil: CalendarDays.between(today, info.date),
          ),
        )
        .toList();
    return Ok(days);
  }

  CalendarFailure _outOfRange() => CalendarOutOfRange(
    minHijriYear: calendar.converter.minHijriYear,
    maxHijriYear: calendar.converter.maxHijriYear,
  );
}
