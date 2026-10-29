import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

/// Asks for notification permission the first time the app runs, since every
/// reminder starts out on. Returns whether notifications may be shown, or
/// `null` when the user was already asked on an earlier launch.
class PromptNotificationPermissionOnce
    implements UseCase<Future<bool?>, NoParams> {
  const new({required this.repository, required this.permission});

  final ReminderRepository repository;
  final NotificationPermission permission;

  @override
  Future<bool?> call(NoParams params) async {
    if (repository.wasPermissionAsked()) return null;
    // Recorded before asking; if the write fails, the user is asked again
    // on the next launch rather than never.
    await repository.markPermissionAsked();
    return await permission.request();
  }
}
