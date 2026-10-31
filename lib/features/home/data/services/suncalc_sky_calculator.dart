import 'dart:math' as math;

import 'package:dart_suncalc/suncalc.dart';
import 'package:dart_suncalc/types.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/services/sky_calculator.dart';

/// [SkyCalculator] on `dart_suncalc`, the only file that imports it. The
/// package works in radians, azimuth from south toward west, and UTC.
class SuncalcSkyCalculator implements SkyCalculator {
  const new();

  @override
  CelestialBodyState sun(DateTime now, GeoPoint at) {
    final position = SunCalc.getSunPosition(
      now.toUtc(),
      lat: at.latitude,
      lng: at.longitude,
    );
    // Asking at local noon gives today's sunrise and sunset.
    final noon = DateTime(now.year, now.month, now.day, 12).toUtc();
    final times = SunCalc.getTimes(noon, lat: at.latitude, lng: at.longitude);
    return CelestialBodyState(
      altitudeDegrees: _degrees(position.altitude),
      azimuthDegrees: _degrees(position.azimuth),
      rise: times.sunrise?.toLocal(),
      set: times.sunset?.toLocal(),
    );
  }

  @override
  CelestialBodyState moon(DateTime now, GeoPoint at) {
    final position = SunCalc.getMoonPosition(
      now.toUtc(),
      lat: at.latitude,
      lng: at.longitude,
    );
    final (rise, set) = _moonPass(now, at);
    return CelestialBodyState(
      altitudeDegrees: _degrees(position.altitude),
      azimuthDegrees: _degrees(position.azimuth),
      rise: rise,
      set: set,
    );
  }

  @override
  MoonPhase moonPhase(DateTime now) {
    final illumination = SunCalc.getMoonIllumination(now.toUtc());
    return MoonPhase(
      fraction: illumination.fraction,
      phase: illumination.phase,
    );
  }

  /// The moon's pass that contains [now], or the next one. A pass often spans
  /// midnight, so yesterday's, today's and tomorrow's events are searched:
  /// the latest rise up to [now] and the first set after it.
  (DateTime?, DateTime?) _moonPass(DateTime now, GeoPoint at) {
    final today = CalendarDays.dateOnly(now);
    final days = [
      for (final offset in [-1, 0, 1]) _moonTimes(today, offset, at),
    ];
    final rises = [for (final t in days) ?t.riseDateTime?.toLocal()];
    final sets = [for (final t in days) ?t.setDateTime?.toLocal()];

    final risenAt = rises
        .where((r) => !r.isAfter(now))
        .fold<DateTime?>(
          null,
          (latest, r) => latest == null || r.isAfter(latest) ? r : latest,
        );
    final rise = risenAt ?? rises.where((r) => r.isAfter(now)).firstOrNull;
    final set = sets
        .where((s) => rise != null && s.isAfter(rise) && s.isAfter(now))
        .fold<DateTime?>(
          null,
          (first, s) => first == null || s.isBefore(first) ? s : first,
        );
    return (rise, set);
  }

  static MoonTimes _moonTimes(DateTime today, int offset, GeoPoint at) =>
      SunCalc.getMoonTimes(
        CalendarDays.addDays(today, offset),
        lat: at.latitude,
        lng: at.longitude,
        inUtc: false,
      );

  static double _degrees(double radians) => radians * 180 / math.pi;
}
