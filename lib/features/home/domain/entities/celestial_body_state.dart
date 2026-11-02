import 'package:equatable/equatable.dart';

/// The sun or the moon at one instant, with the pass across the sky it is
/// on (if it is up) or about to make (if it is down).
final class CelestialBodyState extends Equatable {
  const new({
    required this.altitudeDegrees,
    required this.azimuthDegrees,
    required this.hourAngleDegrees,
    required this.isUp,
    required this.peakAltitudeDegrees,
    this.rise,
    this.set,
  });

  /// Degrees above the horizon; negative below it.
  final double altitudeDegrees;

  /// Compass bearing, 0..360 from north through east.
  final double azimuthDegrees;

  /// −180..180: negative while climbing, 0 at the meridian.
  final double hourAngleDegrees;

  /// Whether the upper limb is above the horizon.
  final bool isUp;

  /// Rise of the current pass when [isUp], else of the next one. UTC;
  /// `null` when there is none within a day (polar day or night).
  final DateTime? rise;

  /// Set of the current pass when [isUp], else of the next one. UTC; `null`
  /// when there is none within a day.
  final DateTime? set;

  /// The highest altitude of the pass, at the meridian.
  final double peakAltitudeDegrees;

  @override
  List<Object?> get props => [
    altitudeDegrees,
    azimuthDegrees,
    hourAngleDegrees,
    isUp,
    rise,
    set,
    peakAltitudeDegrees,
  ];
}
