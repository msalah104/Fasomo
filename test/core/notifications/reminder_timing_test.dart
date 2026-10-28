import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fastingDay = DateTime(2026, 11, 23);

  test('day before fires at 20:00 the evening before', () {
    expect(
      ReminderTiming.dayBefore.fireTimeFor(fastingDay),
      DateTime(2026, 11, 22, 20),
    );
  });

  test('morning of fires at 07:00 on the fasting day', () {
    expect(
      ReminderTiming.morningOf.fireTimeFor(fastingDay),
      DateTime(2026, 11, 23, 7),
    );
  });

  test('custom timing uses its own day offset and wall-clock time', () {
    const sameDayDawn = ReminderTiming(
      daysBefore: 0,
      time: WallClockTime(4, 15),
    );
    const eveningBefore = ReminderTiming(
      daysBefore: 1,
      time: WallClockTime(21, 30),
    );
    expect(sameDayDawn.fireTimeFor(fastingDay), DateTime(2026, 11, 23, 4, 15));
    expect(
      eveningBefore.fireTimeFor(fastingDay),
      DateTime(2026, 11, 22, 21, 30),
    );
  });

  test('the day before the first of a month is the last of the previous', () {
    expect(
      ReminderTiming.dayBefore.fireTimeFor(DateTime(2027)),
      DateTime(2026, 12, 31, 20),
    );
    expect(
      ReminderTiming.dayBefore.fireTimeFor(DateTime(2028, 3)),
      DateTime(2028, 2, 29, 20), // leap year
    );
  });

  test('keeps the wall-clock hour on the day after a DST change', () {
    // 29 March 2026 is the EU spring-forward day; 30 March is the fasting day.
    final fire = ReminderTiming.dayBefore.fireTimeFor(DateTime(2026, 3, 30));
    expect((fire.day, fire.hour, fire.minute), (29, 20, 0));
  });
}
