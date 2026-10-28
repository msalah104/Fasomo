import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/tracker_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = UmmAlQuraHijriConverter();
  const calendar = FastingCalendar(converter);
  const stats = TrackerStats(calendar);

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
      final summary = stats.summarize({}, DateTime(2026, 10, 28));
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

      final summary = stats.summarize(days.toSet(), today);

      expect(summary.currentStreak, 5);
      expect(summary.longestStreak, 5);
    });

    test('a missed fasting day before today resets the current streak', () {
      final today = DateTime(2026, 10, 28);
      final summary = stats.summarize({
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

      expect(stats.summarize(logged, today).currentStreak, 3);
      expect(stats.summarize({...logged, today}, today).currentStreak, 4);
    });

    test('a fasted ordinary day neither extends nor breaks a streak', () {
      final today = DateTime(2026, 10, 28);
      final summary = stats.summarize({
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
      final summary = stats.summarize({overlap.date}, overlap.date);

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

      final summary = stats.summarize(days.toSet(), to);

      expect(summary.currentStreak, days.length);
    });

    test('run through Ramadan and past Eid al-Fitr, which never breaks it', () {
      final from = gregorian(1447, 9, 25);
      final to = gregorian(1447, 10, 4);
      final days = fastingDays(from, to);
      // 1 Shawwal is forbidden, so it is not among the fasting days.
      expect(days, isNot(contains(gregorian(1447, 10, 1))));

      final summary = stats.summarize(days.toSet(), to);

      expect(summary.currentStreak, days.length);
      expect(summary.longestStreak, days.length);
    });

    test('a missed Ramadan day breaks the streak', () {
      final from = gregorian(1447, 9, 20);
      final to = gregorian(1447, 9, 29);
      final days = fastingDays(from, to)..remove(gregorian(1447, 9, 25));

      final summary = stats.summarize(days.toSet(), to);

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

      final month = stats.summarize(whiteDays.toSet(), today).month;

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
      final year = stats.summarize({}, today).year;

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
      final summary = stats.summarize({DateTime(2026, 10, 27)}, today);

      expect(summary.month.fastedDays, 0);
      expect(summary.isFasted(DateTime(2026, 10, 27, 15)), isTrue);
    });
  });
}
