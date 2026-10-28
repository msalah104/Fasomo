import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('between', () {
    test('counts calendar days, not 24-hour periods', () {
      // 23:30 to 00:15 the next day is less than an hour but one day.
      expect(
        CalendarDays.between(
          DateTime(2026, 10, 28, 23, 30),
          DateTime(2026, 10, 29, 0, 15),
        ),
        1,
      );
      expect(
        CalendarDays.between(
          DateTime(2026, 10, 28, 0, 15),
          DateTime(2026, 10, 28, 23, 30),
        ),
        0,
      );
    });

    test('is unaffected by daylight-saving transitions', () {
      // Spans the March and October changes in Europe and North America.
      expect(
        CalendarDays.between(DateTime(2026, 3, 7), DateTime(2026, 3, 31)),
        24,
      );
      expect(
        CalendarDays.between(DateTime(2026, 10, 24), DateTime(2026, 11, 2)),
        9,
      );
    });

    test('is negative for earlier dates and crosses years', () {
      expect(
        CalendarDays.between(DateTime(2027, 1, 2), DateTime(2026, 12, 30)),
        -3,
      );
    });
  });

  test('addDays keeps local midnight across month ends and DST', () {
    expect(
      CalendarDays.addDays(DateTime(2026, 3, 28), 2),
      DateTime(2026, 3, 30),
    );
    expect(CalendarDays.addDays(DateTime(2026, 12, 31), 1), DateTime(2027));
    expect(CalendarDays.addDays(DateTime(2026, 3), -1), DateTime(2026, 2, 28));
  });

  test('dateOnly and isSameDay', () {
    expect(
      CalendarDays.dateOnly(DateTime(2026, 5, 4, 13, 7)),
      DateTime(2026, 5, 4),
    );
    expect(
      CalendarDays.isSameDay(DateTime(2026, 5, 4, 1), DateTime(2026, 5, 4, 23)),
      isTrue,
    );
    expect(
      CalendarDays.isSameDay(DateTime(2026, 5, 4), DateTime(2026, 5, 5)),
      isFalse,
    );
  });
}
