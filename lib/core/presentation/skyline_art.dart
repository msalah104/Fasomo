import 'dart:ui';

/// The skyline from `design/art/sky_*.svg`: a soft ridge with one dome and
/// one minaret, on the art's 600 × 400 grid. The splash and the Home sky
/// both draw it, filled with their ground colour.
abstract final class SkylineArt {
  /// Width of the art grid.
  static const double width = 600;

  /// Height of the art grid.
  static const double height = 400;

  /// Where the sky meets the ground on the grid.
  static const double horizon = 280;

  /// The lowest point of the ridge; everything below is solid ground.
  static const double ridgeBottom = 298;

  /// The top of the minaret, the highest point of the skyline.
  static const double top = 226;

  /// The centre of the dome.
  static const double domeX = 389;

  /// The ridge, dome and minaret, closed along the bottom of the grid.
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
      Offset(427.5, top),
      Offset(433, 238),
    ], true);
}
