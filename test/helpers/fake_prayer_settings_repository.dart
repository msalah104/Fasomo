import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository.dart';

/// Prayer settings held in memory; [readFails] makes reads fail.
class FakePrayerSettingsRepository implements PrayerSettingsRepository {
  new([this.settings = PrayerSettings.defaults]);

  PrayerSettings settings;
  bool readFails = false;

  @override
  Result<PrayerSettings, StorageFailure> getSettings() => readFails
      ? const Err(StorageReadFailed('prayer.settings'))
      : Ok(settings);

  @override
  Future<Result<void, StorageFailure>> saveSettings(
    PrayerSettings settings,
  ) async {
    this.settings = settings;
    return const Ok(null);
  }
}
