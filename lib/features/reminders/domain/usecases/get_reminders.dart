import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class GetReminders implements UseCase<List<Reminder>, NoParams> {
  new(this.repository);
  final ReminderRepository repository;

  @override
  List<Reminder> call(NoParams params) {
    return repository.getReminders();
  }
}
