import 'package:fasomo/core/calendar/hijri_offset.dart';
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
/// every read synchronous. Enum choices are stored by name, the Hijri offset
/// as its number of days.
///
/// Also the [HijriOffsetSource] the Hijri converter reads on every
/// conversion, so a saved offset applies straight away.
class SettingsRepositoryImpl implements SettingsRepository, HijriOffsetSource {
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
      _write(
        AppConstants.languageKey,
        () => sharedPreferences.setString(
          AppConstants.languageKey,
          language.name,
        ),
      );

  @override
  Result<AppThemeMode, StorageFailure> getThemeMode() => _readName(
    AppConstants.themeModeKey,
    AppThemeMode.values,
    fallback: AppThemeMode.system,
  );

  @override
  Future<Result<void, StorageFailure>> saveThemeMode(AppThemeMode mode) =>
      _write(
        AppConstants.themeModeKey,
        () => sharedPreferences.setString(AppConstants.themeModeKey, mode.name),
      );

  @override
  Result<HijriOffset, StorageFailure> getHijriOffset() {
    const key = AppConstants.hijriOffsetKey;
    return switch (sharedPreferences.get(key)) {
      null => const Ok(HijriOffset.none),
      final int days => switch (HijriOffset.fromDays(days)) {
        final offset? => Ok(offset),
        null => const Err(StorageReadFailed(key)),
      },
      _ => const Err(StorageReadFailed(key)),
    };
  }

  @override
  Future<Result<void, StorageFailure>> saveHijriOffset(HijriOffset offset) =>
      _write(
        AppConstants.hijriOffsetKey,
        () =>
            sharedPreferences.setInt(AppConstants.hijriOffsetKey, offset.days),
      );

  /// An unreadable offset counts as none, the same as in the settings.
  @override
  HijriOffset get hijriOffset => switch (getHijriOffset()) {
    Ok(:final value) => value,
    Err() => HijriOffset.none,
  };

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

  /// Runs [write] for [key], turning a refused or failed write into a typed
  /// failure.
  Future<Result<void, StorageFailure>> _write(
    String key,
    Future<bool> Function() write,
  ) async {
    try {
      final saved = await write();
      return saved ? const Ok(null) : Err(StorageWriteFailed(key));
    } on PlatformException catch (e, st) {
      AppLog.error('settings.$key.write', e, st);
      return Err(StorageWriteFailed(key));
    }
  }
}
