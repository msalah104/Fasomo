import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/usecases/get_saved_location.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:fasomo/core/prayer/usecases/get_prayer_settings.dart';
import 'package:fasomo/core/prayer/usecases/save_prayer_settings.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/presentation/bloc/prayer_settings_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPrayerSettings extends Mock implements GetPrayerSettings;

class _MockSavePrayerSettings extends Mock implements SavePrayerSettings;

class _MockGetSavedLocation extends Mock implements GetSavedLocation;

void main() {
  late _MockGetPrayerSettings getSettings;
  late _MockSavePrayerSettings saveSettings;
  late _MockGetSavedLocation getLocation;
  final cairo = GeoPoint.fromCity(CityCatalog.byId('EG:Cairo')!);

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(PrayerSettings.defaults);
  });

  setUp(() {
    getSettings = _MockGetPrayerSettings();
    saveSettings = _MockSavePrayerSettings();
    getLocation = _MockGetSavedLocation();
    when(
      () => getSettings(any()),
    ).thenReturn(const Ok(PrayerSettings.defaults));
    when(() => saveSettings(any())).thenAnswer((_) async => const Ok(null));
    when(() => getLocation(any())).thenReturn(GeoPoint.makkah);
  });

  PrayerSettingsBloc build() => PrayerSettingsBloc(
    getPrayerSettings: getSettings,
    savePrayerSettings: saveSettings,
    getSavedLocation: getLocation,
  );

  test('starts from the saved settings and the saved location', () {
    when(() => getSettings(any())).thenReturn(
      const Ok(PrayerSettings(asrMethod: AsrMethod.hanafi)),
    );
    final bloc = build();
    expect(bloc.state.settings.asrMethod, AsrMethod.hanafi);
    expect(bloc.state.methodInUse, CalculationMethod.ummAlQura);
  });

  test('uses the defaults when the saved settings are unreadable', () {
    when(
      () => getSettings(any()),
    ).thenReturn(const Err(StorageReadFailed('prayer.settings')));
    expect(build().state.settings, PrayerSettings.defaults);
  });

  blocTest<PrayerSettingsBloc, PrayerSettingsState>(
    'choosing a method applies and saves it',
    build: build,
    act: (bloc) =>
        bloc.add(const PrayerMethodChanged(CalculationMethod.egyptian)),
    expect: () => [
      const PrayerSettingsState(
        settings: PrayerSettings(method: CalculationMethod.egyptian),
        location: GeoPoint.makkah,
      ),
    ],
    verify: (_) => verify(
      () => saveSettings(
        const PrayerSettings(method: CalculationMethod.egyptian),
      ),
    ).called(1),
  );

  blocTest<PrayerSettingsBloc, PrayerSettingsState>(
    'Asr, high latitudes, adjustments and reset each save',
    build: build,
    act: (bloc) => bloc
      ..add(const AsrMethodChanged(AsrMethod.hanafi))
      ..add(const HighLatitudeRuleChanged(HighLatitudeRule.twilightAngle))
      ..add(const PrayerAdjustmentChanged(Prayer.maghrib, 3))
      ..add(const PrayerAdjustmentsReset()),
    expect: () => [
      isA<PrayerSettingsState>().having(
        (s) => s.settings.asrMethod,
        'asr',
        AsrMethod.hanafi,
      ),
      isA<PrayerSettingsState>().having(
        (s) => s.settings.highLatitudeRule,
        'rule',
        HighLatitudeRule.twilightAngle,
      ),
      isA<PrayerSettingsState>().having(
        (s) => s.settings.adjustments.maghrib,
        'maghrib',
        3,
      ),
      isA<PrayerSettingsState>().having(
        (s) => s.settings.adjustments.isNone,
        'reset',
        isTrue,
      ),
    ],
    verify: (_) => verify(() => saveSettings(any())).called(4),
  );

  blocTest<PrayerSettingsBloc, PrayerSettingsState>(
    'choosing what is already set saves nothing',
    build: build,
    act: (bloc) => bloc.add(const AsrMethodChanged(AsrMethod.standard)),
    expect: () => <PrayerSettingsState>[],
    verify: (_) => verifyNever(() => saveSettings(any())),
  );

  blocTest<PrayerSettingsBloc, PrayerSettingsState>(
    'a failed save keeps the choice and reports it',
    build: build,
    setUp: () => when(
      () => saveSettings(any()),
    ).thenAnswer((_) async => const Err(StorageWriteFailed('prayer'))),
    act: (bloc) => bloc.add(const AsrMethodChanged(AsrMethod.hanafi)),
    expect: () => [
      const PrayerSettingsState(
        settings: PrayerSettings(asrMethod: AsrMethod.hanafi),
        location: GeoPoint.makkah,
      ),
      const PrayerSettingsState(
        settings: PrayerSettings(asrMethod: AsrMethod.hanafi),
        location: GeoPoint.makkah,
        failure: StorageWriteFailed('prayer'),
      ),
    ],
  );

  blocTest<PrayerSettingsBloc, PrayerSettingsState>(
    'a refresh picks up a new location and its automatic method',
    build: build,
    act: (bloc) {
      when(() => getLocation(any())).thenReturn(cairo);
      bloc.add(const PrayerSettingsRefreshed());
    },
    verify: (bloc) =>
        expect(bloc.state.methodInUse, CalculationMethod.egyptian),
  );
}
