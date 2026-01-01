part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object> get props => [];
}

class LoadReminders extends ReminderEvent {}

class AddFastingDayReminder extends ReminderEvent {
  final String fastingDay;
  final String title;

  const AddFastingDayReminder(this.fastingDay, this.title);

  @override
  List<Object> get props => [fastingDay, title];
}

class ToggleReminder extends ReminderEvent {
  final String fastingDay;

  const ToggleReminder(this.fastingDay);

  @override
  List<Object> get props => [fastingDay];
}

class UpdateReminderSettings extends ReminderEvent {
  final Reminder reminder;

  const UpdateReminderSettings(this.reminder);

  @override
  List<Object> get props => [reminder];
}

class DeleteReminderEvent extends ReminderEvent {
  final String id;

  const DeleteReminderEvent(this.id);

  @override
  List<Object> get props => [id];
}
