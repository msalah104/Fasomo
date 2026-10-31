import 'package:fasomo/core/theme/primitives.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// One moment of the sky as a vertical gradient, top to horizon.
///
/// The sky follows the scene (the splash, or the real sun on Home) rather
/// than the app theme, so these are fixed tokens rather than `AppColors`
/// slots.
@immutable
class SkyCycle {
  const new({
    required this.top,
    required this.middle,
    required this.horizon,
    required this.ground,
  });

  /// The sky at [phase]: 0 is [day], 0.5 [dusk] and 1 [night].
  factory at(double phase) {
    final p = phase.clamp(0.0, 1.0);
    return p < 0.5
        ? SkyCycle._lerp(day, dusk, p * 2)
        : SkyCycle._lerp(dusk, night, p * 2 - 1);
  }

  factory _lerp(SkyCycle a, SkyCycle b, double t) {
    Color mix(Color x, Color y) => Color.lerp(x, y, t)!;
    return SkyCycle(
      top: mix(a.top, b.top),
      middle: mix(a.middle, b.middle),
      horizon: mix(a.horizon, b.horizon),
      ground: mix(a.ground, b.ground),
    );
  }

  final Color top;
  final Color middle;
  final Color horizon;

  /// The skyline silhouette and the ground band below it.
  final Color ground;

  static const day = SkyCycle(
    top: Primitives.sky68,
    middle: Primitives.sky68,
    horizon: Primitives.sky88,
    ground: Primitives.indigo27,
  );

  static const dusk = SkyCycle(
    top: Primitives.dusk42,
    middle: Primitives.dusk70,
    horizon: Primitives.dusk82,
    ground: Primitives.indigo22,
  );

  static const night = SkyCycle(
    top: Primitives.indigo12,
    middle: Primitives.indigo27,
    horizon: Primitives.indigo38,
    ground: Primitives.indigo16,
  );

  /// The sun at its height, and as it sinks into the dusk.
  static const Color sunHigh = Primitives.sun85;
  static const Color sunLow = Primitives.dusk70;
  static const Color sunGlow = Primitives.sun92;

  static const Color moon = Primitives.moon94;
  static const Color star = Primitives.ivory96;

  /// The logo and app name once night has fallen.
  static const Color logoInk = Primitives.gold80;
  static const Color nameInk = Primitives.ivory96;
}
