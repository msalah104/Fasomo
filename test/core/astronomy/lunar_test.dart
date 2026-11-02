import 'package:fasomo/core/astronomy/lunar.dart';
import 'package:flutter_test/flutter_test.dart';

// Reference values are from PyEphem 4.2 (ELP2000), topocentric, with
// refraction pinned to the standard 34′ and the upper limb on the horizon for
// rise and set. The low-precision series is held to 0.5° in position and five
// minutes in rise and set.

typedef _Place = ({double lat, double lng});

const _Place _makkah = (lat: 21.4225, lng: 39.8262);
const _Place _london = (lat: 51.5074, lng: -0.1278);
const _Place _cairo = (lat: 30.0444, lng: 31.2357);
const _Place _sydney = (lat: -33.8688, lng: 151.2093);

Matcher _nearUtc(String expectedUtc) {
  final expected = DateTime.parse('${expectedUtc}Z');
  const tolerance = Duration(minutes: 5);
  return predicate<DateTime?>(
    (actual) =>
        actual != null &&
        actual.isUtc &&
        actual.difference(expected).abs() <= tolerance,
    'a UTC time within $tolerance of $expected',
  );
}

void main() {
  group('moon position', () {
    final cases = <(String, _Place, DateTime, double, double)>[
      (
        'Makkah, below the horizon',
        _makkah,
        DateTime.utc(2026, 11, 2, 18),
        -45.6,
        39.154,
      ),
      (
        'London, full moon rising',
        _london,
        DateTime.utc(2026, 3, 3, 22),
        32.036,
        133.521,
      ),
      (
        'Cairo, evening',
        _cairo,
        DateTime.utc(2026, 10, 28, 18, 40),
        20.121,
        70.267,
      ),
      (
        'Sydney, high in the north',
        _sydney,
        DateTime.utc(2026, 5, 1, 12),
        63.228,
        60.65,
      ),
    ];

    for (final (name, place, time, altitude, azimuth) in cases) {
      test(name, () {
        final moon = moonPosition(
          time,
          latitude: place.lat,
          longitude: place.lng,
        );
        expect(moon.altitudeDegrees, closeTo(altitude, 0.5));
        expect(moon.azimuthDegrees, closeTo(azimuth, 0.5));
      });
    }

    test('the distance stays between perigee and apogee', () {
      for (var day = 0; day < 30; day++) {
        final moon = moonPosition(
          DateTime.utc(2026).add(Duration(days: day)),
          latitude: 0,
          longitude: 0,
        );
        expect(moon.distanceKm, inInclusiveRange(356000, 407000));
      }
    });
  });

  group('moonrise and moonset', () {
    final cases = <(String, _Place, DateTime, String, String)>[
      (
        'Makkah',
        _makkah,
        DateTime.utc(2026, 11, 2),
        '2026-11-02T21:56:18',
        '2026-11-02T10:20:17',
      ),
      (
        'London',
        _london,
        DateTime.utc(2026, 3, 3),
        '2026-03-03T18:00:16',
        '2026-03-03T06:40:55',
      ),
      (
        'Cairo',
        _cairo,
        DateTime.utc(2026, 10, 28),
        '2026-10-28T16:48:41',
        '2026-10-28T06:33:41',
      ),
      (
        'Makkah, near new moon',
        _makkah,
        DateTime.utc(2026, 3, 20),
        '2026-03-20T04:04:37',
        '2026-03-20T17:01:18',
      ),
    ];

    for (final (name, place, start, rise, set) in cases) {
      test(name, () {
        final times = moonTimes(
          start,
          latitude: place.lat,
          longitude: place.lng,
        );
        expect(times.rise, _nearUtc(rise));
        expect(times.set, _nearUtc(set));
        expect(times.isAlwaysUp, isFalse);
        expect(times.isAlwaysDown, isFalse);
      });
    }

    test('the moon is up between its rise and its set', () {
      final times = moonTimes(
        DateTime.utc(2026, 3, 20),
        latitude: _makkah.lat,
        longitude: _makkah.lng,
      );
      final middle = times.rise!.add(times.set!.difference(times.rise!) ~/ 2);
      final moon = moonPosition(
        middle,
        latitude: _makkah.lat,
        longitude: _makkah.lng,
      );
      expect(times.isUpAtStart, isFalse);
      expect(moon.altitudeDegrees, greaterThan(30));
    });

    test('a longer span finds every crossing in order', () {
      final times = moonTimes(
        DateTime.utc(2026, 11),
        latitude: _cairo.lat,
        longitude: _cairo.lng,
        span: const Duration(days: 7),
      );
      expect(times.rises.length, inInclusiveRange(6, 7));
      expect(times.sets.length, inInclusiveRange(6, 7));
      for (var i = 1; i < times.rises.length; i++) {
        final gap = times.rises[i].difference(times.rises[i - 1]);
        // The moon rises 24 h 50 min apart on average.
        expect(gap.inMinutes, inInclusiveRange(24 * 60 + 20, 25 * 60 + 30));
      }
    });

    test('stays up or down all day near the pole', () {
      // Svalbard, around the major lunar standstill: the moon circles
      // without setting when far north and never rises when far south.
      final upDays = <bool>[];
      final downDays = <bool>[];
      for (var day = 0; day < 28; day++) {
        final times = moonTimes(
          DateTime.utc(2026, 11).add(Duration(days: day)),
          latitude: 78.22,
          longitude: 15.65,
        );
        upDays.add(times.isAlwaysUp);
        downDays.add(times.isAlwaysDown);
      }
      expect(upDays, contains(true));
      expect(downDays, contains(true));
    });
  });

  group('moon illumination', () {
    test('full moon is fully lit, half way through the cycle', () {
      final full = moonIllumination(DateTime.utc(2026, 3, 3, 11, 38));
      expect(full.fraction, greaterThan(0.995));
      expect(full.phase, closeTo(0.5, 0.01));
    });

    test('new moon is dark, at the start of the cycle', () {
      final dark = moonIllumination(DateTime.utc(2026, 3, 19, 1, 23));
      expect(dark.fraction, lessThan(0.005));
      final wrapped = dark.phase > 0.5 ? dark.phase - 1 : dark.phase;
      expect(wrapped, closeTo(0, 0.01));
    });

    test('quarters are half lit and set waxing apart from waning', () {
      final last = moonIllumination(DateTime.utc(2026, 11, 1, 20, 28));
      expect(last.fraction, closeTo(0.5, 0.02));
      expect(last.phase, closeTo(0.75, 0.01));
      expect(last.isWaxing, isFalse);

      final first = moonIllumination(DateTime.utc(2026, 11, 17, 11, 48));
      expect(first.fraction, closeTo(0.5, 0.02));
      expect(first.phase, closeTo(0.25, 0.01));
      expect(first.isWaxing, isTrue);
    });

    test('agrees with the reference lit fraction', () {
      expect(
        moonIllumination(DateTime.utc(2026, 11, 2, 18)).fraction,
        closeTo(0.4013, 0.01),
      );
      expect(
        moonIllumination(DateTime.utc(2026, 10, 28, 18, 40)).fraction,
        closeTo(0.9071, 0.01),
      );
    });

    test('the lit limb faces the sun: west of the moon while waxing', () {
      // Position angles run from north through east, so a lit side towards
      // the west is between 180° and 360°.
      final waxing = moonIllumination(DateTime.utc(2026, 11, 13));
      expect(waxing.brightLimbAngleDegrees, inExclusiveRange(180, 360));
      final waning = moonIllumination(DateTime.utc(2026, 11, 4));
      expect(waning.brightLimbAngleDegrees, inExclusiveRange(0, 180));
    });
  });
}
