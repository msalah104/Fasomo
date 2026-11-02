import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/notifications/qada_pace_rate.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:fasomo/features/tracker/domain/qada_pace_planner.dart';
import 'package:fasomo/features/tracker/domain/qada_reminder_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = UmmAlQuraHijriConverter();
  const calendar = FastingCalendar(converter);
  const planner = QadaReminderPlanner(calendar, QadaPacePlanner(calendar));
  // Wednesday 28 October 2026, 17 Jumada al-Ula 1448.
  final today = DateTime(2026, 10, 28);

  DateTime gregorian(int year, int month, int day) =>
      converter.toGregorian(HijriDate(year, month, day));

  List<ReminderOccurrence> plan({
    QadaReminderSettings settings = QadaReminderSettings.defaults,
    int remaining = 4,
    Set<DateTime> fasted = const {},
    DateTime? from,
    int horizonDays = 60,
  }) => planner.plan(
    settings: settings,
    remaining: remaining,
    fastedDays: fasted,
    today: from ?? today,
    horizonDays: horizonDays,
  );

  List<DateTime> qadaDates(List<ReminderOccurrence> occurrences) => [
    for (final o in occurrences)
      if (o is QadaOccurrence) o.date,
  ];

  test('nothing is planned when nothing is owed', () {
    expect(plan(remaining: 0), isEmpty);
  });

  test('defaults: every Saturday plus the 13th of each Hijri month', () {
    final dates = qadaDates(plan());

    expect(dates.where((d) => d.weekday != DateTime.saturday), [
      gregorian(1448, 6, 13),
      gregorian(1448, 7, 13),
    ]);
    expect(dates.where((d) => d.weekday == DateTime.saturday), hasLength(9));
    expect(dates.first, DateTime(2026, 10, 31));
  });

  test('uses the chosen time and carries the balance', () {
    final first =
        plan(
              settings: QadaReminderSettings.defaults.copyWith(
                time: QadaReminderTime.morningOf,
              ),
            ).first
            as QadaOccurrence;
    expect(first.timing, ReminderTiming.morningOf);
    expect(first.remaining, 4);
  });

  test('skips a day already fasted', () {
    final dates = qadaDates(plan(fasted: {DateTime(2026, 10, 31)}));
    expect(dates, isNot(contains(DateTime(2026, 10, 31))));
  });

  test('a day that is weekly and monthly is suggested once', () {
    final thirteenth = gregorian(1448, 6, 13);
    final dates = qadaDates(
      plan(
        settings: QadaReminderSettings.defaults.copyWith(
          weekdays: {thirteenth.weekday},
        ),
      ),
    );
    expect(dates.where((d) => d == thirteenth), hasLength(1));
  });

  test('never suggests Ramadan or Eid', () {
    final every = QadaReminderSettings.defaults.copyWith(
      weekdays: {1, 2, 3, 4, 5, 6, 7},
    );
    final dates = qadaDates(
      plan(settings: every, from: gregorian(1448, 8, 25), horizonDays: 40),
    );
    final hijri = dates.map(converter.toHijri);

    expect(hijri.where((h) => h.month == 9), isEmpty);
    expect(hijri, isNot(contains(const HijriDate(1448, 10, 1))));
    expect(hijri.where((h) => h.month == 10), isNotEmpty);
  });

  test('counts down to Ramadan on each chosen day before it', () {
    final countdowns = [
      for (final o in plan(from: gregorian(1448, 8, 1)))
        if (o is RamadanCountdownOccurrence) o,
    ];
    final ramadan = gregorian(1448, 9, 1);

    expect(countdowns.map((c) => c.daysUntilRamadan).toSet(), {30, 7});
    for (final countdown in countdowns) {
      expect(
        ramadan.difference(countdown.date).inDays,
        countdown.daysUntilRamadan,
      );
      expect(countdown.timing.daysBefore, 0);
    }
  });

  test('switched-off kinds plan nothing', () {
    const off = QadaReminderSettings(
      weeklyEnabled: false,
      monthlyEnabled: false,
      beforeRamadanEnabled: false,
    );
    expect(plan(settings: off, from: gregorian(1448, 8, 1)), isEmpty);
  });

  group('suggested pace', () {
    const paceOnly = QadaReminderSettings(
      weeklyEnabled: false,
      monthlyEnabled: false,
      beforeRamadanEnabled: false,
      paceEnabled: true,
    );
    // Monday 2 November 2026: 6 days owed is 1 a week, on Thursdays.
    final monday = DateTime(2026, 11, 2);

    test('schedules the planned days with the pace', () {
      final occurrences = plan(
        settings: paceOnly,
        remaining: 6,
        from: monday,
      ).cast<QadaOccurrence>();

      expect(occurrences.map((o) => o.date), [
        DateTime(2026, 11, 5),
        DateTime(2026, 11, 12),
        DateTime(2026, 11, 19),
        DateTime(2026, 11, 26),
        DateTime(2026, 12, 3),
        DateTime(2026, 12, 10),
      ]);
      expect(occurrences.map((o) => o.pace).toSet(), {const PerWeekPace(1)});
      expect(occurrences.first.remaining, 6);
      expect(occurrences.first.timing, ReminderTiming.dayBefore);
    });

    test('only the days inside the horizon', () {
      final dates = qadaDates(
        plan(settings: paceOnly, remaining: 20, from: monday, horizonDays: 7),
      );
      expect(dates, [DateTime(2026, 11, 5)]);
    });

    test('a pace day that is also a weekly day is suggested once', () {
      final occurrences = plan(
        settings: paceOnly.copyWith(
          weeklyEnabled: true,
          weekdays: {DateTime.thursday, DateTime.saturday},
        ),
        remaining: 6,
        from: monday,
        horizonDays: 7,
      ).cast<QadaOccurrence>();

      expect(occurrences.map((o) => (o.date, o.pace)), [
        (DateTime(2026, 11, 5), const PerWeekPace(1)),
        (DateTime(2026, 11, 7), null),
      ]);
    });

    test('nothing when nothing is owed', () {
      expect(plan(settings: paceOnly, remaining: 0, from: monday), isEmpty);
    });

    test('off: weekly and monthly days carry no pace', () {
      final occurrences = plan().whereType<QadaOccurrence>();
      expect(occurrences.every((o) => o.pace == null), isTrue);
    });
  });
}
