import '../../../../core/usecases/usecase.dart';
import '../repositories/reminder_repository.dart';

class DeleteReminder implements UseCase<Future<void>, String> {
  final ReminderRepository repository;

  DeleteReminder(this.repository);

  @override
  Future<void> call(String params) {
    return repository.deleteReminder(params);
  }
}
