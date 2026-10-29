import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/fasting_reminder_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_reminder_repository.dart';

void main() {
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

  test('one occurrence per fasting day with an enabled reminder', () {
    final occurrences = FastingReminderSource.occurrencesFor(
      days: [
        day(DateTime(2026, 11, 22), [FastingType.whiteDays]),
        day(DateTime(2026, 11, 26), [FastingType.mondayThursday]),
      ],
      reminders: const [whiteDays],
    );
    expect(occurrences, [
      FastingOccurrence(
        date: DateTime(2026, 11, 22),
        timing: ReminderTiming.dayBefore,
        type: FastingType.whiteDays,
      ),
    ]);
  });

  test(
    'a day with several reminded types is announced once, for the first',
    () {
      final occurrences = FastingReminderSource.occurrencesFor(
        days: [
          day(DateTime(2026, 11, 23), [
            FastingType.whiteDays,
            FastingType.mondayThursday,
          ]),
        ],
        reminders: const [monThu, whiteDays],
      );
      expect(occurrences.single.type, FastingType.whiteDays);
    },
  );

  test('falls through to a lower-priority type when the first is off', () {
    final occurrences = FastingReminderSource.occurrencesFor(
      days: [
        day(DateTime(2026, 11, 23), [
          FastingType.whiteDays,
          FastingType.mondayThursday,
        ]),
      ],
      reminders: [monThu, whiteDays.copyWith(isEnabled: false)],
    );
    expect(occurrences.single.type, FastingType.mondayThursday);
    expect(occurrences.single.timing, ReminderTiming.morningOf);
  });

  test('carries the custom message', () {
    final occurrences = FastingReminderSource.occurrencesFor(
      days: [
        day(DateTime(2026, 11, 22), [FastingType.whiteDays]),
      ],
      reminders: [whiteDays.withCustomMessage('Prepare suhoor')],
    );
    expect(occurrences.single.customMessage, 'Prepare suhoor');
  });

  test('passes on a storage failure', () {
    final repository = InMemoryReminderRepository(const [whiteDays])
      ..failure = const StorageReadFailed('reminders');
    final source = FastingReminderSource(
      repository: repository,
      calendar: const FastingCalendar(UmmAlQuraHijriConverter()),
    );

    expect(
      source.occurrences(today: DateTime(2026, 10, 28), horizonDays: 60),
      isA<Err<List<ReminderOccurrence>, Failure>>(),
    );
  });
}
