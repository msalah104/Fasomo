import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Reminder survives a JSON round trip', () {
    const reminder = Reminder(
      fastingType: FastingType.whiteDays,
      isEnabled: true,
      reminderTime: ReminderTime.morningOfDay,
      customMessage: 'Fast tomorrow',
    );

    expect(Reminder.tryFromJson(reminder.toJson()), reminder);
  });
}
