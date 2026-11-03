import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_backup_section.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository_impl.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_prayer_settings_repository.dart';

/// The value of [result]; `Ok` itself has no value equality.
T _read<T>(Result<T, StorageFailure> result) => switch (result) {
  Ok(:final value) => value,
  Err() => fail('read failed'),
};

void main() {
  final chosen = PrayerSettings.defaults
      .withMethod(CalculationMethod.egyptian)
      .copyWith(
        asrMethod: AsrMethod.hanafi,
        adjustments: PrayerAdjustments.none.withMinutes(Prayer.maghrib, 3),
      );

  Future<PrayerSettingsRepositoryImpl> repository() async =>
      PrayerSettingsRepositoryImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('chosen settings survive export and restore on another phone', () async {
    final phone = await repository();
    await phone.saveSettings(chosen);
    final exported = switch (PrayerBackupSection(phone).export()) {
      Ok(:final value) => value,
      Err() => fail('export failed'),
    };

    SharedPreferences.setMockInitialValues({});
    final newPhone = await repository();
    final section = PrayerBackupSection(newPhone);
    expect(section.validate(exported), const Ok<void, BackupFailure>(null));
    expect(
      await section.restore(exported),
      const Ok<void, BackupFailure>(null),
    );

    expect(_read(newPhone.getSettings()), chosen);
  });

  test('an unreadable store fails the export', () {
    final section = PrayerBackupSection(
      FakePrayerSettingsRepository()..readFails = true,
    );

    expect(section.export(), isA<Err<Map<String, Object?>, BackupFailure>>());
  });

  test('rejects malformed sections without writing', () async {
    final repo = await repository();
    await repo.saveSettings(chosen);
    final section = PrayerBackupSection(repo);

    for (final bad in <Map<String, Object?>>[
      {},
      {'asr': 'standard'},
      {'asr': 'nope', 'highLatitude': 'middleOfTheNight'},
      {'method': 'nope', 'asr': 'standard', 'highLatitude': 'middleOfTheNight'},
      {
        'asr': 'standard',
        'highLatitude': 'middleOfTheNight',
        'adjust': {'maghrib': 'three'},
      },
    ]) {
      expect(section.validate(bad), isA<Err<void, BackupFailure>>());
      expect(await section.restore(bad), isA<Err<void, BackupFailure>>());
    }
    expect(_read(repo.getSettings()), chosen);
  });
}
