import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

/// Saves the reminder sound. Pending reminders keep their old sound until
/// the next notification sync replaces them.
class SaveNotificationTone
    implements UseCase<Future<Result<void, StorageFailure>>, NotificationTone> {
  const new(this.repository);

  final ReminderRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(NotificationTone tone) =>
      repository.saveNotificationTone(tone);
}
