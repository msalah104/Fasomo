import '../../../../core/usecases/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class SaveReminder implements UseCase<Future<void>, Reminder> {
  final ReminderRepository repository;

  SaveReminder(this.repository);

  @override
  Future<void> call(Reminder params) {
    return repository.saveReminder(params);
  }
}
