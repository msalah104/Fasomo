import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/tracker_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = UmmAlQuraHijriConverter();
  const calendar = FastingCalendar(converter);
  const stats = TrackerStats(calendar);

  FastLogSummary summarizeFasted(Set<DateTime> days, DateTime today) =>
      stats.summarize(FastLog(fastedDays: days), today);

  DateTime gregorian(int year, int month, int day) =>
      converter.toGregorian(HijriDate(year, month, day));

  /// The fasting days from [from] to [to], both inclusive.
  List<DateTime> fastingDays(DateTime from, DateTime to) => [
    for (final info in calendar.fastingDaysFrom(
      from,
      days: CalendarDays.between(from, to) + 1,
    ))
      info.date,
  ];

  group('streaks', () {
    test('are zero for an empty log', () {
      final summary = summarizeFasted({}, DateTime(2026, 10, 28));
      expect(summary.currentStreak, 0);
      expect(summary.longestStreak, 0);
      expect(summary.isEmpty, isTrue);
    });

    // Wed 28 Oct 2026 is 17 Jumada al-Ula 1448. The fasting days before it
    // are Mon 19, Thu 22 and the White Days 24–26 (26 is also a Monday).
    test('count fasting days only, skipping the ordinary days between', () {
      final today = DateTime(2026, 10, 28);
      final days = fastingDays(DateTime(2026, 10, 19), DateTime(2026, 10, 27));
      expect(days, [
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 22),
        DateTime(2026, 10, 24),
        DateTime(2026, 10, 25),
        DateTime(2026, 10, 26),
      ]);

      final summary = summarizeFasted(days.toSet(), today);

      expect(summary.currentStreak, 5);
      expect(summary.longestStreak, 5);
    });

    test('a missed fasting day before today resets the current streak', () {
      final today = DateTime(2026, 10, 28);
      final summary = summarizeFasted({
        DateTime(2026, 10, 15),
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 22),
        DateTime(2026, 10, 24),
        DateTime(2026, 10, 25),
        // Missed Monday 26 October.
      }, today);

      expect(summary.currentStreak, 0);
      expect(summary.longestStreak, 5);
    });

    test('today does not break the streak before it is marked', () {
      // Thursday 29 October 2026 is a fasting day.
      final today = DateTime(2026, 10, 29);
      final logged = {
        DateTime(2026, 10, 24),
        DateTime(2026, 10, 25),
        DateTime(2026, 10, 26),
      };

      expect(summarizeFasted(logged, today).currentStreak, 3);
      expect(summarizeFasted({...logged, today}, today).currentStreak, 4);
    });

    test('a fasted ordinary day neither extends nor breaks a streak', () {
      final today = DateTime(2026, 10, 28);
      final summary = summarizeFasted({
        DateTime(2026, 10, 25),
        DateTime(2026, 10, 26),
        DateTime(2026, 10, 27), // Tuesday 16th, ordinary.
      }, today);

      expect(summary.currentStreak, 2);
    });

    test('a White Day on a Monday counts once', () {
      final overlap = calendar
          .fastingDaysFrom(DateTime(2026), days: 365)
          .firstWhere(
            (info) =>
                info.types.contains(FastingType.whiteDays) &&
                info.types.contains(FastingType.mondayThursday),
          );
      final summary = summarizeFasted({overlap.date}, overlap.date);

      expect(summary.currentStreak, 1);
      expect(summary.month.fastedDays, 1);
      final byType = {for (final t in summary.month.byType) t.type: t.fasted};
      expect(byType[FastingType.whiteDays], 1);
      expect(byType[FastingType.mondayThursday], 1);
    });

    test('run across a Hijri month boundary', () {
      final from = gregorian(1448, 4, 25);
      final to = gregorian(1448, 5, 5);
      final days = fastingDays(from, to);

      final summary = summarizeFasted(days.toSet(), to);

      expect(summary.currentStreak, days.length);
    });

    test('run through Ramadan and past Eid al-Fitr, which never breaks it', () {
      final from = gregorian(1447, 9, 25);
      final to = gregorian(1447, 10, 4);
      final days = fastingDays(from, to);
      // 1 Shawwal is forbidden, so it is not among the fasting days.
      expect(days, isNot(contains(gregorian(1447, 10, 1))));

      final summary = summarizeFasted(days.toSet(), to);

      expect(summary.currentStreak, days.length);
      expect(summary.longestStreak, days.length);
    });

    test('a missed Ramadan day breaks the streak', () {
      final from = gregorian(1447, 9, 20);
      final to = gregorian(1447, 9, 29);
      final days = fastingDays(from, to)..remove(gregorian(1447, 9, 25));

      final summary = summarizeFasted(days.toSet(), to);

      expect(summary.currentStreak, 4);
      expect(summary.longestStreak, 5);
    });
  });

  group('totals', () {
    test('count due days only up to today, per type', () {
      // 17 Jumada al-Ula 1448: the White Days (13–15) have passed.
      final today = DateTime(2026, 10, 28);
      final whiteDays = [
        for (final day in [13, 14]) gregorian(1448, 5, day),
      ];

      final month = summarizeFasted(whiteDays.toSet(), today).month;

      final white = month.byType.firstWhere(
        (t) => t.type == FastingType.whiteDays,
      );
      expect(
        white,
        const TypeTotal(type: FastingType.whiteDays, fasted: 2, due: 3),
      );
      final expectedDue = fastingDays(gregorian(1448, 5, 1), today).length;
      expect(month.dueDays, expectedDue);
      expect(month.fastedDays, 2);
    });

    test('the year covers every month so far', () {
      final today = DateTime(2026, 10, 28);
      final year = summarizeFasted({}, today).year;

      final white = year.byType.firstWhere(
        (t) => t.type == FastingType.whiteDays,
      );
      // Four full months of White Days, plus all three of month five.
      expect(white.due, 15);
      expect(white.fasted, 0);
      expect(
        year.byType.map((t) => t.type),
        isNot(contains(FastingType.ramadan)),
      );
    });

    test('a fasted ordinary day is not counted', () {
      final today = DateTime(2026, 10, 28);
      final summary = summarizeFasted({DateTime(2026, 10, 27)}, today);

      expect(summary.month.fastedDays, 0);
      expect(summary.isFasted(DateTime(2026, 10, 27, 15)), isTrue);
    });
  });

  group('make-up (Qada)', () {
    // Wed 28 Oct 2026 is 17 Jumada al-Ula 1448, before Ramadan 1448.
    final today = DateTime(2026, 10, 28);
    final missed1447 = {gregorian(1447, 9, 3), gregorian(1447, 9, 4)};

    test('owes the marked missed days plus the entered ones, per year', () {
      final qada = stats
          .summarize(
            FastLog(missedRamadanDays: missed1447, extraOwed: const {1446: 2}),
            today,
          )
          .qada;

      expect(qada.owed, 4);
      expect(qada.remaining, 4);
      expect(qada.byYear, const [
        QadaYear(hijriYear: 1446, owed: 2, madeUp: 0, extraOwed: 2),
        QadaYear(hijriYear: 1447, owed: 2, madeUp: 0, extraOwed: 0),
      ]);
      expect(qada.extraOwedFor(1446), 2);
      expect(qada.extraOwedFor(1447), 0);
    });

    test('make-up fasts pay off the oldest Ramadan first', () {
      final makeUps = {
        DateTime(2026, 10, 20),
        DateTime(2026, 10, 21),
        DateTime(2026, 10, 27),
      };
      final qada = stats
          .summarize(
            FastLog(
              fastedDays: makeUps,
              makeUpDays: makeUps,
              missedRamadanDays: missed1447,
              extraOwed: const {1446: 2},
            ),
            today,
          )
          .qada;

      expect(qada.byYear.map((y) => y.madeUp), [2, 1]);
      expect(qada.remaining, 1);
    });

    test('the balance never goes below zero', () {
      final makeUps = {DateTime(2026, 10, 20), DateTime(2026, 10, 21)};
      final qada = stats
          .summarize(
            FastLog(
              fastedDays: makeUps,
              makeUpDays: makeUps,
              extraOwed: const {1447: 1},
            ),
            today,
          )
          .qada;

      expect(qada.madeUp, 2);
      expect(qada.remaining, 0);
      expect(qada.byYear.single.madeUp, 1);
    });

    test('a make-up fast on a fasting day counts toward streak and totals', () {
      // Monday 26 October is also the 15th, a White Day.
      final monday = {DateTime(2026, 10, 26)};
      final summary = stats.summarize(
        FastLog(
          fastedDays: monday,
          makeUpDays: monday,
          extraOwed: const {1447: 1},
        ),
        today,
      );

      expect(summary.currentStreak, 1);
      expect(summary.month.fastedDays, 1);
      expect(summary.qada.remaining, 0);
      expect(summary.markFor(DateTime(2026, 10, 26)), DayMark.makeUp);
    });

    test('a missed Ramadan day is marked missed and breaks the streak', () {
      final summary = stats.summarize(
        FastLog(
          fastedDays: {gregorian(1447, 9, 2)},
          missedRamadanDays: {gregorian(1447, 9, 3)},
        ),
        gregorian(1447, 9, 4),
      );

      expect(summary.markFor(gregorian(1447, 9, 3)), DayMark.missed);
      expect(summary.currentStreak, 0);
      expect(summary.longestStreak, 1);
    });

    test('counts down to the next Ramadan, but not during it', () {
      final before = stats.summarize(FastLog.empty, today).qada;
      expect(
        before.daysUntilRamadan,
        CalendarDays.between(today, gregorian(1448, 9, 1)),
      );
      expect(before.latestOwableYear, 1447);

      final during = stats.summarize(FastLog.empty, gregorian(1447, 9, 10));
      expect(during.qada.daysUntilRamadan, isNull);
      expect(during.qada.latestOwableYear, 1447);
      expect(during.canMakeUpToday, isFalse);

      final after = stats.summarize(FastLog.empty, gregorian(1447, 10, 5));
      expect(
        after.qada.daysUntilRamadan,
        CalendarDays.between(gregorian(1447, 10, 5), gregorian(1448, 9, 1)),
      );
      expect(after.canMakeUpToday, isTrue);
    });
  });
}
