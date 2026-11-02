import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Replaces the prayer-time settings.
class SavePrayerSettings
    implements UseCase<Future<Result<void, StorageFailure>>, PrayerSettings> {
  const new(this.repository);

  final PrayerSettingsRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(PrayerSettings settings) =>
      repository.saveSettings(settings);
}
