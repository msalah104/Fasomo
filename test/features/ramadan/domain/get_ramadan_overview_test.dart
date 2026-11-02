import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/adjusted_hijri_converter.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_overview.dart';
import 'package:fasomo/features/ramadan/domain/usecases/get_ramadan_overview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_location_repository.dart';
import '../../../helpers/fake_prayer_settings_repository.dart';

void main() {
  // 1 Ramadan 1448 is 8 February 2027 by Umm al-Qura, and the month has
  // 29 days (Eid on 9 March). London's winter time is UTC.
  final london = GeoPoint.fromCity(CityCatalog.byId('GB:London')!);
  late FakePrayerSettingsRepository settings;

  setUp(() => settings = FakePrayerSettingsRepository());

  RamadanOverview overviewAt(
    DateTime now, {
    HijriOffset offset = HijriOffset.none,
    GeoPoint? location,
  }) => GetRamadanOverview(
    calendar: FastingCalendar(
      AdjustedHijriConverter(
        const UmmAlQuraHijriConverter(),
        FixedHijriOffset(offset),
      ),
    ),
    prayerSettings: settings,
    locationRepository: FakeLocationRepository(location ?? london),
    clock: Clock.fixed(now),
  )(const NoParams());

  group('before Ramadan', () {
    test('nothing more than 30 days ahead', () {
      expect(overviewAt(DateTime(2026, 11, 2, 9)), const RamadanNotNear());
      expect(overviewAt(DateTime(2027, 1, 8, 9)), const RamadanNotNear());
    });

    test('a countdown from 30 days ahead', () {
      expect(
        overviewAt(DateTime(2027, 1, 9, 9)),
        RamadanCountdown(daysUntil: 30, startDate: DateTime(2027, 2, 8)),
      );
      expect(
        overviewAt(DateTime(2027, 1, 27, 9)),
        RamadanCountdown(daysUntil: 12, startDate: DateTime(2027, 2, 8)),
      );
    });

    test('the day before also says when the first suhoor ends', () {
      final overview = overviewAt(DateTime(2027, 2, 7, 20));
      expect(overview, isA<RamadanCountdown>());
      final countdown = overview as RamadanCountdown;
      expect(countdown.daysUntil, 1);
      // Fajr in London on 8 February 2027 (MWL, 18°) is about 05:34 UTC (PrayTimes.org).
      expect(
        countdown.firstSuhoorEnds!
            .difference(DateTime.utc(2027, 2, 8, 5, 34))
            .inMinutes
            .abs(),
        lessThanOrEqualTo(2),
      );
    });

    test('the Hijri adjustment moves the start', () {
      expect(
        overviewAt(DateTime(2027, 1, 27, 9), offset: HijriOffset.minusOne),
        RamadanCountdown(daysUntil: 13, startDate: DateTime(2027, 2, 9)),
      );
    });

    test('nothing after Ramadan', () {
      expect(overviewAt(DateTime(2027, 3, 9, 9)), const RamadanNotNear());
    });
  });

  group('during Ramadan', () {
    RamadanDay dayAt(DateTime now, {HijriOffset offset = HijriOffset.none}) =>
        overviewAt(now, offset: offset) as RamadanDay;

    test('says which day of how many, with today times for the place', () {
      final day = dayAt(DateTime(2027, 2, 19, 13, 40));
      expect(day.dayOfRamadan, 12);
      expect(day.daysInMonth, 29);
      expect(day.hijriDate, const HijriDate(1448, 9, 12));
      expect(day.date, DateTime(2027, 2, 19));
      expect(day.location, london);
      expect(day.method, CalculationMethod.muslimWorldLeague);
      expect(
        day.times,
        settings.settings.timesOn(
          DateTime(2027, 2, 19),
          london,
          inRamadan: true,
        ),
      );
    });

    test('before Fajr the next moment is the end of suhoor', () {
      final day = dayAt(DateTime(2027, 2, 19, 4));
      expect(day.next!.kind, FastingMomentKind.suhoorEnds);
      expect(day.next!.at, day.times.fajr);
      expect(
        day.next!.remaining,
        day.times.fajr!.difference(DateTime(2027, 2, 19, 4)),
      );
    });

    test('between Fajr and Maghrib it is iftar', () {
      final day = dayAt(DateTime(2027, 2, 19, 13, 40));
      expect(day.next!.kind, FastingMomentKind.iftar);
      expect(day.next!.at, day.times.maghrib);
    });

    test("after Maghrib it is tomorrow's suhoor", () {
      final day = dayAt(DateTime(2027, 2, 19, 20));
      final tomorrow = settings.settings.timesOn(
        DateTime(2027, 2, 20),
        london,
        inRamadan: true,
      );
      expect(day.next!.kind, FastingMomentKind.suhoorEnds);
      expect(day.next!.at, tomorrow.fajr);
    });

    test('after the last iftar there is nothing next', () {
      final day = dayAt(DateTime(2027, 3, 8, 20));
      expect(day.dayOfRamadan, 29);
      expect(day.next, isNull);
    });

    test('the Hijri adjustment moves the day', () {
      expect(
        dayAt(
          DateTime(2027, 2, 19, 13),
          offset: HijriOffset.plusOne,
        ).dayOfRamadan,
        13,
      );
    });

    test('the chosen method and settings are used', () {
      settings.settings = const PrayerSettings(
        method: CalculationMethod.isna,
      );
      final day = dayAt(DateTime(2027, 2, 19, 13));
      expect(day.method, CalculationMethod.isna);
    });

    test('unreadable settings fall back to the defaults', () {
      settings.readFails = true;
      final cairo = GeoPoint.fromCity(CityCatalog.byId('EG:Cairo')!);
      final day =
          overviewAt(DateTime(2027, 2, 19, 13), location: cairo) as RamadanDay;
      expect(day.method, CalculationMethod.egyptian);
    });
  });
}
