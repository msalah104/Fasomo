import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/backup/backup_values.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';

/// The app-wide preferences in a backup:
///
/// ```json
/// "settings": {"language": "arabic", "themeMode": "dark", "hijriOffsetDays": 1}
/// ```
final class SettingsBackupSection implements BackupSection {
  const new(this.repository);

  final SettingsRepository repository;

  @override
  String get id => 'settings';

  @override
  Set<String> get storageKeys => const {
    AppConstants.languageKey,
    AppConstants.themeModeKey,
    AppConstants.hijriOffsetKey,
  };

  @override
  Result<Map<String, Object?>, BackupFailure> export() => switch ((
    repository.getLanguage(),
    repository.getThemeMode(),
    repository.getHijriOffset(),
  )) {
    (
      Ok(value: final language),
      Ok(value: final mode),
      Ok(value: final offset),
    ) =>
      Ok({
        'language': language.name,
        'themeMode': mode.name,
        'hijriOffsetDays': offset.days,
      }),
    _ => Err(BackupStorageFailed(id)),
  };

  @override
  Result<void, BackupFailure> validate(Map<String, Object?> json) =>
      _parse(json) == null
      ? Err(BackupMalformed(sectionId: id))
      : const Ok(null);

  @override
  Future<Result<void, BackupFailure>> restore(Map<String, Object?> json) async {
    final parsed = _parse(json);
    if (parsed == null) return Err(BackupMalformed(sectionId: id));
    final (language, mode, offset) = parsed;
    for (final save in [
      () => repository.saveLanguage(language),
      () => repository.saveThemeMode(mode),
      () => repository.saveHijriOffset(offset),
    ]) {
      if (await save() case Err()) return Err(BackupStorageFailed(id));
    }
    return const Ok(null);
  }

  static (AppLanguage, AppThemeMode, HijriOffset)? _parse(
    Map<String, Object?> json,
  ) {
    final language = BackupValues.byName(AppLanguage.values, json['language']);
    final mode = BackupValues.byName(AppThemeMode.values, json['themeMode']);
    final days = json['hijriOffsetDays'];
    final offset = days is int ? HijriOffset.fromDays(days) : null;
    if (language == null || mode == null || offset == null) return null;
    return (language, mode, offset);
  }
}
