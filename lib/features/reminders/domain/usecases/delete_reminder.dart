import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class DeleteReminder implements UseCase<Future<void>, String> {
  new(this.repository);
  final ReminderRepository repository;

  @override
  Future<void> call(String params) {
    return repository.deleteReminder(params);
  }
}
