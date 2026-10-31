import 'package:equatable/equatable.dart';
import 'package:fasomo/core/location/geo_point.dart';

/// Where the sun or the moon is, and its current pass across the sky.
class CelestialBodyState extends Equatable {
  const new({
    required this.altitudeDegrees,
    required this.azimuthDegrees,
    this.rise,
    this.set,
  });

  /// Above the horizon when positive, corrected for refraction.
  final double altitudeDegrees;

  /// Measured from south toward west: east is −90, west 90.
  final double azimuthDegrees;

  /// The start and end of the pass that is in progress (or, for the sun,
  /// today's). `null` when the body doesn't rise or set, as near the poles.
  final DateTime? rise;
  final DateTime? set;

  bool get isUp => altitudeDegrees > 0;

  @override
  List<Object?> get props => [altitudeDegrees, azimuthDegrees, rise, set];
}

/// The moon's phase.
class MoonPhase extends Equatable {
  const new({required this.fraction, required this.phase});

  /// The lit fraction of the disc, 0..1.
  final double fraction;

  /// 0 new, 0.25 first quarter, 0.5 full, 0.75 last quarter.
  final double phase;

  bool get isWaxing => phase < 0.5;

  MoonPhaseName get name => MoonPhaseName.of(phase);

  @override
  List<Object> get props => [fraction, phase];
}

/// The eight traditional phase names.
enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  full,
  waningGibbous,
  lastQuarter,
  waningCrescent;

  /// Each name covers an eighth of the cycle, centred on its exact phase.
  static MoonPhaseName of(double phase) =>
      values[((phase * 8) + 0.5).floor() % 8];
}

/// How dark the sky is, from the sun's altitude.
enum DayPhase {
  night,
  astronomicalTwilight,
  nauticalTwilight,
  civilTwilight,
  goldenHour,
  day;

  static DayPhase fromSunAltitude(double degrees) => switch (degrees) {
    < -18 => night,
    < -12 => astronomicalTwilight,
    < -6 => nauticalTwilight,
    < -0.833 => civilTwilight,
    < 6 => goldenHour,
    _ => day,
  };

  /// Whether the sun is up (the golden hour or full day).
  bool get isDaylight => this == goldenHour || this == day;
}

/// One moment of the sky over [location]: everything the header draws.
class SkyScene extends Equatable {
  const new({
    required this.now,
    required this.location,
    required this.sun,
    required this.moon,
    required this.moonPhase,
  });

  final DateTime now;
  final GeoPoint location;
  final CelestialBodyState sun;
  final CelestialBodyState moon;
  final MoonPhase moonPhase;

  DayPhase get dayPhase => DayPhase.fromSunAltitude(sun.altitudeDegrees);

  @override
  List<Object> get props => [now, location, sun, moon, moonPhase];
}
