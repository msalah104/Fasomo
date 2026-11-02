import 'package:fasomo/core/theme/sky_cycle.dart';
import 'package:fasomo/core/theme/sky_palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (light, dark) = la > lb ? (la, lb) : (lb, la);
  return (light + 0.05) / (dark + 0.05);
}

void main() {
  final altitudes = [for (var a = -40.0; a <= 70; a += 0.5) a];

  test('full night below −18° and full day above 10°', () {
    final night = SkyPalette.forSunAltitude(-30);
    expect(night.skyTop, SkyCycle.night.top);
    expect(night.ground, SkyCycle.night.ground);
    expect(night.starOpacity, 1);
    expect(night.isSkyLight, isFalse);
    expect(night.overlayStyle, SystemUiOverlayStyle.light);

    final day = SkyPalette.forSunAltitude(40);
    expect(day.skyTop, SkyCycle.day.top);
    expect(day.starOpacity, 0);
    expect(day.isSkyLight, isTrue);
    expect(day.overlayStyle, SystemUiOverlayStyle.dark);
  });

  test('dusk colours at sunset, stars fading in through twilight', () {
    expect(SkyPalette.forSunAltitude(-1).skyTop, SkyCycle.dusk.top);
    expect(SkyPalette.forSunAltitude(-6).starOpacity, 0);
    expect(SkyPalette.forSunAltitude(-9).starOpacity, closeTo(0.5, 1e-9));
    expect(SkyPalette.forSunAltitude(-12).starOpacity, 1);
  });

  test('changes smoothly with altitude', () {
    for (final altitude in altitudes) {
      final a = SkyPalette.forSunAltitude(altitude);
      final b = SkyPalette.forSunAltitude(altitude + 0.5);
      final step =
          (a.skyTop.r - b.skyTop.r).abs() +
          (a.skyTop.g - b.skyTop.g).abs() +
          (a.skyTop.b - b.skyTop.b).abs();
      expect(step, lessThan(0.1), reason: 'at $altitude°');
    }
  });

  test('the sun reddens near the horizon', () {
    expect(SkyPalette.forSunAltitude(30).sunDisc, SkyCycle.sunHigh);
    expect(SkyPalette.forSunAltitude(0).sunDisc, SkyCycle.sunLow);
  });

  group('contrast at every sun altitude', () {
    test('ground text is at least 4.5:1', () {
      for (final altitude in altitudes) {
        final palette = SkyPalette.forSunAltitude(altitude);
        expect(
          _contrast(palette.groundInk, palette.ground),
          greaterThanOrEqualTo(4.5),
          reason: 'at $altitude°',
        );
      }
    });

    test(
      'chip text on its fill is at least 4.5:1 over any part of the sky',
      () {
        for (final altitude in altitudes) {
          final palette = SkyPalette.forSunAltitude(altitude);
          for (final sky in [palette.skyTop, palette.skyMiddle]) {
            final fill = Color.alphaBlend(palette.chipFill, sky);
            expect(
              _contrast(palette.ink, fill),
              greaterThanOrEqualTo(4.5),
              reason: 'at $altitude°',
            );
          }
        }
      },
    );

    test('icons and the logo on the open sky are at least 3:1', () {
      for (final altitude in altitudes) {
        final palette = SkyPalette.forSunAltitude(altitude);
        expect(
          _contrast(palette.ink, palette.skyTop),
          greaterThanOrEqualTo(3),
          reason: 'ink at $altitude°',
        );
        expect(
          _contrast(palette.logoInk, palette.skyTop),
          greaterThanOrEqualTo(3),
          reason: 'logo at $altitude°',
        );
      }
    });
  });
}
