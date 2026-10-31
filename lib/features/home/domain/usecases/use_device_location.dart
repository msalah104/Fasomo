import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Switches the sky to the device's location, asking for permission if
/// needed. Only run when the user asks for it.
class UseDeviceLocation
    implements UseCase<Future<Result<GeoPoint, LocationFailure>>, NoParams> {
  const new(this.repository);

  final LocationRepository repository;

  @override
  Future<Result<GeoPoint, LocationFailure>> call(NoParams params) =>
      repository.refreshFromDevice();
}
