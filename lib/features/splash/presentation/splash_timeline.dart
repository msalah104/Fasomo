import 'package:fasomo/core/presentation/logo_mark.dart';
import 'package:flutter/animation.dart';

/// When each beat of the splash plays, as fractions of [total].
///
/// The sun sets, the sky runs through dusk into night, the stars come out,
/// and the new moon rises and settles as the dot of the ف. The letter is
/// then drawn around it and the app name typed out.
abstract final class SplashTimeline {
  static const total = Duration(milliseconds: 4400);

  static const sunset = Interval(0.02, 0.38, curve: Curves.easeInOutSine);
  static const skyTurn = Interval(0.06, 0.54, curve: Curves.easeInOut);
  static const stars = Interval(0.34, 0.58, curve: Curves.easeOut);
  static const moonRise = Interval(0.36, 0.50, curve: Curves.easeOutCubic);
  static const moonSettle = Interval(0.50, 0.64, curve: Curves.easeInOutCubic);
  static const letter = Interval(0.62, 0.80, curve: Curves.easeInOutSine);
  static const name = Interval(0.78, 0.90);

  /// The status bar switches to light icons once the sky is dark enough.
  static const darkSkyFrom = 0.32;
}

/// Where the parts of the splash sit on a screen of [size].
class SplashLayout {
  const new(this.size);

  // The skyline is drawn on the 600 × 400 grid of design/art/sky_*.svg,
  // with its horizon at y = 280 and the dome centred on x = 400.
  static const double _artHeight = 400;
  static const double _artHorizon = 280;
  static const double _artDomeX = 400;

  // Only this much of the art's width fits across the screen, so the
  // skyline reads at phone height; the art's sides are cropped.
  static const double _artVisibleWidth = 380;

  final Size size;

  /// Screen pixels per unit of the skyline art.
  double get artScale => size.width / _artVisibleWidth;

  /// Left edge of the art grid on screen, placing the dome towards the end
  /// side of the screen.
  double get artLeft => size.width * 0.66 - _artDomeX * artScale;

  /// Top of the art grid on screen; the skyline art is bottom-anchored.
  double get artTop => size.height - _artHeight * artScale;

  /// Where the sky meets the ground.
  double get horizonY => artTop + _artHorizon * artScale;

  /// The square the logo mark is drawn in.
  Rect get logoRect {
    final side = (size.width * 0.42).clamp(120.0, 200.0);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.40),
      width: side,
      height: side,
    );
  }

  /// Screen pixels per unit of the logo's 128-unit grid.
  double get logoScale => logoRect.width / LogoMarkGeometry.grid;

  /// Where the new moon comes to rest: the dot of the ف.
  Offset get moonHome =>
      logoRect.topLeft + LogoMarkGeometry.dotCenter * logoScale;
}
