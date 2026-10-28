import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const custom = ReminderTiming(daysBefore: 0, time: WallClockTime(4, 15));

  test('survives a JSON round trip', () {
    const reminder = Reminder(
      fastingType: FastingType.whiteDays,
      isEnabled: true,
      reminderTime: ReminderTime.custom,
      customTiming: custom,
      customMessage: 'Fast tomorrow',
    );
    expect(Reminder.tryFromJson(reminder.toJson()), reminder);
  });

  test('reads the pre-1.0 format', () {
    final reminder = Reminder.tryFromJson({
      'id': '1700000000000',
      'fastingDay': 'FastingType.mondayThursday',
      'title': 'Monday & Thursday',
      'isEnabled': true,
      'reminderTime': 'ReminderTime.custom',
      'customTime': '2024-01-01T05:30:00.000',
      'customMessage': null,
    });
    expect(reminder?.fastingType, FastingType.mondayThursday);
    expect(
      reminder?.timing,
      const ReminderTiming(daysBefore: 1, time: WallClockTime(5, 30)),
    );
  });

  test('rejects malformed data instead of throwing', () {
    expect(Reminder.tryFromJson('nope'), isNull);
    expect(
      Reminder.tryFromJson({'fastingType': 'unknown', 'isEnabled': true}),
      isNull,
    );
    expect(Reminder.tryFromJson({'fastingType': 'whiteDays'}), isNull);
  });

  test('ignores an out-of-range stored custom time', () {
    final reminder = Reminder.tryFromJson({
      'fastingType': 'whiteDays',
      'isEnabled': true,
      'customDaysBefore': 1,
      'customHour': 25,
      'customMinute': 0,
    });
    expect(reminder?.customTiming, Reminder.defaultCustomTiming);
  });

  test('timing follows the selected preset and keeps the custom choice', () {
    const reminder = Reminder(
      fastingType: FastingType.whiteDays,
      isEnabled: true,
      customTiming: custom,
    );
    expect(reminder.timing, ReminderTiming.dayBefore);
    expect(
      reminder.copyWith(reminderTime: ReminderTime.morningOfDay).timing,
      ReminderTiming.morningOf,
    );
    expect(reminder.copyWith(reminderTime: ReminderTime.custom).timing, custom);
  });

  test('the fasting type is the id', () {
    const reminder = Reminder(
      fastingType: FastingType.shawwal,
      isEnabled: false,
    );
    expect(reminder.id, 'shawwal');
  });
}
