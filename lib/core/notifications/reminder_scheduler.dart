import 'package:fasomo/core/notifications/deterministic_id.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/notifications/scheduled_notification.dart';

/// One notification for one day, with its localized text.
class ReminderRequest {
  const new({
    required this.reminderId,
    required this.fastingDate,
    required this.timing,
    required this.title,
    required this.body,
  });

  final String reminderId;

  /// Local midnight of the day the reminder is about.
  final DateTime fastingDate;
  final ReminderTiming timing;
  final String title;
  final String body;

  /// The local moment the notification fires.
  DateTime get fireAt => timing.fireTimeFor(fastingDate);

  ReminderRequest withBody(String body) => ReminderRequest(
    reminderId: reminderId,
    fastingDate: fastingDate,
    timing: timing,
    title: title,
    body: body,
  );
}

/// Pure scheduling math: turns reminder requests into the notifications the
/// OS should hold right now. No IO, no clock reads.
abstract final class ReminderScheduler {
  /// Headroom under iOS's silent 64-pending cap. The nearest notifications
  /// win; later ones are added by the next foreground sync.
  static const int defaultBudget = 50;

  /// Every notification plays [tone]. The tone is part of each id, so
  /// choosing another one replaces every pending notification: on Android
  /// the sound belongs to the channel, which a pending notification can't
  /// change.
  static List<ScheduledNotification> compute({
    required List<ReminderRequest> requests,
    required DateTime now,
    required NotificationTone tone,
    int budget = defaultBudget,
  }) {
    final upcoming =
        [
            for (final request in requests)
              (
                request: request,
                fireAt: request.timing.fireTimeFor(request.fastingDate),
              ),
          ].where((entry) => entry.fireAt.isAfter(now)).toList()
          ..sort((a, b) => a.fireAt.compareTo(b.fireAt));

    return [
      for (final entry in upcoming.take(budget))
        _toNotification(entry.request, entry.fireAt, tone),
    ];
  }

  static ScheduledNotification _toNotification(
    ReminderRequest request,
    DateTime fireAt,
    NotificationTone tone,
  ) {
    final day = _isoDate(request.fastingDate);
    return ScheduledNotification(
      id: DeterministicId.of([
        request.reminderId,
        day,
        fireAt.toIso8601String(),
        request.title,
        request.body,
        tone.name,
      ]),
      fireAt: fireAt,
      title: request.title,
      body: request.body,
      payload: 'reminder/${request.reminderId}/$day',
      tone: tone,
    );
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
