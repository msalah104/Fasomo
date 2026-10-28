import 'package:fasomo/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  new({required this.localDataSource});
  final ReminderLocalDataSource localDataSource;

  @override
  List<Reminder> getReminders() {
    return localDataSource.getReminders();
  }

  @override
  Future<void> saveReminder(Reminder reminder) {
    return localDataSource.saveReminder(reminder);
  }

  @override
  Future<void> deleteReminder(String id) {
    return localDataSource.deleteReminder(id);
  }

  @override
  Future<void> updateReminder(Reminder reminder) {
    return localDataSource.updateReminder(reminder);
  }
}
