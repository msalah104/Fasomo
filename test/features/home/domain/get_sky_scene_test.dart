import 'package:clock/clock.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/day_phase.dart';
import 'package:fasomo/features/home/domain/entities/moon_phase.dart';
import 'package:fasomo/features/home/domain/sky_scene_builder.dart';
import 'package:fasomo/features/home/domain/usecases/get_sky_scene.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [LocationRepository] that always answers [location].
class FakeLocationRepository implements LocationRepository {
  new(this.location);

  GeoPoint location;

  @override
  GeoPoint current() => location;

  @override
  Future<GeoPoint> chooseCity(City city) async =>
      location = GeoPoint.fromCity(city);

  @override
  Future<Result<GeoPoint, LocationFailure>> refreshFromDevice() async =>
      const Err(LocationUnavailable());

  @override
  Future<bool> openSettings() async => false;

  @override
  GeoPoint? saved() => location.isApproximate ? null : location;

  @override
  Future<bool> replaceSaved(GeoPoint? point) async => true;
}

void main() {
  final cairo = GeoPoint.fromCity(CityCatalog.byId('EG:Cairo')!);
  final tromso = GeoPoint.fromCity(CityCatalog.byId('NO:Tromsø')!);

  test('reads the clock and the saved location', () {
    final now = DateTime.utc(2026, 11, 2, 9, 38);
    final scene = GetSkyScene(
      clock: Clock.fixed(now),
      locationRepository: FakeLocationRepository(cairo),
    )(const NoParams());

    expect(scene.now, now);
    expect(scene.location, cairo);
  });

  group('the sun', () {
    test('at solar noon in Cairo it is up, at the top of its arc', () {
      // Cairo's solar noon on 2 November is 09:38:36 UTC.
      final scene = buildSkyScene(DateTime.utc(2026, 11, 2, 9, 38, 36), cairo);

      expect(scene.sun.isUp, isTrue);
      expect(scene.dayPhase, DayPhase.day);
      expect(scene.sun.altitudeDegrees, closeTo(45.2, 0.3));
      expect(scene.sun.peakAltitudeDegrees, closeTo(45.2, 0.3));
      final point = scene.sunPoint!;
      expect(point.x, closeTo(0.5, 0.01));
      expect(point.y, closeTo(1, 0.001));
    });

    test('at night it is down and its next rise is tomorrow morning', () {
      final scene = buildSkyScene(DateTime.utc(2026, 11, 2, 20), cairo);

      expect(scene.sun.isUp, isFalse);
      expect(scene.sunPoint, isNull);
      expect(scene.dayPhase, DayPhase.night);
      expect(scene.sun.rise, isNotNull);
      expect(
        scene.sun.rise!.difference(DateTime.utc(2026, 11, 3, 4, 10)).abs(),
        lessThan(const Duration(minutes: 3)),
      );
      expect(scene.sun.set!.isAfter(scene.sun.rise!), isTrue);
    });

    test('just after sunrise it is near the start edge', () {
      final scene = buildSkyScene(DateTime.utc(2026, 11, 2, 4, 20), cairo);
      expect(scene.sun.isUp, isTrue);
      expect(scene.sunPoint!.x, lessThan(0.05));
      expect(scene.isMorning, isTrue);
    });

    test('dawn and dusk are told apart by the hour angle', () {
      final dawn = buildSkyScene(DateTime.utc(2026, 11, 2, 3, 30), cairo);
      final dusk = buildSkyScene(DateTime.utc(2026, 11, 2, 15, 40), cairo);
      expect(dawn.dayPhase.isTwilight, isTrue);
      expect(dawn.isMorning, isTrue);
      expect(dusk.dayPhase.isTwilight, isTrue);
      expect(dusk.isMorning, isFalse);
    });

    test('the midnight sun in Tromsø is up with no rise or set', () {
      final scene = buildSkyScene(DateTime.utc(2026, 6, 21, 23), tromso);
      expect(scene.sun.isUp, isTrue);
      expect(scene.sun.rise, isNull);
      expect(scene.sun.set, isNull);
      final point = scene.sunPoint!;
      expect(point.isOnArc, isFalse);
      expect(point.y, inExclusiveRange(0, 0.3));
    });

    test('the polar night in Tromsø has no sun at noon', () {
      final scene = buildSkyScene(DateTime.utc(2026, 12, 21, 10, 45), tromso);
      expect(scene.sun.isUp, isFalse);
      expect(scene.sunPoint, isNull);
      expect(scene.sun.altitudeDegrees, closeTo(-3.1, 0.5));
      expect(scene.dayPhase, DayPhase.civilTwilight);
    });
  });

  group('the moon', () {
    test('in the evening sky it is up on its arc with its rise and set', () {
      final scene = buildSkyScene(
        DateTime.utc(2026, 10, 28, 18, 40),
        GeoPoint.makkah,
      );
      final moon = scene.moon;
      expect(moon.isUp, isTrue);
      expect(moon.altitudeDegrees, greaterThan(15));
      expect(moon.rise!.isBefore(scene.now), isTrue);
      expect(moon.set!.isAfter(scene.now), isTrue);
      expect(scene.moonPoint!.isOnArc, isTrue);
      expect(moon.peakAltitudeDegrees, greaterThan(moon.altitudeDegrees));
    });

    test('below the horizon it is not drawn, and its next rise is ahead', () {
      // Makkah, 2 November 18:00 UTC: the moon is 45° below the horizon.
      final scene = buildSkyScene(
        DateTime.utc(2026, 11, 2, 18),
        GeoPoint.makkah,
      );
      expect(scene.moon.isUp, isFalse);
      expect(scene.moonPoint, isNull);
      expect(scene.moon.rise!.isAfter(scene.now), isTrue);
      expect(
        scene.moon.rise!.difference(DateTime.utc(2026, 11, 2, 21, 56)).abs(),
        lessThan(const Duration(minutes: 5)),
      );
    });

    test('carries the phase and the lit side faces the set sun', () {
      // A waxing crescent seen from Makkah after sunset: the sun is below
      // the western horizon, so the lit side points down and to the west.
      final scene = buildSkyScene(
        DateTime.utc(2026, 11, 12, 16, 30),
        GeoPoint.makkah,
      );
      final phase = scene.moonPhase;
      expect(phase.name, MoonPhaseName.waxingCrescent);
      expect(phase.isWaxing, isTrue);
      expect(phase.illuminatedFraction, inExclusiveRange(0.02, 0.2));
      // From up, counter-clockwise with east on the left: west is negative.
      expect(phase.brightLimbZenithAngleDegrees, inExclusiveRange(-180, -60));
    });
  });

  group('day phases', () {
    test('follow the sun altitude', () {
      expect(DayPhase.fromSunAltitude(-30), DayPhase.night);
      expect(DayPhase.fromSunAltitude(-15), DayPhase.astronomicalTwilight);
      expect(DayPhase.fromSunAltitude(-9), DayPhase.nauticalTwilight);
      expect(DayPhase.fromSunAltitude(-3), DayPhase.civilTwilight);
      expect(DayPhase.fromSunAltitude(2), DayPhase.goldenHour);
      expect(DayPhase.fromSunAltitude(30), DayPhase.day);
      expect(DayPhase.goldenHour.isSunUp, isTrue);
      expect(DayPhase.civilTwilight.isSunUp, isFalse);
    });
  });

  group('moon phase names', () {
    test('name the principal phases for about a day either side', () {
      expect(MoonPhaseName.fromPhase(0), MoonPhaseName.newMoon);
      expect(MoonPhaseName.fromPhase(0.99), MoonPhaseName.newMoon);
      expect(MoonPhaseName.fromPhase(0.1), MoonPhaseName.waxingCrescent);
      expect(MoonPhaseName.fromPhase(0.26), MoonPhaseName.firstQuarter);
      expect(MoonPhaseName.fromPhase(0.4), MoonPhaseName.waxingGibbous);
      expect(MoonPhaseName.fromPhase(0.5), MoonPhaseName.fullMoon);
      expect(MoonPhaseName.fromPhase(0.6), MoonPhaseName.waningGibbous);
      expect(MoonPhaseName.fromPhase(0.75), MoonPhaseName.lastQuarter);
      expect(MoonPhaseName.fromPhase(0.9), MoonPhaseName.waningCrescent);
    });
  });
}
