import 'dart:math' as math;

import 'package:fasomo/core/location/bundled_cities.dart';
import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/country_names.dart';

/// Lookups over [bundledCities]. Every function is pure and total.
abstract final class CityCatalog {
  static final Map<String, City> _byId = {
    for (final city in bundledCities) city.id: city,
  };

  /// The bundled city with [id] (see [City.id]), if there is one.
  static City? byId(String id) => _byId[id];

  /// The bundled city nearest to [latitude], [longitude], if one lies within
  /// [withinKm]. Use a large [withinKm] to find the country of a point far
  /// from any listed city.
  static City? nearest({
    required double latitude,
    required double longitude,
    double withinKm = 50,
  }) {
    City? best;
    var bestKm = double.infinity;
    for (final city in bundledCities) {
      final km = greatCircleDistanceKm(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );
      if (km < bestKm) {
        best = city;
        bestKm = km;
      }
    }
    return bestKm <= withinKm ? best : null;
  }

  /// Cities whose English or Arabic name, or whose country's name, contains
  /// [query], ignoring case, accents, Arabic diacritics and hamza forms.
  ///
  /// Names that start with the query come first; ties sort by the name in
  /// [languageCode]. An empty query returns every city sorted that way.
  static List<City> search(String query, {required String languageCode}) {
    final needle = normalizeForSearch(query);
    final starts = <City>[];
    final contains = <City>[];
    for (final city in bundledCities) {
      final names = [city.nameEn, city.nameAr].map(normalizeForSearch);
      if (names.any((name) => name.startsWith(needle))) {
        starts.add(city);
      } else if (names.any((name) => name.contains(needle)) ||
          _countryMatches(city.countryCode, needle)) {
        contains.add(city);
      }
    }
    int byName(City a, City b) =>
        a.nameFor(languageCode).compareTo(b.nameFor(languageCode));
    return [...starts..sort(byName), ...contains..sort(byName)];
  }

  static bool _countryMatches(String countryCode, String needle) {
    final country = countryNames[countryCode];
    if (country == null || needle.isEmpty) return false;
    return normalizeForSearch(country.en).contains(needle) ||
        normalizeForSearch(country.ar).contains(needle);
  }
}

/// [text] folded for matching: lower case, Latin accents removed, Arabic
/// diacritics and tatweel removed, and alef, teh marbuta and alef maqsura
/// forms unified. Spaces are kept; apostrophes, hyphens and dots go.
String normalizeForSearch(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().trim().runes) {
    final char = String.fromCharCode(rune);
    if (_dropped.contains(rune)) continue;
    buffer.write(_folded[char] ?? char);
  }
  return buffer.toString();
}

/// Arabic harakat and tatweel, and punctuation that names spell variously.
final Set<int> _dropped = {
  for (var c = 0x064B; c <= 0x0652; c++) c,
  0x0640,
  0x0670,
  ..."'’-.".runes,
};

const Map<String, String> _folded = {
  'أ': 'ا',
  'إ': 'ا',
  'آ': 'ا',
  'ٱ': 'ا',
  'ة': 'ه',
  'ى': 'ي',
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ı': 'i',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ø': 'o',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ş': 's',
  'ğ': 'g',
};

/// The distance in km between two points on a spherical Earth (haversine),
/// accurate to about 0.5%.
double greatCircleDistanceKm(
  double latitudeA,
  double longitudeA,
  double latitudeB,
  double longitudeB,
) {
  const earthRadiusKm = 6371.0;
  const toRadians = math.pi / 180;
  final dLat = (latitudeB - latitudeA) * toRadians;
  final dLng = (longitudeB - longitudeA) * toRadians;
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(latitudeA * toRadians) *
          math.cos(latitudeB * toRadians) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.sqrt(a.clamp(0, 1)));
}
