part of 'reminder_bloc.dart';

sealed class ReminderEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

final class LoadReminders extends ReminderEvent {
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

final class DeleteReminderEvent extends ReminderEvent {
  const new(this.fastingType);

  final FastingType fastingType;

  @override
  List<Object> get props => [fastingType];
}
