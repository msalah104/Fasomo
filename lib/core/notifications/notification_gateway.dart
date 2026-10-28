import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_reconciler.dart'
    show NotificationReconciler;
import 'package:fasomo/core/notifications/scheduled_notification.dart';

/// The port to the OS notification scheduler. The OS pending set is a cache;
/// the stored reminders are the source of truth, and only
/// [NotificationReconciler] calls these operations.
abstract interface class NotificationGateway {
  Future<Result<void, NotificationFailure>> schedule(
    ScheduledNotification notification,
  );
  Future<Result<void, NotificationFailure>> cancel(int id);
  Future<Result<void, NotificationFailure>> cancelAll();

  /// Ids of the notifications currently pending in the OS.
  Future<Result<Set<int>, NotificationFailure>> getPending();
}

/// Asks the user for permission to show notifications.
abstract interface class NotificationPermission {
  /// Whether notifications may be shown after the request.
  Future<bool> request();
}
