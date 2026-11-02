import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [SettingsRepository] on [SharedPreferences], whose in-memory cache makes
/// every read synchronous. Enum choices are stored by name.
class SettingsRepositoryImpl implements SettingsRepository {
  const new({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  Result<AppLanguage, StorageFailure> getLanguage() => _readName(
    AppConstants.languageKey,
    AppLanguage.values,
    fallback: AppLanguage.system,
  );

  @override
  Future<Result<void, StorageFailure>> saveLanguage(AppLanguage language) =>
      _writeString(AppConstants.languageKey, language.name);

  @override
  Result<AppThemeMode, StorageFailure> getThemeMode() => _readName(
    AppConstants.themeModeKey,
    AppThemeMode.values,
    fallback: AppThemeMode.system,
  );

  @override
  Future<Result<void, StorageFailure>> saveThemeMode(AppThemeMode mode) =>
      _writeString(AppConstants.themeModeKey, mode.name);

  /// The value named by [key], [fallback] when nothing is stored, or a read
  /// failure when the stored value is not one of [values].
  Result<T, StorageFailure> _readName<T extends Enum>(
    String key,
    List<T> values, {
    required T fallback,
  }) {
    final stored = sharedPreferences.get(key);
    if (stored == null) return Ok(fallback);
    for (final value in values) {
      if (value.name == stored) return Ok(value);
    }
    return Err(StorageReadFailed(key));
  }

  Future<Result<void, StorageFailure>> _writeString(
    String key,
    String value,
  ) async {
    try {
      final saved = await sharedPreferences.setString(key, value);
      return saved ? const Ok(null) : Err(StorageWriteFailed(key));
    } on PlatformException catch (e, st) {
      AppLog.error('settings.$key.write', e, st);
      return Err(StorageWriteFailed(key));
    }
  }
}
