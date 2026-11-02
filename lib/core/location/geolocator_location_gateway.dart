import 'dart:async';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/device_location_gateway.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/// [DeviceLocationGateway] over the `geolocator` plugin, at low accuracy
/// only (Android `ACCESS_COARSE_LOCATION`, iOS when-in-use).
final class GeolocatorLocationGateway implements DeviceLocationGateway {
  const new();

  static const _timeLimit = Duration(seconds: 10);

  @override
  Future<Result<DeviceFix, LocationFailure>> coarseFix() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const Err(LocationServiceDisabled());
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      switch (permission) {
        case LocationPermission.denied:
          return const Err(LocationPermissionDenied(permanently: false));
        case LocationPermission.deniedForever:
          return const Err(LocationPermissionDenied(permanently: true));
        case LocationPermission.unableToDetermine:
          return const Err(LocationUnavailable());
        case LocationPermission.whileInUse || LocationPermission.always:
          return await _fix();
      }
    } on PermissionDeniedException catch (e, st) {
      AppLog.error('location.permission', e, st);
      return const Err(LocationPermissionDenied(permanently: false));
    } on LocationServiceDisabledException catch (e, st) {
      AppLog.error('location.service', e, st);
      return const Err(LocationServiceDisabled());
    } on PlatformException catch (e, st) {
      AppLog.error('location.platform', e, st);
      return const Err(LocationUnavailable());
    }
  }

  /// A fresh low-accuracy fix, or the last known one if none arrives in
  /// [_timeLimit] (indoors, or with the radio asleep).
  Future<Result<DeviceFix, LocationFailure>> _fix() async {
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: _timeLimit,
        ),
      );
    } on TimeoutException catch (e, st) {
      AppLog.error('location.timeout', e, st);
      position = await Geolocator.getLastKnownPosition();
    }
    if (position == null) return const Err(LocationUnavailable());
    return Ok(
      DeviceFix(latitude: position.latitude, longitude: position.longitude),
    );
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } on PlatformException catch (e, st) {
      AppLog.error('location.settings', e, st);
      return false;
    }
  }
}
