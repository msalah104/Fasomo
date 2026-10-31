import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// A coarse device fix, in degrees.
typedef DeviceFix = ({double latitude, double longitude});

/// The port to the device's location services. Only the adapter in
/// `core/services/location/` imports the plugin.
abstract interface class DeviceLocationGateway {
  /// Whether location permission is already granted. Never prompts.
  Future<bool> hasPermission();

  /// Asks for permission if needed, then gets an approximate fix.
  ///
  /// With [acceptRecent], a last-known fix from the past few hours is
  /// returned without asking for a new one (for silent refreshes). Without
  /// it a new fix is always requested, and the last known one is only a
  /// fallback (for when the user asks).
  Future<Result<DeviceFix, LocationFailure>> coarseFix({
    bool acceptRecent = true,
  });

  /// Opens the app's page in system settings, where a permanently refused
  /// permission can be granted.
  Future<bool> openAppSettings();

  /// Opens the system location settings, to switch location services on.
  Future<bool> openLocationSettings();
}
