import 'package:fasomo/core/notifications/deterministic_id.dart';
import 'package:fasomo/core/notifications/reminder_scheduler.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:flutter_test/flutter_test.dart';

ReminderRequest request(
  DateTime fastingDate, {
  ReminderTiming timing = ReminderTiming.dayBefore,
  String title = 'Tomorrow: White Days',
  String body = 'Fast tomorrow',
}) => ReminderRequest(
  reminderId: 'whiteDays',
  fastingDate: fastingDate,
  timing: timing,
  title: title,
  body: body,
);

void main() {
  final now = DateTime(2026, 11, 1, 12);

  test('drops reminders whose fire time has passed', () {
    final result = ReminderScheduler.compute(
      requests: [
        request(DateTime(2026, 11)), // fired yesterday evening
        request(DateTime(2026, 11, 2)), // fires tonight
      ],
      now: now,
    );
    expect(result.map((n) => n.fireAt), [DateTime(2026, 11, 1, 20)]);
  });

  test('a reminder due exactly now is not scheduled', () {
    final result = ReminderScheduler.compute(
      requests: [request(DateTime(2026, 11, 2))],
      now: DateTime(2026, 11, 1, 20),
    );
    expect(result, isEmpty);
  });

  test('sorts by fire time and keeps only the nearest within budget', () {
    final requests = [
      for (var day = 30; day >= 2; day--) request(DateTime(2026, 11, day)),
    ];
    final result = ReminderScheduler.compute(
      requests: requests,
      now: now,
      budget: 5,
    );
    expect(result.map((n) => n.fireAt.day), [1, 2, 3, 4, 5]);
  });

  test('defaults to a budget below the iOS 64 pending cap', () {
    final requests = [
      for (var day = 0; day < 80; day++) request(DateTime(2026, 11, 2 + day)),
    ];
    final result = ReminderScheduler.compute(requests: requests, now: now);
    expect(result, hasLength(ReminderScheduler.defaultBudget));
    expect(ReminderScheduler.defaultBudget, lessThan(64));
  });

  test('carries text and a serializable payload', () {
    final n = ReminderScheduler.compute(
      requests: [request(DateTime(2026, 11, 2))],
      now: now,
    ).single;
    expect(n.title, 'Tomorrow: White Days');
    expect(n.body, 'Fast tomorrow');
    expect(n.payload, 'reminder/whiteDays/2026-11-02');
  });

  group('deterministic ids', () {
    int idFor(ReminderRequest r) =>
        ReminderScheduler.compute(requests: [r], now: now).single.id;

    test('are stable for the same input', () {
      expect(
        idFor(request(DateTime(2026, 11, 2))),
        idFor(request(DateTime(2026, 11, 2))),
      );
    });

    test('change when the fire time or the text changes', () {
      final base = idFor(request(DateTime(2026, 11, 2)));
      expect(
        idFor(request(DateTime(2026, 11, 2), timing: ReminderTiming.morningOf)),
        isNot(base),
      );
      expect(
        idFor(request(DateTime(2026, 11, 2), body: 'edited')),
        isNot(base),
      );
      expect(idFor(request(DateTime(2026, 11, 2), title: 'غداً')), isNot(base));
    });

    test('are unique and positive 31-bit ints across a year of reminders', () {
      final ids = <int>{};
      for (var day = 0; day < 366; day++) {
        for (final id in ['whiteDays', 'mondayThursday', 'shawwal']) {
          final value = DeterministicId.of([id, day, '20:00']);
          expect(value, inInclusiveRange(0, 0x7fffffff));
          ids.add(value);
        }
      }
      expect(ids, hasLength(366 * 3));
    });
  });
}
