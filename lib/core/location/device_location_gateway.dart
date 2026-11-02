import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// A coarse position from the device, before rounding.
final class DeviceFix {
  const new({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// The device's location service and its permission, the one place the
/// location plugin is touched.
abstract interface class DeviceLocationGateway {
  /// Asks for when-in-use permission if it has not been decided, then gets a
  /// coarse fix (about 1 km). Never runs in the background.
  Future<Result<DeviceFix, LocationFailure>> coarseFix();

  /// Opens this app's page in the system settings, where a permanently
  /// denied permission can be granted. Whether the page opened.
  Future<bool> openAppSettings();
}
