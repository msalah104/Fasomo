import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class InMemoryReminderRepository implements ReminderRepository {
  new(this.reminders);

  List<Reminder> reminders;
  StorageFailure? failure;
  bool permissionAsked = false;

  @override
  Result<List<Reminder>, StorageFailure> getReminders() =>
      failure == null ? Ok(reminders) : Err(failure!);

  @override
  Future<Result<void, StorageFailure>> saveReminder(Reminder reminder) async {
    reminders = [
      for (final r in reminders)
        if (r.id != reminder.id) r,
      reminder,
    ];
    return const Ok(null);
  }

  @override
  bool wasPermissionAsked() => permissionAsked;

  @override
  Future<Result<void, StorageFailure>> markPermissionAsked() async {
    permissionAsked = true;
    return const Ok(null);
  }
}
