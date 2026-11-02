import 'dart:convert';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/ramadan/data/repositories/suhoor_iftar_settings_repository_impl.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSharedPreferences extends Mock implements SharedPreferences;

const String _key = SuhoorIftarSettingsRepositoryImpl.storageKey;

void main() {
  Future<SuhoorIftarSettingsRepositoryImpl> repository([
    Map<String, Object> stored = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(stored);
    return SuhoorIftarSettingsRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
  }

  test('defaults: both on, 45 minutes before Fajr, at Maghrib', () async {
    final repo = await repository();
    final settings =
        (repo.getSettings() as Ok<SuhoorIftarSettings, StorageFailure>).value;
    expect(settings, SuhoorIftarSettings.defaults);
    expect(settings.suhoorEnabled, isTrue);
    expect(settings.suhoorMinutesBeforeFajr, 45);
    expect(settings.iftarEnabled, isTrue);
    expect(settings.iftarMinutesBeforeMaghrib, 0);
    expect(settings.onOtherFastingDays, isFalse);
  });

  test('round-trips every field', () async {
    final repo = await repository();
    const settings = SuhoorIftarSettings(
      suhoorEnabled: false,
      suhoorMinutesBeforeFajr: 90,
      iftarMinutesBeforeMaghrib: 10,
      onOtherFastingDays: true,
    );
    expect(await repo.saveSettings(settings), isA<Ok<void, StorageFailure>>());
    expect(
      (repo.getSettings() as Ok<SuhoorIftarSettings, StorageFailure>).value,
      settings,
    );
  });

  group('unreadable data is a read failure', () {
    const good = {
      'suhoor': true,
      'suhoorMinutes': 45,
      'iftar': true,
      'iftarMinutes': 0,
      'otherDays': false,
    };
    for (final raw in [
      'not json',
      '[]',
      jsonEncode({...good, 'suhoor': 'yes'}),
      jsonEncode({...good, 'suhoorMinutes': -5}),
      jsonEncode({...good, 'iftarMinutes': 600}),
      jsonEncode({...good}..remove('otherDays')),
    ]) {
      test(raw, () async {
        final repo = await repository({_key: raw});
        expect(
          repo.getSettings(),
          isA<Err<SuhoorIftarSettings, StorageFailure>>(),
        );
      });
    }
  });

  test('a refused or failed write is a write failure', () async {
    final prefs = _MockSharedPreferences();
    final repo = SuhoorIftarSettingsRepositoryImpl(sharedPreferences: prefs);

    when(() => prefs.setString(any(), any())).thenAnswer((_) async => false);
    expect(
      await repo.saveSettings(SuhoorIftarSettings.defaults),
      isA<Err<void, StorageFailure>>().having(
        (e) => e.failure,
        'failure',
        isA<StorageWriteFailed>(),
      ),
    );

    when(
      () => prefs.setString(any(), any()),
    ).thenThrow(PlatformException(code: 'io'));
    expect(
      await repo.saveSettings(SuhoorIftarSettings.defaults),
      isA<Err<void, StorageFailure>>(),
    );
  });
}
