import 'dart:typed_data';

import 'package:flutter/painting.dart';

/// Mirrors a path left to right about the origin.
final Float64List _mirrorX = Float64List.fromList([
  -1, 0, 0, 0, //
  0, 1, 0, 0,
  0, 0, 1, 0,
  0, 0, 0, 1,
]);

/// The lit part of a moon of [radius] centred on the origin, with [fraction]
/// of the disc lit (0 new, 1 full).
///
/// The lit side is a half disc; the terminator is half an ellipse of
/// half-width `radius · |2·fraction − 1|`, bulging into the lit half for a
/// crescent and into the dark half for a gibbous moon. [litOnRight] puts the
/// lit side on the right, as for a waxing moon seen from the north.
Path moonLitPath({
  required double radius,
  required double fraction,
  required bool litOnRight,
}) {
  final f = fraction.clamp(0.0, 1.0);
  final terminator = Radius.elliptical(radius * (2 * f - 1).abs(), radius);
  final path = Path()
    ..moveTo(0, -radius)
    // The lit limb, top to bottom down the right side.
    ..arcToPoint(
      Offset(0, radius),
      radius: Radius.circular(radius),
    )
    // Back up through the terminator: right of centre for a crescent,
    // left of it for a gibbous moon.
    ..arcToPoint(
      Offset(0, -radius),
      radius: terminator,
      clockwise: f > 0.5,
    )
    ..close();
  return litOnRight ? path : path.transform(_mirrorX);
}
