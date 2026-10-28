part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

class LoadCalendar extends CalendarEvent;

class ChangeMonth extends CalendarEvent {
  const new(this.month, this.year);
  final int month;
  final int year;

  @override
  List<Object> get props => [month, year];
}

class NextMonth extends CalendarEvent;

class PreviousMonth extends CalendarEvent;

class SelectDay extends CalendarEvent {
  const new(this.day);
  final CalendarDay day;

  @override
  List<Object> get props => [day];
}
