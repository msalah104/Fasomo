import 'package:fasomo/core/calendar/adjusted_hijri_converter.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_rules.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/notifications/qada_pace_rate.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_pace.dart';
import 'package:fasomo/features/tracker/domain/qada_pace_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = UmmAlQuraHijriConverter();
  const planner = QadaPacePlanner(FastingCalendar(converter));
  // Monday 2 November 2026, 22 Jumada al-Ula 1448. Ramadan 1448 starts on
  // Monday 8 February 2027, so 3 November to 7 February is 97 days, none of
  // them an Eid or Tashreeq.
  final today = DateTime(2026, 11, 2);
  final ramadan = DateTime(2027, 2, 8);
  const daysBeforeRamadan = 97;

  DateTime gregorian(int year, int month, int day) =>
      converter.toGregorian(HijriDate(year, month, day));

  QadaPace plan(
    int owed, {
    DateTime? from,
    Set<DateTime> fasted = const {},
    QadaPacePlanner using = planner,
  }) => using.plan(remaining: owed, fastedDays: fasted, today: from ?? today)!;

  bool isMondayOrThursday(DateTime d) =>
      d.weekday == DateTime.monday || d.weekday == DateTime.thursday;

  group('nothing to plan', () {
    test('when nothing is owed', () {
      expect(planner.plan(remaining: 0, fastedDays: {}, today: today), isNull);
      expect(planner.plan(remaining: -2, fastedDays: {}, today: today), isNull);
    });

    test('when today or the next Ramadan is outside the calendar', () {
      // Dhul Hijjah 1500: the next Ramadan, 1501, is past the table.
      expect(
        planner.plan(remaining: 3, fastedDays: {}, today: DateTime(2077, 11)),
        isNull,
      );
      expect(
        planner.plan(remaining: 3, fastedDays: {}, today: DateTime(2090)),
        isNull,
      );
    });
  });

  group('the pace', () {
    test('6 days and 14 weeks left: 1 a week, on Thursdays', () {
      final pace = plan(6);

      expect(pace.rate, const PerWeekPace(1));
      expect(pace.owed, 6);
      expect(pace.availableDays, daysBeforeRamadan);
      expect(pace.ramadanStart, ramadan);
      expect(pace.next, DateTime(2026, 11, 5));
      expect(pace.days, [
        for (var week = 0; week < 6; week++)
          CalendarDays.addDays(DateTime(2026, 11, 5), week * 7),
      ]);
    });

    test('20 days: 2 a week, every one a Monday or a Thursday', () {
      final pace = plan(20);

      expect(pace.rate, const PerWeekPace(2));
      expect(pace.days, hasLength(20));
      expect(pace.days.every(isMondayOrThursday), isTrue);
    });

    test('40 days: 3 a week, never more in any week, all before Ramadan', () {
      final pace = plan(40);

      expect(pace.rate, const PerWeekPace(3));
      expect(pace.days, hasLength(40));
      expect(pace.days.toSet(), hasLength(40));
      expect(pace.days.last.isBefore(ramadan), isTrue);
      final first = CalendarDays.addDays(today, 1);
      final perWeek = <int, int>{};
      for (final day in pace.days) {
        final week = CalendarDays.between(first, day) ~/ 7;
        perWeek.update(week, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(perWeek.values.every((n) => n <= 3), isTrue);
    });

    test('exactly as many days as are left: every day', () {
      final pace = plan(daysBeforeRamadan);

      expect(pace.rate, const EveryDayPace());
      expect(pace.days, hasLength(daysBeforeRamadan));
      expect(pace.next, DateTime(2026, 11, 3));
      expect(pace.days.last, DateTime(2027, 2, 7));
    });

    test('more days owed than are left says so and plans every day', () {
      final pace = plan(100);

      expect(pace.rate, const NotEnoughDaysPace(daysBeforeRamadan));
      expect(pace.owed, 100);
      expect(pace.days, hasLength(daysBeforeRamadan));
      expect(pace.days.last.isBefore(ramadan), isTrue);
    });

    test('starts tomorrow, never today', () {
      expect(plan(daysBeforeRamadan).days, isNot(contains(today)));
    });

    test('skips a day already fasted', () {
      final pace = plan(6, fasted: {DateTime(2026, 11, 5)});

      expect(pace.availableDays, daysBeforeRamadan - 1);
      expect(pace.days, isNot(contains(DateTime(2026, 11, 5))));
      expect(pace.next, DateTime(2026, 11, 9));
    });

    test('re-planned as the balance changes', () {
      // Thursday 5 November was fasted and one day is paid off.
      final pace = plan(5, from: DateTime(2026, 11, 6));

      expect(pace.rate, const PerWeekPace(1));
      expect(pace.next, DateTime(2026, 11, 9));
      expect(pace.days, hasLength(5));
    });
  });

  group('little or no time left', () {
    final lastOfShaban = gregorian(1448, 8, 30);

    test('Ramadan tomorrow: no day is left', () {
      final pace = plan(4, from: lastOfShaban);

      expect(pace.rate, const NotEnoughDaysPace(0));
      expect(pace.days, isEmpty);
      expect(pace.next, isNull);
      expect(pace.ramadanStart, ramadan);
    });

    test('under a week left: the balance is this week', () {
      // 25 Sha'ban: 26 to 30 Sha'ban are left.
      final from = gregorian(1448, 8, 25);

      final two = plan(2, from: from);
      expect(two.rate, const PerWeekPace(2));
      expect(two.availableDays, 5);
      expect(two.days, hasLength(2));

      expect(plan(5, from: from).rate, const EveryDayPace());
      expect(plan(6, from: from).rate, const NotEnoughDaysPace(5));
    });
  });

  group('around Ramadan and the Eids', () {
    test('from inside Ramadan it aims at next Ramadan, after Eid', () {
      final pace = plan(400, from: gregorian(1448, 9, 20));
      final hijri = pace.days.map(converter.toHijri).toList();

      expect(pace.ramadanStart, gregorian(1449, 9, 1));
      expect(pace.rate, isA<NotEnoughDaysPace>());
      expect(hijri.first, const HijriDate(1448, 10, 2));
      expect(pace.days.last, CalendarDays.addDays(pace.ramadanStart, -1));
      expect(hijri.where((h) => h.month == FastingRules.ramadan), isEmpty);
      expect(hijri.where(FastingRules.isForbidden), isEmpty);
      expect(hijri, contains(const HijriDate(1448, 12, 9)));
      expect(hijri, contains(const HijriDate(1448, 12, 14)));
    });

    test('a week cut short by Eid al-Adha is made up from later days', () {
      // 1 Dhul Hijjah 1448: Eid and Tashreeq take four days of the second
      // week, so 6 a week can't all fit in it.
      final from = gregorian(1448, 12, 1);
      final available = plan(1000, from: from).availableDays;
      final pace = plan(available - 1, from: from);
      final hijri = pace.days.map(converter.toHijri);

      expect(pace.rate, const PerWeekPace(6));
      expect(pace.days, hasLength(available - 1));
      expect(pace.days.toSet(), hasLength(available - 1));
      expect(hijri.where(FastingRules.isForbidden), isEmpty);
    });
  });

  group('with a Hijri adjustment', () {
    QadaPacePlanner adjusted(HijriOffset offset) => QadaPacePlanner(
      FastingCalendar(
        AdjustedHijriConverter(converter, FixedHijriOffset(offset)),
      ),
    );

    test('a day later moon sighting: Ramadan a day later, one more day', () {
      final pace = plan(200, using: adjusted(HijriOffset.minusOne));

      expect(pace.ramadanStart, DateTime(2027, 2, 9));
      expect(pace.availableDays, daysBeforeRamadan + 1);
      expect(pace.days.last, DateTime(2027, 2, 8));
    });

    test('a day earlier: Ramadan a day earlier, one day fewer', () {
      final pace = plan(200, using: adjusted(HijriOffset.plusOne));

      expect(pace.ramadanStart, DateTime(2027, 2, 7));
      expect(pace.availableDays, daysBeforeRamadan - 1);
      expect(pace.days.last, DateTime(2027, 2, 6));
    });
  });

  group('rateFor', () {
    QadaPaceRate rate(int owed, int available, int window) =>
        QadaPacePlanner.rateFor(
          owed: owed,
          availableDays: available,
          windowDays: window,
        );

    test('spreads over the whole window', () {
      expect(rate(6, 140, 140), const PerWeekPace(1));
      expect(rate(21, 140, 140), const PerWeekPace(2));
      expect(rate(1, 2, 2), const PerWeekPace(1));
    });

    test('caps at 6 a week while some day is spare', () {
      expect(rate(13, 14, 14), const PerWeekPace(6));
    });

    test('every day only when every day is needed', () {
      expect(rate(3, 3, 3), const EveryDayPace());
      expect(rate(10, 10, 14), const EveryDayPace());
    });

    test('more owed than available, including no days at all', () {
      expect(rate(4, 3, 10), const NotEnoughDaysPace(3));
      expect(rate(1, 0, 0), const NotEnoughDaysPace(0));
    });
  });
}
