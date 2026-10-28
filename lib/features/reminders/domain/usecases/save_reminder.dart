import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class SaveReminder
    implements UseCase<Future<Result<void, StorageFailure>>, Reminder> {
  const new(this.repository);

  final ReminderRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(Reminder reminder) =>
      repository.saveReminder(reminder);
}
