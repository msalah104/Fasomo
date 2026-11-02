/// The moon, by the Astronomical Almanac's low-precision series: about 0.3°
/// in position, a few minutes in rise and set times, and well under 1% in
/// lit fraction. Plenty for drawing the sky and naming the phase; not for
/// predicting the first sighting of a crescent.
///
/// Every function is pure and total and takes instants as [DateTime]s, which
/// may be local or UTC; results are UTC.
library;

import 'dart:math' as math;

import 'package:fasomo/core/astronomy/astro_math.dart';
import 'package:fasomo/core/astronomy/solar.dart';

/// Equatorial radius of the Earth, km.
const double _earthRadiusKm = 6378.14;

/// One astronomical unit, km.
const double _auKm = 149597870.7;

/// The moon in the sky of an observer at one instant.
final class MoonPosition {
  const new({
    required this.horizontal,
    required this.hourAngleDegrees,
    required this.declinationDegrees,
    required this.distanceKm,
    required this.parallacticAngleDegrees,
  });

  /// Topocentric altitude (corrected for parallax, no refraction) and
  /// azimuth of the moon's centre.
  final HorizontalPosition horizontal;

  double get altitudeDegrees => horizontal.altitudeDegrees;

  double get azimuthDegrees => horizontal.azimuthDegrees;

  /// Local hour angle, -180..180: negative while the moon climbs towards
  /// the meridian, positive after it.
  final double hourAngleDegrees;

  final double declinationDegrees;

  /// Centre to centre, about 356 500..406 700 km.
  final double distanceKm;

  /// The angle from the direction of the celestial north pole to the
  /// direction of the zenith, at the moon. Subtract it from
  /// [MoonIllumination.brightLimbAngleDegrees] to get the lit side's angle
  /// from "up" in the observer's sky.
  final double parallacticAngleDegrees;
}

/// Where the moon is at [time] for an observer at [latitude], [longitude]
/// (degrees, north and east positive).
MoonPosition moonPosition(
  DateTime time, {
  required double latitude,
  required double longitude,
}) {
  final moon = _moonCoordinates(time);
  final hourAngle = signedDegrees(
    greenwichSiderealDegrees(time) + longitude - moon.rightAscension,
  );
  final geocentric = HorizontalPosition.fromEquatorial(
    hourAngleDegrees: hourAngle,
    declinationDegrees: moon.declination,
    latitudeDegrees: latitude,
  );
  // Seen from the Earth's surface the moon sits lower than from its centre,
  // by up to its horizontal parallax (about 1°) at the horizon.
  final topocentricAltitude =
      geocentric.altitudeDegrees -
      moon.parallax * cosDegrees(geocentric.altitudeDegrees);
  return MoonPosition(
    horizontal: HorizontalPosition(
      altitudeDegrees: topocentricAltitude,
      azimuthDegrees: geocentric.azimuthDegrees,
    ),
    hourAngleDegrees: hourAngle,
    declinationDegrees: moon.declination,
    distanceKm: moon.distanceKm,
    parallacticAngleDegrees: parallacticAngleDegrees(
      hourAngleDegrees: hourAngle,
      declinationDegrees: moon.declination,
      latitudeDegrees: latitude,
    ),
  );
}

/// The moonrises and moonsets in a span of time.
final class MoonTimes {
  const new({
    required this.rises,
    required this.sets,
    required this.isUpAtStart,
  });

  /// UTC, in order. Usually one or none a day; the moon rises about 50
  /// minutes later each day, so some days have no rise or no set.
  final List<DateTime> rises;

  /// UTC, in order.
  final List<DateTime> sets;

  /// Whether the moon was above the horizon when the span began.
  final bool isUpAtStart;

  /// The first moonrise of the span, if any.
  DateTime? get rise => rises.isEmpty ? null : rises.first;

  /// The first moonset of the span, if any.
  DateTime? get set => sets.isEmpty ? null : sets.first;

  /// Whether the moon stayed up through the whole span.
  bool get isAlwaysUp => rises.isEmpty && sets.isEmpty && isUpAtStart;

  /// Whether the moon stayed down through the whole span.
  bool get isAlwaysDown => rises.isEmpty && sets.isEmpty && !isUpAtStart;
}

/// Every moonrise and moonset from [start] for [span] (a day by default) at
/// [latitude], [longitude].
///
/// A rise or set is the moment the moon's upper limb meets the horizon,
/// allowing for refraction and parallax (Meeus, ch. 15). For "today", pass
/// the observer's local midnight as [start].
MoonTimes moonTimes(
  DateTime start, {
  required double latitude,
  required double longitude,
  Duration span = const Duration(days: 1),
}) {
  double aboveHorizon(DateTime time) =>
      _moonGeocentricAltitude(time, latitude, longitude) -
      _moonRiseAltitude(time);

  const step = Duration(minutes: 10);
  final from = start.toUtc();
  final end = from.add(span);
  final rises = <DateTime>[];
  final sets = <DateTime>[];
  var before = from;
  var valueBefore = aboveHorizon(before);
  final isUpAtStart = valueBefore > 0;

  while (before.isBefore(end)) {
    var after = before.add(step);
    if (after.isAfter(end)) after = end;
    final valueAfter = aboveHorizon(after);
    if ((valueBefore > 0) != (valueAfter > 0)) {
      final crossing = _bisect(aboveHorizon, before, after);
      (valueAfter > 0 ? rises : sets).add(crossing);
    }
    before = after;
    valueBefore = valueAfter;
  }
  return MoonTimes(rises: rises, sets: sets, isUpAtStart: isUpAtStart);
}

/// How much of the moon is lit and which way the lit side faces.
final class MoonIllumination {
  const new({
    required this.fraction,
    required this.phase,
    required this.brightLimbAngleDegrees,
  });

