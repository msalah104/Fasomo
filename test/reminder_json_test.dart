import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Reminder survives a JSON round trip', () {
    const reminder = Reminder(
      id: '1',
      fastingDay: 'FastingType.whiteDays',
      title: 'White Days',
      isEnabled: true,
      reminderTime: ReminderTime.morningOfDay,
      customMessage: 'Fast tomorrow',
    );

    expect(Reminder.fromJson(reminder.toJson()), reminder);
  });
}
