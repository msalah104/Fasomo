import 'package:equatable/equatable.dart';
import 'package:fasomo/core/location/bundled_cities.dart';
import 'package:fasomo/core/location/city.dart';

/// Where a [GeoPoint] came from.
enum LocationSource {
  /// A coarse fix from the device, taken when the user asked for it.
  device,

  /// A city the user picked from the bundled list.
  manual,

  /// Nothing set yet, or nothing usable: [GeoPoint.makkah].
  fallback,
}

/// A place on Earth the app computes the sky for.
///
/// Stored on the device only, rounded to two decimals (about 1.1 km).
final class GeoPoint extends Equatable {
  const new({
    required this.latitude,
    required this.longitude,
    required this.source,
    this.city,
  }) : assert(latitude >= -90 && latitude <= 90, 'latitude out of range'),
       assert(
         longitude >= -180 && longitude <= 180,
         'longitude out of range',
       );

  /// A [LocationSource.manual] point at [city].
  factory fromCity(City city) => GeoPoint(
    latitude: city.latitude,
    longitude: city.longitude,
    source: LocationSource.manual,
    city: city,
  );

  /// The default until the user sets a location; shown as approximate.
  static const makkah = GeoPoint(
    latitude: 21.42,
    longitude: 39.83,
    source: LocationSource.fallback,
    city: makkahCity,
  );

  /// Degrees, −90..90, north positive.
  final double latitude;

  /// Degrees, −180..180, east positive.
  final double longitude;

  final LocationSource source;

  /// The bundled city this point was picked from, or the nearest one within
  /// 50 km of a device fix; `null` when no listed city is that close. Gives
  /// the place a name and a country.
  final City? city;

  /// Whether this is a stand-in rather than the user's own location.
  bool get isApproximate => source == LocationSource.fallback;

  /// This point rounded to two decimals, the precision it is stored at.
  GeoPoint rounded() => GeoPoint(
    latitude: _round2(latitude),
    longitude: _round2(longitude),
    source: source,
    city: city,
  );

  static double _round2(double value) => (value * 100).roundToDouble() / 100;

  @override
  List<Object?> get props => [latitude, longitude, source, city];

  @override
  bool get stringify => true;
}
