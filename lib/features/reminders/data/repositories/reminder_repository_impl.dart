import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_data_source.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepositoryImpl({required this.localDataSource});

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
