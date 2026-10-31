import 'dart:math' as math;

import 'package:fasomo/features/home/domain/entities/sky_scene.dart';

/// A point in the header's sky, as fractions: `x` 0 at the start edge (where
/// bodies rise) to 1 at the end edge, `y` 0 on the horizon to 1 at the top
/// of the arc.
typedef SkyPoint = ({double x, double y});

/// Maps a body onto a stylised arc. Real altitudes would look odd on a phone
/// (a low winter sun, a sun that never sets), so the arc is the same every
/// day and real data only says how far along it the body is. Pure.
abstract final class SkyProjection {
  /// Where [body] sits on the arc at [now], or `null` when it's below the
  /// horizon.
  static SkyPoint? place(CelestialBodyState body, DateTime now) {
    if (!body.isUp) return null;
    final x = _progress(body, now);
    return (x: x, y: arcHeight(x));
  }

  /// The arc's height at [x]: 0 at both edges, 1 in the middle.
  static double arcHeight(double x) => math.sin(math.pi * x.clamp(0.0, 1.0));

  static double _progress(CelestialBodyState body, DateTime now) {
    final (rise, set) = (body.rise, body.set);
    if (rise != null && set != null && set.isAfter(rise)) {
      final total = set.difference(rise).inSeconds;
      return (now.difference(rise).inSeconds / total).clamp(0.0, 1.0);
    }
    // No rise or set (near the poles): east to west by azimuth instead.
    return ((body.azimuthDegrees + 90) / 180).clamp(0.0, 1.0);
  }
}
