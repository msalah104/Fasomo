import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class GetReminders
    implements UseCase<Result<List<Reminder>, StorageFailure>, NoParams> {
  const new(this.repository);

  final ReminderRepository repository;

  @override
  Result<List<Reminder>, StorageFailure> call(NoParams params) =>
      repository.getReminders();
}
