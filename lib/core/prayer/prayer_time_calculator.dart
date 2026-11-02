/// Prayer times from the sun's position, on top of `core/astronomy`.
///
/// Follows the published PrayTimes.org algorithm: Fajr and Isha when the sun
/// is a method's angle below the horizon, Asr by shadow length, and a cap
/// at a portion of the night where twilight never ends. The sun's position
/// comes from the NOAA/Meeus formulas in `solar.dart`, refined at each
/// estimate, so it is pure, total and needs no network or package.
library;

import 'dart:math' as math;

import 'package:fasomo/core/astronomy/astro_math.dart';
import 'package:fasomo/core/astronomy/solar.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';

abstract final class PrayerTimeCalculator {
  /// The prayer times of the local day [date] (only its year, month and day
  /// are used) at [latitude], [longitude] in degrees, north and east
  /// positive.
  ///
  /// [inRamadan] selects the Ramadan Isha interval of methods that have one
  /// (Umm al-Qura). [adjustments] are added after everything else.
  static PrayerTimes compute(
    DateTime date, {
    required double latitude,
    required double longitude,
    required CalculationMethod method,
    AsrMethod asrMethod = AsrMethod.standard,
    HighLatitudeRule highLatitudeRule = HighLatitudeRule.middleOfTheNight,
    PrayerAdjustments adjustments = PrayerAdjustments.none,
    bool inRamadan = false,
  }) {
    DateTime? sunAt(double altitude, {required bool rising}) => sunTimeForAngle(
      date,
      latitude: latitude,
      longitude: longitude,
      angleDegrees: altitude,
      rising: rising,
    );

    final noon = solarNoon(date, longitude: longitude);
    final sunrise = sunAt(sunriseAltitudeDegrees, rising: true);
    final sunset = sunAt(sunriseAltitudeDegrees, rising: false);
    final asr = switch (_asrAltitude(
      asrMethod,
      latitude,
      solarDeclination(noon),
    )) {
      final altitude? => sunAt(altitude, rising: false),
      null => null,
    };

    DateTime? fajr;
    DateTime? maghrib;
    DateTime? isha;
    // Without a sunrise and a sunset (polar day or night) there is no night
    // to divide, so the twilight prayers are left undefined.
    if (sunrise != null && sunset != null) {
      final night = sunrise.add(const Duration(days: 1)).difference(sunset);
      Duration portion(double angle) =>
          night * highLatitudeRule.nightFraction(angle);

      fajr = _notBefore(
        sunAt(-method.fajrAngleDegrees, rising: true),
        sunrise.subtract(portion(method.fajrAngleDegrees)),
      );
      maghrib = switch (method.maghribAngleDegrees) {
        final angle? => _notAfter(
          sunAt(-angle, rising: false),
          sunset.add(portion(angle)),
        ),
        null => sunset,
      };
      isha = switch ((
        method.ishaAngleDegrees,
        method.ishaMinutesAfterMaghrib,
      )) {
        (final angle?, _) => _notAfter(
          sunAt(-angle, rising: false),
          sunset.add(portion(angle)),
        ),
        (null, final minutes?) => maghrib.add(
          Duration(
            minutes: inRamadan
                ? method.ishaMinutesInRamadan ?? minutes
                : minutes,
          ),
        ),
        (null, null) => null,
      };
    }

    DateTime? finish(DateTime? time, Prayer prayer) => time == null
        ? null
        : _nearestMinute(time.add(Duration(minutes: adjustments[prayer])));

    return PrayerTimes(
      date: DateTime(date.year, date.month, date.day),
      fajr: finish(fajr, Prayer.fajr),
      sunrise: finish(sunrise, Prayer.sunrise),
      dhuhr: _nearestMinute(noon.add(Duration(minutes: adjustments.dhuhr))),
      asr: finish(asr, Prayer.asr),
      maghrib: finish(maghrib, Prayer.maghrib),
      isha: finish(isha, Prayer.isha),
    );
  }

  /// The sun's altitude at Asr: where an object's shadow is [method]'s
  /// factor times its height plus its noon shadow. `null` when the sun stays
  /// below the horizon at noon, so there is no noon shadow.
  static double? _asrAltitude(
    AsrMethod method,
    double latitude,
    double declination,
  ) {
    final zenithAtNoon = (latitude - declination).abs();
    if (zenithAtNoon >= 90) return null;
    final noonShadow = math.tan(zenithAtNoon * radiansPerDegree);
    return math.atan(1 / (method.shadowFactor + noonShadow)) / radiansPerDegree;
  }

  /// [time], or [limit] when [time] is missing or earlier than it.
  static DateTime _notBefore(DateTime? time, DateTime limit) =>
      time == null || time.isBefore(limit) ? limit : time;

  /// [time], or [limit] when [time] is missing or later than it.
  static DateTime _notAfter(DateTime? time, DateTime limit) =>
      time == null || time.isAfter(limit) ? limit : time;

  static DateTime _nearestMinute(DateTime time) {
    const minute = Duration.millisecondsPerMinute;
    final rounded =
        (time.millisecondsSinceEpoch + minute ~/ 2) ~/ minute * minute;
    return DateTime.fromMillisecondsSinceEpoch(rounded, isUtc: true);
  }
}
