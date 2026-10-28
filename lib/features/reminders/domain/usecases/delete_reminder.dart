import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class DeleteReminder
    implements UseCase<Future<Result<void, StorageFailure>>, String> {
  const new(this.repository);

  final ReminderRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(String id) =>
      repository.deleteReminder(id);
}
