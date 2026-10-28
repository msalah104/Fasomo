import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_reconciler.dart';
import 'package:fasomo/core/notifications/scheduled_notification.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_notification_gateway.dart';

ScheduledNotification notification(int id) => ScheduledNotification(
  id: id,
  fireAt: DateTime(2026, 11, id),
  title: 't',
  body: 'b',
  payload: 'p',
);

void main() {
  late FakeNotificationGateway gateway;
  late NotificationReconciler reconciler;

  setUp(() {
    gateway = FakeNotificationGateway();
    reconciler = NotificationReconciler(gateway);
  });

  test('schedules everything into an empty pending set', () async {
    await reconciler.reconcile([notification(1), notification(2)]);
    expect(gateway.pending.keys, unorderedEquals([1, 2]));
  });

  test('is a no-op when nothing changed', () async {
    await reconciler.reconcile([notification(1), notification(2)]);
    gateway.clearLog();

    await reconciler.reconcile([notification(1), notification(2)]);

    expect(gateway.scheduledIds, isEmpty);
    expect(gateway.cancelledIds, isEmpty);
  });

  test('cancels stale ids and schedules only new ones', () async {
    await reconciler.reconcile([notification(1), notification(2)]);
    gateway.clearLog();

    await reconciler.reconcile([notification(2), notification(3)]);

    expect(gateway.cancelledIds, [1]);
    expect(gateway.scheduledIds, [3]);
    expect(gateway.pending.keys, unorderedEquals([2, 3]));
  });

  test('an empty desired set clears the pending set', () async {
    await reconciler.reconcile([notification(1)]);
    await reconciler.reconcile([]);
    expect(gateway.pending, isEmpty);
  });

  test('returns the gateway failure', () async {
    gateway.failWith = const NotificationPlatformFailed('getPending');
    final result = await reconciler.reconcile([notification(1)]);
    expect(result, isA<Err<void, NotificationFailure>>());
  });
}
