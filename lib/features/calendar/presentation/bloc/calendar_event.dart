part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object> get props => [];
}

class LoadCalendar extends CalendarEvent {}

class ChangeMonth extends CalendarEvent {
  final int month;
  final int year;

  const ChangeMonth(this.month, this.year);

  @override
  List<Object> get props => [month, year];
}

class NextMonth extends CalendarEvent {}

class PreviousMonth extends CalendarEvent {}

class SelectDay extends CalendarEvent {
  final CalendarDay day;

  const SelectDay(this.day);

  @override
  List<Object> get props => [day];
}
