import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_reconciler.dart';
import 'package:fasomo/core/notifications/reminder_scheduler.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder_copy.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

/// The single entry point for every scheduling change: recomputes the
/// desired notifications from the stored reminders and the real fasting
/// dates, then reconciles the OS pending set against them.
///
/// Run it after any reminder change, when the language changes, and on every
/// app start and resume (which also refills the rolling window).
class SyncReminderNotifications
    implements UseCase<Future<Result<void, Failure>>, ReminderCopy> {
  const new({
    required this.repository,
    required this.calendar,
    required this.reconciler,
    required this.clock,
  });

  /// How far ahead fasting days are scheduled.
  static const int horizonDays = 60;

  final ReminderRepository repository;
  final FastingCalendar calendar;
  final NotificationReconciler reconciler;
  final Clock clock;

  @override
  Future<Result<void, Failure>> call(ReminderCopy copy) async {
    final List<Reminder> reminders;
    switch (repository.getReminders()) {
      case Ok(:final value):
        reminders = value;
      case Err(:final failure):
        return Err(failure);
    }

    final now = clock.now();
    final days = calendar.fastingDaysFrom(
      CalendarDays.dateOnly(now),
      days: horizonDays,
    );
    final desired = ReminderScheduler.compute(
      requests: buildRequests(days: days, reminders: reminders, copy: copy),
      now: now,
    );
    return switch (await reconciler.reconcile(desired)) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  /// One request per fasting day that has an enabled reminder. When a day has
  /// several types with reminders (a White Day that is also a Monday), only
  /// the highest-priority one fires, so the user gets a single notification.
  static List<ReminderRequest> buildRequests({
    required List<FastingDayInfo> days,
    required List<Reminder> reminders,
    required ReminderCopy copy,
  }) {
    final enabled = <FastingType, Reminder>{
      for (final reminder in reminders)
        if (reminder.isEnabled) reminder.fastingType: reminder,
    };
    return [
      for (final day in days)
        if (day.types.map((type) => enabled[type]).nonNulls.firstOrNull
            case final reminder?)
          ReminderRequest(
            reminderId: reminder.id,
            fastingDate: day.date,
            timing: reminder.timing,
            title: copy.title(
              reminder.fastingType,
              daysBefore: reminder.timing.daysBefore,
            ),
            body: reminder.customMessage ?? copy.body(reminder.fastingType),
          ),
    ];
  }
}
