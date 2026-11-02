import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/geo_point.dart';

/// The user's location: the single place it is read and saved.
///
/// It is kept on the device only, rounded to about a kilometre, and the
/// device is asked for a fix only when the user requests one.
abstract interface class LocationRepository {
  /// The saved location, or [GeoPoint.makkah] when none is saved. Never
  /// fails and never prompts; reading it is cheap.
  GeoPoint current();

  /// Asks for permission if needed, gets a coarse fix, saves it rounded and
  /// returns it. On failure the saved location is unchanged.
  Future<Result<GeoPoint, LocationFailure>> refreshFromDevice();

  /// Saves [city] as the user's chosen location and returns it.
  ///
  /// The choice applies at once; if the device refuses to store it, it lasts
  /// until the app is closed (the error is logged).
  Future<GeoPoint> chooseCity(City city);

  /// Opens the system settings where location permission is granted.
  Future<bool> openSettings();

  /// The location the user saved, or `null` when the sky still uses the
  /// approximate fallback. Read by backups.
  GeoPoint? saved();

  /// Replaces the saved location with [point], or forgets it when `null`, so
  /// the fallback applies again. Used by restore; returns whether it was
  /// written.
  Future<bool> replaceSaved(GeoPoint? point);
}
