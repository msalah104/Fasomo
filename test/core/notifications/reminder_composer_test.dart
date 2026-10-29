import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/reminder_composer.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_copy.dart';

void main() {
  final monday = DateTime(2026, 11, 2);
  final saturday = DateTime(2026, 10, 31);
  final fasting = FastingOccurrence(
    date: monday,
    timing: ReminderTiming.dayBefore,
    type: FastingType.mondayThursday,
  );
  QadaOccurrence qadaOn(DateTime date, {ReminderTiming? timing}) =>
      QadaOccurrence(
        date: date,
        timing: timing ?? ReminderTiming.morningOf,
        remaining: 4,
      );

  test('a fasting day alone keeps its own text', () {
    final request = ReminderComposer.compose([
      fasting,
    ], const TestCopy()).single;
    expect(request.reminderId, 'mondayThursday');
    expect(request.title, 'mondayThursday-1');
    expect(request.body, 'body-mondayThursday');
  });

  test('a make-up day alone is a Qada reminder', () {
    final request = ReminderComposer.compose([
      qadaOn(saturday),
    ], const TestCopy()).single;
    expect(request.reminderId, 'qada');
    expect(request.title, 'qada-0');
    expect(request.body, 'owe-4');
    expect(request.fireAt, DateTime(2026, 10, 31, 7));
  });

  test(
    "a fasting day that's also a make-up day merges, at the fasting time",
    () {
      final request = ReminderComposer.compose([
        fasting,
        qadaOn(monday),
      ], const TestCopy()).single;
      expect(request.reminderId, 'merged.mondayThursday');
      expect(request.title, 'mondayThursday+qada-1');
      expect(request.body, 'both-mondayThursday-owe-4');
      expect(request.fireAt, DateTime(2026, 11, 1, 20));
    },
  );

  test('a custom message still wins in a merged reminder', () {
    final request = ReminderComposer.compose([
      FastingOccurrence(
        date: monday,
        timing: ReminderTiming.dayBefore,
        type: FastingType.mondayThursday,
        customMessage: 'Sahoor!',
      ),
      qadaOn(monday),
    ], const TestCopy()).single;
    expect(request.body, 'Sahoor!');
  });

  group('Ramadan countdown', () {
    RamadanCountdownOccurrence countdownOn(DateTime date) =>
        RamadanCountdownOccurrence(
          date: date,
          timing: const ReminderTiming(
            daysBefore: 0,
            time: WallClockTime(20, 0),
          ),
          daysUntilRamadan: 30,
          remaining: 4,
        );

    test('fires on its own on a quiet day', () {
      final request = ReminderComposer.compose([
        countdownOn(DateTime(2026, 11, 4)),
      ], const TestCopy()).single;
      expect(request.reminderId, 'qada.ramadan.30');
      expect(request.title, 'ramadan-in-30');
      expect(request.body, 'countdown-30-owe-4');
    });

    test('joins a notification that fires the same day', () {
      // Monday's reminder fires on Sunday evening, as does the countdown.
      final requests = ReminderComposer.compose([
        fasting,
        countdownOn(DateTime(2026, 11)),
      ], const TestCopy());
      expect(requests.single.title, 'mondayThursday-1');
      expect(requests.single.body, 'body-mondayThursday\ncountdown-30-owe-4');
    });
  });
}
