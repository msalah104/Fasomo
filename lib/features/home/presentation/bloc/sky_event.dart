part of 'sky_bloc.dart';

sealed class SkyEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The header is showing: draw the sky now and then every minute.
final class SkyStarted extends SkyEvent {
  const new();
}

/// A new minute began.
final class SkyTicked extends SkyEvent {
  const new();
}

/// The header went out of view (app in the background, another tab): stop
/// the minute ticks.
final class SkyPaused extends SkyEvent {
  const new();
}

/// The header is back in view: redraw at once and tick again.
final class SkyResumed extends SkyEvent {
  const new();
}

/// The user asked to use the device's location.
final class SkyDeviceLocationRequested extends SkyEvent {
  const new();
}

/// The user picked [city] from the list.
final class SkyCityChosen extends SkyEvent {
  const new(this.city);

  final City city;

  @override
  List<Object> get props => [city];
}

/// The user asked to open the system settings to allow location.
final class SkyLocationSettingsRequested extends SkyEvent {
  const new();
}
