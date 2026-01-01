import '../../../../core/usecases/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class GetReminders implements UseCase<List<Reminder>, NoParams> {
  final ReminderRepository repository;

  GetReminders(this.repository);

  @override
  List<Reminder> call(NoParams params) {
    return repository.getReminders();
  }
}
