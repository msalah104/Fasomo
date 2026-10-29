import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/notifications/notification_copy.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_scheduler.dart';

/// Turns occurrences from every source into one request per notification.
/// Pure: no IO, no clock reads.
///
/// - A fasting day that is also a suggested make-up day becomes one merged
///   notification at the fasting reminder's time.
/// - A Ramadan countdown that fires on the same day as another notification
///   is appended to that notification's text instead of firing on its own.
abstract final class ReminderComposer {
  static List<ReminderRequest> compose(
    List<ReminderOccurrence> occurrences,
    NotificationCopy copy,
  ) {
    final fasting = <DateTime, FastingOccurrence>{};
    final qada = <DateTime, QadaOccurrence>{};
    final countdowns = <RamadanCountdownOccurrence>[];
    for (final occurrence in occurrences) {
      switch (occurrence) {
        case FastingOccurrence():
          fasting[occurrence.date] = occurrence;
        case QadaOccurrence():
          qada[occurrence.date] = occurrence;
        case RamadanCountdownOccurrence():
          countdowns.add(occurrence);
      }
    }

    final requests = <ReminderRequest>[
      for (final date in {...fasting.keys, ...qada.keys})
        switch ((fasting[date], qada[date])) {
          (final f?, final q?) => ReminderRequest(
            reminderId: 'merged.${f.type.name}',
            fastingDate: date,
            timing: f.timing,
            title: copy.mergedTitle(f.type, daysBefore: f.timing.daysBefore),
            body: f.customMessage ?? copy.mergedBody(f.type, q.remaining),
          ),
          (final f?, null) => ReminderRequest(
            reminderId: f.type.name,
            fastingDate: date,
            timing: f.timing,
            title: copy.fastingTitle(f.type, daysBefore: f.timing.daysBefore),
            body: f.customMessage ?? copy.fastingBody(f.type),
          ),
          (null, final q?) => ReminderRequest(
            reminderId: 'qada',
            fastingDate: date,
            timing: q.timing,
            title: copy.qadaTitle(daysBefore: q.timing.daysBefore),
            body: copy.qadaBody(q.remaining),
          ),
          (null, null) => throw StateError('unreachable: date from either map'),
        },
    ];

    for (final countdown in countdowns) {
      final line = copy.ramadanCountdownBody(
        countdown.daysUntilRamadan,
        countdown.remaining,
      );
      final sameDay = requests.indexWhere(
        (r) => CalendarDays.isSameDay(r.fireAt, countdown.fireAt),
      );
      if (sameDay == -1) {
        requests.add(
          ReminderRequest(
            reminderId: 'qada.ramadan.${countdown.daysUntilRamadan}',
            fastingDate: countdown.date,
            timing: countdown.timing,
            title: copy.ramadanCountdownTitle(countdown.daysUntilRamadan),
            body: line,
          ),
        );
      } else {
        final host = requests[sameDay];
        requests[sameDay] = host.withBody('${host.body}\n$line');
      }
    }
    return requests;
  }
}
