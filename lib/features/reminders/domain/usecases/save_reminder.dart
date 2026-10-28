import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class SaveReminder implements UseCase<Future<void>, Reminder> {
  new(this.repository);
  final ReminderRepository repository;

  @override
  Future<void> call(Reminder params) {
    return repository.saveReminder(params);
  }
}
