part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

class LoadReminders extends ReminderEvent;

class AddFastingDayReminder extends ReminderEvent {
  const new(this.fastingDay, this.title);
  final String fastingDay;
  final String title;

  @override
  List<Object> get props => [fastingDay, title];
}

class ToggleReminder extends ReminderEvent {
  const new(this.fastingDay);
  final String fastingDay;

  @override
  List<Object> get props => [fastingDay];
}

class UpdateReminderSettings extends ReminderEvent {
  const new(this.reminder);
  final Reminder reminder;

  @override
  List<Object> get props => [reminder];
}

class DeleteReminderEvent extends ReminderEvent {
  const new(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}
