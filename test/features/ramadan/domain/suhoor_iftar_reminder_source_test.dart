import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/repositories/suhoor_iftar_settings_repository.dart';
import 'package:fasomo/features/ramadan/domain/suhoor_iftar_reminder_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_location_repository.dart';
import '../../../helpers/fake_prayer_settings_repository.dart';

class _FakeSettings implements SuhoorIftarSettingsRepository {
  SuhoorIftarSettings settings = SuhoorIftarSettings.defaults;
  bool readFails = false;

  @override
  Result<SuhoorIftarSettings, StorageFailure> getSettings() => readFails
      ? const Err(StorageReadFailed('ramadan.reminders'))
      : Ok(settings);

  @override
  Future<Result<void, StorageFailure>> saveSettings(
    SuhoorIftarSettings settings,
  ) async {
    this.settings = settings;
    return const Ok(null);
  }
}

void main() {
  // 1 Ramadan 1448 is Monday 8 February 2027.
  final cairo = GeoPoint.fromCity(CityCatalog.byId('EG:Cairo')!);
  late _FakeSettings settings;
  late FakePrayerSettingsRepository prayer;
  late SuhoorIftarReminderSource source;

  setUp(() {
    settings = _FakeSettings();
    prayer = FakePrayerSettingsRepository();
    source = SuhoorIftarReminderSource(
      settings: settings,
      prayerSettings: prayer,
      locationRepository: FakeLocationRepository(cairo),
      calendar: const FastingCalendar(UmmAlQuraHijriConverter()),
    );
  });

  List<SuhoorIftarOccurrence> occurrences(DateTime today, int days) =>
      switch (source.occurrences(today: today, horizonDays: days)) {
        Ok(:final value) => value.cast<SuhoorIftarOccurrence>(),
        Err(:final failure) => fail('unexpected $failure'),
      };

  /// The local minute [utc] minus [minutes] falls on.
  DateTime localMinute(DateTime utc, int minutes) {
    final local = utc.subtract(Duration(minutes: minutes)).toLocal();
    return DateTime(
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    );
  }

  test('only Ramadan days by default, two reminders each', () {
    final result = occurrences(DateTime(2027, 2, 6), 5);

    expect(result, hasLength(6));
    expect(
      result.map((o) => CalendarDays.dateOnly(o.prayerTime)).toSet(),
      {DateTime(2027, 2, 8), DateTime(2027, 2, 9), DateTime(2027, 2, 10)},
    );
    expect(
      result.map((o) => o.meal),
      everyElement(isIn(FastingMeal.values)),
    );
  });

  test('suhoor 45 minutes before Fajr, iftar at Maghrib', () {
    final result = occurrences(DateTime(2027, 2, 8), 1);
    final times = PrayerSettings.defaults.timesOn(
      DateTime(2027, 2, 8),
      cairo,
      inRamadan: true,
    );

    final suhoor = result.singleWhere((o) => o.meal == FastingMeal.suhoor);
    expect(suhoor.prayerTime, times.fajr);
    expect(suhoor.minutesBefore, 45);
    expect(suhoor.fireAt, localMinute(times.fajr!, 45));

    final iftar = result.singleWhere((o) => o.meal == FastingMeal.iftar);
    expect(iftar.prayerTime, times.maghrib);
    expect(iftar.minutesBefore, 0);
    expect(iftar.fireAt, localMinute(times.maghrib!, 0));
  });

  test('uses the chosen lead times and the prayer settings', () {
    settings.settings = const SuhoorIftarSettings(
      suhoorMinutesBeforeFajr: 90,
      iftarMinutesBeforeMaghrib: 5,
    );
    prayer.settings = const PrayerSettings(method: CalculationMethod.isna);
    final result = occurrences(DateTime(2027, 2, 8), 1);
    final times = prayer.settings.timesOn(
      DateTime(2027, 2, 8),
      cairo,
      inRamadan: true,
    );

    expect(result.first.fireAt, localMinute(times.fajr!, 90));
    expect(result.last.fireAt, localMinute(times.maghrib!, 5));
  });

  test('a switched-off meal is left out', () {
    settings.settings = const SuhoorIftarSettings(suhoorEnabled: false);
    expect(
      occurrences(DateTime(2027, 2, 8), 3).map((o) => o.meal),
      everyElement(FastingMeal.iftar),
    );

    settings.settings = const SuhoorIftarSettings(
      suhoorEnabled: false,
      iftarEnabled: false,
    );
    expect(occurrences(DateTime(2027, 2, 8), 3), isEmpty);
  });

  test('other fasting days only when chosen', () {
    // Monday 2 and Thursday 5 November 2026; no White Days that week.
    final week = DateTime(2026, 11, 2);
    expect(occurrences(week, 7), isEmpty);

    settings.settings = const SuhoorIftarSettings(onOtherFastingDays: true);
    final result = occurrences(week, 7);
    expect(result, hasLength(4));
    expect(
      result.map((o) => CalendarDays.dateOnly(o.prayerTime)).toSet(),
      {DateTime(2026, 11, 2), DateTime(2026, 11, 5)},
    );
  });

  test('never on Eid', () {
    settings.settings = const SuhoorIftarSettings(onOtherFastingDays: true);
    // Eid al-Fitr 1448 is 9 March 2027.
    expect(
      occurrences(DateTime(2027, 3, 9), 1),
      isEmpty,
    );
  });

  test('unreadable reminder settings fail the sync', () {
    settings.readFails = true;
    expect(
      source.occurrences(today: DateTime(2027, 2, 8), horizonDays: 1),
      isA<Err<List<ReminderOccurrence>, Failure>>(),
    );
  });

  test('unreadable prayer settings use the defaults', () {
    prayer.readFails = true;
    expect(occurrences(DateTime(2027, 2, 8), 1), hasLength(2));
  });
}
