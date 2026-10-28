import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/tracker/data/datasources/fast_log_local_data_source.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/fast_log_rules.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';
import 'package:fasomo/features/tracker/domain/tracker_stats.dart';
import 'package:flutter/services.dart';

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
      _read().map((days) => _stats.summarize(days, clock.now()));

  @override
  Future<Result<void, Failure>> setFasted(
    DateTime date, {
    required bool fasted,
  }) async {
    final day = CalendarDays.dateOnly(date);
    if (fasted) {
      final info = calendar.dayInfo(day);
      if (info == null) {
        return Err(
          CalendarOutOfRange(
            minHijriYear: calendar.converter.minHijriYear,
            maxHijriYear: calendar.converter.maxHijriYear,
          ),
        );
      }
      final rejected = FastLogRules.whyNotLoggable(
        date: day,
        hijri: info.hijri,
        today: CalendarDays.dateOnly(clock.now()),
      );
      if (rejected != null) return Err(rejected);
    }

    switch (_read()) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: final current):
        final next = {...current};
        if (fasted) {
          next.add(day);
        } else {
          next.remove(day);
        }
        try {
          await localDataSource.saveFastedDays(next);
          return const Ok(null);
        } on StorageWriteException catch (e, st) {
          AppLog.error('fast_log.write', e, st);
          return const Err(StorageWriteFailed(_key));
        } on PlatformException catch (e, st) {
          AppLog.error('fast_log.write', e, st);
          return const Err(StorageWriteFailed(_key));
        }
    }
  }

  Result<Set<DateTime>, StorageFailure> _read() {
    try {
      return Ok(localDataSource.getFastedDays());
    } on FormatException catch (e, st) {
      AppLog.error('fast_log.read', e, st);
      return const Err(StorageReadFailed(_key));
    }
  }
}
