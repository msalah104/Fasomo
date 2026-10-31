import 'dart:math' as math;

import 'package:fasomo/core/presentation/skyline.dart';
import 'package:fasomo/core/theme/sky_cycle.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/sky_projection.dart';
import 'package:fasomo/features/home/presentation/sky_palette.dart';
import 'package:fasomo/features/home/presentation/widgets/moon_path.dart';
import 'package:flutter/rendering.dart';

/// Where things go in a sky of [size]: the skyline art is scaled to the
/// width and sits on the bottom edge; bodies travel an arc between the
/// horizon and [topInset].
class SkyLayout {
  new(this.size, {this.topInset = 64});

  final Size size;

  /// Space at the top kept clear for the logo row.
  final double topInset;

  double get artScale => size.width / Skyline.artSize.width;
  double get artTop => size.height - Skyline.artSize.height * artScale;
  double get horizonY => artTop + Skyline.horizonY * artScale;

  /// Where a body at [point] is drawn. Rising is on the start edge, so the
  /// arc reads like a timeline in either direction.
  Offset bodyAt(SkyPoint point, TextDirection direction) {
    final x = direction == TextDirection.rtl ? 1 - point.x : point.x;
    // A little below the horizon at the edges, so bodies set behind the hills.
    final base = horizonY + 8;
    return Offset(
      size.width * (0.08 + 0.84 * x),
      base - (base - topInset) * point.y,
    );
  }
}

/// Paints one [scene]: the sky gradient for the sun's altitude, the stars,
/// the arc of the body in the sky, the sun or moon, and the skyline. Text
/// and the logo are widgets drawn on top.
class SkyPainter extends CustomPainter {
  new({
    required this.scene,
    required this.palette,
    required this.textDirection,
  });

  final SkyScene scene;
  final SkyPalette palette;
  final TextDirection textDirection;

  static const double _sunRadius = 15;
  static const double _moonRadius = 13;

  /// Star positions as fractions of the sky above the horizon, with radii.
  /// Seeded, so the same stars show every night.
  static final List<(Offset, double)> _stars = () {
    final random = math.Random(1448);
    return List.generate(
      52,
      (_) => (
        Offset(random.nextDouble(), random.nextDouble() * 0.9),
        0.6 + random.nextDouble() * 1.1,
      ),
    );
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final layout = SkyLayout(size);
    _paintSky(canvas, size, layout);
    _paintStars(canvas, size, layout);

    final sunPoint = SkyProjection.place(scene.sun, scene.now);
    final moonPoint = SkyProjection.place(scene.moon, scene.now);
    final arcPoint = sunPoint ?? moonPoint;
    if (arcPoint != null) _paintArc(canvas, layout);
    if (moonPoint != null) {
      _paintMoon(canvas, layout.bodyAt(moonPoint, textDirection));
    }
    if (sunPoint != null) {
      _paintSun(canvas, layout.bodyAt(sunPoint, textDirection));
    }
    _paintSkyline(canvas, size, layout);
  }

  void _paintSky(Canvas canvas, Size size, SkyLayout layout) {
    final sky = palette.sky;
    final rect = Offset.zero & Size(size.width, layout.horizonY);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sky.top, sky.middle, sky.horizon],
          stops: const [0.1, 0.6, 1],
        ).createShader(rect),
    );
  }

  void _paintStars(Canvas canvas, Size size, SkyLayout layout) {
    final alpha = palette.starAlpha;
    if (alpha == 0) return;
    final paint = Paint()..color = SkyCycle.star.withValues(alpha: alpha);
    for (final (spot, radius) in _stars) {
      canvas.drawCircle(
        Offset(spot.dx * size.width, spot.dy * layout.horizonY),
        radius,
        paint,
      );
    }
  }

  /// A faint dotted path for the body crossing the sky.
  void _paintArc(Canvas canvas, SkyLayout layout) {
    final paint = Paint()
      ..color = palette.ink.withValues(alpha: 0.22)
      ..strokeCap = StrokeCap.round;
    const dots = 36;
    for (var i = 0; i <= dots; i++) {
      final x = i / dots;
      canvas.drawCircle(
        layout.bodyAt((x: x, y: SkyProjection.arcHeight(x)), textDirection),
        1.2,
        paint,
      );
    }
  }

  void _paintSun(Canvas canvas, Offset center) {
    // Redder and with a wider glow near the horizon.
    final low = 1 - (scene.sun.altitudeDegrees / 20).clamp(0.0, 1.0);
    final glow = _sunRadius * (3 + 1.5 * low);
    canvas
      ..drawCircle(
        center,
        glow,
        Paint()
          ..shader = RadialGradient(
            colors: [
              SkyCycle.sunGlow.withValues(alpha: 0.6),
              SkyCycle.sunGlow.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: glow)),
      )
      ..drawCircle(
        center,
        _sunRadius,
        Paint()..color = Color.lerp(SkyCycle.sunHigh, SkyCycle.sunLow, low)!,
      );
  }

  void _paintMoon(Canvas canvas, Offset center) {
    // Pale by day, bright at night.
    final alpha = 0.55 + 0.45 * palette.darkness;
    final phase = scene.moonPhase;
    const glow = _moonRadius * 2.6;
    canvas
      ..drawCircle(
        center,
        glow,
        Paint()
          ..shader = RadialGradient(
            colors: [
              SkyCycle.moon.withValues(alpha: 0.25 * phase.fraction * alpha),
              SkyCycle.moon.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: glow)),
      )
      // Earthshine: the dark part stays faintly visible.
      ..drawCircle(
        center,
        _moonRadius,
        Paint()..color = SkyCycle.moon.withValues(alpha: 0.12 * alpha),
      )
      ..save()
      ..translate(center.dx, center.dy)
      ..drawPath(
        moonLitPathFor(phase, southern: scene.location.isSouthernHemisphere),
        Paint()..color = SkyCycle.moon.withValues(alpha: alpha),
      )
      ..restore();
  }

  void _paintSkyline(Canvas canvas, Size size, SkyLayout layout) {
    canvas
      ..save()
      ..translate(0, layout.artTop)
      ..scale(layout.artScale)
      ..drawPath(Skyline.path, Paint()..color = palette.ground)
      ..restore();
  }

  @override
  bool shouldRepaint(SkyPainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.textDirection != textDirection;
}

/// The lit part of the moon for [phase]: waxing is lit on the right seen
/// from the north, mirrored in the south.
Path moonLitPathFor(MoonPhase phase, {required bool southern}) => moonLitPath(
  radius: SkyPainter._moonRadius,
  fraction: phase.fraction,
  litOnRight: phase.isWaxing != southern,
);
