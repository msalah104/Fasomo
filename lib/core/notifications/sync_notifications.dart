import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_copy.dart';
import 'package:fasomo/core/notifications/notification_reconciler.dart';
import 'package:fasomo/core/notifications/reminder_composer.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_scheduler.dart';
import 'package:fasomo/core/notifications/reminder_source.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// The single entry point for every scheduling change: asks every
/// [ReminderSource], composes the notifications (merging same-day ones),
/// keeps the nearest within the budget and reconciles the OS pending set.
///
/// Run it after any reminder or fasting-log change, when the language
/// changes, and on every app start and resume (which also refills the
/// rolling window). If any source fails, nothing is changed, so a read error
/// never cancels the notifications already scheduled.
class SyncNotifications
    implements UseCase<Future<Result<void, Failure>>, NotificationCopy> {
  const new({
    required this.sources,
    required this.reconciler,
    required this.clock,
  });

  /// How far ahead occurrences are scheduled.
  static const int horizonDays = 60;

  final List<ReminderSource> sources;
  final NotificationReconciler reconciler;
  final Clock clock;

  @override
  Future<Result<void, Failure>> call(NotificationCopy copy) async {
    final now = clock.now();
    final today = CalendarDays.dateOnly(now);
    final occurrences = <ReminderOccurrence>[];
    for (final source in sources) {
      switch (source.occurrences(today: today, horizonDays: horizonDays)) {
        case Ok(:final value):
          occurrences.addAll(value);
        case Err(:final failure):
          return Err(failure);
      }
    }

    final desired = ReminderScheduler.compute(
      requests: ReminderComposer.compose(occurrences, copy),
      now: now,
    );
    return switch (await reconciler.reconcile(desired)) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }
}
