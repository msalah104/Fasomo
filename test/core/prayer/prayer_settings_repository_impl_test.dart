import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository_impl.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSharedPreferences extends Mock implements SharedPreferences;

const String _key = PrayerSettingsRepositoryImpl.storageKey;

void main() {
  Future<PrayerSettingsRepositoryImpl> repository([
    Map<String, Object> stored = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(stored);
    return PrayerSettingsRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
  }

  PrayerSettings read(PrayerSettingsRepositoryImpl repo) =>
      switch (repo.getSettings()) {
        Ok(:final value) => value,
        Err(:final failure) => fail('unexpected $failure'),
      };

  test('defaults when nothing is saved', () async {
    final repo = await repository();
    expect(read(repo), PrayerSettings.defaults);
    expect(read(repo).isAutomatic, isTrue);
  });

  test('round-trips every field', () async {
    final repo = await repository();
    const settings = PrayerSettings(
      method: CalculationMethod.egyptian,
      asrMethod: AsrMethod.hanafi,
      highLatitudeRule: HighLatitudeRule.seventhOfTheNight,
      adjustments: PrayerAdjustments(fajr: -2, maghrib: 3),
    );

    expect(await repo.saveSettings(settings), isA<Ok<void, StorageFailure>>());

    final reopened = PrayerSettingsRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
    expect(read(reopened), settings);
  });

  test('automatic is stored as no method', () async {
    final repo = await repository();
    await repo.saveSettings(
      const PrayerSettings(asrMethod: AsrMethod.hanafi),
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(_key), isNot(contains('method')));
    expect(read(repo).isAutomatic, isTrue);
    expect(read(repo).asrMethod, AsrMethod.hanafi);
  });

  group('unreadable data is a read failure', () {
    const base = '"asr": "standard", "highLatitude": "middleOfTheNight"';
    for (final raw in [
      'not json',
      '[]',
      '{"asr": "standard"}',
      '{"method": "nope", $base}',
      '{$base, "adjust": 2}',
      '{$base, "adjust": {"fajr": "two"}}',
      '{$base, "adjust": {"midnight": 2}}',
    ]) {
      test(raw, () async {
        final repo = await repository({_key: raw});
        expect(
          repo.getSettings(),
          isA<Err<PrayerSettings, StorageFailure>>().having(
            (e) => e.failure,
            'failure',
            isA<StorageReadFailed>(),
          ),
        );
      });
    }

    test('a value of the wrong type', () async {
      final repo = await repository({_key: 3});
      expect(repo.getSettings(), isA<Err<PrayerSettings, StorageFailure>>());
    });
  });

  test('stored adjustments outside ±30 are clamped', () async {
    final repo = await repository({
      _key:
          '{"asr": "standard", "highLatitude": "middleOfTheNight", '
          '"adjust": {"isha": 90}}',
    });
    expect(read(repo).adjustments.isha, 30);
  });

  group('a failed write is a write failure', () {
    late _MockSharedPreferences prefs;

    setUp(() => prefs = _MockSharedPreferences());

    test('refused', () async {
      when(() => prefs.setString(any(), any())).thenAnswer((_) async => false);
      final repo = PrayerSettingsRepositoryImpl(sharedPreferences: prefs);
      expect(
        await repo.saveSettings(PrayerSettings.defaults),
        isA<Err<void, StorageFailure>>().having(
          (e) => e.failure,
          'failure',
          isA<StorageWriteFailed>(),
        ),
      );
    });

    test('thrown by the platform', () async {
      when(
        () => prefs.setString(any(), any()),
      ).thenThrow(PlatformException(code: 'io'));
      final repo = PrayerSettingsRepositoryImpl(sharedPreferences: prefs);
      expect(
        await repo.saveSettings(PrayerSettings.defaults),
        isA<Err<void, StorageFailure>>(),
      );
    });
  });
}
