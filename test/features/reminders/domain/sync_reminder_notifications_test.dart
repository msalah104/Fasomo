import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_reconciler.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:fasomo/features/reminders/domain/usecases/sync_reminder_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_notification_gateway.dart';
import '../../../helpers/test_copy.dart';

class InMemoryReminderRepository implements ReminderRepository {
  new(this.reminders);

  List<Reminder> reminders;
  StorageFailure? failure;

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
  Future<Result<void, StorageFailure>> deleteReminder(String id) async {
    reminders = [
      for (final r in reminders)
        if (r.id != id) r,
    ];
    return const Ok(null);
  }
}

void main() {
  const calendar = FastingCalendar(UmmAlQuraHijriConverter());
  const whiteDays = Reminder(
    fastingType: FastingType.whiteDays,
    isEnabled: true,
  );
  const monThu = Reminder(
    fastingType: FastingType.mondayThursday,
    isEnabled: true,
    reminderTime: ReminderTime.morningOfDay,
  );

  FastingDayInfo day(DateTime date, List<FastingType> types) => FastingDayInfo(
    date: date,
    hijri: const HijriDate(1448, 6, 13),
    types: types,
  );

  group('buildRequests', () {
    test('one request per fasting day with an enabled reminder', () {
      final requests = SyncReminderNotifications.buildRequests(
        days: [
          day(DateTime(2026, 11, 22), [FastingType.whiteDays]),
          day(DateTime(2026, 11, 26), [FastingType.mondayThursday]),
        ],
        reminders: const [whiteDays],
        copy: const TestCopy(),
      );
      expect(requests.single.fastingDate, DateTime(2026, 11, 22));
      expect(requests.single.title, 'whiteDays-1');
      expect(requests.single.body, 'body-whiteDays');
      expect(requests.single.timing, ReminderTiming.dayBefore);
    });

    test(
      'a day with several reminded types fires once, for the first type',
      () {
        final requests = SyncReminderNotifications.buildRequests(
          days: [
            day(DateTime(2026, 11, 23), [
              FastingType.whiteDays,
              FastingType.mondayThursday,
            ]),
          ],
          reminders: const [monThu, whiteDays],
          copy: const TestCopy(),
        );
        expect(requests.single.reminderId, 'whiteDays');
      },
    );

    test('falls through to a lower-priority type when the first has none', () {
      final requests = SyncReminderNotifications.buildRequests(
        days: [
          day(DateTime(2026, 11, 23), [
            FastingType.whiteDays,
            FastingType.mondayThursday,
          ]),
        ],
        reminders: [monThu, whiteDays.copyWith(isEnabled: false)],
        copy: const TestCopy(),
      );
      expect(requests.single.reminderId, 'mondayThursday');
      expect(requests.single.title, 'mondayThursday-0');
    });

    test('a custom message replaces the default body', () {
      final requests = SyncReminderNotifications.buildRequests(
        days: [
          day(DateTime(2026, 11, 22), [FastingType.whiteDays]),
        ],
        reminders: [whiteDays.withCustomMessage('Prepare suhoor')],
        copy: const TestCopy(),
      );
      expect(requests.single.body, 'Prepare suhoor');
    });
  });

  group('call', () {
    late FakeNotificationGateway gateway;
    late InMemoryReminderRepository repository;
    late DateTime now;

    SyncReminderNotifications sync() => SyncReminderNotifications(
      repository: repository,
      calendar: calendar,
      reconciler: NotificationReconciler(gateway),
      clock: Clock(() => now),
    );

    setUp(() {
      gateway = FakeNotificationGateway();
      repository = InMemoryReminderRepository([whiteDays]);
      now = DateTime(2026, 10, 28, 15);
    });

    test(
      'schedules the real White Days of next month, evening before',
      () async {
        await sync()(const TestCopy());
        expect(
          gateway.pending.values.map((n) => n.fireAt).toList()..sort(),
          [
            DateTime(2026, 11, 22, 20),
            DateTime(2026, 11, 23, 20),
            DateTime(2026, 11, 24, 20),
            DateTime(2026, 12, 21, 20),
            DateTime(2026, 12, 22, 20),
            DateTime(2026, 12, 23, 20),
          ],
        );
      },
    );

    test('a second run with the same input changes nothing', () async {
      await sync()(const TestCopy());
      gateway.clearLog();
      await sync()(const TestCopy());
      expect(gateway.scheduledIds, isEmpty);
      expect(gateway.cancelledIds, isEmpty);
    });

    test('editing the time reschedules at the new time', () async {
      await sync()(const TestCopy());
      repository.reminders = [
        whiteDays.copyWith(reminderTime: ReminderTime.morningOfDay),
      ];
      await sync()(const TestCopy());
      expect(
        gateway.pending.values.map((n) => n.fireAt.hour).toSet(),
        {7},
      );
    });

    test('disabling a reminder cancels its notifications', () async {
      await sync()(const TestCopy());
      repository.reminders = [whiteDays.copyWith(isEnabled: false)];
      await sync()(const TestCopy());
      expect(gateway.pending, isEmpty);
    });

    test('drops occurrences that have fired as time passes', () async {
      await sync()(const TestCopy());
      now = DateTime(2026, 11, 22, 21);
      await sync()(const TestCopy());
      expect(
        gateway.pending.values
            .map((n) => n.fireAt)
            .reduce(
              (a, b) => a.isBefore(b) ? a : b,
            ),
        DateTime(2026, 11, 23, 20),
      );
    });

    test(
      'returns the storage failure without touching notifications',
      () async {
        repository.failure = const StorageReadFailed('reminders');
        final result = await sync()(const TestCopy());
        expect(result, isA<Err<void, Failure>>());
        expect(gateway.scheduledIds, isEmpty);
      },
    );
  });
}
