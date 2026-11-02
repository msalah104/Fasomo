import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// The saved prayer-time settings, or the defaults.
class GetPrayerSettings
    implements UseCase<Result<PrayerSettings, StorageFailure>, NoParams> {
  const new(this.repository);

  final PrayerSettingsRepository repository;

  @override
  Result<PrayerSettings, StorageFailure> call(NoParams params) =>
      repository.getSettings();
}
