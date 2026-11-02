import 'dart:convert';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/device_location_gateway.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the location in [SharedPreferences] as one JSON value:
/// `{"lat": 30.04, "lng": 31.24, "source": "manual", "city": "EG:Cairo"}`.
class LocationRepositoryImpl implements LocationRepository {
  new({required this.sharedPreferences, required this.gateway});

  static const String storageKey = 'location.saved';

  final SharedPreferences sharedPreferences;
  final DeviceLocationGateway gateway;

  /// The last location read or chosen this session, so a failed write still
  /// takes effect until the app closes.
  GeoPoint? _latest;

  @override
  GeoPoint current() => _latest ??= _read() ?? GeoPoint.makkah;

  @override
  Future<Result<GeoPoint, LocationFailure>> refreshFromDevice() async {
    switch (await gateway.coarseFix()) {
      case Ok(value: final fix):
        final rounded = GeoPoint(
          latitude: fix.latitude.clamp(-90.0, 90.0),
          longitude: _wrapLongitude(fix.longitude),
          source: LocationSource.device,
        ).rounded();
        final point = GeoPoint(
          latitude: rounded.latitude,
          longitude: rounded.longitude,
          source: LocationSource.device,
          city: CityCatalog.nearest(
            latitude: rounded.latitude,
            longitude: rounded.longitude,
          ),
        );
        await _save(point);
        return Ok(point);
      case Err(:final failure):
        return Err(failure);
    }
  }

  @override
  Future<GeoPoint> chooseCity(City city) async {
    final point = GeoPoint.fromCity(city).rounded();
    await _save(point);
    return point;
  }

  @override
  Future<bool> openSettings() => gateway.openAppSettings();

  @override
  GeoPoint? saved() => switch (current()) {
    GeoPoint(isApproximate: true) => null,
    final point => point,
  };

  @override
  Future<bool> replaceSaved(GeoPoint? point) async {
    if (point != null) return await _save(point);
    _latest = null;
    try {
      return await sharedPreferences.remove(storageKey);
    } on PlatformException catch (e, st) {
      AppLog.error('location.write', e, st);
      return false;
    }
  }

  GeoPoint? _read() {
    final raw = sharedPreferences.getString(storageKey);
    if (raw == null) return null;
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException catch (e, st) {
      AppLog.error('location.read', e, st);
      return null;
    }
    final point = _decode(json);
    if (point == null) {
      AppLog.error('location.read', 'Unrecognised: $raw', StackTrace.current);
    }
    return point;
  }

  static GeoPoint? _decode(Object? json) {
    if (json
        case {
          'lat': final num lat,
          'lng': final num lng,
          'source': final String sourceName,
        }
        when lat.abs() <= 90 && lng.abs() <= 180) {
      final source = switch (sourceName) {
        'device' => LocationSource.device,
        'manual' => LocationSource.manual,
        _ => null,
      };
      if (source == null) return null;
      return GeoPoint(
        latitude: lat.toDouble(),
        longitude: lng.toDouble(),
        source: source,
        city: switch (json['city']) {
          final String id => CityCatalog.byId(id),
          _ => null,
        },
      );
    }
    return null;
  }

  Future<bool> _save(GeoPoint point) async {
    _latest = point;
    final encoded = jsonEncode({
      'lat': point.latitude,
      'lng': point.longitude,
      'source': point.source.name,
      if (point.city case final city?) 'city': city.id,
    });
    try {
      final saved = await sharedPreferences.setString(storageKey, encoded);
      if (!saved) {
        AppLog.error('location.write', 'Not saved', StackTrace.current);
      }
      return saved;
    } on PlatformException catch (e, st) {
      AppLog.error('location.write', e, st);
      return false;
    }
  }

  static double _wrapLongitude(double longitude) {
    final wrapped = (longitude + 180) % 360 - 180;
    return wrapped == -180 ? 180 : wrapped;
  }
}
