import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/backup/backup_values.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/tracker/data/datasources/fast_log_local_data_source.dart';
import 'package:fasomo/features/tracker/data/datasources/qada_reminder_local_data_source.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:flutter/services.dart';

/// The fasting log and the make-up reminder settings in a backup. Days are
/// local calendar dates as `yyyy-MM-dd`, sorted:
///
/// ```json
/// "tracker": {
///   "fastedDays": ["2026-03-02", "2026-03-05"],
///   "makeUpDays": ["2026-03-05"],
///   "missedRamadanDays": ["2026-02-20"],
///   "extraOwed": [{"hijriYear": 1446, "days": 3}],
///   "qadaReminders": {"weeklyEnabled": true, "weekdays": [6], …}
/// }
/// ```
final class TrackerBackupSection implements BackupSection {
  const new({required this.fastLog, required this.qadaReminders});

  final FastLogLocalDataSource fastLog;
  final QadaReminderLocalDataSource qadaReminders;

  // The bounds the fast log's storage format accepts. Validation is never
  // stricter than storage, so every backup this app writes restores.
  static const int _minHijriYear = 1000;
  static const int _maxHijriYear = 9999;
  static const int _maxDaysOwed = 999;

  @override
  String get id => 'tracker';

  @override
  Set<String> get storageKeys => const {
    AppConstants.fastLogKey,
    AppConstants.makeUpDaysKey,
    AppConstants.missedRamadanKey,
    AppConstants.extraOwedKey,
    AppConstants.qadaRemindersKey,
  };

  @override
  Result<Map<String, Object?>, BackupFailure> export() {
    try {
      final log = fastLog.getLog();
      final settings =
          qadaReminders.getSettings() ?? QadaReminderSettings.defaults;
      final years = log.extraOwed.keys.toList()..sort();
      return Ok({
        'fastedDays': BackupValues.dates(log.fastedDays),
        'makeUpDays': BackupValues.dates(log.makeUpDays),
        'missedRamadanDays': BackupValues.dates(log.missedRamadanDays),
        'extraOwed': [
          for (final year in years)
            {'hijriYear': year, 'days': log.extraOwed[year]},
        ],
        'qadaReminders': settings.toJson(),
      });
    } on FormatException catch (e, st) {
      AppLog.error('backup.tracker.export', e, st);
      return Err(BackupStorageFailed(id));
    }
  }

  @override
  Result<void, BackupFailure> validate(Map<String, Object?> json) =>
      _parse(json) == null
      ? Err(BackupMalformed(sectionId: id))
      : const Ok(null);

  @override
  Future<Result<void, BackupFailure>> restore(Map<String, Object?> json) async {
    final parsed = _parse(json);
    if (parsed == null) return Err(BackupMalformed(sectionId: id));
    final (log, settings) = parsed;
    try {
      await fastLog.saveLog(log);
      await qadaReminders.saveSettings(settings);
      return const Ok(null);
    } on StorageWriteException catch (e, st) {
      AppLog.error('backup.tracker.restore', e, st);
      return Err(BackupStorageFailed(id));
    } on PlatformException catch (e, st) {
      AppLog.error('backup.tracker.restore', e, st);
      return Err(BackupStorageFailed(id));
    }
  }

  static (FastLog, QadaReminderSettings)? _parse(Map<String, Object?> json) {
    final fasted = BackupValues.parseDates(json['fastedDays']);
    final makeUp = BackupValues.parseDates(json['makeUpDays']);
    final missed = BackupValues.parseDates(json['missedRamadanDays']);
    final extraOwed = _parseOwed(json['extraOwed']);
    final settings = QadaReminderSettings.tryFromJson(json['qadaReminders']);
    if (fasted == null ||
        makeUp == null ||
        missed == null ||
        extraOwed == null ||
        settings == null) {
      return null;
    }
    return (
      FastLog(
        fastedDays: fasted,
        makeUpDays: makeUp,
        missedRamadanDays: missed,
        extraOwed: extraOwed,
      ),
      settings,
    );
  }

  /// Days owed by Hijri year, or `null` when [raw] is not a list of
  /// distinct four-digit years each owing up to 999 days.
  static Map<int, int>? _parseOwed(Object? raw) {
    if (raw is! List<Object?>) return null;
    final owed = <int, int>{};
    for (final entry in raw) {
      if (entry
          case {
            'hijriYear': final int year,
            'days': final int days,
          }
          when year >= _minHijriYear &&
              year <= _maxHijriYear &&
              days >= 0 &&
              days <= _maxDaysOwed &&
              !owed.containsKey(year)) {
        owed[year] = days;
      } else {
        return null;
      }
    }
    return owed;
  }
}
