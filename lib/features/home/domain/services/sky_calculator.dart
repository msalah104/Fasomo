import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';

/// Astronomy for the sky header. Implemented in `data/`, the only place that
/// knows the astronomy package.
abstract interface class SkyCalculator {
  /// The sun at [now] over [at], with today's sunrise and sunset in local
  /// time.
  CelestialBodyState sun(DateTime now, GeoPoint at);

  /// The moon at [now] over [at]; its rise and set are those of the pass in
  /// progress (or the next one) in local time.
  CelestialBodyState moon(DateTime now, GeoPoint at);

  MoonPhase moonPhase(DateTime now);
}
