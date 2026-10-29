import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_source.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';

/// The fasting-day reminders: one occurrence per fasting day that has an
/// enabled reminder.
class FastingReminderSource implements ReminderSource {
  const new({required this.repository, required this.calendar});

  final ReminderRepository repository;
  final FastingCalendar calendar;

  @override
  Result<List<ReminderOccurrence>, Failure> occurrences({
    required DateTime today,
    required int horizonDays,
  }) => switch (repository.getReminders()) {
    Ok(:final value) => Ok(
      occurrencesFor(
        days: calendar.fastingDaysFrom(today, days: horizonDays),
        reminders: value,
      ),
    ),
    Err(:final failure) => Err(failure),
  };

  /// When a day has several types with reminders (a White Day that is also a
  /// Monday), only the highest-priority one is announced, so the user gets a
  /// single notification.
  static List<FastingOccurrence> occurrencesFor({
    required List<FastingDayInfo> days,
    required List<Reminder> reminders,
  }) {
    final enabled = <FastingType, Reminder>{
      for (final reminder in reminders)
        if (reminder.isEnabled) reminder.fastingType: reminder,
    };
    return [
      for (final day in days)
        if (day.types.map((type) => enabled[type]).nonNulls.firstOrNull
            case final reminder?)
          FastingOccurrence(
            date: day.date,
            timing: reminder.timing,
            type: reminder.fastingType,
            customMessage: reminder.customMessage,
          ),
    ];
  }
}
