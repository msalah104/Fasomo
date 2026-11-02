import 'package:equatable/equatable.dart';
import 'package:fasomo/core/theme/primitives.dart';
import 'package:fasomo/core/theme/sky_cycle.dart';
import 'package:flutter/services.dart';

/// Every colour of the live Home sky for one sun altitude: a snapshot the
/// painter and the overlays read, so nothing calls `Theme.of` while painting.
///
/// Like [SkyCycle], the sky follows the real sun rather than the app theme,
/// so the light and dark themes share it.
final class SkyPalette extends Equatable {
  const new({
    required this.skyTop,
    required this.skyMiddle,
    required this.skyHorizon,
    required this.ground,
    required this.starOpacity,
    required this.sunDisc,
    required this.sunGlow,
    required this.moonLit,
    required this.moonShadow,
    required this.isSkyLight,
  });

  /// The palette for a sun at [altitudeDegrees]: night below −18°, through
  /// the twilights and the golden hour, to full day above 10°.
  factory forSunAltitude(double altitudeDegrees) {
    final cycle = _cycleAt(altitudeDegrees);
    final stars = ((-6 - altitudeDegrees) / 6).clamp(0.0, 1.0);
    final sunHeight = (altitudeDegrees / 15).clamp(0.0, 1.0);
    return SkyPalette(
      skyTop: cycle.top,
      skyMiddle: cycle.middle,
      skyHorizon: cycle.horizon,
      ground: cycle.ground,
      starOpacity: stars,
      sunDisc: Color.lerp(SkyCycle.sunLow, SkyCycle.sunHigh, sunHeight)!,
      sunGlow: SkyCycle.sunGlow,
      moonLit: SkyCycle.moon,
      // Earthshine on the dark part, visible only against a dark sky.
      moonShadow: SkyCycle.moon.withValues(alpha: 0.14 * stars),
      isSkyLight: cycle.top.computeLuminance() > _lightSkyLuminance,
    );
  }

  /// Above this, text on the open sky is dark; below it, light. It is where
  /// both inks give the same contrast (about 3.6:1), so neither falls lower.
  static const double _lightSkyLuminance = 0.21;

  /// Below this the sky is dark enough for the gold letter of the logo to
  /// keep 3:1; between it and [_lightSkyLuminance] the letter is ivory.
  static const double _goldLogoLuminance = 0.14;

  final Color skyTop;
  final Color skyMiddle;
  final Color skyHorizon;

  /// The skyline and the band below it that carries the date and times.
  final Color ground;

  /// 0 by day, 1 once the sun is 12° below the horizon.
  final double starOpacity;

  final Color sunDisc;
  final Color sunGlow;
  final Color moonLit;

  /// The unlit part of the moon's disc.
  final Color moonShadow;

  /// Whether the top of the sky is light enough to need dark ink.
  final bool isSkyLight;

  Color get star => SkyCycle.star;

  /// Icons and text drawn straight on the open sky.
  Color get ink => isSkyLight ? Primitives.indigo27 : Primitives.ivory96;

  /// The fill behind the location chip, so its text stays at 4.5:1 on any
  /// part of the sky.
  Color get chipFill => isSkyLight
      ? Primitives.ivory96.withValues(alpha: 0.7)
      : Primitives.indigo12.withValues(alpha: 0.5);

  /// The faint dots of the body's path.
  Color get arc => ink.withValues(alpha: 0.35);

  /// The ف of the logo mark on the open sky: gold at night, as on the splash.
  Color get logoInk {
    if (isSkyLight) return Primitives.indigo27;
    return skyTop.computeLuminance() < _goldLogoLuminance
        ? Primitives.gold80
        : Primitives.ivory96;
  }

  /// The new-moon dot of the logo mark.
  Color get logoDot => isSkyLight ? Primitives.gold75 : Primitives.ivory96;

  /// Text on the [ground] band.
  Color get groundInk => Primitives.ivory96;

  /// Status bar icons that read on [skyTop].
  SystemUiOverlayStyle get overlayStyle =>
      isSkyLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;

  @override
  List<Object> get props => [
    skyTop,
    skyMiddle,
    skyHorizon,
    ground,
    starOpacity,
    sunDisc,
    sunGlow,
    moonLit,
    moonShadow,
    isSkyLight,
  ];

  /// The sky at sun altitudes, low to high; colours between are mixed.
  static final List<(double, SkyCycle)> _keyframes = [
    (-18, SkyCycle.night),
    (-12, _mix(SkyCycle.night, SkyCycle.dusk, 0.3)),
    (-6, _mix(SkyCycle.night, SkyCycle.dusk, 0.7)),
    (-1, SkyCycle.dusk),
    (4, _golden),
    (10, SkyCycle.day),
  ];

  /// A low sun: blue overhead, gold at the horizon.
  static final SkyCycle _golden = SkyCycle(
    top: Color.lerp(SkyCycle.dusk.top, SkyCycle.day.top, 0.6)!,
    middle: Color.lerp(SkyCycle.dusk.middle, SkyCycle.day.middle, 0.45)!,
    horizon: SkyCycle.dusk.horizon,
    ground: Color.lerp(SkyCycle.dusk.ground, SkyCycle.day.ground, 0.5)!,
  );

  static SkyCycle _cycleAt(double altitude) {
    final (firstAltitude, first) = _keyframes.first;
    if (altitude <= firstAltitude) return first;
    for (var i = 1; i < _keyframes.length; i++) {
      final (lowAltitude, low) = _keyframes[i - 1];
      final (highAltitude, high) = _keyframes[i];
      if (altitude <= highAltitude) {
        final t = (altitude - lowAltitude) / (highAltitude - lowAltitude);
        return _mix(low, high, t);
      }
    }
    return _keyframes.last.$2;
  }

  static SkyCycle _mix(SkyCycle a, SkyCycle b, double t) => SkyCycle(
    top: Color.lerp(a.top, b.top, t)!,
    middle: Color.lerp(a.middle, b.middle, t)!,
    horizon: Color.lerp(a.horizon, b.horizon, t)!,
    ground: Color.lerp(a.ground, b.ground, t)!,
  );
}
