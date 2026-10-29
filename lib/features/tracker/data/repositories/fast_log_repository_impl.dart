import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/tracker/data/datasources/fast_log_local_data_source.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/fast_log_rules.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';
import 'package:fasomo/features/tracker/domain/tracker_stats.dart';
import 'package:flutter/services.dart';

/// Checks whether a day is acceptable for a change, given its Hijri date and
/// today.
typedef _DayRule = TrackerFailure? Function({
  required DateTime date,
  required HijriDate hijri,
  required DateTime today,
});

class FastLogRepositoryImpl implements FastLogRepository {
  new({
    required this.localDataSource,
    required this.calendar,
    required this.clock,
  }) : _stats = TrackerStats(calendar);

  static const String _key = AppConstants.fastLogKey;

  final FastLogLocalDataSource localDataSource;
  final FastingCalendar calendar;
  final Clock clock;
  final TrackerStats _stats;

  @override
  Result<FastLogSummary, StorageFailure> getSummary() =>
      _read().map((log) => _stats.summarize(log, clock.now()));

  @override
  Future<Result<void, Failure>> setFasted(
    DateTime date, {
    required bool fasted,
  }) {
    final day = CalendarDays.dateOnly(date);
    return _update(
      day,
      rule: fasted ? FastLogRules.whyNotLoggable : null,
      change: (log) => fasted
          ? log.copyWith(
              fastedDays: {...log.fastedDays, day},
              missedRamadanDays: {...log.missedRamadanDays}..remove(day),
            )
          : log.copyWith(
              fastedDays: {...log.fastedDays}..remove(day),
              makeUpDays: {...log.makeUpDays}..remove(day),
            ),
    );
  }

  @override
  Future<Result<void, Failure>> setMissedRamadan(
    DateTime date, {
    required bool missed,
  }) {
    final day = CalendarDays.dateOnly(date);
    return _update(
      day,
      rule: missed ? FastLogRules.whyNotMissed : null,
      change: (log) => missed
          ? log.copyWith(
              missedRamadanDays: {...log.missedRamadanDays, day},
              fastedDays: {...log.fastedDays}..remove(day),
              makeUpDays: {...log.makeUpDays}..remove(day),
            )
          : log.copyWith(
              missedRamadanDays: {...log.missedRamadanDays}..remove(day),
            ),
    );
  }

  @override
  bool canMakeUpOn(DateTime date) {
    final info = calendar.dayInfo(date);
    return info != null &&
        FastLogRules.canMakeUp(
          date: info.date,
          hijri: info.hijri,
          today: CalendarDays.dateOnly(clock.now()),
        );
  }

  @override
  Future<Result<void, Failure>> setMakeUp(
    DateTime date, {
    required bool makeUp,
  }) {
    final day = CalendarDays.dateOnly(date);
    return _update(
      day,
      rule: makeUp ? FastLogRules.whyNotMakeUp : null,
      change: (log) => makeUp
          ? log.copyWith(
              fastedDays: {...log.fastedDays, day},
              makeUpDays: {...log.makeUpDays, day},
            )
          : log.copyWith(makeUpDays: {...log.makeUpDays}..remove(day)),
    );
  }

  @override
  Future<Result<void, Failure>> setExtraOwed(
    int hijriYear, {
    required int days,
  }) {
    assert(days >= 0, 'days owed cannot be negative');
    return _save(
      (log) => log.copyWith(
        extraOwed: {
          for (final MapEntry(:key, :value) in log.extraOwed.entries)
            if (key != hijriYear) key: value,
          if (days > 0) hijriYear: days,
        },
      ),
    );
  }

  /// Applies [change] to the stored log after [rule], if any, accepts [day].
  Future<Result<void, Failure>> _update(
    DateTime day, {
    required _DayRule? rule,
    required FastLog Function(FastLog log) change,
  }) async {
    if (rule != null) {
      final info = calendar.dayInfo(day);
      if (info == null) {
        return Err(
          CalendarOutOfRange(
            minHijriYear: calendar.converter.minHijriYear,
            maxHijriYear: calendar.converter.maxHijriYear,
          ),
        );
      }
      final rejected = rule(
        date: day,
        hijri: info.hijri,
        today: CalendarDays.dateOnly(clock.now()),
      );
      if (rejected != null) return Err(rejected);
    }
    return await _save(change);
  }

  Future<Result<void, Failure>> _save(
    FastLog Function(FastLog log) change,
  ) async {
    switch (_read()) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: final current):
        try {
          await localDataSource.saveLog(change(current));
          return const Ok(null);
        } on StorageWriteException catch (e, st) {
          AppLog.error('fast_log.write', e, st);
          return Err(StorageWriteFailed(e.key));
        } on PlatformException catch (e, st) {
          AppLog.error('fast_log.write', e, st);
          return const Err(StorageWriteFailed(_key));
        }
    }
  }

  Result<FastLog, StorageFailure> _read() {
    try {
      return Ok(localDataSource.getLog());
    } on FormatException catch (e, st) {
      AppLog.error('fast_log.read', e, st);
      return const Err(StorageReadFailed(_key));
    }
  }
}
