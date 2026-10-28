part of 'calendar_bloc.dart';

sealed class CalendarEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// Opens the month containing today.
final class LoadCalendar extends CalendarEvent {
  const new();
}

final class ChangeMonth extends CalendarEvent {
  const new(this.month);

  final HijriMonth month;

  @override
  List<Object> get props => [month];
}

final class NextMonth extends CalendarEvent {
  const new();
}

final class PreviousMonth extends CalendarEvent {
  const new();
}
