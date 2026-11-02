import 'package:fasomo/features/home/domain/entities/celestial_body_state.dart';
import 'package:fasomo/features/home/domain/sky_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rise = DateTime.utc(2026, 3, 20, 3, 25);
  final set = DateTime.utc(2026, 3, 20, 15, 31);
  final noon = rise.add(set.difference(rise) ~/ 2);

  CelestialBodyState body({
    bool isUp = true,
    DateTime? riseAt,
    DateTime? setAt,
    double altitude = 40,
    double hourAngle = 0,
    double peak = 68,
  }) => CelestialBodyState(
    altitudeDegrees: altitude,
    azimuthDegrees: 180,
    hourAngleDegrees: hourAngle,
    isUp: isUp,
    rise: riseAt,
    set: setAt,
    peakAltitudeDegrees: peak,
  );

  final day = body(riseAt: rise, setAt: set);

  test('solar noon is at the top centre', () {
    final point = SkyProjection.project(day, noon)!;
    expect(point.x, closeTo(0.5, 1e-9));
    expect(point.y, closeTo(1, 1e-9));
    expect(point.isOnArc, isTrue);
  });

  test('sunrise is at the start edge on the horizon', () {
    final point = SkyProjection.project(day, rise)!;
    expect(point.x, 0);
    expect(point.y, closeTo(0, 1e-9));
  });

  test('sunset is at the end edge on the horizon', () {
    final point = SkyProjection.project(day, set)!;
    expect(point.x, 1);
    expect(point.y, closeTo(0, 1e-9));
  });

  test('a quarter of the way is part way up the arc', () {
    final point = SkyProjection.project(
      day,
      rise.add(set.difference(rise) ~/ 4),
    )!;
    expect(point.x, closeTo(0.25, 1e-6));
    expect(point.y, closeTo(0.7071, 1e-3));
  });

  test('times just outside the pass stay on the arc ends', () {
    final early = SkyProjection.project(
      day,
      rise.subtract(const Duration(minutes: 1)),
    )!;
    expect(early.x, 0);
  });

  test('a body below the horizon is not drawn', () {
    expect(
      SkyProjection.project(body(isUp: false, riseAt: rise, setAt: set), noon),
      isNull,
    );
  });

  group('polar day: no rise or set', () {
    test('local noon is at the top centre', () {
      final point = SkyProjection.project(body(altitude: 44, peak: 44), noon)!;
      expect(point.x, 0.5);
      expect(point.y, 1);
      expect(point.isOnArc, isFalse);
    });

    test('local midnight is low at the end edge', () {
      final point = SkyProjection.project(
        body(altitude: 4, peak: 44, hourAngle: 180),
        noon,
      )!;
      expect(point.x, 1);
      expect(point.y, closeTo(4 / 44, 1e-9));
    });

    test('the morning is on the start side', () {
      final point = SkyProjection.project(
        body(altitude: 20, peak: 44, hourAngle: -90),
        noon,
      )!;
      expect(point.x, 0.25);
    });
  });
}
