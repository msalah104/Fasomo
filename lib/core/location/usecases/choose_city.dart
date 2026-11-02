import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Saves a city the user picked from the bundled list as their location.
class ChooseCity implements UseCase<Future<GeoPoint>, City> {
  const new(this.repository);

  final LocationRepository repository;

  @override
  Future<GeoPoint> call(City city) => repository.chooseCity(city);
}
