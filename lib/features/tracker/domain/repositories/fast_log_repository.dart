import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';

abstract interface class FastLogRepository {
  /// The log with its streaks, totals and make-up balance as of today.
  Result<FastLogSummary, StorageFailure> getSummary();

  /// Marks [date] as fasted, or clears it when [fasted] is false.
  ///
  /// Marking a day fasted clears "missed" on it; clearing it also clears its
  /// make-up flag. Fails with a [TrackerFailure] when [date] is in the future
  /// or fasting is forbidden on it; clearing a day is always allowed.
  Future<Result<void, Failure>> setFasted(
    DateTime date, {
    required bool fasted,
  });

  /// Marks a Ramadan day as missed (owing a make-up fast), or clears it.
  ///
  /// Marking it missed clears "fasted". Fails with a [TrackerFailure] for a
  /// future day or a day outside Ramadan; clearing is always allowed.
  Future<Result<void, Failure>> setMissedRamadan(
    DateTime date, {
    required bool missed,
  });

  /// Marks [date] as a make-up fast, which also marks it fasted, or clears
  /// the make-up flag and leaves it fasted.
  ///
  /// Fails with a [TrackerFailure] for a future, forbidden or Ramadan day;
  /// clearing is always allowed.
  Future<Result<void, Failure>> setMakeUp(
    DateTime date, {
    required bool makeUp,
  });

  /// Sets the days owed for the Ramadan of [hijriYear] that are not marked
  /// day by day; zero removes the entry. [days] must not be negative.
  Future<Result<void, Failure>> setExtraOwed(
    int hijriYear, {
    required int days,
  });
}
