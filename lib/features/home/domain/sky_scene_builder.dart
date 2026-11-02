import 'package:fasomo/core/astronomy/astro_math.dart';
import 'package:fasomo/core/astronomy/lunar.dart';
import 'package:fasomo/core/astronomy/solar.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/features/home/domain/entities/celestial_body_state.dart';
import 'package:fasomo/features/home/domain/entities/moon_phase.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';

/// The sky over [location] at [now] (the clock's local time). Pure and
/// total: a few thousand trigonometric calls, well under a millisecond.
SkyScene buildSkyScene(DateTime now, GeoPoint location) {
  final latitude = location.latitude;
  final longitude = location.longitude;
  final illumination = moonIllumination(now);
  final moonNow = moonPosition(now, latitude: latitude, longitude: longitude);

  return SkyScene(
    now: now,
    location: location,
    sun: _sun(now, latitude, longitude),
    moon: _moon(now, latitude, longitude),
    moonPhase: MoonPhase(
      illuminatedFraction: illumination.fraction,
      phase: illumination.phase,
      brightLimbZenithAngleDegrees: signedDegrees(
        illumination.brightLimbAngleDegrees - moonNow.parallacticAngleDegrees,
      ),
    ),
  );
}

CelestialBodyState _sun(DateTime now, double latitude, double longitude) {
  final position = sunPosition(now, latitude: latitude, longitude: longitude);
  final isUp = position.altitudeDegrees > sunriseAltitudeDegrees;

  // The pass under way, or the next one. Yesterday and tomorrow are checked
  // too, since the location's solar day need not match the phone's date.
  final days = [
    for (final offset in [-1, 0, 1, 2])
      sunTimes(
        DateTime(now.year, now.month, now.day + offset),
        latitude: latitude,
        longitude: longitude,
      ),
  ];
  bool current(SunTimes day) =>
      day.sunrise != null &&
      day.sunset != null &&
      !day.sunrise!.isAfter(now) &&
      !day.sunset!.isBefore(now);
  bool upcoming(SunTimes day) =>
      day.sunrise != null && day.sunrise!.isAfter(now);
  final pass = days.firstWhere(
    isUp ? current : upcoming,
    orElse: () => days[1],
  );

  return CelestialBodyState(
    altitudeDegrees: position.altitudeDegrees,
    azimuthDegrees: position.azimuthDegrees,
    hourAngleDegrees: position.hourAngleDegrees,
    isUp: isUp,
    rise: pass.sunrise,
    set: pass.sunset,
    peakAltitudeDegrees: pass.noonAltitudeDegrees,
  );
}

CelestialBodyState _moon(DateTime now, double latitude, double longitude) {
  const reach = Duration(hours: 30);
  final position = moonPosition(now, latitude: latitude, longitude: longitude);
  final times = moonTimes(
    now.subtract(reach),
    latitude: latitude,
    longitude: longitude,
    span: reach * 2,
  );

  final lastRise = times.rises.where((t) => !t.isAfter(now)).lastOrNull;
  final lastSet = times.sets.where((t) => !t.isAfter(now)).lastOrNull;
  final isUp = switch ((lastRise, lastSet)) {
    (null, null) => times.isUpAtStart,
    (_?, null) => true,
    (null, _?) => false,
    (final rise?, final set?) => rise.isAfter(set),
  };

  final DateTime? rise;
  final DateTime? set;
  if (isUp) {
    rise = lastRise;
    set = times.sets.where((t) => t.isAfter(now)).firstOrNull;
  } else {
    final nextRise = times.rises.where((t) => t.isAfter(now)).firstOrNull;
    rise = nextRise;
    set = nextRise == null
        ? null
        : times.sets.where((t) => t.isAfter(nextRise)).firstOrNull;
  }

  return CelestialBodyState(
    altitudeDegrees: position.altitudeDegrees,
    azimuthDegrees: position.azimuthDegrees,
    hourAngleDegrees: position.hourAngleDegrees,
    isUp: isUp,
    rise: rise,
    set: set,
    peakAltitudeDegrees: _moonPeak(
      rise,
      set,
      latitude,
      longitude,
      position.declinationDegrees,
    ),
  );
}

/// The moon's highest altitude between [rise] and [set], sampled every 15
/// minutes; without both, the meridian altitude at its declination.
double _moonPeak(
  DateTime? rise,
  DateTime? set,
  double latitude,
  double longitude,
  double declination,
) {
  if (rise == null || set == null || !set.isAfter(rise)) {
    return 90 - (latitude - declination).abs();
  }
  var peak = -90.0;
  for (var t = rise; t.isBefore(set); t = t.add(const Duration(minutes: 15))) {
    final altitude = moonPosition(
      t,
      latitude: latitude,
      longitude: longitude,
    ).altitudeDegrees;
    if (altitude > peak) peak = altitude;
  }
  return peak;
}
