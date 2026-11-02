import 'package:fasomo/core/calendar/adjusted_hijri_converter.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:flutter_test/flutter_test.dart';

/// An offset the test changes between conversions, like the saved setting.
class _MutableOffset implements HijriOffsetSource {
  @override
  HijriOffset hijriOffset = HijriOffset.none;
}

void main() {
  const base = UmmAlQuraHijriConverter();

  AdjustedHijriConverter adjustedBy(HijriOffset offset) =>
      AdjustedHijriConverter(base, FixedHijriOffset(offset));

  test('HijriOffset covers −2..+2 and nothing else', () {
    expect(HijriOffset.values.map((o) => o.days), [-2, -1, 0, 1, 2]);
    for (final offset in HijriOffset.values) {
      expect(HijriOffset.fromDays(offset.days), offset);
    }
    expect(HijriOffset.fromDays(3), isNull);
    expect(HijriOffset.fromDays(-3), isNull);
  });

  test('with no offset it agrees with the Umm al-Qura table', () {
    final converter = adjustedBy(HijriOffset.none);
    var day = DateTime(2026);
    for (var i = 0; i < 400; i++) {
      expect(converter.toHijri(day), base.toHijri(day));
      day = CalendarDays.addDays(day, 1);
    }
  });

  group('known dates move with the offset', () {
    // 1 Ramadan 1446 is Saturday 1 March 2025 in the table.
    final ramadanStart = DateTime(2025, 3);
    final cases = <HijriOffset, (DateTime, HijriDate)>{
      HijriOffset.plusOne: (DateTime(2025, 2, 28), const HijriDate(1446, 9, 1)),
      HijriOffset.plusTwo: (DateTime(2025, 2, 27), const HijriDate(1446, 9, 1)),
      HijriOffset.minusOne: (DateTime(2025, 3, 2), const HijriDate(1446, 9, 1)),
      HijriOffset.minusTwo: (DateTime(2025, 3, 3), const HijriDate(1446, 9, 1)),
    };

    for (final MapEntry(key: offset, value: (gregorian, hijri))
        in cases.entries) {
      test('${offset.days} days: 1 Ramadan 1446 is $gregorian', () {
        final converter = adjustedBy(offset);
        expect(converter.toGregorian(hijri), gregorian);
        expect(converter.toHijri(gregorian), hijri);
      });
    }

    test('+1 shows the table date one day ahead', () {
      expect(
        adjustedBy(HijriOffset.plusOne).toHijri(ramadanStart),
        const HijriDate(1446, 9, 2),
      );
    });

    test('−1 shows the table date one day behind, across a month boundary', () {
      expect(
        adjustedBy(HijriOffset.minusOne).toHijri(ramadanStart),
        const HijriDate(1446, 8, 29),
      );
    });
  });

  for (final offset in HijriOffset.values) {
    group('offset ${offset.days}', () {
      final converter = adjustedBy(offset);

      test('every day of 1447 round-trips at the start of the day', () {
        var date = converter.toGregorian(const HijriDate(1447, 1, 1));
        for (var month = 1; month <= 12; month++) {
          final length = converter.daysInMonth(HijriMonth(1447, month));
          expect(length, base.daysInMonth(HijriMonth(1447, month)));
          for (var day = 1; day <= length; day++) {
            final hijri = HijriDate(1447, month, day);
            final gregorian = converter.toGregorian(hijri);
            expect(gregorian, date, reason: '$hijri');
            // The start of its day, even where DST skips local midnight.
            expect(
              gregorian,
              CalendarDays.dateOnly(gregorian),
              reason: '$hijri',
            );
            expect(converter.toHijri(gregorian), hijri);
            date = CalendarDays.addDays(date, 1);
          }
        }
        expect(converter.toHijri(date), const HijriDate(1448, 1, 1));
      });

      test('moves the Gregorian day by exactly the offset', () {
        const hijri = HijriDate(1447, 12, 9);
        expect(
          CalendarDays.between(
            converter.toGregorian(hijri),
            base.toGregorian(hijri),
          ),
          offset.days,
        );
      });

      test('ignores the time of day', () {
        expect(
          converter.toHijri(DateTime(2025, 3, 1, 23, 59)),
          converter.toHijri(DateTime(2025, 3)),
        );
      });

      test('the supported range moves with the offset', () {
        final first = converter.toGregorian(const HijriDate(1356, 1, 1));
        final last = converter.toGregorian(const HijriDate(1500, 12, 30));
        expect(converter.supportsGregorian(first), isTrue);
        expect(converter.supportsGregorian(last), isTrue);
        expect(converter.toHijri(first), const HijriDate(1356, 1, 1));
        expect(converter.toHijri(last), const HijriDate(1500, 12, 30));
        expect(
          converter.supportsGregorian(CalendarDays.addDays(first, -1)),
          isFalse,
        );
        expect(
          converter.supportsGregorian(CalendarDays.addDays(last, 1)),
          isFalse,
        );
        expect(converter.minHijriYear, base.minHijriYear);
        expect(converter.maxHijriYear, base.maxHijriYear);
      });
    });
  }

  test('reads the offset on every conversion, so a change applies live', () {
    final offsets = _MutableOffset();
    final converter = AdjustedHijriConverter(base, offsets);
    final day = DateTime(2025, 3);

    expect(converter.toHijri(day), const HijriDate(1446, 9, 1));
    offsets.hijriOffset = HijriOffset.plusTwo;
    expect(converter.toHijri(day), const HijriDate(1446, 9, 3));
    offsets.hijriOffset = HijriOffset.minusOne;
    expect(converter.toHijri(day), const HijriDate(1446, 8, 29));
  });

  test('the fasting rules follow the adjusted dates', () {
    // Arafah 1447 is Tuesday 26 May 2026 in the table.
    final arafah = DateTime(2026, 5, 26);
    final earlier = FastingCalendar(adjustedBy(HijriOffset.plusOne));
    final later = FastingCalendar(adjustedBy(HijriOffset.minusOne));

    expect(
      earlier.dayInfo(CalendarDays.addDays(arafah, -1))?.types,
      contains(FastingType.arafah),
    );
    expect(earlier.dayInfo(arafah)?.types, isNot(contains(FastingType.arafah)));
    expect(
      later.dayInfo(CalendarDays.addDays(arafah, 1))?.types,
      contains(FastingType.arafah),
    );
    expect(
      later.month(const HijriMonth(1447, 12))?.first.date,
      CalendarDays.addDays(base.toGregorian(const HijriDate(1447, 12, 1)), 1),
    );
  });
}
