import 'package:fasomo/core/location/bundled_cities.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/country_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the bundled table', () {
    test('holds about three hundred cities with unique ids', () {
      expect(bundledCities.length, inInclusiveRange(250, 350));
      final ids = bundledCities.map((city) => city.id).toSet();
      expect(ids, hasLength(bundledCities.length));
    });

    test(
      'every city has both names, a named country and valid coordinates',
      () {
        final arabicLetter = RegExp('[؀-ۿ]');
        for (final city in bundledCities) {
          expect(city.nameEn.trim(), isNotEmpty, reason: city.id);
          expect(city.nameAr, contains(arabicLetter), reason: city.id);
          expect(countryNames, contains(city.countryCode), reason: city.id);
          expect(city.latitude.abs(), lessThanOrEqualTo(90), reason: city.id);
          expect(city.longitude.abs(), lessThanOrEqualTo(180), reason: city.id);
        }
      },
    );

    // Catches a dropped minus sign, the likeliest typo in the table.
    test('cities lie in the right hemispheres', () {
      const south = {'AU', 'NZ', 'ZA', 'AR', 'CL', 'MU', 'KM', 'PE'};
      const west = {
        'US', 'CA', 'MX', 'BR', 'AR', 'CO', 'PE', 'CL', 'VE', 'TT', 'GY', //
        'SR', 'MA', 'MR', 'SN', 'GM', 'GN', 'SL', 'CI', 'IE', 'PT', 'IS',
      };
      const east = {
        'SA', 'AE', 'EG', 'TR', 'IR', 'PK', 'IN', 'ID', 'MY', 'CN', 'JP', //
        'AU', 'NZ', 'RU', 'KZ', 'UZ', 'IQ', 'SY', 'JO', 'NG', 'KE', 'TZ',
      };
      for (final city in bundledCities) {
        final code = city.countryCode;
        if (south.contains(code)) {
          expect(city.latitude, isNegative, reason: city.id);
        }
        if (west.contains(code)) {
          expect(city.longitude, isNegative, reason: city.id);
        }
        if (east.contains(code)) {
          expect(city.longitude, isPositive, reason: city.id);
        }
      }
    });

    test('Makkah is the default and is in the table', () {
      expect(bundledCities, contains(makkahCity));
      expect(CityCatalog.byId('SA:Makkah'), makkahCity);
    });
  });

  group('byId', () {
    test('finds every city by its id', () {
      for (final city in bundledCities) {
        expect(CityCatalog.byId(city.id), city);
      }
    });

    test('tells two cities of the same name apart by country', () {
      expect(CityCatalog.byId('LB:Tripoli')!.longitude, closeTo(35.8, 0.1));
      expect(CityCatalog.byId('LY:Tripoli')!.longitude, closeTo(13.2, 0.1));
    });

    test('is null for an unknown id', () {
      expect(CityCatalog.byId('XX:Atlantis'), isNull);
    });
  });

  group('nearest', () {
    test('finds the city a point is in', () {
      final city = CityCatalog.nearest(latitude: 30.06, longitude: 31.33);
      expect(city?.nameEn, 'Cairo');
    });

    test('is null far from every listed city', () {
      expect(CityCatalog.nearest(latitude: 0, longitude: -30), isNull);
    });

    test('a wide radius always finds one', () {
      final city = CityCatalog.nearest(
        latitude: 0,
        longitude: -30,
        withinKm: 20000,
      );
      expect(city, isNotNull);
    });
  });

  group('search', () {
    List<String> names(String query, [String languageCode = 'en']) => [
      for (final city in CityCatalog.search(query, languageCode: languageCode))
        city.nameEn,
    ];

    test('matches the start of an English name first', () {
      expect(names('cair').first, 'Cairo');
      expect(names('MAK'), containsAll(['Makkah', 'Makassar', 'Makhachkala']));
    });

    test('ignores Latin accents', () {
      expect(names('sao paulo'), ['São Paulo']);
      expect(names('urumqi'), ['Ürümqi']);
    });

    test('ignores hamza forms, teh marbuta and diacritics in Arabic', () {
      expect(names('القاهره'), ['Cairo']);
      expect(names('الاسكندرية'), ['Alexandria']);
      // The same letters spell Oman, so its cities follow Amman.
      expect(names('عَمّان').first, 'Amman');
    });

    test('matches a country name in either language', () {
      expect(names('egypt'), containsAll(['Cairo', 'Alexandria', 'Luxor']));
      expect(names('مصر'), containsAll(['Cairo', 'Alexandria', 'Luxor']));
    });

    test('sorts by the name in the given language', () {
      final arabic = CityCatalog.search('', languageCode: 'ar');
      expect(arabic, hasLength(bundledCities.length));
      final sorted = [...arabic.map((c) => c.nameAr)]..sort();
      expect(arabic.map((c) => c.nameAr), sorted);
    });

    test('finds nothing for a place that is not listed', () {
      expect(names('springfield'), isEmpty);
    });
  });

  test('normalizeForSearch folds case, accents and Arabic letter forms', () {
    expect(normalizeForSearch("  N'Djamena "), 'ndjamena');
    expect(normalizeForSearch('Şanlıurfa'), 'sanliurfa');
    expect(normalizeForSearch('مكّة المكرمة'), 'مكه المكرمه');
    expect(normalizeForSearch('إسطنبول'), 'اسطنبول');
  });

  test('great-circle distances match known ones', () {
    // Makkah to Madinah is about 340 km, London to Paris about 344 km.
    expect(greatCircleDistanceKm(21.42, 39.83, 24.47, 39.61), closeTo(340, 5));
    expect(greatCircleDistanceKm(51.51, -0.13, 48.86, 2.35), closeTo(344, 5));
    expect(greatCircleDistanceKm(10, 20, 10, 20), 0);
  });
}
