import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/scheduled_notification.dart';

/// In-memory OS pending set that records every call.
class FakeNotificationGateway implements NotificationGateway {
  final Map<int, ScheduledNotification> pending = {};
  final List<int> scheduledIds = [];
  final List<int> cancelledIds = [];

  /// When set, every call fails with this failure.
  NotificationFailure? failWith;

  @override
  Future<Result<void, NotificationFailure>> schedule(
    ScheduledNotification notification,
  ) async {
    if (failWith case final failure?) return Err(failure);
    pending[notification.id] = notification;
    scheduledIds.add(notification.id);
    return const Ok(null);
  }

  @override
  Future<Result<void, NotificationFailure>> cancel(int id) async {
    if (failWith case final failure?) return Err(failure);
    pending.remove(id);
    cancelledIds.add(id);
    return const Ok(null);
  }

  @override
  Future<Result<void, NotificationFailure>> cancelAll() async {
    if (failWith case final failure?) return Err(failure);
    cancelledIds.addAll(pending.keys);
    pending.clear();
    return const Ok(null);
  }

  @override
  Future<Result<Set<int>, NotificationFailure>> getPending() async {
    if (failWith case final failure?) return Err(failure);
    return Ok(pending.keys.toSet());
  }

  void clearLog() {
    scheduledIds.clear();
    cancelledIds.clear();
  }
}
