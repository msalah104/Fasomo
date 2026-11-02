import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_time_calculator.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cairo = GeoPoint.fromCity(CityCatalog.byId('EG:Cairo')!);
  final london = GeoPoint.fromCity(CityCatalog.byId('GB:London')!);
  const unnamedFix = GeoPoint(
    latitude: 40.1,
    longitude: -30.2,
    source: LocationSource.device,
  );

  group('the automatic method follows the country', () {
    test('Egypt, Britain, Makkah and no city', () {
      const settings = PrayerSettings.defaults;
      expect(settings.methodAt(cairo), CalculationMethod.egyptian);
      expect(settings.methodAt(london), CalculationMethod.muslimWorldLeague);
      expect(settings.methodAt(GeoPoint.makkah), CalculationMethod.ummAlQura);
      expect(
        settings.methodAt(unnamedFix),
        CalculationMethod.muslimWorldLeague,
      );
    });

    test('a chosen method wins over the country', () {
      const settings = PrayerSettings(method: CalculationMethod.isna);
      expect(settings.methodAt(cairo), CalculationMethod.isna);
      expect(settings.isAutomatic, isFalse);
      expect(settings.withMethod(null).isAutomatic, isTrue);
    });
  });

  test('timesOn uses every setting', () {
    const settings = PrayerSettings(
      asrMethod: AsrMethod.hanafi,
      highLatitudeRule: HighLatitudeRule.seventhOfTheNight,
      adjustments: PrayerAdjustments(maghrib: 3),
    );
    final date = DateTime(2027, 2, 15);
    expect(
      settings.timesOn(date, cairo, inRamadan: true),
      PrayerTimeCalculator.compute(
        date,
        latitude: cairo.latitude,
        longitude: cairo.longitude,
        method: CalculationMethod.egyptian,
        asrMethod: AsrMethod.hanafi,
        highLatitudeRule: HighLatitudeRule.seventhOfTheNight,
        adjustments: const PrayerAdjustments(maghrib: 3),
        inRamadan: true,
      ),
    );
  });

  test('copyWith keeps the method, withMethod keeps the rest', () {
    const settings = PrayerSettings(
      method: CalculationMethod.turkey,
      asrMethod: AsrMethod.hanafi,
    );
    final changed = settings.copyWith(
      highLatitudeRule: HighLatitudeRule.twilightAngle,
    );
    expect(changed.method, CalculationMethod.turkey);
    expect(changed.asrMethod, AsrMethod.hanafi);
    expect(changed.highLatitudeRule, HighLatitudeRule.twilightAngle);
    expect(
      changed.withMethod(CalculationMethod.qatar).highLatitudeRule,
      HighLatitudeRule.twilightAngle,
    );
  });
}
