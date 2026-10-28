import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';

abstract interface class FastLogRepository {
  /// The log with its streaks and totals as of today.
  Result<FastLogSummary, StorageFailure> getSummary();

  /// Marks [date] as fasted, or clears it when [fasted] is false.
  ///
  /// Fails with a [TrackerFailure] when [date] is in the future or fasting is
  /// forbidden on it; clearing a day is always allowed.
  Future<Result<void, Failure>> setFasted(
    DateTime date, {
    required bool fasted,
  });
}
