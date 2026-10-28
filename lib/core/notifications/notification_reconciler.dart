import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/scheduled_notification.dart';

/// Makes the OS pending set equal to the desired set: cancels stale ids and
/// schedules missing ones. Idempotent — running it twice changes nothing.
class NotificationReconciler {
  const new(this._gateway);

  final NotificationGateway _gateway;

  Future<Result<void, NotificationFailure>> reconcile(
    List<ScheduledNotification> desired,
  ) async {
    final Set<int> pending;
    switch (await _gateway.getPending()) {
      case Ok(:final value):
        pending = value;
      case Err(:final failure):
        return Err(failure);
    }

    final desiredIds = {for (final n in desired) n.id};
    for (final id in pending.difference(desiredIds)) {
      if (await _gateway.cancel(id) case Err(:final failure)) {
        return Err(failure);
      }
    }
    for (final notification in desired) {
      if (pending.contains(notification.id)) continue;
      if (await _gateway.schedule(notification) case Err(:final failure)) {
        return Err(failure);
      }
    }
    return const Ok(null);
  }
}
