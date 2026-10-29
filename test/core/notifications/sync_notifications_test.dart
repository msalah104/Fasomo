import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_reconciler.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_source.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/notifications/sync_notifications.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/fasting_reminder_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_notification_gateway.dart';
import '../../helpers/in_memory_reminder_repository.dart';
import '../../helpers/test_copy.dart';

void main() {
  const calendar = FastingCalendar(UmmAlQuraHijriConverter());
  const whiteDays = Reminder(
    fastingType: FastingType.whiteDays,
    isEnabled: true,
  );

  group('call', () {
    late FakeNotificationGateway gateway;
    late InMemoryReminderRepository repository;
    late DateTime now;
    late FakeSource qada;

    SyncNotifications sync() => SyncNotifications(
      sources: [
        FastingReminderSource(repository: repository, calendar: calendar),
        qada,
      ],
      reconciler: NotificationReconciler(gateway),
      clock: Clock(() => now),
    );

    setUp(() {
      gateway = FakeNotificationGateway();
      repository = InMemoryReminderRepository([whiteDays]);
      now = DateTime(2026, 10, 28, 15);
      qada = FakeSource();
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

    test(
      'merges a make-up day into the fasting reminder on that day',
      () async {
        qada.occurrences_ = [
          // 23 November is the first White Day.
          QadaOccurrence(
            date: DateTime(2026, 11, 23),
            timing: ReminderTiming.dayBefore,
            remaining: 3,
          ),
          QadaOccurrence(
            date: DateTime(2026, 11, 28),
            timing: ReminderTiming.dayBefore,
            remaining: 3,
          ),
        ];

        await sync()(const TestCopy());

        final byFire = {
          for (final n in gateway.pending.values) n.fireAt: n,
        };
        expect(byFire[DateTime(2026, 11, 22, 20)]!.title, 'whiteDays+qada-1');
        expect(
          byFire[DateTime(2026, 11, 22, 20)]!.body,
          'both-whiteDays-owe-3',
        );
        expect(byFire[DateTime(2026, 11, 27, 20)]!.title, 'qada-1');
        expect(gateway.pending, hasLength(7));
      },
    );

    test('a failing source changes nothing', () async {
      await sync()(const TestCopy());
      gateway.clearLog();
      qada.failure = const StorageReadFailed('qada_reminders');

      final result = await sync()(const TestCopy());

      expect(result, isA<Err<void, Failure>>());
      expect(gateway.cancelledIds, isEmpty);
      expect(gateway.pending, isNotEmpty);
    });
  });
}

/// A source that returns whatever the test sets.
class FakeSource implements ReminderSource {
  List<ReminderOccurrence> occurrences_ = [];
  Failure? failure;

  @override
  Result<List<ReminderOccurrence>, Failure> occurrences({
    required DateTime today,
    required int horizonDays,
  }) => failure == null ? Ok(occurrences_) : Err(failure!);
}
