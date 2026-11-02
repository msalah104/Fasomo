import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';

/// The suhoor and iftar reminder settings: the single place they are read
/// and saved.
abstract interface class SuhoorIftarSettingsRepository {
  /// The saved settings, or [SuhoorIftarSettings.defaults] when none are.
  Result<SuhoorIftarSettings, StorageFailure> getSettings();

  Future<Result<void, StorageFailure>> saveSettings(
    SuhoorIftarSettings settings,
  );
}
