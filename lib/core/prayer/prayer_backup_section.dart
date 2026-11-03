import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository_impl.dart';

/// The prayer-time settings in a backup, in the form they are stored. No
/// `method` means automatic; adjustments left out are zero:
///
/// ```json
/// "prayer": {"method": "egyptian", "asr": "hanafi",
///            "highLatitude": "seventhOfTheNight", "adjust": {"maghrib": 3}}
/// ```
final class PrayerBackupSection implements BackupSection {
  const new(this.repository);

  final PrayerSettingsRepository repository;

  @override
  String get id => 'prayer';

  @override
  Set<String> get storageKeys => const {
    PrayerSettingsRepositoryImpl.storageKey,
  };

  @override
  Result<Map<String, Object?>, BackupFailure> export() =>
      switch (repository.getSettings()) {
        Ok(:final value) => Ok(PrayerSettingsRepositoryImpl.encode(value)),
        Err() => Err(BackupStorageFailed(id)),
      };

  @override
  Result<void, BackupFailure> validate(Map<String, Object?> json) =>
      PrayerSettingsRepositoryImpl.decode(json) == null
      ? Err(BackupMalformed(sectionId: id))
      : const Ok(null);

  @override
  Future<Result<void, BackupFailure>> restore(Map<String, Object?> json) async {
    final settings = PrayerSettingsRepositoryImpl.decode(json);
    if (settings == null) return Err(BackupMalformed(sectionId: id));
    return switch (await repository.saveSettings(settings)) {
      Ok() => const Ok(null),
      Err() => Err(BackupStorageFailed(id)),
    };
  }
}
