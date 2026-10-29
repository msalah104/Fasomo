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

/// Marks a Ramadan [date] as missed (owing a make-up fast), or clears it.
final class ToggleRamadanMissed extends TrackerEvent {
  const new(this.date);

  final DateTime date;

  @override
  List<Object> get props => [date];
}

/// Marks [date] as a make-up fast, or clears the make-up flag.
final class ToggleMakeUp extends TrackerEvent {
  const new(this.date);

  final DateTime date;

  @override
  List<Object> get props => [date];
}

/// Sets the days owed for the Ramadan of [hijriYear] that are not marked day
/// by day.
final class SetExtraOwed extends TrackerEvent {
  const new({required this.hijriYear, required this.days});

  final int hijriYear;
  final int days;

  @override
  List<Object> get props => [hijriYear, days];
}

/// Replaces the make-up reminder settings.
final class UpdateQadaReminders extends TrackerEvent {
  const new(this.settings);

  final QadaReminderSettings settings;

  @override
  List<Object> get props => [settings];
}
