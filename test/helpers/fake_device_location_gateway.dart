import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/device_location_gateway.dart';

/// A [DeviceLocationGateway] that answers with [result], which a test sets
/// to a fix or to any [LocationFailure].
class FakeDeviceLocationGateway implements DeviceLocationGateway {
  Result<DeviceFix, LocationFailure> result = const Err(LocationUnavailable());

  int fixRequests = 0;
  int settingsOpened = 0;

  @override
  Future<Result<DeviceFix, LocationFailure>> coarseFix() async {
    fixRequests++;
    return result;
  }

  @override
  Future<bool> openAppSettings() async {
    settingsOpened++;
    return true;
  }
}
