import 'dart:math' as math;

import 'package:fasomo/features/home/presentation/sky_palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('darkness runs from day through dusk to night', () {
    expect(SkyPalette.forSunAltitude(30).darkness, 0);
    expect(SkyPalette.forSunAltitude(-6).darkness, 0.5);
    expect(SkyPalette.forSunAltitude(-18).darkness, 1);
    expect(SkyPalette.forSunAltitude(0).darkness, closeTo(0.25, 1e-9));
  });

  test('stars only come out after dusk', () {
    expect(SkyPalette.forSunAltitude(-6).starAlpha, 0);
    expect(SkyPalette.forSunAltitude(-12).starAlpha, closeTo(0.5, 1e-9));
    expect(SkyPalette.night.starAlpha, 1);
  });

  test('the status bar style follows the sky', () {
    expect(SkyPalette.day.overlayStyle, SystemUiOverlayStyle.dark);
    expect(SkyPalette.night.overlayStyle, SystemUiOverlayStyle.light);
  });

  // The logo and the action are graphics on the sky (3:1); the date and
  // times are text on the ground band (4.5:1).
  for (var altitude = -30; altitude <= 30; altitude++) {
    test('contrast holds at a sun altitude of $altitude°', () {
      final palette = SkyPalette.forSunAltitude(altitude.toDouble());
      expect(contrast(palette.ink, palette.top), greaterThanOrEqualTo(3));
      expect(contrast(palette.logoInk, palette.top), greaterThanOrEqualTo(3));
      expect(
        contrast(palette.groundInk, palette.ground),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
}
