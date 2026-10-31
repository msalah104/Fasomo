part of 'sky_bloc.dart';

sealed class SkyEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// Computes the sky and starts the minute ticks.
final class SkyStarted extends SkyEvent {
  const new();
}

/// Recomputes the sky: a minute passed, or the app came back to the
/// foreground.
final class SkyRefreshed extends SkyEvent {
  const new();
}

/// The user asked to use the device's location for the sky.
final class SkyLocationRequested extends SkyEvent {
  const new();
}

/// The user asked to fix [failure] in system settings.
final class SkySettingsRequested extends SkyEvent {
  const new(this.failure);

  final LocationFailure failure;

  @override
  List<Object> get props => [failure];
}
