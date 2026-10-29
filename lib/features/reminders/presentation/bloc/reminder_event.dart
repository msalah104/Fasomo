part of 'reminder_bloc.dart';

sealed class ReminderEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

final class LoadReminders extends ReminderEvent {
  const new();
}

/// The app language changed (or is known for the first time); notification
/// text is rebuilt and notifications are resynced.
final class ReminderCopyChanged extends ReminderEvent {
  const new(this.copy);

  final NotificationCopy copy;

  @override
  List<Object> get props => [copy];
}

/// The app is showing for the first time: ask for notification permission,
/// since every reminder starts out on. Does nothing on later launches.
final class PermissionPromptRequested extends ReminderEvent {
  const new();
}

/// Re-runs the notification sync, e.g. when the app returns to the
/// foreground. Refills the rolling window and repairs dropped notifications.
final class SyncRequested extends ReminderEvent {
  const new();
}

final class AddFastingDayReminder extends ReminderEvent {
  const new(this.fastingType);

  final FastingType fastingType;

  @override
  List<Object> get props => [fastingType];
}

final class ToggleReminder extends ReminderEvent {
  const new(this.fastingType);

  final FastingType fastingType;

  @override
  List<Object> get props => [fastingType];
}

final class UpdateReminderSettings extends ReminderEvent {
  const new(this.reminder);

  final Reminder reminder;

  @override
  List<Object> get props => [reminder];
}
