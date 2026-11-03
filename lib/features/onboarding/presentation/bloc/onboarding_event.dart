part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The flow is showing: record that it is under way.
final class OnboardingStarted extends OnboardingEvent {
  const new();
}

/// Go on to the next step.
final class OnboardingNextPressed extends OnboardingEvent {
  const new();
}

/// Go back to the previous step.
final class OnboardingBackPressed extends OnboardingEvent {
  const new();
}

/// Turn one fasting-type choice on or off.
final class OnboardingInterestToggled extends OnboardingEvent {
  const new(this.interest);

  final FastingInterest interest;

  @override
  List<Object> get props => [interest];
}

/// Pick the default reminder time.
final class OnboardingReminderPresetChanged extends OnboardingEvent {
  const new(this.preset);

  final ReminderTimePreset preset;

  @override
  List<Object> get props => [preset];
}

/// Change the day or time of the custom reminder time; also selects it.
final class OnboardingCustomTimingChanged extends OnboardingEvent {
  const new(this.timing);

  final ReminderTiming timing;

  @override
  List<Object> get props => [timing];
}

/// Use the device's approximate location.
final class OnboardingDeviceLocationRequested extends OnboardingEvent {
  const new();
}

/// The user picked [city] from the list.
final class OnboardingCityChosen extends OnboardingEvent {
  const new(this.city);

  final City city;

  @override
  List<Object> get props => [city];
}

/// The last step was answered: save the choices and finish. Asks the OS
/// for notification permission first when [allowNotifications].
final class OnboardingFinished extends OnboardingEvent {
  const new({required this.allowNotifications});

  final bool allowNotifications;

  @override
  List<Object> get props => [allowNotifications];
}

/// Skip the rest of the flow, keeping the choices made so far.
final class OnboardingSkipped extends OnboardingEvent {
  const new();
}
