/// The sun, by the NOAA solar calculator's low-precision formulas (after
/// Meeus, *Astronomical Algorithms*). Rise and set times agree with a full
/// ephemeris to within a minute between latitudes ±65°.
///
/// Every function is pure and total and takes instants as [DateTime]s, which
/// may be local or UTC; results are UTC.
library;

import 'dart:math' as math;

import 'package:fasomo/core/astronomy/astro_math.dart';

/// Altitude of the sun's centre at sunrise and sunset: 34′ of refraction
/// plus a 16′ semi-diameter, so the upper limb touches the horizon.
const double sunriseAltitudeDegrees = -0.833;

/// Where the sun is among the stars at one instant, as seen from the
/// Earth's centre.
final class SolarCoordinates {
  const new({
    required this.declinationDegrees,
    required this.rightAscensionDegrees,
    required this.apparentLongitudeDegrees,
    required this.equationOfTimeMinutes,
    required this.distanceAu,
  });

  /// Angle north (+) or south (−) of the celestial equator, about ±23.44°
  /// at the solstices.
  final double declinationDegrees;

  /// 0..360.
  final double rightAscensionDegrees;

  /// Ecliptic longitude, corrected for nutation and aberration, 0..360.
  final double apparentLongitudeDegrees;

  /// Apparent minus mean solar time, in minutes: about −14 in mid-February
  /// and +16 in early November.
  final double equationOfTimeMinutes;

  /// Distance from the Earth in astronomical units, 0.983..1.017.
  final double distanceAu;
}

