import 'package:flutter/painting.dart';

/// The skyline from `design/art/sky_*.svg`: a dome and a minaret on a soft
/// ridge, in the art's own 600 × 400 space. Shared by the splash and the
/// Home sky so both draw the same horizon.
abstract final class Skyline {
  static const Size artSize = Size(600, 400);

  /// Roughly where the ridge meets the sky, in art units.
  static const double horizonY = 282;

  static final Path path = Path()
    ..moveTo(0, 292)
    ..quadraticBezierTo(90, 270, 180, 284)
    ..quadraticBezierTo(270, 298, 340, 280)
    ..lineTo(372, 280)
    ..lineTo(372, 258)
    ..arcToPoint(const Offset(406, 258), radius: const Radius.circular(17))
    ..lineTo(406, 280)
    ..lineTo(414, 280)
    ..quadraticBezierTo(500, 270, 600, 290)
    ..lineTo(600, 400)
    ..lineTo(0, 400)
    ..close()
    ..addRect(const Rect.fromLTWH(424, 236, 7, 50))
    ..addPolygon(const [
      Offset(422, 238),
      Offset(427.5, 226),
      Offset(433, 238),
    ], true);
}