  /// Lit fraction of the disc, 0 (new) to 1 (full).
  final double fraction;

  /// Position in the cycle, 0..1: 0 new, 0.25 first quarter, 0.5 full,
  /// 0.75 last quarter. It is the moon's elongation in longitude from the
  /// sun over 360°.
  final double phase;

  /// Position angle of the middle of the lit limb, 0..360, from celestial
  /// north through east (Meeus, eq. 48.5). The lit side faces the sun.
  final double brightLimbAngleDegrees;

  /// Whether the lit part is growing: from new moon to full moon.
  bool get isWaxing => phase < 0.5;
}

/// The moon's phase at [time], as seen from the Earth's centre.
MoonIllumination moonIllumination(DateTime time) {
  final sun = solarCoordinates(time);
  final moon = _moonCoordinates(time);
  final sunDistanceKm = sun.distanceAu * _auKm;

  final elongation = math.acos(
    (cosDegrees(moon.latitude) *
            cosDegrees(moon.longitude - sun.apparentLongitudeDegrees))
        .clamp(-1.0, 1.0),
  );
  final phaseAngle = math.atan2(
    sunDistanceKm * math.sin(elongation),
    moon.distanceKm - sunDistanceKm * math.cos(elongation),
  );

  final deltaRa = sun.rightAscensionDegrees - moon.rightAscension;
  final brightLimb = atan2Degrees(
    cosDegrees(sun.declinationDegrees) * sinDegrees(deltaRa),
    sinDegrees(sun.declinationDegrees) * cosDegrees(moon.declination) -
        cosDegrees(sun.declinationDegrees) *
            sinDegrees(moon.declination) *
            cosDegrees(deltaRa),
  );

  return MoonIllumination(
    fraction: (1 + math.cos(phaseAngle)) / 2,
    phase:
        normalizeDegrees(moon.longitude - sun.apparentLongitudeDegrees) / 360,
    brightLimbAngleDegrees: normalizeDegrees(brightLimb),
  );
}

/// The moon's geocentric ecliptic and equatorial coordinates.
final class _MoonCoordinates {
  const new({
    required this.longitude,
    required this.latitude,
    required this.parallax,
    required this.rightAscension,
    required this.declination,
  });

  final double longitude;
  final double latitude;

  /// Horizontal parallax, degrees.
  final double parallax;
  final double rightAscension;
  final double declination;

  double get distanceKm => _earthRadiusKm / sinDegrees(parallax);
}

_MoonCoordinates _moonCoordinates(DateTime time) {
  final t = julianCenturies(time);
  final longitude =
      218.32 +
      481267.881 * t +
      6.29 * sinDegrees(135.0 + 477198.87 * t) -
      1.27 * sinDegrees(259.3 - 413335.36 * t) +
      0.66 * sinDegrees(235.7 + 890534.22 * t) +
      0.21 * sinDegrees(269.9 + 954397.74 * t) -
      0.19 * sinDegrees(357.5 + 35999.05 * t) -
      0.11 * sinDegrees(186.5 + 966404.03 * t);
  final latitude =
      5.13 * sinDegrees(93.3 + 483202.02 * t) +
      0.28 * sinDegrees(228.2 + 960400.89 * t) -
      0.28 * sinDegrees(318.3 + 6003.15 * t) -
      0.17 * sinDegrees(217.6 - 407332.21 * t);
  final parallax =
      0.9508 +
      0.0518 * cosDegrees(135.0 + 477198.87 * t) +
      0.0095 * cosDegrees(259.3 - 413335.36 * t) +
      0.0078 * cosDegrees(235.7 + 890534.22 * t) +
      0.0028 * cosDegrees(269.9 + 954397.74 * t);

  final obliquity = 23.439291 - 0.0130042 * t;
  final x = cosDegrees(latitude) * cosDegrees(longitude);
  final y =
      cosDegrees(obliquity) * cosDegrees(latitude) * sinDegrees(longitude) -
      sinDegrees(obliquity) * sinDegrees(latitude);
  final z =
      sinDegrees(obliquity) * cosDegrees(latitude) * sinDegrees(longitude) +
      cosDegrees(obliquity) * sinDegrees(latitude);

  return _MoonCoordinates(
    longitude: normalizeDegrees(longitude),
    latitude: latitude,
    parallax: parallax,
    rightAscension: normalizeDegrees(atan2Degrees(y, x)),
    declination: asinDegrees(z),
  );
}

double _moonGeocentricAltitude(
  DateTime time,
  double latitude,
  double longitude,
) {
  final moon = _moonCoordinates(time);
  return HorizontalPosition.fromEquatorial(
    hourAngleDegrees:
        greenwichSiderealDegrees(time) + longitude - moon.rightAscension,
    declinationDegrees: moon.declination,
    latitudeDegrees: latitude,
  ).altitudeDegrees;
}

/// The geocentric altitude of the moon's centre at moonrise: parallax lifts
/// the horizon, refraction and the semi-diameter lower it (Meeus, eq. 15.1).
double _moonRiseAltitude(DateTime time) =>
    0.7275 * _moonCoordinates(time).parallax - 0.5667;

/// The instant between [low] and [high] where [f] changes sign, to within a
/// second.
DateTime _bisect(
  double Function(DateTime) f,
  DateTime low,
  DateTime high,
) {
  var a = low;
  var b = high;
  final signA = f(a) > 0;
  while (b.difference(a) > const Duration(seconds: 1)) {
    final middle = a.add(b.difference(a) ~/ 2);
    if ((f(middle) > 0) == signA) {
      a = middle;
    } else {
      b = middle;
    }
  }
  return a.add(b.difference(a) ~/ 2);
}