/// The sun's geocentric coordinates at [time].
SolarCoordinates solarCoordinates(DateTime time) {
  final t = julianCenturies(time);
  final meanLongitude = normalizeDegrees(
    280.46646 + t * (36000.76983 + t * 0.0003032),
  );
  final meanAnomaly = 357.52911 + t * (35999.05029 - 0.0001537 * t);
  final eccentricity = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
  final center =
      sinDegrees(meanAnomaly) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
      sinDegrees(2 * meanAnomaly) * (0.019993 - 0.000101 * t) +
      sinDegrees(3 * meanAnomaly) * 0.000289;
  final trueLongitude = meanLongitude + center;
  final trueAnomaly = meanAnomaly + center;
  final distance =
      1.000001018 *
      (1 - eccentricity * eccentricity) /
      (1 + eccentricity * cosDegrees(trueAnomaly));

  final omega = 125.04 - 1934.136 * t;
  final apparentLongitude =
      trueLongitude - 0.00569 - 0.00478 * sinDegrees(omega);
  final meanObliquity =
      23 +
      (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60;
  final obliquity = meanObliquity + 0.00256 * cosDegrees(omega);

  final declination = asinDegrees(
    sinDegrees(obliquity) * sinDegrees(apparentLongitude),
  );
  final rightAscension = atan2Degrees(
    cosDegrees(obliquity) * sinDegrees(apparentLongitude),
    cosDegrees(apparentLongitude),
  );

  final y = math.pow(math.tan(obliquity * radiansPerDegree / 2), 2);
  final l0 = meanLongitude * radiansPerDegree;
  final m = meanAnomaly * radiansPerDegree;
  final e = eccentricity;
  final equationOfTimeRadians =
      y * math.sin(2 * l0) -
      2 * e * math.sin(m) +
      4 * e * y * math.sin(m) * math.cos(2 * l0) -
      0.5 * y * y * math.sin(4 * l0) -
      1.25 * e * e * math.sin(2 * m);

  return SolarCoordinates(
    declinationDegrees: declination,
    rightAscensionDegrees: normalizeDegrees(rightAscension),
    apparentLongitudeDegrees: normalizeDegrees(apparentLongitude),
    equationOfTimeMinutes: 4 * equationOfTimeRadians / radiansPerDegree,
    distanceAu: distance,
  );
}

/// The sun's declination at [time], in degrees.
double solarDeclination(DateTime time) =>
    solarCoordinates(time).declinationDegrees;

/// The equation of time at [time], in minutes (apparent minus mean solar
/// time).
double equationOfTimeMinutes(DateTime time) =>
    solarCoordinates(time).equationOfTimeMinutes;

/// The sun in the sky of an observer at one instant.
final class SunPosition {
  const new({required this.horizontal, required this.hourAngleDegrees});

  /// Geometric altitude (no refraction) and azimuth of the sun's centre.
  final HorizontalPosition horizontal;

  double get altitudeDegrees => horizontal.altitudeDegrees;

  double get azimuthDegrees => horizontal.azimuthDegrees;

  /// Local hour angle, -180..180: negative before solar noon, 0 at noon,
  /// positive after it.
  final double hourAngleDegrees;
}

/// Where the sun is at [time] for an observer at [latitude], [longitude]
/// (degrees, north and east positive).
SunPosition sunPosition(
  DateTime time, {
  required double latitude,
  required double longitude,
}) {
  final sun = solarCoordinates(time);
  final utc = time.toUtc();
  final minutes =
      utc.hour * 60 +
      utc.minute +
      utc.second / 60 +
      utc.millisecond / Duration.millisecondsPerMinute;
  final trueSolarMinutes = minutes + sun.equationOfTimeMinutes + 4 * longitude;
  final hourAngle = signedDegrees(trueSolarMinutes / 4 - 180);
  return SunPosition(
    horizontal: HorizontalPosition.fromEquatorial(
      hourAngleDegrees: hourAngle,
      declinationDegrees: sun.declinationDegrees,
      latitudeDegrees: latitude,
    ),
    hourAngleDegrees: hourAngle,
  );
}

/// Solar noon of the local day [date] at [longitude]: the instant the sun
/// crosses the meridian, highest in the sky.
///
/// Only the calendar date of [date] is used (its year, month and day as
/// written), so pass the observer's local date. The result is UTC.
DateTime solarNoon(DateTime date, {required double longitude}) {
  final midnight = DateTime.utc(date.year, date.month, date.day);
  var minutes = 720 - 4 * longitude;
  // The equation of time barely moves in a day; two passes settle it.
  for (var pass = 0; pass < 2; pass++) {
    final eot = equationOfTimeMinutes(midnight.add(_minutes(minutes)));
    minutes = 720 - 4 * longitude - eot;
  }
  return midnight.add(_minutes(minutes));
}

/// When the sun's centre stands at [angleDegrees] of altitude on the local
/// day [date], before solar noon if [rising] and after it otherwise; `null`
/// when the sun never reaches that altitude that day (polar day or night,
/// or no −18° twilight in a high-latitude summer).
///
/// Use −0.833 for sunrise and sunset ([sunTimes] does), −6/−12/−18 for
/// civil, nautical and astronomical twilight (Fajr and Isha), or a positive
/// angle in the afternoon for Asr. Only the calendar date of [date] is used;
/// the result is UTC.
DateTime? sunTimeForAngle(
  DateTime date, {
  required double latitude,
  required double longitude,
  required double angleDegrees,
  required bool rising,
}) {
  final midnight = DateTime.utc(date.year, date.month, date.day);
  final sign = rising ? -1 : 1;
  // Start from a quarter day either side of noon and refine with the sun's
  // declination and equation of time at the estimate.
  var minutes = 720 - 4 * longitude + sign * 360;
  for (var pass = 0; pass < 4; pass++) {
    final sun = solarCoordinates(midnight.add(_minutes(minutes)));
    final hourAngle = _hourAngleForAltitude(
      angleDegrees,
      latitude,
      sun.declinationDegrees,
    );
    if (hourAngle == null) return null;
    minutes =
        720 - 4 * longitude - sun.equationOfTimeMinutes + sign * 4 * hourAngle;
  }
  return midnight.add(_minutes(minutes));
}

/// Sunrise, solar noon and sunset of one local day.
final class SunTimes {
  const new({
    required this.solarNoon,
    required this.noonAltitudeDegrees,
    this.sunrise,
    this.sunset,
  });

  /// UTC. `null` on a day of polar day or polar night.
  final DateTime? sunrise;

  /// UTC.
  final DateTime solarNoon;

  /// UTC. `null` on a day of polar day or polar night.
  final DateTime? sunset;

  /// The sun's geometric altitude at [solarNoon].
  final double noonAltitudeDegrees;

  /// Whether the sun stays above the horizon all day (midnight sun).
  bool get isPolarDay =>
      sunrise == null && noonAltitudeDegrees > sunriseAltitudeDegrees;

  /// Whether the sun stays below the horizon all day.
  bool get isPolarNight =>
      sunrise == null && noonAltitudeDegrees <= sunriseAltitudeDegrees;
}

/// Sunrise, solar noon and sunset on the local day [date] at [latitude],
/// [longitude]. Only the calendar date of [date] is used; times are UTC.
SunTimes sunTimes(
  DateTime date, {
  required double latitude,
  required double longitude,
}) {
  final noon = solarNoon(date, longitude: longitude);
  DateTime? at({required bool rising}) => sunTimeForAngle(
    date,
    latitude: latitude,
    longitude: longitude,
    angleDegrees: sunriseAltitudeDegrees,
    rising: rising,
  );
  final sunrise = at(rising: true);
  final sunset = at(rising: false);
  final polar = sunrise == null || sunset == null;
  return SunTimes(
    sunrise: polar ? null : sunrise,
    solarNoon: noon,
    sunset: polar ? null : sunset,
    noonAltitudeDegrees: sunPosition(
      noon,
      latitude: latitude,
      longitude: longitude,
    ).altitudeDegrees,
  );
}

/// The hour angle, 0..180, at which a body of declination [declination]
/// stands at [altitude] for [latitude]; `null` if it never does.
double? _hourAngleForAltitude(
  double altitude,
  double latitude,
  double declination,
) {
  final denominator = cosDegrees(latitude) * cosDegrees(declination);
  if (denominator.abs() < 1e-12) return null;
  final cosine =
      (sinDegrees(altitude) - sinDegrees(latitude) * sinDegrees(declination)) /
      denominator;
  if (cosine < -1 || cosine > 1) return null;
  return math.acos(cosine) / radiansPerDegree;
}

Duration _minutes(double minutes) =>
    Duration(microseconds: (minutes * Duration.microsecondsPerMinute).round());
