import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/features/tracker/domain/fast_log_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 28, 14);
  const ordinary = HijriDate(1448, 5, 17);

  TrackerFailure? check(DateTime date, [HijriDate hijri = ordinary]) =>
      FastLogRules.whyNotLoggable(date: date, hijri: hijri, today: today);

  test('accepts today and past days', () {
    expect(check(DateTime(2026, 10, 28)), isNull);
    expect(check(DateTime(2026, 10, 28, 23, 59)), isNull);
    expect(check(DateTime(2025)), isNull);
  });

  test('rejects future days', () {
    expect(check(DateTime(2026, 10, 29)), isA<FutureDayNotLoggable>());
  });

  test('rejects the Eids and the days of Tashreeq', () {
    final past = DateTime(2026);
    expect(
      check(past, const HijriDate(1447, 10, 1)),
      isA<ForbiddenDayNotLoggable>(),
    );
    for (final day in [10, 11, 12, 13]) {
      expect(
        check(past, HijriDate(1447, 12, day)),
        isA<ForbiddenDayNotLoggable>(),
      );
    }
    expect(check(past, const HijriDate(1447, 12, 9)), isNull);
  });

  group('make-up fasts', () {
    TrackerFailure? makeUp(DateTime date, HijriDate hijri) =>
        FastLogRules.whyNotMakeUp(date: date, hijri: hijri, today: today);

    test('are allowed on past days outside Ramadan', () {
      expect(makeUp(DateTime(2026, 10, 27), ordinary), isNull);
    });

    test('are rejected in Ramadan, on Eid and in the future', () {
      final past = DateTime(2026, 3);
      expect(
        makeUp(past, const HijriDate(1447, 9, 12)),
        isA<RamadanDayNotMakeUp>(),
      );
      expect(
        makeUp(past, const HijriDate(1447, 10, 1)),
        isA<ForbiddenDayNotLoggable>(),
      );
      expect(
        makeUp(DateTime(2026, 10, 29), ordinary),
        isA<FutureDayNotLoggable>(),
      );
    });
  });

  group('missed days', () {
    TrackerFailure? missed(DateTime date, HijriDate hijri) =>
        FastLogRules.whyNotMissed(date: date, hijri: hijri, today: today);

    test('are Ramadan days up to today', () {
      expect(missed(DateTime(2026, 3), const HijriDate(1447, 9, 12)), isNull);
    });

    test('are rejected outside Ramadan and in the future', () {
      expect(missed(DateTime(2026, 10, 27), ordinary), isA<NotARamadanDay>());
      expect(
        missed(DateTime(2027, 2, 20), const HijriDate(1448, 9, 12)),
        isA<FutureDayNotLoggable>(),
      );
    });
  });
}
