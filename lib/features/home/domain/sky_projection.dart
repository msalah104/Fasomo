import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:fasomo/features/home/domain/entities/celestial_body_state.dart';

/// Where a body sits on the stylised sky arc, in unit coordinates.
final class SkyPoint extends Equatable {
  const new({required this.x, required this.y, required this.isOnArc});

  /// 0 at the rise edge (the reading-start side), 1 at the set edge.
  final double x;

  /// 0 on the horizon, 1 at the top of the arc.
  final double y;

  /// Whether the point lies on the arc `y = sin(πx)` drawn for the pass. It
  /// does not when the body neither rises nor sets that day.
  final bool isOnArc;

  @override
  List<Object> get props => [x, y, isOnArc];
}

/// Maps a body's real pass onto a stylised arc that reads like a timeline.
///
/// A phone screen cannot show true azimuth and altitude well: a winter sun
/// would hug the bottom edge and a polar one never move. So [SkyPoint.x] is the
/// share of the pass that has elapsed and [SkyPoint.y] follows a half sine:
/// the rise is at the start edge, the meridian at the top centre and the set
/// at the end edge.
abstract final class SkyProjection {
  /// Where [body] sits at [now], or `null` while it is below the horizon.
  static SkyPoint? project(CelestialBodyState body, DateTime now) {
    if (!body.isUp) return null;
    final rise = body.rise;
    final set = body.set;
    if (rise != null && set != null && set.isAfter(rise)) {
      final elapsed = now.difference(rise).inMilliseconds;
      final total = set.difference(rise).inMilliseconds;
      final x = (elapsed / total).clamp(0.0, 1.0);
      return SkyPoint(x: x, y: math.sin(math.pi * x), isOnArc: true);
    }
    // Up all day: across by hour angle, up by altitude against the peak.
    final peak = body.peakAltitudeDegrees;
    return SkyPoint(
      x: ((body.hourAngleDegrees + 180) / 360).clamp(0.0, 1.0),
      y: peak > 0 ? (body.altitudeDegrees / peak).clamp(0.0, 1.0) : 0,
      isOnArc: false,
    );
  }
}
