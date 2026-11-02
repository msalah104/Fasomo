import 'dart:math' as math;
import 'dart:ui';

import 'package:fasomo/core/presentation/skyline_art.dart';
import 'package:fasomo/features/home/domain/sky_projection.dart';

/// Where the parts of the Home sky sit on a canvas of [size].
///
/// The arc follows reading direction: in a right-to-left locale the rise is
/// on the right, so the sky reads like a timeline either way.
final class SkyLayout {
  const new(this.size, {required this.isRightToLeft});

  /// Highest point of the arc, clear of the logo and location row.
  static const double arcTop = 66;

  /// Horizontal inset of the arc's ends from the canvas edges.
  static const double edgeInset = 30;

  final Size size;
  final bool isRightToLeft;

  /// Canvas pixels per unit of the skyline art: the art's width across a
  /// phone, but never so tall that the skyline crowds the sky.
  double get artScale =>
      math.min(size.width / 380, size.height / 230).clamp(0.1, 10.0);

  /// Left edge of the art grid, placing the dome two thirds of the way
  /// across.
  double get artLeft => size.width * 0.66 - SkylineArt.domeX * artScale;

  /// Top of the art grid: the bottom of the ridge sits on the canvas edge,
  /// where the ground band takes over.
  double get artTop => size.height - SkylineArt.ridgeBottom * artScale;

  /// The horizon the arc stands on.
  double get horizonY => artTop + SkylineArt.horizon * artScale;

  /// Radius of the sun and moon discs.
  double get bodyRadius => (size.width * 0.034).clamp(10.0, 18.0);

  /// The canvas position of [point].
  Offset bodyCenter(SkyPoint point) {
    final across = edgeInset + point.x * (size.width - 2 * edgeInset);
    final top = math.min(arcTop, horizonY - bodyRadius * 2);
    return Offset(
      isRightToLeft ? size.width - across : across,
      horizonY - point.y * (horizonY - top),
    );
  }

  /// Turns an angle measured from straight up, counter-clockwise with east
  /// on the start side, into a canvas rotation (radians, clockwise) for
  /// something drawn pointing towards +x.
  double rotationFromZenithAngle(double degrees) {
    final clockwiseFromUp = isRightToLeft ? degrees : -degrees;
    return (clockwiseFromUp - 90) * math.pi / 180;
  }
}
