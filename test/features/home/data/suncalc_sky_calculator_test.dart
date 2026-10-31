import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/features/home/data/services/suncalc_sky_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden vectors checked against NOAA's solar calculator (within ±0.5° and
/// a couple of minutes). Times are UTC so the test doesn't depend on the
/// machine's time zone.
void main() {
  const calculator = SuncalcSkyCalculator();
  const makkah = GeoPoint(
    latitude: 21.4225,
    longitude: 39.8262,
    source: LocationSource.device,
  );
  const oslo = GeoPoint(
    latitude: 59.9139,
    longitude: 10.7522,
    source: LocationSource.device,
  );
  const tromso = GeoPoint(
    latitude: 69.65,
    longitude: 18.96,
    source: LocationSource.device,
  );

  Matcher near(DateTime expected) => predicate<DateTime?>(
    (actual) =>
        actual != null &&
        actual.toUtc().difference(expected).inMinutes.abs() <= 2,
    'within 2 minutes of $expected',
  );

  test('Makkah, June solstice: sun almost overhead at noon', () {
    final sun = calculator.sun(DateTime.utc(2026, 6, 21, 9, 23), makkah);
    expect(sun.altitudeDegrees, closeTo(87.98, 0.5));
    expect(sun.rise, near(DateTime.utc(2026, 6, 21, 2, 40)));
    expect(sun.set, near(DateTime.utc(2026, 6, 21, 16, 7)));
  });

  test('Makkah, March equinox: noon altitude is 90° minus the latitude', () {
    final sun = calculator.sun(DateTime.utc(2026, 3, 20, 9, 30), makkah);
    expect(sun.altitudeDegrees, closeTo(68.5, 0.5));
  });

  test('Makkah at night: the sun is well below the horizon', () {
    final sun = calculator.sun(DateTime.utc(2026, 10, 31, 20), makkah);
    expect(sun.isUp, isFalse);
    expect(sun.altitudeDegrees, lessThan(-18));
  });

  test('Oslo, June solstice: a long day', () {
    final sun = calculator.sun(DateTime.utc(2026, 6, 21, 11, 20), oslo);
    expect(sun.altitudeDegrees, closeTo(53.5, 0.5));
    expect(sun.rise, near(DateTime.utc(2026, 6, 21, 1, 55)));
    expect(sun.set, near(DateTime.utc(2026, 6, 21, 20, 45)));
  });

  test('Tromsø, June solstice: midnight sun, no rise or set', () {
    final sun = calculator.sun(DateTime.utc(2026, 6, 21, 22), tromso);
    expect(sun.isUp, isTrue);
    expect(sun.rise, isNull);
    expect(sun.set, isNull);
  });

  test('the full moon of 26 October 2026 is fully lit', () {
    final phase = calculator.moonPhase(DateTime.utc(2026, 10, 26, 4, 12));
    expect(phase.fraction, greaterThan(0.99));
    expect(phase.phase, closeTo(0.5, 0.02));
  });

  test('a moon that is up is inside its pass', () {
    // Late evening after the full moon: the moon is up over Makkah.
    final now = DateTime.utc(2026, 10, 27, 20);
    final moon = calculator.moon(now, makkah);
    expect(moon.isUp, isTrue);
    expect(moon.rise!.isAfter(now), isFalse);
    expect(moon.set!.isAfter(now), isTrue);
    expect(moon.set!.difference(moon.rise!).inHours, inInclusiveRange(10, 15));
  });
}
