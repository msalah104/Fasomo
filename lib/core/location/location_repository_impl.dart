import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/device_location_gateway.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the location in shared preferences as
/// `{"lat": 30.04, "lng": 31.24, "at": "2026-10-31T09:15:00.000"}`, falling
/// back to [GeoPoint.makkah].
class LocationRepositoryImpl implements LocationRepository {
  new({
    required this.sharedPreferences,
    required this.gateway,
    required this.clock,
  });

  /// How long a saved fix is used before a silent refresh.
  static const Duration refreshAfter = Duration(days: 1);

  final SharedPreferences sharedPreferences;
  final DeviceLocationGateway gateway;
  final Clock clock;

  /// The latest fix, in case it couldn't be written to storage.
  GeoPoint? _latest;

  @override
  GeoPoint current() => _latest ?? _read()?.point ?? GeoPoint.makkah;

  @override
  Future<Result<GeoPoint, LocationFailure>> refreshFromDevice() async {
    // The user asked, so a fresh fix is wanted even if a recent one is known.
    switch (await gateway.coarseFix(acceptRecent: false)) {
      case Ok(:final value):
        return Ok(await _save(value));
      case Err(:final failure):
        return Err(failure);
    }
  }

  @override
  Future<GeoPoint?> refreshIfGranted() async {
    final saved = _read();
    if (saved != null && clock.now().difference(saved.at) < refreshAfter) {
      AppLog.info('location', 'silent refresh skipped: saved fix is recent');
      return null;
    }
    if (!await gateway.hasPermission()) {
      AppLog.info('location', 'silent refresh skipped: no permission');
      return null;
    }
    AppLog.info('location', 'silent refresh: the saved fix is a day old');
    switch (await gateway.coarseFix()) {
      case Ok(:final value):
        return await _save(value);
      case Err(:final failure):
        AppLog.info('location', 'silent refresh failed: ${failure.code}');
        return null;
    }
  }

  @override
  Future<void> openSettingsFor(LocationFailure failure) async {
    await switch (failure) {
      LocationServiceDisabled() => gateway.openLocationSettings(),
      LocationPermissionDenied() ||
      LocationUnavailable() => gateway.openAppSettings(),
    };
  }

  Future<GeoPoint> _save(DeviceFix fix) async {
    final point = GeoPoint(
      latitude: _round(fix.latitude),
      longitude: _round(fix.longitude),
      source: LocationSource.device,
    );
    _latest = point;
    AppLog.info(
      'location',
      'saved for the sky: ${point.latitude}, ${point.longitude}',
    );
    final saved = await sharedPreferences.setString(
      AppConstants.locationKey,
      jsonEncode({
        'lat': point.latitude,
        'lng': point.longitude,
        'at': clock.now().toIso8601String(),
      }),
    );
    // Only costs a fresh fix next launch, so it's logged, not surfaced.
    if (!saved) {
      AppLog.error(
        'location.write',
        StateError('location not saved'),
        StackTrace.current,
      );
    }
    return point;
  }

  /// The saved point and when it was saved, or `null` if there is none or it
  /// can't be read. A bad entry only costs accuracy, so it never fails.
  ({GeoPoint point, DateTime at})? _read() {
    final encoded = sharedPreferences.getString(AppConstants.locationKey);
    if (encoded == null) return null;
    try {
      if (jsonDecode(encoded)
          case {'lat': final num lat, 'lng': final num lng} && final json
          when lat.abs() <= 90 && lng.abs() <= 180) {
        final at = switch (json['at']) {
          final String iso => DateTime.tryParse(iso),
          _ => null,
        };
        return (
          point: GeoPoint(
            latitude: lat.toDouble(),
            longitude: lng.toDouble(),
            source: LocationSource.cached,
          ),
          // Undated entries count as old, so they get refreshed.
          at: at ?? DateTime.fromMillisecondsSinceEpoch(0),
        );
      }
    } on FormatException catch (e, st) {
      AppLog.error('location.read', e, st);
    }
    return null;
  }

  /// Two decimals, about 1.1 km: enough for the sky, no more.
  static double _round(double degrees) => (degrees * 100).round() / 100;
}
