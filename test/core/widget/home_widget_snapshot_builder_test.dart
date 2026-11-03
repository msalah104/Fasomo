import 'package:fasomo/core/calendar/adjusted_hijri_converter.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/presentation/localized_home_widget_copy.dart';
import 'package:fasomo/core/widget/home_widget_copy.dart';
import 'package:fasomo/core/widget/home_widget_snapshot_builder.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Predictable widget text, so these tests check the computation only.
class _TestCopy implements HomeWidgetCopy {
  const new();

  @override
  bool get isRightToLeft => false;

  @override
  String hijriDate(HijriDate date) => '${date.day}/${date.month}/${date.year}';

  @override
  String gregorianDate(DateTime date) => '${date.month}-${date.day}';

  @override
  String nextFast(FastingType type, {required int daysUntil}) =>
      '${type.name}+$daysUntil';

  @override
  String get noUpcomingFast => 'none';

  @override
  String get openAppToUpdate => 'stale';
}

void main() {
  const builder = HomeWidgetSnapshotBuilder(
    FastingCalendar(UmmAlQuraHijriConverter()),
  );
  const copy = _TestCopy();

  group('next fasting day', () {
    test('counts the days to the next one, from each day', () {
      // Friday 10 Jumada al-Akhirah 1448; the White Days start on Monday 23.
      final snapshot = builder.build(
        today: DateTime(2026, 11, 20, 21, 30),
        copy: copy,
      );

      expect(snapshot.generatedFor, DateTime(2026, 11, 20));
      expect(snapshot.days.map((day) => day.date), [
        for (var day = 20; day < 27; day++) DateTime(2026, 11, day),
      ]);
      expect(snapshot.days.map((day) => day.nextFastText), [
        'whiteDays+3',
        'whiteDays+2',
        'whiteDays+1',
        'whiteDays+0',
        'whiteDays+0',
        'whiteDays+0',
        'mondayThursday+0',
      ]);
      expect(snapshot.days.map((day) => day.isFastingDay), [
        false,
        false,
        false,
        true,
        true,
        true,
        true,
      ]);
    });

    test('says tomorrow for the day before', () {
      // Wednesday; Thursday is the next fasting day.
      final snapshot = builder.build(
        today: DateTime(2026, 11, 18),
        copy: copy,
      );

      expect(snapshot.days.first.nextFastText, 'mondayThursday+1');
      expect(snapshot.days.first.isFastingDay, isFalse);
    });

    test('names the primary type of a day with several', () {
      // Monday 23 November is a White Day and a Monday.
      final day = builder
          .build(today: DateTime(2026, 11, 23), copy: copy)
          .days
          .first;

      expect(day.nextFastText, 'whiteDays+0');
    });

    test('says today on the Day of Arafah', () {
      final snapshot = builder.build(
        today: DateTime(2027, 5, 15, 8),
        copy: copy,
      );

      expect(snapshot.days.first.hijriText, '9/12/1448');
      expect(snapshot.days.first.nextFastText, 'arafah+0');
      // The Eid and Tashreeq come next, so the next fast is days away.
      expect(snapshot.days[1].nextFastText, 'whiteDays+4');
    });

    test('has none when no fasting day is left in the supported range', () {
      // 16 November 2077 is the last day of the Umm al-Qura table.
      final snapshot = builder.build(
        today: DateTime(2077, 11, 12),
        copy: copy,
      );

      expect(snapshot.days.map((day) => day.nextFastText), [
        'mondayThursday+3',
        'mondayThursday+2',
        'mondayThursday+1',
        'mondayThursday+0',
        'none',
      ]);
    });

    test('is empty, and so stale, outside the supported range', () {
      final snapshot = builder.build(today: DateTime(2080), copy: copy);

      expect(snapshot.days, isEmpty);
      expect(snapshot.staleText, 'stale');
    });
  });

  test('dayFor finds the entry for any time of a day', () {
    final snapshot = builder.build(today: DateTime(2026, 11, 20), copy: copy);

    expect(
      snapshot.dayFor(DateTime(2026, 11, 22, 23, 59))?.hijriText,
      '12/6/1448',
    );
    expect(snapshot.dayFor(DateTime(2026, 11, 27)), isNull);
  });

  test('applies the Hijri adjustment to the dates and the fasting days', () {
    const adjusted = HomeWidgetSnapshotBuilder(
      FastingCalendar(
        AdjustedHijriConverter(
          UmmAlQuraHijriConverter(),
          FixedHijriOffset(HijriOffset.plusOne),
        ),
      ),
    );

    // Sunday 22 November is 13 Jumada al-Akhirah with one day added.
    final day = adjusted
        .build(today: DateTime(2026, 11, 22), copy: copy)
        .days
        .first;

    expect(day.hijriText, '13/6/1448');
    expect(day.nextFastText, 'whiteDays+0');
    expect(day.isFastingDay, isTrue);
  });

  group('in the app languages', () {
    // The app's localization delegates do this before the first frame.
    setUpAll(initializeDateFormatting);

    Future<LocalizedHomeWidgetCopy> copyFor(String language) async =>
        LocalizedHomeWidgetCopy(
          await AppLocalizations.delegate.load(Locale(language)),
        );

    test('English', () async {
      final english = await copyFor('en');
      final days = builder
          .build(today: DateTime(2026, 11, 20), copy: english)
          .days;
      final arafah = builder
          .build(today: DateTime(2027, 5, 15), copy: english)
          .days
          .first;
      final wednesday = builder
          .build(today: DateTime(2026, 11, 18), copy: english)
          .days
          .first;

      expect(days.first.hijriText, '10 Jumada al-Akhirah 1448 AH');
      expect(days.first.gregorianText, 'Friday, November 20');
      expect(days.first.nextFastText, 'White Days in 3 days');
      expect(days[2].nextFastText, 'Tomorrow: White Days');
      expect(days[3].nextFastText, 'Today: White Days');
      expect(wednesday.nextFastText, 'Tomorrow: Monday & Thursday');
      expect(arafah.nextFastText, 'Today: Day of Arafah');
    });

    test('Arabic, with its plural forms and right-to-left flag', () async {
      final arabic = await copyFor('ar');
      final snapshot = builder.build(
        today: DateTime(2026, 11, 20),
        copy: arabic,
      );
      final days = snapshot.days;
      final arafah = builder
          .build(today: DateTime(2027, 5, 15), copy: arabic)
          .days
          .first;
      final wednesday = builder
          .build(today: DateTime(2026, 11, 18), copy: arabic)
          .days
          .first;

      expect(snapshot.isRightToLeft, isTrue);
      expect(snapshot.staleText, 'افتح فاصومو للتحديث');
      expect(days.first.hijriText, '10 جمادى الآخرة 1448 هـ');
      expect(days.first.nextFastText, 'الأيام البيض بعد 3 أيام');
      expect(days[1].nextFastText, 'الأيام البيض بعد يومين');
      expect(days[2].nextFastText, 'غداً: الأيام البيض');
      expect(days[3].nextFastText, 'اليوم: الأيام البيض');
      expect(wednesday.nextFastText, 'غداً: الاثنين والخميس');
      expect(arafah.nextFastText, 'اليوم: يوم عرفة');
    });

    test('English is left to right', () async {
      final snapshot = builder.build(
        today: DateTime(2026, 11, 20),
        copy: await copyFor('en'),
      );

      expect(snapshot.isRightToLeft, isFalse);
      expect(snapshot.staleText, 'Open Fasomo to update');
    });
  });
}
