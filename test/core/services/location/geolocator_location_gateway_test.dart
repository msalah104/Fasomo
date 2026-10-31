import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/device_location_gateway.dart';
import 'package:fasomo/core/services/location/geolocator_location_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

/// The plugin's platform side, answering as each test sets it.
class FakeGeolocatorPlatform extends GeolocatorPlatform {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission afterRequest = LocationPermission.whileInUse;

  /// The fused provider's last fix, and the location manager's.
  Position? lastKnown;
  Position? managerLastKnown;

  Position current = _position(30.0444, 31.2357, DateTime(2026, 10, 31, 9));

  /// Thrown by [getCurrentPosition] instead of returning [current].
  Exception? failure;
  LocationSettings? requested;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => afterRequest;

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async => forceLocationManager ? managerLastKnown : lastKnown;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    requested = locationSettings;
    if (failure case final failure?) throw failure;
    return current;
  }
}

Position _position(double lat, double lng, DateTime at) => Position(
  latitude: lat,
  longitude: lng,
  timestamp: at,
  accuracy: 1000,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  late FakeGeolocatorPlatform platform;
  const gateway = GeolocatorLocationGateway();
  final now = DateTime(2026, 10, 31, 9, 30);

  setUp(
    () => GeolocatorPlatform.instance = platform = FakeGeolocatorPlatform(),
  );

  Future<Result<DeviceFix, LocationFailure>> fix({bool acceptRecent = true}) =>
      withClock(
        Clock.fixed(now),
        () => gateway.coarseFix(acceptRecent: acceptRecent),
      );

  test('asks for balanced accuracy with time for a first fix', () async {
    final result = await fix();

    expect((result as Ok).value, (latitude: 30.0444, longitude: 31.2357));
    expect(platform.requested?.accuracy, LocationAccuracy.medium);
    expect(platform.requested?.timeLimit, const Duration(seconds: 30));
  });

  test('uses a recent last-known fix without asking for a new one', () async {
    platform.lastKnown = _position(
      21.42,
      39.83,
      now.subtract(const Duration(hours: 1)),
    );

    final result = await fix();

    expect((result as Ok).value, (latitude: 21.42, longitude: 39.83));
    expect(platform.requested, isNull);
  });

  test(
    'when the user asks, a new fix is fetched even if one is recent',
    () async {
      platform.lastKnown = _position(
        21.42,
        39.83,
        now.subtract(const Duration(minutes: 2)),
      );

      final result = await fix(acceptRecent: false);

      expect((result as Ok).value, (latitude: 30.0444, longitude: 31.2357));
      expect(platform.requested, isNotNull);
    },
  );

  test('falls back to the newer of the fused and manager fixes', () async {
    platform
      ..lastKnown = _position(
        37.42,
        -122.08,
        now.subtract(const Duration(days: 3)),
      )
      ..managerLastKnown = _position(
        29.95,
        31.4,
        now.subtract(const Duration(minutes: 5)),
      )
      ..failure = TimeoutException('no fix');

    final result = await fix(acceptRecent: false);

    expect((result as Ok).value, (latitude: 29.95, longitude: 31.4));
  });

  test('falls back to an old last-known fix when none comes in time', () async {
    platform
      ..lastKnown = _position(
        21.42,
        39.83,
        now.subtract(const Duration(days: 3)),
      )
      ..failure = TimeoutException('no fix');

    final result = await fix();

    expect((result as Ok).value, (latitude: 21.42, longitude: 39.83));
  });

  test(
    "falls back to the location manager's fix when fused has none",
    () async {
      platform
        ..managerLastKnown = _position(
          37.42,
          -122.08,
          now.subtract(const Duration(days: 2)),
        )
        ..failure = TimeoutException('no fix');

      final result = await fix();

      expect((result as Ok).value, (latitude: 37.42, longitude: -122.08));
    },
  );

  test('is unavailable when no fix comes and none is known', () async {
    for (final error in <Exception>[
      TimeoutException('no fix'),
      const PositionUpdateException('lost'),
      const ActivityMissingException('no activity'),
    ]) {
      platform.failure = error;
      expect(
        (await fix() as Err).failure,
        isA<LocationUnavailable>(),
        reason: '$error',
      );
    }
  });

  test('reports services off, and refusals once or for good', () async {
    platform.serviceEnabled = false;
    expect((await fix() as Err).failure, isA<LocationServiceDisabled>());

    platform
      ..serviceEnabled = true
      ..permission = LocationPermission.denied
      ..afterRequest = LocationPermission.denied;
    expect(
      (await fix() as Err).failure,
      isA<LocationPermissionDenied>().having(
        (f) => f.permanently,
        'permanently',
        isFalse,
      ),
    );

    platform.permission = LocationPermission.deniedForever;
    expect(
      (await fix() as Err).failure,
      isA<LocationPermissionDenied>().having(
        (f) => f.permanently,
        'permanently',
        isTrue,
      ),
    );
  });

  test('asks for permission only when it was not decided yet', () async {
    platform
      ..permission = LocationPermission.denied
      ..afterRequest = LocationPermission.whileInUse;

    expect(await fix(), isA<Ok<DeviceFix, LocationFailure>>());
    expect(await gateway.hasPermission(), isFalse);
  });
}
