import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/theme/sky_palette.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/sky_projection.dart';
import 'package:fasomo/features/home/domain/sky_scene_builder.dart';
import 'package:fasomo/features/home/presentation/widgets/moon_path.dart';
import 'package:fasomo/features/home/presentation/widgets/sky_layout.dart';
import 'package:fasomo/features/home/presentation/widgets/sky_painter.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// The share of a grid of points over the disc that [path] covers.
double _coverage(Path path, double radius) {
  var inside = 0;
  var total = 0;
  for (var x = -radius; x <= radius; x += radius / 40) {
    for (var y = -radius; y <= radius; y += radius / 40) {
      if (x * x + y * y > radius * radius) continue;
      total++;
      if (path.contains(Offset(x, y))) inside++;
    }
  }
  return inside / total;
}

void main() {
  group('moonLitPath', () {
    const radius = 20.0;

    test('covers the lit fraction of the disc', () {
      for (final fraction in [0.1, 0.25, 0.5, 0.75, 0.9]) {
        final path = moonLitPath(radius: radius, fraction: fraction);
        expect(
          _coverage(path, radius),
          closeTo(fraction, 0.03),
          reason: 'fraction $fraction',
        );
      }
    });

    test('a new moon is dark and a full moon is the whole disc', () {
      expect(moonLitPath(radius: radius, fraction: 0).getBounds(), Rect.zero);
      expect(_coverage(moonLitPath(radius: radius, fraction: 1), radius), 1);
    });

    test('the lit side is towards +x', () {
      final crescent = moonLitPath(radius: radius, fraction: 0.2);
      expect(crescent.contains(const Offset(18, 0)), isTrue);
      expect(crescent.contains(const Offset(-18, 0)), isFalse);
      final gibbous = moonLitPath(radius: radius, fraction: 0.8);
      expect(gibbous.contains(const Offset(-5, 0)), isTrue);
      expect(gibbous.contains(const Offset(-18, 0)), isFalse);
    });
  });

  group('SkyLayout', () {
    const size = Size(400, 196);
    const ltr = SkyLayout(size, isRightToLeft: false);
    const rtl = SkyLayout(size, isRightToLeft: true);

    test('the arc rises on the start side and sets on the end side', () {
      const rise = SkyPoint(x: 0, y: 0, isOnArc: true);
      const set = SkyPoint(x: 1, y: 0, isOnArc: true);
      expect(ltr.bodyCenter(rise).dx, SkyLayout.edgeInset);
      expect(ltr.bodyCenter(set).dx, size.width - SkyLayout.edgeInset);
      expect(rtl.bodyCenter(rise).dx, size.width - SkyLayout.edgeInset);
      expect(rtl.bodyCenter(set).dx, SkyLayout.edgeInset);
    });

    test('the top of the arc clears the top row and the horizon is low', () {
      const top = SkyPoint(x: 0.5, y: 1, isOnArc: true);
      expect(ltr.bodyCenter(top), const Offset(200, SkyLayout.arcTop));
      expect(ltr.horizonY, inExclusiveRange(size.height - 30, size.height));
    });

    test('rotations mirror with the reading direction', () {
      // A lit side pointing up (0°) means turning the +x-facing path back
      // a quarter turn, in either direction.
      expect(ltr.rotationFromZenithAngle(0), closeTo(-math.pi / 2, 1e-9));
      expect(rtl.rotationFromZenithAngle(0), closeTo(-math.pi / 2, 1e-9));
      // East (counter-clockwise, +90°) is on the start side.
      expect(ltr.rotationFromZenithAngle(90), closeTo(-math.pi, 1e-9));
      expect(rtl.rotationFromZenithAngle(90), closeTo(0, 1e-9));
    });
  });

  group('SkyPainter', () {
    const size = Size(400, 196);
    final cairo = GeoPoint.fromCity(CityCatalog.byId('EG:Cairo')!);
    final scenes = {
      'dawn': buildSkyScene(DateTime.utc(2026, 11, 2, 3, 30), cairo),
      'noon': buildSkyScene(DateTime.utc(2026, 11, 2, 9, 38), cairo),
      'sunset': buildSkyScene(DateTime.utc(2026, 11, 2, 15, 7), cairo),
      'crescent night': buildSkyScene(
        DateTime.utc(2026, 11, 12, 16, 30),
        GeoPoint.makkah,
      ),
      'full-moon night': buildSkyScene(
        DateTime.utc(2026, 10, 26, 21),
        GeoPoint.makkah,
      ),
    };

    SkyPainter painterFor(SkyScene scene, TextDirection direction) =>
        SkyPainter(
          scene: scene,
          palette: SkyPalette.forSunAltitude(scene.sun.altitudeDegrees),
          textDirection: direction,
        );

    Future<ByteData> render(SkyPainter painter) async {
      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), size);
      final image = await recorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      return (await image.toByteData())!;
    }

    Color pixel(ByteData bytes, Offset at) {
      final offset = (at.dy.round() * size.width.toInt() + at.dx.round()) * 4;
      return Color.fromARGB(
        bytes.getUint8(offset + 3),
        bytes.getUint8(offset),
        bytes.getUint8(offset + 1),
        bytes.getUint8(offset + 2),
      );
    }

    double distance(Color a, Color b) =>
        (a.r - b.r).abs() + (a.g - b.g).abs() + (a.b - b.b).abs();

    for (final MapEntry(key: name, value: scene) in scenes.entries) {
      for (final direction in TextDirection.values) {
        testWidgets('paints $name, ${direction.name}', (tester) async {
          final painter = painterFor(scene, direction);
          final bytes = (await tester.runAsync(() => render(painter)))!;
          final palette = painter.palette;
          final layout = SkyLayout(
            size,
            isRightToLeft: direction == TextDirection.rtl,
          );

          // The sky behind the top corner, the ground along the bottom.
          expect(
            distance(pixel(bytes, const Offset(2, 1)), palette.skyTop),
            lessThan(0.1),
          );
          expect(
            distance(
              pixel(bytes, Offset(size.width / 2, size.height - 1)),
              palette.ground,
            ),
            lessThan(0.02),
          );
          // The sun's disc where the layout puts it.
          if (scene.sunPoint case final sun? when sun.y > 0.2) {
            final center = layout.bodyCenter(sun);
            expect(
              distance(pixel(bytes, center), palette.sunDisc),
              lessThan(0.05),
            );
          }
        });
      }
    }

    test('repaints only when the scene, palette or direction change', () {
      final noon = scenes['noon']!;
      final painter = painterFor(noon, TextDirection.ltr);
      expect(
        painter.shouldRepaint(painterFor(noon, TextDirection.ltr)),
        isFalse,
      );
      expect(
        painter.shouldRepaint(painterFor(noon, TextDirection.rtl)),
        isTrue,
      );
      expect(
        painter.shouldRepaint(painterFor(scenes['dawn']!, TextDirection.ltr)),
        isTrue,
      );
    });
  });
}
