import 'package:fasomo/core/location/bundled_cities.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Makkah is the approximate fallback', () {
    expect(GeoPoint.makkah.isApproximate, isTrue);
    expect(GeoPoint.makkah.source, LocationSource.fallback);
    expect(GeoPoint.makkah.city, makkahCity);
  });

  test('a picked city is manual and not approximate', () {
    final cairo = CityCatalog.byId('EG:Cairo')!;
    final point = GeoPoint.fromCity(cairo);
    expect(point.source, LocationSource.manual);
    expect(point.isApproximate, isFalse);
    expect(point.latitude, cairo.latitude);
    expect(point.city, cairo);
  });

  test('rounds to two decimals, about a kilometre', () {
    const precise = GeoPoint(
      latitude: 30.044419,
      longitude: -0.127758,
      source: LocationSource.device,
    );
    final rounded = precise.rounded();
    expect(rounded.latitude, 30.04);
    expect(rounded.longitude, -0.13);
    expect(rounded.source, LocationSource.device);
  });

  test('equal by value', () {
    expect(
      const GeoPoint(latitude: 1, longitude: 2, source: LocationSource.device),
      const GeoPoint(latitude: 1, longitude: 2, source: LocationSource.device),
    );
    expect(
      const GeoPoint(latitude: 1, longitude: 2, source: LocationSource.device),
      isNot(
        const GeoPoint(
          latitude: 1,
          longitude: 2,
          source: LocationSource.manual,
        ),
      ),
    );
  });
}
