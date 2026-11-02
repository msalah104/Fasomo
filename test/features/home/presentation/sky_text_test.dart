import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/features/home/domain/sky_scene_builder.dart';
import 'package:fasomo/features/home/presentation/sky_text.dart';
import 'package:fasomo/l10n/generated/app_localizations_ar.dart';
import 'package:fasomo/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final cairo = GeoPoint.fromCity(CityCatalog.byId('EG:Cairo')!);
  final english = AppLocalizationsEn();
  final arabic = AppLocalizationsAr();

  setUpAll(initializeDateFormatting);

  test("by day: today's sunrise, then sunset", () {
    final scene = buildSkyScene(DateTime.utc(2026, 11, 2, 9), cairo);
    final (start, end) = skyEventTimes(scene);
    expect(start!.kind, SkyEventKind.sunrise);
    expect(end!.kind, SkyEventKind.sunset);
    expect(start.time.isBefore(scene.now), isTrue);
    expect(end.time.isAfter(scene.now), isTrue);
  });

  test("by night: the moon's rise, then the next sunrise", () {
    final scene = buildSkyScene(DateTime.utc(2026, 11, 2, 22), cairo);
    final (start, end) = skyEventTimes(scene);
    expect(start!.kind, SkyEventKind.moonrise);
    expect(end!.kind, SkyEventKind.sunrise);
    expect(end.time.isAfter(scene.now), isTrue);
  });

  test('times follow the clock format and the language', () {
    final event = SkyEventTime(
      SkyEventKind.sunrise,
      DateTime(2026, 11, 2, 6, 4),
    );
    expect(
      english.skyEventLabel(event, use24HourClock: true),
      'Sunrise 06:04',
    );
    expect(
      english.skyEventLabel(event, use24HourClock: false),
      'Sunrise 6:04 AM',
    );
    expect(
      arabic.skyEventLabel(event, use24HourClock: true),
      startsWith('الشروق'),
    );
  });

  test('a device fix far from any city is "My location"', () {
    const far = GeoPoint(
      latitude: -45,
      longitude: -120,
      source: LocationSource.device,
    );
    expect(english.placeName(far), 'My location');
    expect(english.placeName(cairo), 'Cairo');
    expect(arabic.placeName(cairo), 'القاهرة');
  });

  test('describes a sunny day with the moon set', () {
    final scene = buildSkyScene(DateTime.utc(2026, 11, 2, 9), cairo);
    expect(
      english.skySemanticsLabel(scene),
      matches(
        RegExp(
          r'^Daytime\. Sky over Cairo\. The sun is up\. '
          r'The moon is (up|below the horizon): [a-z ]+, \d+% lit\.$',
        ),
      ),
    );
  });
}
