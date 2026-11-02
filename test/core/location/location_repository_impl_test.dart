import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/device_location_gateway.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_device_location_gateway.dart';

void main() {
  late FakeDeviceLocationGateway gateway;

  setUp(() => gateway = FakeDeviceLocationGateway());

  Future<LocationRepositoryImpl> repository([
    Map<String, Object> stored = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(stored);
    return LocationRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
      gateway: gateway,
    );
  }

  /// A second repository over the same storage, as after a restart.
  Future<LocationRepositoryImpl> reopened() async => LocationRepositoryImpl(
    sharedPreferences: await SharedPreferences.getInstance(),
    gateway: gateway,
  );

  test('falls back to Makkah when nothing is saved, without asking', () async {
    final repo = await repository();
    expect(repo.current(), GeoPoint.makkah);
    expect(gateway.fixRequests, 0);
  });

  test('a chosen city is used at once and after a restart', () async {
    final repo = await repository();
    final cairo = CityCatalog.byId('EG:Cairo')!;

    final point = await repo.chooseCity(cairo);

    expect(point, GeoPoint.fromCity(cairo));
    expect(repo.current(), point);
    expect((await reopened()).current(), point);
  });

  test(
    'a device fix is rounded, named after a nearby city and saved',
    () async {
      final repo = await repository();
      gateway.result = const Ok(
        DeviceFix(latitude: 51.507351, longitude: -0.127758),
      );

      final result = await repo.refreshFromDevice();

      const expected = GeoPoint(
        latitude: 51.51,
        longitude: -0.13,
        source: LocationSource.device,
      );
      final point = switch (result) {
        Ok(:final value) => value,
        Err() => fail('expected a fix'),
      };
      expect(point.latitude, expected.latitude);
      expect(point.longitude, expected.longitude);
      expect(point.source, LocationSource.device);
      expect(point.city?.nameEn, 'London');
      expect((await reopened()).current(), point);
    },
  );

  test('a device fix far from any listed city has no name', () async {
    final repo = await repository();
    gateway.result = const Ok(DeviceFix(latitude: -45, longitude: -120));

    final result = await repo.refreshFromDevice();

    expect(result, isA<Ok<GeoPoint, LocationFailure>>());
    expect(repo.current().city, isNull);
    expect(repo.current().isApproximate, isFalse);
  });

  for (final failure in const <LocationFailure>[
    LocationPermissionDenied(permanently: false),
    LocationPermissionDenied(permanently: true),
    LocationServiceDisabled(),
    LocationUnavailable(),
  ]) {
    test('${failure.code} keeps the saved location', () async {
      final repo = await repository();
      final cairo = CityCatalog.byId('EG:Cairo')!;
      await repo.chooseCity(cairo);
      gateway.result = Err(failure);

      final result = await repo.refreshFromDevice();

      expect(result, isA<Err<GeoPoint, LocationFailure>>());
      expect((result as Err<GeoPoint, LocationFailure>).failure, failure);
      expect(repo.current(), GeoPoint.fromCity(cairo));
    });
  }

  group('unreadable storage falls back to Makkah', () {
    for (final (name, raw) in [
      ('not JSON', '{lat:'),
      ('missing fields', '{"lat": 30}'),
      ('out of range', '{"lat": 120, "lng": 0, "source": "manual"}'),
      ('fallback source', '{"lat": 30, "lng": 31, "source": "fallback"}'),
      ('wrong types', '{"lat": "30", "lng": 31, "source": "manual"}'),
    ]) {
      test(name, () async {
        final repo = await repository({
          LocationRepositoryImpl.storageKey: raw,
        });
        expect(repo.current(), GeoPoint.makkah);
      });
    }
  });

  test('an unknown city id keeps the coordinates', () async {
    final repo = await repository({
      LocationRepositoryImpl.storageKey:
          '{"lat": 30.04, "lng": 31.24, "source": "manual", "city": "EG:Gone"}',
    });
    expect(
      repo.current(),
      const GeoPoint(
        latitude: 30.04,
        longitude: 31.24,
        source: LocationSource.manual,
      ),
    );
  });

  test('opens the system settings through the gateway', () async {
    final repo = await repository();
    expect(await repo.openSettings(), isTrue);
    expect(gateway.settingsOpened, 1);
  });
}
