import 'package:equatable/equatable.dart';

/// A city from the bundled offline list, named in English and Arabic.
///
/// The [countryCode] is kept for features that default by country, such as
/// a prayer-time calculation method.
final class City extends Equatable {
  /// A row of the bundled table. Positional so each city fits on one line
  /// of `bundled_cities.dart`; it is the only constructor.
  const new(
    this.nameEn,
    this.nameAr,
    this.countryCode,
    this.latitude,
    this.longitude,
  );

  final String nameEn;
  final String nameAr;

  /// ISO 3166-1 alpha-2, upper case: `EG`, `SA`, `GB`.
  final String countryCode;

  /// Degrees, north positive, to two decimals (about 1 km).
  final double latitude;

  /// Degrees, east positive, to two decimals.
  final double longitude;

  /// A stable key for storage: the country and the English name.
  String get id => '$countryCode:$nameEn';

  /// The name in [languageCode], English unless it is Arabic.
  String nameFor(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  @override
  List<Object> get props => [nameEn, nameAr, countryCode, latitude, longitude];

  @override
  bool get stringify => true;
}
