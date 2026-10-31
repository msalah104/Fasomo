import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/device_location_gateway.dart';

/// A [DeviceLocationGateway] whose answers the test sets, recording calls.
class FakeLocationGateway implements DeviceLocationGateway {
  bool permission = true;
  Result<DeviceFix, LocationFailure> fix = const Ok((
    latitude: 30.04444,
    longitude: 31.23571,
  ));
  int fixRequests = 0;

  /// The `acceptRecent` of the last [coarseFix] call.
  bool? acceptedRecent;
  final List<String> opened = [];

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<Result<DeviceFix, LocationFailure>> coarseFix({
    bool acceptRecent = true,
  }) async {
    fixRequests++;
    acceptedRecent = acceptRecent;
    return fix;
  }

  @override
  Future<bool> openAppSettings() async {
    opened.add('app');
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    opened.add('location');
    return true;
  }
}
