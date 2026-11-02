import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';

/// The prayer-time settings: the single place they are read and saved.
///
/// Shared by everything that shows or schedules around prayer times, so it
/// lives in core like the location.
abstract interface class PrayerSettingsRepository {
  /// The saved settings, or [PrayerSettings.defaults] when none are saved.
  Result<PrayerSettings, StorageFailure> getSettings();

  Future<Result<void, StorageFailure>> saveSettings(PrayerSettings settings);
}
