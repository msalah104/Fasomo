import 'package:fasomo/core/astronomy/solar.dart';
import 'package:flutter_test/flutter_test.dart';

// Reference instants are from PyEphem 4.2 (VSOP87) with refraction pinned to
// the standard 34′: the upper limb on the horizon for sunrise and sunset, the
// centre for twilight angles. They match the NOAA solar calculator.

typedef _Place = ({double lat, double lng});

const _Place _makkah = (lat: 21.4225, lng: 39.8262);
const _Place _london = (lat: 51.5074, lng: -0.1278);
const _Place _cairo = (lat: 30.0444, lng: 31.2357);
const _Place _sydney = (lat: -33.8688, lng: 151.2093);
const _Place _tromso = (lat: 69.6492, lng: 18.9553);

/// Matches a UTC [DateTime] within [tolerance] of [expectedUtc].
Matcher _twoMinutes(
  String expectedUtc, {
  Duration tolerance = const Duration(minutes: 2),
}) {
  final expected = DateTime.parse('${expectedUtc}Z');
  return predicate<DateTime?>(
    (actual) =>
        actual != null &&
        actual.isUtc &&
        actual.difference(expected).abs() <= tolerance,
    'a UTC time within $tolerance of $expected',
  );
}

SunTimes _times(_Place place, DateTime date) =>
    sunTimes(date, latitude: place.lat, longitude: place.lng);

DateTime? _angle(
  _Place place,
  DateTime date,
  double angle, {
  required bool rising,
}) => sunTimeForAngle(
  date,
  latitude: place.lat,
  longitude: place.lng,
  angleDegrees: angle,
  rising: rising,
);

