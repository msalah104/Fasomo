import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';

/// The single write path for reminders.
abstract interface class ReminderRepository {
  /// One reminder per fasting type, in priority order. A type the user never
  /// changed is on, with the default timing.
  Result<List<Reminder>, StorageFailure> getReminders();

  /// Inserts [reminder], or replaces the stored one with the same id.
  Future<Result<void, StorageFailure>> saveReminder(Reminder reminder);

  /// Whether notification permission has been asked for before.
  bool wasPermissionAsked();

  /// Records that notification permission has been asked for, so the app
  /// doesn't prompt again on every launch.
  Future<Result<void, StorageFailure>> markPermissionAsked();
}
