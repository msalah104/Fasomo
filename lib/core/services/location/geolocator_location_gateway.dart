import 'package:clock/clock.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/device_location_gateway.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:geolocator/geolocator.dart';

/// [DeviceLocationGateway] on `geolocator`, the only file that imports it.
/// Asks for coarse, when-in-use permission: the sky needs no better than a
/// kilometre or so.
class GeolocatorLocationGateway implements DeviceLocationGateway {
  const new();

  /// A last-known fix younger than this is used instead of a new one.
  static const Duration _freshEnough = Duration(hours: 12);

  /// Long enough for a first fix from Wi-Fi and cell towers indoors.
  static const Duration _timeLimit = Duration(seconds: 30);

  /// Balanced accuracy. `low` maps to Android's low-power priority, which
  /// mostly waits for another app's fix and often returns nothing in time;
  /// with only coarse permission Android still blurs the result to about a
  /// kilometre.
  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.medium,
    timeLimit: _timeLimit,
  );

  @override
  Future<bool> hasPermission() async =>
      switch (await Geolocator.checkPermission()) {
        LocationPermission.whileInUse || LocationPermission.always => true,
        _ => false,
      };

  @override
  Future<Result<DeviceFix, LocationFailure>> coarseFix({
    bool acceptRecent = true,
  }) async {
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      _log('location services ${serviceOn ? 'on' : 'off'}');
      if (!serviceOn) return const Err(LocationServiceDisabled());

      var permission = await Geolocator.checkPermission();
      _log('permission ${permission.name}');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        _log('asked for permission → ${permission.name}');
      }
      switch (permission) {
        case LocationPermission.denied:
          return const Err(LocationPermissionDenied(permanently: false));
        case LocationPermission.deniedForever:
          return const Err(LocationPermissionDenied(permanently: true));
        case LocationPermission.unableToDetermine:
          return const Err(LocationUnavailable());
        case LocationPermission.whileInUse || LocationPermission.always:
          break;
      }

      final last = await _lastKnown();
      if (acceptRecent && last != null && _age(last) < _freshEnough) {
        _log('using the last known fix, it is recent enough');
        return Ok(_fixOf(last));
      }

      _log(
        'asking for a new fix (${_settings.accuracy.name} accuracy, '
        '${_timeLimit.inSeconds}s limit)',
      );
      final stopwatch = Stopwatch()..start();
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: _settings,
        );
        _log('new fix after ${_seconds(stopwatch)}: ${_describe(position)}');
        return Ok(_fixOf(position));
      } on Exception catch (e) {
        if (e is LocationServiceDisabledException ||
            e is PermissionDeniedException) {
          rethrow;
        }
        // No new fix in time: an old one still places the sky far better
        // than the fallback city.
        _log(
          'no new fix after ${_seconds(stopwatch)} (${e.runtimeType}: $e); '
          '${last == null ? 'no last known fix either, giving up' : 'using the last known fix'}',
        );
        return last == null
            ? const Err(LocationUnavailable())
            : Ok(_fixOf(last));
      }
    } on LocationServiceDisabledException {
      _log('location services turned off during the request');
      return const Err(LocationServiceDisabled());
    } on PermissionDeniedException {
      _log('permission refused during the request');
      return const Err(LocationPermissionDenied(permanently: false));
    } on Exception catch (e, st) {
      // PlatformException, ActivityMissingException and the like.
      AppLog.error('location.fix', e, st);
      return const Err(LocationUnavailable());
    }
  }

  /// The newer of the last fixes known to Google's fused provider and to
  /// Android's own location manager. The fused one only moves while some
  /// app is asking for location, so a fix that reached GPS directly (as one
  /// sent from the emulator's controls does) can be newer in the manager.
  /// On iOS both calls return the same fix.
  static Future<Position?> _lastKnown() async {
    final fused = await Geolocator.getLastKnownPosition();
    final manager = await Geolocator.getLastKnownPosition(
      forceAndroidLocationManager: true,
    );
    _log(
      'last known fix: fused ${fused == null ? 'none' : _describe(fused)}; '
      'location manager ${manager == null ? 'none' : _describe(manager)}',
    );
    return switch ((fused, manager)) {
      (final f?, final m?) => m.timestamp.isAfter(f.timestamp) ? m : f,
      (final f, final m) => f ?? m,
    };
  }

  static Duration _age(Position position) =>
      clock.now().difference(position.timestamp);

  /// Rounded to about a kilometre, like the saved location.
  static String _describe(Position position) =>
      '${position.latitude.toStringAsFixed(2)}, '
      '${position.longitude.toStringAsFixed(2)} '
      '(±${position.accuracy.round()} m, ${_ageText(_age(position))} old'
      '${position.isMocked ? ', mocked' : ''})';

  static String _ageText(Duration age) => age.inHours >= 1
      ? '${age.inHours} h'
      : age.inMinutes >= 1
      ? '${age.inMinutes} min'
      : '${age.inSeconds} s';

  static String _seconds(Stopwatch stopwatch) =>
      '${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s';

  static void _log(String message) => AppLog.info('location', message);

  static DeviceFix _fixOf(Position position) =>
      (latitude: position.latitude, longitude: position.longitude);

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
