import 'package:flutter/widgets.dart';

/// The Fasomo mark: the letter ف drawn in [color], with the new moon as its
/// dot in [dotColor]. Drawn on a transparent background.
class LogoMark extends StatelessWidget {
  const new({
    required this.color,
    required this.dotColor,
    required this.semanticLabel,
    this.size = 32,
    super.key,
  });

  final Color color;
  final Color dotColor;
  final String semanticLabel;

  /// Width and height in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoMarkPainter(color: color, dotColor: dotColor),
      ),
    );
  }
}

/// Paints the mark on a 128-unit grid scaled to the canvas, matching
/// `design/art/logo_mark_*.svg`.
class _LogoMarkPainter extends CustomPainter {
  new({required this.color, required this.dotColor});

  final Color color;
  final Color dotColor;

  static final Path _letter = Path()
    ..moveTo(26, 62)
    ..quadraticBezierTo(26, 90, 54, 90)
    ..lineTo(100, 90)
    ..quadraticBezierTo(108, 90, 106, 78);

  static final Path _crescent = Path.combine(
    PathOperation.difference,
    Path()..addOval(Rect.fromCircle(center: const Offset(92, 34), radius: 14)),
    Path()..addOval(Rect.fromCircle(center: const Offset(99, 29), radius: 12)),
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 128, size.height / 128);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(_letter, stroke..strokeWidth = 12)
      ..drawCircle(const Offset(94, 68), 11, stroke..strokeWidth = 10)
      ..drawPath(_crescent, Paint()..color = dotColor);
  }

  @override
  bool shouldRepaint(_LogoMarkPainter old) =>
      old.color != color || old.dotColor != dotColor;
}