void main() {
  group('sunrise, solar noon and sunset', () {
    final cases = <(String, _Place, DateTime, String, String, String)>[
      (
        'Makkah, March equinox',
        _makkah,
        DateTime(2026, 3, 20),
        '2026-03-20T03:24:57',
        '2026-03-20T09:28:09',
        '2026-03-20T15:31:40',
      ),
      (
        'Makkah, June solstice',
        _makkah,
        DateTime(2026, 6, 21),
        '2026-06-21T02:39:19',
        '2026-06-21T09:22:29',
        '2026-06-21T16:05:39',
      ),
      (
        'Makkah, December solstice',
        _makkah,
        DateTime(2026, 12, 21),
        '2026-12-21T03:53:47',
        '2026-12-21T09:18:42',
        '2026-12-21T14:43:36',
      ),
      (
        'London, June solstice',
        _london,
        DateTime(2026, 6, 21),
        '2026-06-21T03:43:08',
        '2026-06-21T12:02:19',
        '2026-06-21T20:21:30',
      ),
      (
        'London, December solstice',
        _london,
        DateTime(2026, 12, 21),
        '2026-12-21T08:03:42',
        '2026-12-21T11:58:34',
        '2026-12-21T15:53:25',
      ),
      (
        'Cairo, 2 November',
        _cairo,
        DateTime(2026, 11, 2),
        '2026-11-02T04:09:35',
        '2026-11-02T09:38:36',
        '2026-11-02T15:07:16',
      ),
      // East of UTC by ten hours: the local morning is the UTC evening before.
      (
        'Sydney, 15 January',
        _sydney,
        DateTime(2026, 1, 15),
        '2026-01-14T18:59:28',
        '2026-01-15T02:04:24',
        '2026-01-15T09:09:00',
      ),
    ];

    for (final (name, place, date, rise, noon, set) in cases) {
      test(name, () {
        final times = _times(place, date);
        expect(times.sunrise, _twoMinutes(rise));
        expect(times.solarNoon, _twoMinutes(noon));
        expect(times.sunset, _twoMinutes(set));
        expect(times.isPolarDay, isFalse);
        expect(times.isPolarNight, isFalse);
      });
    }

    test('uses only the calendar date of the given DateTime', () {
      final morning = _times(_makkah, DateTime(2026, 3, 20, 1));
      final evening = _times(_makkah, DateTime.utc(2026, 3, 20, 23, 59));
      expect(morning.sunrise, evening.sunrise);
      expect(morning.sunset, evening.sunset);
    });
  });

  group('polar day and night in Tromsø', () {
    test('midnight sun at the June solstice', () {
      final times = _times(_tromso, DateTime(2026, 6, 21));
      expect(times.sunrise, isNull);
      expect(times.sunset, isNull);
      expect(times.isPolarDay, isTrue);
      expect(times.isPolarNight, isFalse);
      expect(times.noonAltitudeDegrees, closeTo(43.8, 0.3));
    });

    test('polar night at the December solstice', () {
      final times = _times(_tromso, DateTime(2026, 12, 21));
      expect(times.sunrise, isNull);
      expect(times.sunset, isNull);
      expect(times.isPolarNight, isTrue);
      expect(times.isPolarDay, isFalse);
      expect(times.noonAltitudeDegrees, closeTo(-3.1, 0.3));
    });
  });

  group('twilight angles', () {
    test('Makkah at −18° (Fajr and Isha by that angle)', () {
      final date = DateTime(2026, 3, 20);
      expect(
        _angle(_makkah, date, -18, rising: true),
        _twoMinutes('2026-03-20T02:11:03'),
      );
      expect(
        _angle(_makkah, date, -18, rising: false),
        _twoMinutes('2026-03-20T16:45:40'),
      );
    });

    test('London at −18° in December', () {
      final date = DateTime(2026, 12, 21);
      expect(
        _angle(_london, date, -18, rising: true),
        _twoMinutes('2026-12-21T05:59:22'),
      );
      expect(
        _angle(_london, date, -18, rising: false),
        _twoMinutes('2026-12-21T17:57:45'),
      );
    });

    test('civil twilight at −6°', () {
      final date = DateTime(2026, 6, 21);
      expect(
        _angle(_london, date, -6, rising: true),
        _twoMinutes('2026-06-21T02:55:19'),
      );
      expect(
        _angle(_london, date, -6, rising: false),
        _twoMinutes('2026-06-21T21:09:19'),
      );
    });

    test('London never reaches −18° around the June solstice', () {
      final date = DateTime(2026, 6, 21);
      expect(_angle(_london, date, -18, rising: true), isNull);
      expect(_angle(_london, date, -18, rising: false), isNull);
    });

    test('an afternoon altitude comes after noon', () {
      final date = DateTime(2026, 3, 20);
      final noon = solarNoon(date, longitude: _makkah.lng);
      final afternoon = _angle(_makkah, date, 40, rising: false)!;
      final morning = _angle(_makkah, date, 40, rising: true)!;
      expect(afternoon.isAfter(noon), isTrue);
      expect(morning.isBefore(noon), isTrue);
      final altitude = sunPosition(
        afternoon,
        latitude: _makkah.lat,
        longitude: _makkah.lng,
      ).altitudeDegrees;
      expect(altitude, closeTo(40, 0.05));
    });

    test('no angle at the poles where the formula degenerates', () {
      expect(
        sunTimeForAngle(
          DateTime(2026, 3, 20),
          latitude: 90,
          longitude: 0,
          angleDegrees: -18,
          rising: true,
        ),
        isNull,
      );
    });
  });

  group('sun position', () {
    final cases = <(String, _Place, DateTime, double, double)>[
      (
        'Makkah near noon',
        _makkah,
        DateTime.utc(2026, 6, 21, 9, 20),
        87.904,
        15.805,
      ),
      (
        'London afternoon',
        _london,
        DateTime.utc(2026, 3, 20, 15),
        27.069,
        230.016,
      ),
      ('Sydney noon', _sydney, DateTime.utc(2026, 1, 15, 2), 77.239, 4.659),
      (
        'Cairo morning',
        _cairo,
        DateTime.utc(2026, 11, 2, 6, 30),
        26.205,
        127.795,
      ),
    ];

    for (final (name, place, time, altitude, azimuth) in cases) {
      test(name, () {
        final sun = sunPosition(
          time,
          latitude: place.lat,
          longitude: place.lng,
        );
        expect(sun.altitudeDegrees, closeTo(altitude, 0.1));
        // Azimuth is unstable right at the zenith; the cases avoid it.
        expect(sun.azimuthDegrees, closeTo(azimuth, 0.5));
      });
    }

    test('local and UTC instants give the same position', () {
      final utc = DateTime.utc(2026, 11, 2, 6, 30);
      final a = sunPosition(utc, latitude: 30, longitude: 31);
      final b = sunPosition(utc.toLocal(), latitude: 30, longitude: 31);
      expect(a.horizontal, b.horizontal);
    });

    test('the hour angle is negative in the morning and zero at noon', () {
      final noon = solarNoon(DateTime(2026, 11, 2), longitude: _cairo.lng);
      final atNoon = sunPosition(
        noon,
        latitude: _cairo.lat,
        longitude: _cairo.lng,
      );
      final morning = sunPosition(
        noon.subtract(const Duration(hours: 3)),
        latitude: _cairo.lat,
        longitude: _cairo.lng,
      );
      expect(atNoon.hourAngleDegrees, closeTo(0, 0.1));
      expect(morning.hourAngleDegrees, closeTo(-45, 0.2));
    });
  });

  group('declination and equation of time', () {
    test('declination peaks near ±23.44° at the solstices', () {
      expect(
        solarDeclination(DateTime.utc(2026, 6, 21, 8, 24)),
        closeTo(23.44, 0.02),
      );
      expect(
        solarDeclination(DateTime.utc(2026, 12, 21, 20, 50)),
        closeTo(-23.44, 0.02),
      );
      expect(
        solarDeclination(DateTime.utc(2026, 3, 20, 14, 46)),
        closeTo(0, 0.02),
      );
    });

    test('the equation of time swings from −14 to +16 minutes', () {
      expect(
        equationOfTimeMinutes(DateTime.utc(2026, 2, 11, 12)),
        closeTo(-14.2, 0.2),
      );
      expect(
        equationOfTimeMinutes(DateTime.utc(2026, 11, 3, 12)),
        closeTo(16.4, 0.2),
      );
    });

    test('the sun is about 1 AU away', () {
      expect(
        solarCoordinates(DateTime.utc(2026, 1, 3)).distanceAu,
        closeTo(0.983, 0.001),
      );
      expect(
        solarCoordinates(DateTime.utc(2026, 7, 6)).distanceAu,
        closeTo(1.017, 0.001),
      );
    });
  });
}
