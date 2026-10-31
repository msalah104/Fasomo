import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Keeps the saved location current without ever prompting: refreshed at
/// most once a day, and only when permission was already granted. Returns
/// the new location, or `null` when nothing changed.
class RefreshSavedLocation implements UseCase<Future<GeoPoint?>, NoParams> {
  const new(this.repository);

  final LocationRepository repository;

  @override
  Future<GeoPoint?> call(NoParams params) => repository.refreshIfGranted();
}
