import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Opens the system settings that can fix a location failure.
class OpenLocationSettings implements UseCase<Future<void>, LocationFailure> {
  const new(this.repository);

  final LocationRepository repository;

  @override
  Future<void> call(LocationFailure failure) =>
      repository.openSettingsFor(failure);
}
