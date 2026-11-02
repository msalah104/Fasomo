import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_month.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = UmmAlQuraHijriConverter();
  // Wednesday 28 October 2026 is 17 Jumada al-Ula 1448.
  final repository = CalendarRepositoryImpl(
    calendar: const FastingCalendar(converter),
    clock: Clock.fixed(DateTime(2026, 10, 28, 10)),
  );

  group('getYear', () {
    late List<CalendarMonth> months;

    setUp(() {
      months = (repository.getYear(
        1448,
      ) as Ok<List<CalendarMonth>, CalendarFailure>).value;
    });

    test('is the twelve months in order, each with all its days', () {
      expect(months.map((m) => m.month), [
        for (var month = 1; month <= 12; month++) HijriMonth(1448, month),
      ]);
      for (final month in months) {
        expect(
          month.days.length,
          converter.daysInMonth(month.month),
          reason: '${month.month}',
        );
        expect(
          month.days.first.hijriDate,
          HijriDate(1448, month.month.month, 1),
        );
      }
    });

    test('marks only the month containing today', () {
      expect(
        [
          for (final month in months)
            if (month.containsToday) month.month,
        ],
        [const HijriMonth(1448, 5)],
      );
    });

    test('counts the fasting days of each month', () {
      final ramadan = months[8];
      expect(ramadan.fastingDayCount, ramadan.days.length);
      for (final month in months) {
        expect(
          month.fastingDayCount,
          month.days.where((day) => day.fastingTypes.isNotEmpty).length,
        );
        // At least the White Days and the Mondays and Thursdays.
        expect(month.fastingDayCount, greaterThanOrEqualTo(3));
      }
    });

    test('a year outside the supported range is a typed failure', () {
      expect(
        repository.getYear(converter.maxHijriYear + 1),
        isA<Err<List<CalendarMonth>, CalendarFailure>>().having(
          (err) => err.failure,
          'failure',
          isA<CalendarOutOfRange>(),
        ),
      );
    });
  });
}
