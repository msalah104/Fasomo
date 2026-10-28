import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = UmmAlQuraHijriConverter();

  group('known Umm al-Qura dates', () {
    final cases = <(DateTime, HijriDate)>[
      (DateTime(2025, 3), const HijriDate(1446, 9, 1)), // 1 Ramadan
      (DateTime(2025, 6, 5), const HijriDate(1446, 12, 9)), // Arafah
      (DateTime(2025, 6, 26), const HijriDate(1447, 1, 1)), // New Year
      (DateTime(2026, 3, 20), const HijriDate(1447, 10, 1)), // Eid al-Fitr
      (DateTime(2026, 5, 26), const HijriDate(1447, 12, 9)), // Arafah
    ];

    for (final (gregorian, hijri) in cases) {
      test('$gregorian <-> $hijri', () {
        expect(converter.toHijri(gregorian), hijri);
        expect(converter.toGregorian(hijri), gregorian);
      });
    }
  });

  test('ignores the time of day', () {
    expect(
      converter.toHijri(DateTime(2025, 3, 1, 23, 59)),
      const HijriDate(1446, 9, 1),
    );
  });

  test('every day of 1447 round-trips and months are 29 or 30 days', () {
    var date = converter.toGregorian(const HijriDate(1447, 1, 1));
    for (var month = 1; month <= 12; month++) {
      final length = converter.daysInMonth(HijriMonth(1447, month));
      expect(length, anyOf(29, 30));
      for (var day = 1; day <= length; day++) {
        final hijri = HijriDate(1447, month, day);
        expect(converter.toHijri(date), hijri);
        expect(converter.toGregorian(hijri), date);
        date = DateTime(date.year, date.month, date.day + 1);
      }
    }
    expect(converter.toHijri(date), const HijriDate(1448, 1, 1));
  });

  group('supported range', () {
    test('accepts the first and last table days', () {
      expect(converter.supportsGregorian(DateTime(1937, 3, 14)), isTrue);
      expect(converter.supportsGregorian(DateTime(2077, 11, 16)), isTrue);
    });

    test('rejects days outside the table', () {
      expect(converter.supportsGregorian(DateTime(1937, 3, 13)), isFalse);
      expect(converter.supportsGregorian(DateTime(2077, 11, 17)), isFalse);
      expect(converter.supportsMonth(const HijriMonth(1355, 12)), isFalse);
      expect(converter.supportsMonth(const HijriMonth(1501, 1)), isFalse);
    });

    test('the edge months convert', () {
      expect(converter.daysInMonth(const HijriMonth(1356, 1)), 29);
      expect(converter.daysInMonth(const HijriMonth(1500, 12)), 30);
    });
  });

  group('HijriMonth navigation', () {
    test('wraps across years', () {
      expect(const HijriMonth(1447, 12).next, const HijriMonth(1448, 1));
      expect(const HijriMonth(1448, 1).previous, const HijriMonth(1447, 12));
    });
  });
}
