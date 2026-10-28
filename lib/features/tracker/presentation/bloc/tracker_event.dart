part of 'tracker_bloc.dart';

sealed class TrackerEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

final class LoadTracker extends TrackerEvent {
  const new();
}

/// Recomputes the summary, e.g. when the app returns to the foreground and
/// "today" may have moved on.
final class RefreshTracker extends TrackerEvent {
  const new();
}

/// Marks [date] as fasted, or clears it if it already is.
final class ToggleDayFasted extends TrackerEvent {
  const new(this.date);

  final DateTime date;

  @override
  List<Object> get props => [date];
}
