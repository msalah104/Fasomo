import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calendar = FastingCalendar(UmmAlQuraHijriConverter());

  test('dayInfo combines both calendars and the rules', () {
    // 13 Jumada al-Akhirah 1448 is a Monday.
    final info = calendar.dayInfo(DateTime(2026, 11, 23, 18))!;
    expect(info.date, DateTime(2026, 11, 23));
    expect(info.hijri, const HijriDate(1448, 6, 13));
    expect(info.types, [FastingType.whiteDays, FastingType.mondayThursday]);
  });

  test('dayInfo is null outside the supported range', () {
    expect(calendar.dayInfo(DateTime(2080)), isNull);
  });

  test('fastingDaysFrom finds next month White Days and only fasting days', () {
    final days = calendar.fastingDaysFrom(DateTime(2026, 10, 28), days: 30);
    expect(
      days,
      everyElement(predicate<FastingDayInfo>((d) => d.isFastingDay)),
    );
    expect(
      days
          .where((d) => d.types.contains(FastingType.whiteDays))
          .map((d) => d.date),
      [DateTime(2026, 11, 23), DateTime(2026, 11, 24), DateTime(2026, 11, 25)],
    );
    expect(days.first.date, DateTime(2026, 10, 29)); // Thursday
  });

  test('fastingDaysFrom includes the start day', () {
    final days = calendar.fastingDaysFrom(DateTime(2026, 10, 29), days: 1);
    expect(days.single.date, DateTime(2026, 10, 29));
  });

  test('month lists every day in order with matching Gregorian dates', () {
    final days = calendar.month(const HijriMonth(1447, 12))!;
    expect(days, hasLength(29));
    expect(days.first.date, DateTime(2026, 5, 18));
    expect(days[8].types, [FastingType.arafah]);
    for (var i = 0; i < days.length; i++) {
      expect(days[i].hijri.day, i + 1);
    }
  });

  test('month is null for an unsupported month', () {
    expect(calendar.month(const HijriMonth(1600, 1)), isNull);
  });
}
