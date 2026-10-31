import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/sky_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rise = DateTime(2026, 10, 31, 6);
  final set = DateTime(2026, 10, 31, 18);
  CelestialBodyState sunAt(double altitude) => CelestialBodyState(
    altitudeDegrees: altitude,
    azimuthDegrees: 0,
    rise: rise,
    set: set,
  );

  group('place', () {
    test('noon is the top of the arc', () {
      final point = SkyProjection.place(sunAt(50), DateTime(2026, 10, 31, 12));
      expect(point!.x, closeTo(0.5, 1e-9));
      expect(point.y, closeTo(1, 1e-9));
    });

    test('just after rise is near the start edge, low', () {
      final point = SkyProjection.place(
        sunAt(1),
        DateTime(2026, 10, 31, 6, 30),
      );
      expect(point!.x, closeTo(0.5 / 12, 1e-9));
      expect(point.y, lessThan(0.15));
    });

    test('just before set is near the end edge', () {
      final point = SkyProjection.place(
        sunAt(1),
        DateTime(2026, 10, 31, 17, 30),
      );
      expect(point!.x, greaterThan(0.95));
    });

    test('a body below the horizon has no place', () {
      expect(
        SkyProjection.place(sunAt(-3), DateTime(2026, 10, 31, 20)),
        isNull,
      );
    });

    test('without rise and set (polar day), azimuth decides', () {
      const south = CelestialBodyState(altitudeDegrees: 30, azimuthDegrees: 0);
      const west = CelestialBodyState(altitudeDegrees: 10, azimuthDegrees: 80);
      final now = DateTime(2026, 6, 21, 12);
      expect(SkyProjection.place(south, now)!.x, 0.5);
      expect(SkyProjection.place(west, now)!.x, closeTo(170 / 180, 1e-9));
    });
  });

  test('the arc is 0 at both edges and 1 in the middle', () {
    expect(SkyProjection.arcHeight(0), closeTo(0, 1e-9));
    expect(SkyProjection.arcHeight(1), closeTo(0, 1e-9));
    expect(SkyProjection.arcHeight(0.5), 1);
  });

  test('day phases follow the sun altitude', () {
    expect(DayPhase.fromSunAltitude(-30), DayPhase.night);
    expect(DayPhase.fromSunAltitude(-15), DayPhase.astronomicalTwilight);
    expect(DayPhase.fromSunAltitude(-8), DayPhase.nauticalTwilight);
    expect(DayPhase.fromSunAltitude(-3), DayPhase.civilTwilight);
    expect(DayPhase.fromSunAltitude(3), DayPhase.goldenHour);
    expect(DayPhase.fromSunAltitude(40), DayPhase.day);
    expect(DayPhase.goldenHour.isDaylight, isTrue);
    expect(DayPhase.civilTwilight.isDaylight, isFalse);
  });

  test('moon phase names cover each eighth of the cycle', () {
    expect(MoonPhaseName.of(0), MoonPhaseName.newMoon);
    expect(MoonPhaseName.of(0.98), MoonPhaseName.newMoon);
    expect(MoonPhaseName.of(0.1), MoonPhaseName.waxingCrescent);
    expect(MoonPhaseName.of(0.25), MoonPhaseName.firstQuarter);
    expect(MoonPhaseName.of(0.5), MoonPhaseName.full);
    expect(MoonPhaseName.of(0.75), MoonPhaseName.lastQuarter);
    expect(MoonPhaseName.of(0.9), MoonPhaseName.waningCrescent);
    expect(const MoonPhase(fraction: 0.2, phase: 0.1).isWaxing, isTrue);
    expect(const MoonPhase(fraction: 0.2, phase: 0.9).isWaxing, isFalse);
  });
}
