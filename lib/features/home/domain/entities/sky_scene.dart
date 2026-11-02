import 'package:equatable/equatable.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/features/home/domain/entities/celestial_body_state.dart';
import 'package:fasomo/features/home/domain/entities/day_phase.dart';
import 'package:fasomo/features/home/domain/entities/moon_phase.dart';
import 'package:fasomo/features/home/domain/sky_projection.dart';

/// The sky over [location] at [now]: an immutable snapshot the Home header
/// draws and describes.
final class SkyScene extends Equatable {
  const new({
    required this.now,
    required this.location,
    required this.sun,
    required this.moon,
    required this.moonPhase,
  });

  /// The moment, as read from the clock.
  final DateTime now;
  final GeoPoint location;
  final CelestialBodyState sun;
  final CelestialBodyState moon;
  final MoonPhase moonPhase;

  DayPhase get dayPhase => DayPhase.fromSunAltitude(sun.altitudeDegrees);

  /// Whether the sun is still climbing (or, at night, past midnight).
  bool get isMorning => sun.hourAngleDegrees < 0;

  /// The sun on the arc, or `null` below the horizon.
  SkyPoint? get sunPoint => SkyProjection.project(sun, now);

  /// The moon on the arc, or `null` below the horizon.
  SkyPoint? get moonPoint => SkyProjection.project(moon, now);

  @override
  List<Object> get props => [now, location, sun, moon, moonPhase];
}
