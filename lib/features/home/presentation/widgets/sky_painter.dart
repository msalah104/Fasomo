import 'dart:math' as math;

import 'package:fasomo/core/presentation/skyline_art.dart';
import 'package:fasomo/core/theme/sky_palette.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/sky_projection.dart';
import 'package:fasomo/features/home/presentation/widgets/moon_path.dart';
import 'package:fasomo/features/home/presentation/widgets/sky_layout.dart';
import 'package:flutter/rendering.dart';

/// Paints [scene] in [palette]: the gradient, stars, the body's path, the
/// moon in its real phase, the sun, and the skyline. Text and the location
/// chip are widgets on top, so they scale and read aloud.
class SkyPainter extends CustomPainter {
  const new({
    required this.scene,
    required this.palette,
    required this.textDirection,
  });

  final SkyScene scene;
  final SkyPalette palette;
  final TextDirection textDirection;

  /// Star positions as fractions of the sky above the horizon, with a
  /// radius and a brightness. Seeded, so the sky is the same every time.
  static final List<(Offset, double, double)> _stars = () {
    final random = math.Random(42);
    return List.generate(60, (_) {
      return (
        Offset(random.nextDouble(), random.nextDouble() * 0.92),
        0.5 + random.nextDouble(),
        0.45 + random.nextDouble() * 0.55,
      );
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final layout = SkyLayout(
      size,
      isRightToLeft: textDirection == TextDirection.rtl,
    );
    final sun = scene.sunPoint;
    final moon = scene.moonPoint;

    _paintSky(canvas, size);
    _paintStars(canvas, size, layout);
    if (sun ?? moon case final body? when body.isOnArc) {
      _paintArc(canvas, layout);
    }
    if (moon != null) {
      _paintMoon(
        canvas,
        layout,
        layout.bodyCenter(moon),
        inDaylight: sun != null,
      );
    }
    if (sun != null) _paintSun(canvas, layout, layout.bodyCenter(sun));
    _paintSkyline(canvas, size, layout);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.skyTop, palette.skyMiddle, palette.skyHorizon],
          stops: const [0.1, 0.6, 1],
        ).createShader(rect),
    );
  }

  void _paintStars(Canvas canvas, Size size, SkyLayout layout) {
    if (palette.starOpacity == 0) return;
    final paint = Paint();
    for (final (spot, radius, brightness) in _stars) {
      paint.color = palette.star.withValues(
        alpha: palette.starOpacity * brightness,
      );
      canvas.drawCircle(
        Offset(spot.dx * size.width, spot.dy * layout.horizonY),
        radius,
        paint,
      );
    }
  }

  /// Faint dots along the arc `y = sin(πx)` the body travels.
  void _paintArc(Canvas canvas, SkyLayout layout) {
    final paint = Paint()..color = palette.arc;
    const dots = 34;
    for (var i = 1; i < dots; i++) {
      final x = i / dots;
      final point = SkyPoint(x: x, y: math.sin(math.pi * x), isOnArc: true);
      canvas.drawCircle(layout.bodyCenter(point), 1.3, paint);
    }
  }

  void _paintSun(Canvas canvas, SkyLayout layout, Offset center) {
    final radius = layout.bodyRadius;
    // Bigger and softer near the horizon.
    final lowness = 1 - (scene.sun.altitudeDegrees / 20).clamp(0.0, 1.0);
    final glowRadius = radius * (3 + 2 * lowness);
    canvas
      ..drawCircle(
        center,
        glowRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              palette.sunGlow.withValues(alpha: 0.6),
              palette.sunGlow.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: glowRadius)),
      )
      ..drawCircle(center, radius, Paint()..color = palette.sunDisc);
  }

  void _paintMoon(
    Canvas canvas,
    SkyLayout layout,
    Offset center, {
    required bool inDaylight,
  }) {
    final radius = layout.bodyRadius * 0.9;
    final phase = scene.moonPhase;
    final glowRadius = radius * 3;
    final glow = inDaylight ? 0.0 : 0.22 * phase.illuminatedFraction + 0.06;
    canvas
      ..drawCircle(
        center,
        glowRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              palette.moonLit.withValues(alpha: glow),
              palette.moonLit.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: glowRadius)),
      )
      ..drawCircle(center, radius, Paint()..color = palette.moonShadow)
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(
        layout.rotationFromZenithAngle(phase.brightLimbZenithAngleDegrees),
      )
      ..drawPath(
        moonLitPath(radius: radius, fraction: phase.illuminatedFraction),
        Paint()
          ..color = palette.moonLit.withValues(alpha: inDaylight ? 0.85 : 1),
      )
      ..restore();
  }

  void _paintSkyline(Canvas canvas, Size size, SkyLayout layout) {
    final paint = Paint()..color = palette.ground;
    final scale = layout.artScale;
    // Ground beyond the art's edges on wide screens.
    final ridge = layout.artTop + SkylineArt.ridgeBottom * scale - 8 * scale;
    canvas
      ..drawRect(Rect.fromLTRB(0, ridge, size.width, size.height), paint)
      ..save()
      ..translate(layout.artLeft, layout.artTop)
      ..scale(scale)
      ..drawPath(SkylineArt.path, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(SkyPainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.textDirection != textDirection;
}
