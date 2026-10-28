import 'package:fasomo/core/calendar/fasting_rules.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const wednesday = DateTime.wednesday;

  List<FastingType> typesFor(int month, int day, [int weekday = wednesday]) =>
      FastingRules.typesFor(HijriDate(1447, month, day), weekday);

  test('an ordinary day has no fasting type', () {
    expect(typesFor(5, 20), isEmpty);
  });

  test('White Days are the 13th, 14th and 15th', () {
    expect(typesFor(5, 12), isEmpty);
    for (final day in [13, 14, 15]) {
      expect(typesFor(5, day), [FastingType.whiteDays]);
    }
    expect(typesFor(5, 16), isEmpty);
  });

  test('Monday and Thursday', () {
    expect(typesFor(5, 20, DateTime.monday), [FastingType.mondayThursday]);
    expect(typesFor(5, 20, DateTime.thursday), [FastingType.mondayThursday]);
    expect(typesFor(5, 20, DateTime.friday), isEmpty);
  });

  test('special days', () {
    expect(typesFor(12, 9), [FastingType.arafah]);
    expect(typesFor(1, 9), [FastingType.tasua]);
    expect(typesFor(1, 10), [FastingType.ashura]);
  });

  test('Six Days of Shawwal cover 2–30 Shawwal', () {
    expect(typesFor(10, 2), [FastingType.shawwal]);
    expect(typesFor(10, 30), [FastingType.shawwal]);
  });

  group('forbidden days', () {
    test('Eid al-Fitr', () {
      expect(typesFor(10, 1, DateTime.monday), isEmpty);
      expect(FastingRules.isForbidden(const HijriDate(1447, 10, 1)), isTrue);
    });

    test('Eid al-Adha and Tashreeq, even on a White Day or Monday', () {
      for (final day in [10, 11, 12, 13]) {
        expect(typesFor(12, day, DateTime.monday), isEmpty, reason: '$day');
      }
      expect(typesFor(12, 14), [FastingType.whiteDays]);
    });
  });

  test('Ramadan replaces every voluntary type', () {
    expect(typesFor(9, 13, DateTime.monday), [FastingType.ramadan]);
    expect(FastingType.ramadan.isObligatory, isTrue);
  });

  test('several types are sorted by priority', () {
    expect(typesFor(10, 13, DateTime.thursday), [
      FastingType.shawwal,
      FastingType.whiteDays,
      FastingType.mondayThursday,
    ]);
  });
}
