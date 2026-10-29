import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';

/// A feature's contribution to the notification schedule. Every source is
/// asked on each sync, because the OS pending set is reconciled as a whole.
abstract interface class ReminderSource {
  /// What to announce on the [horizonDays] days starting at [today] (a local
  /// midnight).
  Result<List<ReminderOccurrence>, Failure> occurrences({
    required DateTime today,
    required int horizonDays,
  });
}
