import 'package:equatable/equatable.dart';

/// The eight named phases of the moon.
enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent;

  /// The name for [phase], 0..1 through the cycle (0 new, 0.5 full). The
  /// principal phases are named for about a day either side of the instant.
  static MoonPhaseName fromPhase(double phase) {
    const day = 1 / 29.53;
    final p = phase % 1;
    if (p < day || p > 1 - day) return newMoon;
    if (p < 0.25 - day) return waxingCrescent;
    if (p <= 0.25 + day) return firstQuarter;
    if (p < 0.5 - day) return waxingGibbous;
    if (p <= 0.5 + day) return fullMoon;
    if (p < 0.75 - day) return waningGibbous;
    if (p <= 0.75 + day) return lastQuarter;
    return waningCrescent;
  }
}

/// How the moon looks: how much is lit and which way the lit side faces.
final class MoonPhase extends Equatable {
  const new({
    required this.illuminatedFraction,
    required this.phase,
    required this.brightLimbZenithAngleDegrees,
  });

  /// 0 (new) to 1 (full).
  final double illuminatedFraction;

  /// 0..1 through the cycle: 0 new, 0.25 first quarter, 0.5 full.
  final double phase;

  /// Which way the lit side faces in the observer's sky: degrees from
  /// straight up, counter-clockwise as seen with east on the left (the view
  /// facing south from the northern hemisphere). The lit side faces the sun.
  final double brightLimbZenithAngleDegrees;

  bool get isWaxing => phase < 0.5;

  MoonPhaseName get name => MoonPhaseName.fromPhase(phase);

  @override
  List<Object> get props => [
    illuminatedFraction,
    phase,
    brightLimbZenithAngleDegrees,
  ];
}
