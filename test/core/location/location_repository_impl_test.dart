import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_location_gateway.dart';

void main() {
  late FakeLocationGateway gateway;
  final now = DateTime(2026, 10, 31, 9);

  setUp(() => gateway = FakeLocationGateway());

  Future<LocationRepositoryImpl> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return LocationRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
      gateway: gateway,
      clock: Clock.fixed(now),
    );
  }

  String saved({required double lat, required double lng, DateTime? at}) =>
      jsonEncode({'lat': lat, 'lng': lng, 'at': ?at?.toIso8601String()});

  group('current', () {
    test('falls back to Makkah, marked approximate', () async {
      final point = (await repositoryWith({})).current();
      expect(point, GeoPoint.makkah);
      expect(point.isApproximate, isTrue);
    });

    test('reads a saved location', () async {
      final point = (await repositoryWith({
        AppConstants.locationKey: saved(lat: -33.87, lng: 151.21),
      })).current();
      expect(point.latitude, -33.87);
      expect(point.longitude, 151.21);
      expect(point.source, LocationSource.cached);
      expect(point.isSouthernHemisphere, isTrue);
    });

    test('a bad entry falls back instead of failing', () async {
      for (final bad in ['nope', '{"lat": 120, "lng": 0}', '{"lat": "x"}']) {
        expect(
          (await repositoryWith({AppConstants.locationKey: bad})).current(),
          GeoPoint.makkah,
          reason: bad,
        );
      }
    });
  });

  group('refreshFromDevice', () {
    test('saves the fix rounded to about a kilometre', () async {
      final repository = await repositoryWith({});

      final result = await repository.refreshFromDevice();

      const cairo = GeoPoint(
        latitude: 30.04,
        longitude: 31.24,
        source: LocationSource.device,
      );
      expect((result as Ok<GeoPoint, LocationFailure>).value, cairo);
      expect(repository.current(), cairo);
      // The user asked, so a recent last-known fix isn't enough.
      expect(gateway.acceptedRecent, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(
        jsonDecode(prefs.getString(AppConstants.locationKey)!),
        {'lat': 30.04, 'lng': 31.24, 'at': now.toIso8601String()},
      );
    });

    test('passes on a failure and keeps the old location', () async {
      gateway.fix = const Err(LocationPermissionDenied(permanently: true));
      final repository = await repositoryWith({});

      final result = await repository.refreshFromDevice();

      expect(
        (result as Err<GeoPoint, LocationFailure>).failure,
        const LocationPermissionDenied(permanently: true),
      );
      expect(repository.current(), GeoPoint.makkah);
    });
  });

  group('refreshIfGranted', () {
    test('leaves a fix younger than a day alone', () async {
      final repository = await repositoryWith({
        AppConstants.locationKey: saved(
          lat: 30.04,
          lng: 31.24,
          at: now.subtract(const Duration(hours: 5)),
        ),
      });

      expect(await repository.refreshIfGranted(), isNull);
      expect(gateway.fixRequests, 0);
    });

    test('refreshes an old fix when permission was granted', () async {
      final repository = await repositoryWith({
        AppConstants.locationKey: saved(
          lat: 21.42,
          lng: 39.83,
          at: now.subtract(const Duration(days: 2)),
        ),
      });

      final point = await repository.refreshIfGranted();

      expect(point?.latitude, 30.04);
      expect(gateway.acceptedRecent, isTrue);
      expect(repository.current().source, LocationSource.device);
    });

    test('never prompts: without permission nothing happens', () async {
      gateway.permission = false;
      final repository = await repositoryWith({});

      expect(await repository.refreshIfGranted(), isNull);
      expect(gateway.fixRequests, 0);
      expect(repository.current(), GeoPoint.makkah);
    });
  });

  test('opens the settings that can fix each failure', () async {
    final repository = await repositoryWith({});

    await repository.openSettingsFor(const LocationServiceDisabled());
    await repository.openSettingsFor(
      const LocationPermissionDenied(permanently: true),
    );

    expect(gateway.opened, ['location', 'app']);
  });
}
