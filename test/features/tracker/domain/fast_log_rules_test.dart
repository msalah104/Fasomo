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
}
