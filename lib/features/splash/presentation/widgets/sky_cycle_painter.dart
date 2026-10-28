import 'dart:math' as math;

import 'package:fasomo/core/presentation/logo_mark.dart';
import 'package:fasomo/core/theme/sky_cycle.dart';
import 'package:fasomo/features/splash/presentation/splash_timeline.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

/// Paints the splash sky at [progress] of [SplashTimeline.total]: gradient,
/// sun, stars, the new moon and the skyline. The logo letter and the name
/// are widgets drawn on top.
class SkyCyclePainter extends CustomPainter {
  new({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  // The skyline from design/art/sky_*.svg: dome and minaret on a soft ridge.
  static final Path _skyline = Path()
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

  /// Star positions as fractions of the sky above the horizon, each with a
  /// radius and a twinkle phase. Seeded, so every launch shows the same sky.
  static final List<(Offset, double, double)> _stars = () {
    final random = math.Random(1447);
    return List.generate(46, (_) {
      return (
        Offset(random.nextDouble(), random.nextDouble() * 0.82),
        0.7 + random.nextDouble() * 1.1,
        random.nextDouble() * math.pi * 2,
      );
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final layout = SplashLayout(size);
    final sky = SkyCycle.at(SplashTimeline.skyTurn.transform(t));

    _paintSky(canvas, size, layout, sky);
    _paintStars(canvas, size, layout, t);
    _paintSun(canvas, size, layout, SplashTimeline.sunset.transform(t));
    _paintSkyline(canvas, layout, sky.ground);
    _paintMoon(canvas, size, layout, t);
  }

  void _paintSky(Canvas canvas, Size size, SplashLayout layout, SkyCycle sky) {
    final skyRect = Offset.zero & Size(size.width, layout.horizonY);
    canvas
      ..drawRect(
        skyRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [sky.top, sky.middle, sky.horizon],
            stops: const [0.15, 0.62, 1],
          ).createShader(skyRect),
      )
      // Ground below the skyline, so tall screens never show a gap.
      ..drawRect(
        Rect.fromLTRB(0, layout.horizonY, size.width, size.height),
        Paint()..color = sky.horizon,
      );
  }

  void _paintStars(Canvas canvas, Size size, SplashLayout layout, double t) {
    final fade = SplashTimeline.stars.transform(t);
    if (fade == 0) return;
    final paint = Paint();
    for (final (spot, radius, phase) in _stars) {
      // Each star fades in at its own moment, then twinkles gently.
      final own = ((fade - spot.dy * 0.4) / 0.6).clamp(0.0, 1.0);
      final twinkle = 0.65 + 0.35 * math.sin(t * 18 + phase);
      paint.color = SkyCycle.star.withValues(alpha: own * twinkle);
      canvas.drawCircle(
        Offset(spot.dx * size.width, spot.dy * layout.horizonY),
        radius,
        paint,
      );
    }
  }

  void _paintSun(Canvas canvas, Size size, SplashLayout layout, double set) {
    if (set >= 1) return;
    // Along a gentle curve from high on the end side down behind the dome.
    final start = Offset(size.width * 0.68, size.height * 0.18);
    final control = Offset(size.width * 0.80, size.height * 0.30);
    final end = Offset(size.width * 0.66, layout.horizonY + 40);
    final center = _quadratic(start, control, end, set);
    final radius = size.width * 0.075;
    final color = Color.lerp(SkyCycle.sunHigh, SkyCycle.sunLow, set)!;
    final glowRadius = radius * (3.2 + set * 1.6);
    canvas
      ..drawCircle(
        center,
        glowRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              SkyCycle.sunGlow.withValues(alpha: 0.65),
              SkyCycle.sunGlow.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: glowRadius)),
      )
      ..drawCircle(center, radius, Paint()..color = color);
  }

  void _paintSkyline(Canvas canvas, SplashLayout layout, Color color) {
    canvas
      ..save()
      ..translate(layout.artLeft, layout.artTop)
      ..scale(layout.artScale)
      ..drawPath(_skyline, Paint()..color = color)
      ..restore();
  }

  void _paintMoon(Canvas canvas, Size size, SplashLayout layout, double t) {
    final rise = SplashTimeline.moonRise.transform(t);
    if (rise == 0) return;
    final settle = SplashTimeline.moonSettle.transform(t);

    // It rises on the start side, then glides into the dot of the ف,
    // shrinking from a moon in the sky to the size of the mark's dot.
    final low = Offset(size.width * 0.26, layout.horizonY - size.height * 0.04);
    final high = Offset(size.width * 0.28, size.height * 0.20);
    final risen = Offset.lerp(low, high, rise)!;
    final center = Offset.lerp(risen, layout.moonHome, settle)!;
    final scale = layout.logoScale * (2.2 - 1.2 * settle);
    final glowRadius = 14 * scale * 2.6;

    canvas
      ..drawCircle(
        center,
        glowRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              SkyCycle.moon.withValues(alpha: 0.28 * rise),
              SkyCycle.moon.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: glowRadius)),
      )
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(scale)
      ..translate(
        -LogoMarkGeometry.dotCenter.dx,
        -LogoMarkGeometry.dotCenter.dy,
      )
      ..drawPath(
        LogoMarkGeometry.crescent,
        Paint()..color = SkyCycle.moon.withValues(alpha: rise),
      )
      ..restore();
  }

  static Offset _quadratic(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + c * (t * t);
  }

  @override
  bool shouldRepaint(SkyCyclePainter old) => old.progress != progress;
}
