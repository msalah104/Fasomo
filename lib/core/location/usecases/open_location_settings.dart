import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Opens the system settings where a permanently denied location
/// permission can be granted.
class OpenLocationSettings implements UseCase<Future<bool>, NoParams> {
  const new(this.repository);

  final LocationRepository repository;

  @override
  Future<bool> call(NoParams params) => repository.openSettings();
}
