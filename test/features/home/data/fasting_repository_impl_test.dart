import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/home/data/repositories/fasting_repository_impl.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FastingRepositoryImpl repositoryAt(DateTime now) => FastingRepositoryImpl(
    calendar: const FastingCalendar(UmmAlQuraHijriConverter()),
    clock: Clock.fixed(now),
  );

  List<FastingDay> upcoming(
    FastingRepositoryImpl repository, {
    int limit = 5,
  }) => switch (repository.getUpcomingFastingDays(limit: limit)) {
    Ok(:final value) => value,
    Err() => fail('expected upcoming days'),
  };

  test("today's Hijri date comes from the injected clock", () {
    final result = repositoryAt(DateTime(2025, 3, 1, 9)).getCurrentHijriDate();
    switch (result) {
      case Ok(:final value):
        expect(value.hijriDate, const HijriDate(1446, 9, 1));
        expect(value.gregorianDate, DateTime(2025, 3));
      case Err():
        fail('expected today');
    }
  });

  test('daysUntil counts calendar days even late in the evening', () {
    // Wednesday 23:30: Thursday is 1 day away, Monday 5.
    final days = upcoming(repositoryAt(DateTime(2026, 10, 28, 23, 30)));
    expect(days.take(2).map((d) => d.daysUntil), [1, 5]);
    expect(days.first.gregorianDate, DateTime(2026, 10, 29));
  });

  test('today counts as 0 when it is a fasting day', () {
    final days = upcoming(repositoryAt(DateTime(2026, 10, 29, 8)));
    expect(days.first.daysUntil, 0);
  });

  test("includes next month's White Days", () {
    final days = upcoming(repositoryAt(DateTime(2026, 11, 20)), limit: 10);
    final white = days.where((d) => d.types.contains(FastingType.whiteDays));
    expect(white.map((d) => d.daysUntil), [3, 4, 5]);
    expect(white.first.primaryType, FastingType.whiteDays);
    expect(white.first.types, contains(FastingType.mondayThursday));
  });

  test('respects the limit', () {
    expect(
      upcoming(repositoryAt(DateTime(2026, 10, 28)), limit: 2),
      hasLength(2),
    );
  });

  test('is a typed failure outside the supported range', () {
    final repository = repositoryAt(DateTime(2090));
    expect(
      repository.getCurrentHijriDate(),
      isA<Err<HijriDateInfo, CalendarFailure>>(),
    );
    expect(
      repository.getUpcomingFastingDays(),
      isA<Err<List<FastingDay>, CalendarFailure>>(),
    );
  });
}
