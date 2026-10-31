import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/geo_point.dart';

/// The user's location, for computing the sky (and later prayer times).
abstract interface class LocationRepository {
  /// The saved location, or [GeoPoint.makkah] when none is saved or it can't
  /// be read. Never fails and never prompts.
  GeoPoint current();

  /// Asks for permission if needed, gets an approximate device fix and saves
  /// it, rounded to about a kilometre, on the device only.
  Future<Result<GeoPoint, LocationFailure>> refreshFromDevice();

  /// Refreshes the saved fix without ever prompting: only when permission is
  /// already granted and the saved fix is a day old or more. Returns the new
  /// location, or `null` when nothing changed.
  Future<GeoPoint?> refreshIfGranted();

  /// Opens the settings that can fix [failure]: the app's page for a refused
  /// permission, the location settings when services are off.
  Future<void> openSettingsFor(LocationFailure failure);
}
