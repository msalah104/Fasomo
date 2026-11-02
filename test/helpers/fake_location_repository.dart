import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';

/// A location repository that always returns [point].
class FakeLocationRepository implements LocationRepository {
  new(this.point);

  GeoPoint point;

  @override
  GeoPoint current() => point;

  @override
  Future<GeoPoint> chooseCity(City city) async =>
      point = GeoPoint.fromCity(city);

  @override
  Future<bool> openSettings() async => true;

  @override
  Future<Result<GeoPoint, LocationFailure>> refreshFromDevice() async =>
      Ok(point);
}
