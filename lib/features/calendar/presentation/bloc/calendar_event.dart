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

/// Opens [month] in the month view, from any view.
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

/// Jumps back to the month containing today, resolving "today" afresh.
final class GoToToday extends CalendarEvent {
  const new();
}

/// Shows or hides the Gregorian day number in each day cell, and saves the
/// choice.
final class ToggleGregorianDays extends CalendarEvent {
  const new();
}

/// Shows the twelve months of the year of the shown month.
final class ShowYearView extends CalendarEvent {
  const new();
}

/// Returns from the year view to the month it was opened from.
final class ShowMonthView extends CalendarEvent {
  const new();
}

final class NextYear extends CalendarEvent {
  const new();
}

final class PreviousYear extends CalendarEvent {
  const new();
}
