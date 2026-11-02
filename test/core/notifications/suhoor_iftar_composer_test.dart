import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/notifications/reminder_composer.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_scheduler.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_copy.dart';

void main() {
  final day = DateTime(2027, 2, 19);
  final fajr = DateTime.utc(2027, 2, 19, 5, 16);
  final maghrib = DateTime.utc(2027, 2, 19, 17, 22);
  final suhoor = SuhoorIftarOccurrence(
    date: day,
    timing: const ReminderTiming(daysBefore: 0, time: WallClockTime(4, 31)),
    meal: FastingMeal.suhoor,
    prayerTime: fajr,
    minutesBefore: 45,
  );
  final iftar = SuhoorIftarOccurrence(
    date: day,
    timing: const ReminderTiming(daysBefore: 0, time: WallClockTime(17, 22)),
    meal: FastingMeal.iftar,
    prayerTime: maghrib,
    minutesBefore: 0,
  );

  test('each meal is its own notification at its own minute', () {
    final requests = ReminderComposer.compose([
      suhoor,
      iftar,
    ], const TestCopy());

    expect(requests.map((r) => r.reminderId), ['suhoor', 'iftar']);
    expect(requests.map((r) => r.title), ['suhoor-45', 'iftar-0']);
    expect(requests.first.body, 'fajr-${fajr.toIso8601String()}');
    expect(requests.last.body, 'maghrib-${maghrib.toIso8601String()}');
    expect(requests.first.fireAt, DateTime(2027, 2, 19, 4, 31));
    expect(requests.last.fireAt, DateTime(2027, 2, 19, 17, 22));
  });

  test('they never merge with a fasting reminder or host a countdown', () {
    final requests = ReminderComposer.compose([
      suhoor,
      FastingOccurrence(
        date: day,
        timing: ReminderTiming.morningOf,
        type: FastingType.ramadan,
      ),
      RamadanCountdownOccurrence(
        date: day,
        timing: ReminderTiming.morningOf,
        daysUntilRamadan: 7,
        remaining: 2,
      ),
    ], const TestCopy());

    final meal = requests.singleWhere((r) => r.reminderId == 'suhoor');
    expect(meal.body, 'fajr-${fajr.toIso8601String()}');
    final fasting = requests.singleWhere((r) => r.reminderId == 'ramadan');
    expect(fasting.body, contains('countdown-7-owe-2'));
  });

  test('a later sync with the same times keeps the same ids', () {
    List<int> ids() => ReminderScheduler.compute(
      requests: ReminderComposer.compose([suhoor, iftar], const TestCopy()),
      now: DateTime(2027, 2, 19),
      tone: NotificationTone.systemDefault,
    ).map((n) => n.id).toList();

    expect(ids(), ids());
    expect(ids().toSet(), hasLength(2));
  });
}
