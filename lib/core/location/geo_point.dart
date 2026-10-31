import 'package:equatable/equatable.dart';

/// Where a [GeoPoint] came from.
enum LocationSource {
  /// A device fix saved on an earlier launch.
  cached,

  /// A fresh device fix.
  device,

  /// No location is known yet; see [GeoPoint.makkah].
  fallback,
}

/// A place on Earth, in degrees. Rounded to 2 decimals (about 1 km), which
/// is all the sky needs.
class GeoPoint extends Equatable {
  const new({
    required this.latitude,
    required this.longitude,
    required this.source,
  }) : assert(latitude >= -90 && latitude <= 90, 'latitude is −90..90'),
       assert(longitude >= -180 && longitude <= 180, 'longitude is −180..180');

  /// Used until the user shares a location.
  static const makkah = GeoPoint(
    latitude: 21.42,
    longitude: 39.83,
    source: LocationSource.fallback,
  );

  final double latitude;
  final double longitude;
  final LocationSource source;

  /// Whether this is the fallback rather than the user's own location.
  bool get isApproximate => source == LocationSource.fallback;

  bool get isSouthernHemisphere => latitude < 0;

  @override
  List<Object> get props => [latitude, longitude, source];
}
