import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';

/// App-wide preferences. Reads are synchronous so they can be applied before
/// the first frame.
abstract interface class SettingsRepository {
  /// The saved language, or [AppLanguage.system] when none was saved.
  Result<AppLanguage, StorageFailure> getLanguage();

  Future<Result<void, StorageFailure>> saveLanguage(AppLanguage language);

  /// The saved theme mode, or [AppThemeMode.system] when none was saved.
  Result<AppThemeMode, StorageFailure> getThemeMode();

  Future<Result<void, StorageFailure>> saveThemeMode(AppThemeMode mode);
}
