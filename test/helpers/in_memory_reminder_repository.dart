import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class InMemoryReminderRepository
    implements ReminderRepository, NotificationToneSource {
  new(this.reminders);

  List<Reminder> reminders;
  StorageFailure? failure;
  bool permissionAsked = false;
  NotificationTone tone = NotificationTone.systemDefault;

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

  @override
  Result<NotificationTone, StorageFailure> getNotificationTone() => Ok(tone);

  @override
  Future<Result<void, StorageFailure>> saveNotificationTone(
    NotificationTone tone,
  ) async {
    this.tone = tone;
    return const Ok(null);
  }

  @override
  NotificationTone get notificationTone => tone;
}
