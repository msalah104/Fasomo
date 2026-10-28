import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

/// The Fasomo mark: the letter ف drawn in [color], with the new moon as its
/// dot in [dotColor]. Drawn on a transparent background.
class LogoMark extends StatelessWidget {
  const new({
    required this.color,
    required this.dotColor,
    required this.semanticLabel,
    this.size = 32,
    this.strokeProgress = 1,
    this.showDot = true,
    super.key,
  });

  final Color color;
  final Color dotColor;
  final String semanticLabel;

  /// Width and height in logical pixels.
  final double size;

  /// How much of the letter is drawn, 0 to 1, tracing it pen-stroke style.
  final double strokeProgress;

  /// Whether the new-moon dot is painted. The splash hides it while it
  /// paints its own moon flying into the same spot.
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoMarkPainter(
          color: color,
          dotColor: dotColor,
          strokeProgress: strokeProgress,
          showDot: showDot,
        ),
      ),
    );
  }
}

/// The mark's shapes on its 128-unit grid, matching
/// `design/art/logo_mark_*.svg`.
abstract final class LogoMarkGeometry {
  /// Side of the square grid the shapes are drawn on.
  static const double grid = 128;

  /// Centre of the new-moon dot, on the [grid].
  static const Offset dotCenter = Offset(92, 34);

  /// The new-moon dot.
  static final Path crescent = Path.combine(
    PathOperation.difference,
    Path()..addOval(Rect.fromCircle(center: dotCenter, radius: 14)),
    Path()..addOval(Rect.fromCircle(center: const Offset(99, 29), radius: 12)),
  );

  static final Path _letter = Path()
    ..moveTo(26, 62)
    ..quadraticBezierTo(26, 90, 54, 90)
    ..lineTo(100, 90)
    ..quadraticBezierTo(108, 90, 106, 78);

  // Starts at the bowl's join with the stem and runs counter-clockwise,
  // so the pen draws the stem and carries straight on into the loop.
  static final Path _bowl = Path()
    ..addArc(
      Rect.fromCircle(center: const Offset(94, 68), radius: 11),
      1.2,
      6.283,
    );

  static final PathMetric _letterMetric = _letter.computeMetrics().single;
  static final PathMetric _bowlMetric = _bowl.computeMetrics().single;
}

class _LogoMarkPainter extends CustomPainter {
  new({
    required this.color,
    required this.dotColor,
    required this.strokeProgress,
    required this.showDot,
  });

  final Color color;
  final Color dotColor;
  final double strokeProgress;
  final bool showDot;

  // The stem takes the first 70% of the stroke, the bowl the rest.
  static const double _stemShare = 0.7;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(
      size.width / LogoMarkGeometry.grid,
      size.height / LogoMarkGeometry.grid,
    );
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final t = strokeProgress.clamp(0.0, 1.0);
    final stem = (t / _stemShare).clamp(0.0, 1.0);
    final bowl = ((t - _stemShare) / (1 - _stemShare)).clamp(0.0, 1.0);
    if (stem > 0) {
      canvas.drawPath(
        _partial(LogoMarkGeometry._letterMetric, stem),
        stroke..strokeWidth = 12,
      );
    }
    if (bowl > 0) {
      canvas.drawPath(
        _partial(LogoMarkGeometry._bowlMetric, bowl),
        stroke..strokeWidth = 10,
      );
    }
    if (showDot) {
      canvas.drawPath(LogoMarkGeometry.crescent, Paint()..color = dotColor);
    }
  }

  static Path _partial(PathMetric metric, double fraction) =>
      metric.extractPath(0, metric.length * fraction);

  @override
  bool shouldRepaint(_LogoMarkPainter old) =>
      old.color != color ||
      old.dotColor != dotColor ||
      old.strokeProgress != strokeProgress ||
      old.showDot != showDot;
}
