import 'package:fasomo/features/reminders/domain/entities/reminder.dart';

abstract class ReminderRepository {
  List<Reminder> getReminders();
  Future<void> saveReminder(Reminder reminder);
  Future<void> deleteReminder(String id);
  Future<void> updateReminder(Reminder reminder);
}
