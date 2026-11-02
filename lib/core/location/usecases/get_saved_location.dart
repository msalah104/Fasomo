import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// The saved location, or Makkah until one is set. Never prompts.
class GetSavedLocation implements UseCase<GeoPoint, NoParams> {
  const new(this.repository);

  final LocationRepository repository;

  @override
  GeoPoint call(NoParams params) => repository.current();
}
