import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  const new({required this.calendar, required this.clock});

  final FastingCalendar calendar;
  final Clock clock;

  @override
  Result<HijriMonth, CalendarFailure> getCurrentMonth() {
    final today = calendar.dayInfo(clock.now());
    if (today == null) return Err(_outOfRange());
    return Ok(today.hijri.hijriMonth);
  }

  @override
  Result<List<CalendarDay>, CalendarFailure> getMonth(HijriMonth month) {
    final days = calendar.month(month);
    if (days == null) return Err(_outOfRange());

    final today = clock.now();
    return Ok([
      for (final day in days)
        CalendarDay(
          hijriDate: day.hijri,
          gregorianDate: day.date,
          isToday: CalendarDays.isSameDay(day.date, today),
          fastingTypes: day.types,
        ),
    ]);
  }

  CalendarFailure _outOfRange() => CalendarOutOfRange(
    minHijriYear: calendar.converter.minHijriYear,
    maxHijriYear: calendar.converter.maxHijriYear,
  );
}
