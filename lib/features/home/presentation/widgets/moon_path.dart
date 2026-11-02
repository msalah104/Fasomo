import 'dart:math' as math;
import 'dart:ui';

/// The lit part of a moon of [radius] centred on the origin, with the lit
/// side towards +x. Rotate it to point the lit side elsewhere.
///
/// The outline is the lit half of the disc closed by the terminator, half an
/// ellipse of half-width `radius × |2f − 1|` for lit fraction [fraction]: on
/// the lit side for a crescent, on the dark side for a gibbous moon, and a
/// straight line at a quarter. The shape's area is [fraction] of the disc.
Path moonLitPath({required double radius, required double fraction}) {
  final f = fraction.clamp(0.0, 1.0);
  final disc = Rect.fromCircle(center: Offset.zero, radius: radius);
  if (f <= 0.005) return Path();
  if (f >= 0.995) return Path()..addOval(disc);

  final halfWidth = radius * (2 * f - 1).abs();
  final path = Path()
    ..moveTo(0, -radius)
    // The lit limb, from the top round the +x side to the bottom.
    ..arcTo(disc, -math.pi / 2, math.pi, false);
  if (halfWidth < 0.01) {
    path.lineTo(0, -radius);
  } else {
    // The terminator back to the top: through +x for a crescent, through
    // −x for a gibbous moon.
    path.arcTo(
      Rect.fromLTRB(-halfWidth, -radius, halfWidth, radius),
      math.pi / 2,
      f < 0.5 ? -math.pi : math.pi,
      false,
    );
  }
  return path..close();
}
