import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

class GetNotificationTone
    implements UseCase<Result<NotificationTone, StorageFailure>, NoParams> {
  const new(this.repository);

  final ReminderRepository repository;

  @override
  Result<NotificationTone, StorageFailure> call(NoParams params) =>
      repository.getNotificationTone();
}
