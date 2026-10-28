import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';

/// The single write path for reminders.
abstract interface class ReminderRepository {
  Result<List<Reminder>, StorageFailure> getReminders();

  /// Inserts [reminder], or replaces the stored one with the same id.
  Future<Result<void, StorageFailure>> saveReminder(Reminder reminder);

  Future<Result<void, StorageFailure>> deleteReminder(String id);
}
