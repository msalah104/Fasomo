/// Shared angle and time helpers for the astronomy library.
///
/// Every function here is total: any finite input gives a finite output.
library;

import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// Radians per degree.
const double radiansPerDegree = math.pi / 180;

/// Julian Day of the J2000.0 epoch, 2000-01-01 12:00 TT.
const double julianDayJ2000 = 2451545;

/// The Julian Day of [time], a continuous day count used by every formula.
///
/// Only the instant matters, so a local and a UTC [DateTime] of the same
/// moment give the same value.
double julianDay(DateTime time) =>
    time.millisecondsSinceEpoch / Duration.millisecondsPerDay + 2440587.5;

/// The UTC instant of Julian Day [julianDay].
DateTime dateTimeFromJulianDay(double julianDay) =>
    DateTime.fromMillisecondsSinceEpoch(
      ((julianDay - 2440587.5) * Duration.millisecondsPerDay).round(),
      isUtc: true,
    );

/// Julian centuries of 36525 days since J2000.0, the time argument of the
/// series expansions.
double julianCenturies(DateTime time) =>
    (julianDay(time) - julianDayJ2000) / 36525;

/// [degrees] wrapped into 0 (inclusive) to 360 (exclusive).
double normalizeDegrees(double degrees) => degrees % 360;

/// [degrees] wrapped into -180 (exclusive) to 180 (inclusive).
double signedDegrees(double degrees) {
  final wrapped = degrees % 360;
  return wrapped > 180 ? wrapped - 360 : wrapped;
}

double sinDegrees(double degrees) => math.sin(degrees * radiansPerDegree);

double cosDegrees(double degrees) => math.cos(degrees * radiansPerDegree);

/// Arc sine in degrees, with the argument clamped to -1..1 so rounding
/// error never produces NaN.
double asinDegrees(double value) =>
    math.asin(value.clamp(-1.0, 1.0)) / radiansPerDegree;

/// Two-argument arc tangent in degrees, -180..180.
double atan2Degrees(double y, double x) => math.atan2(y, x) / radiansPerDegree;

/// Greenwich mean sidereal time at [time], in degrees 0..360.
double greenwichSiderealDegrees(DateTime time) {
  final days = julianDay(time) - julianDayJ2000;
  final t = days / 36525;
  return normalizeDegrees(
    280.46061837 +
        360.98564736629 * days +
        0.000387933 * t * t -
        t * t * t / 38710000,
  );
}

/// A direction in the observer's sky.
final class HorizontalPosition extends Equatable {
  const new({required this.altitudeDegrees, required this.azimuthDegrees});

  /// Converts equatorial coordinates seen from latitude [latitudeDegrees]
  /// at local hour angle [hourAngleDegrees].
  factory fromEquatorial({
    required double hourAngleDegrees,
    required double declinationDegrees,
    required double latitudeDegrees,
  }) {
    final h = hourAngleDegrees * radiansPerDegree;
    final d = declinationDegrees * radiansPerDegree;
    final phi = latitudeDegrees * radiansPerDegree;
    final altitude = asinDegrees(
      math.sin(phi) * math.sin(d) + math.cos(phi) * math.cos(d) * math.cos(h),
    );
    // Measured from south towards west, then turned to start from north.
    final azimuth =
        math.atan2(
          math.sin(h),
          math.cos(h) * math.sin(phi) - math.tan(d) * math.cos(phi),
        ) /
        radiansPerDegree;
    return HorizontalPosition(
      altitudeDegrees: altitude,
      azimuthDegrees: normalizeDegrees(azimuth + 180),
    );
  }

  /// Degrees above the horizon, -90..90; negative when below it.
  final double altitudeDegrees;

  /// Compass bearing in degrees, 0..360, from north through east.
  final double azimuthDegrees;

  @override
  List<Object> get props => [altitudeDegrees, azimuthDegrees];
}

/// The parallactic angle in degrees: the tilt between the direction to the
/// celestial north pole and the direction to the zenith, at a body seen at
/// [hourAngleDegrees] from [latitudeDegrees] (Meeus, eq. 14.1).
double parallacticAngleDegrees({
  required double hourAngleDegrees,
  required double declinationDegrees,
  required double latitudeDegrees,
}) {
  final h = hourAngleDegrees * radiansPerDegree;
  final d = declinationDegrees * radiansPerDegree;
  final phi = latitudeDegrees * radiansPerDegree;
  return math.atan2(
        math.sin(h),
        math.tan(phi) * math.cos(d) - math.sin(d) * math.cos(h),
      ) /
      radiansPerDegree;
}
