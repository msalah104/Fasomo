part of 'onboarding_bloc.dart';

/// Where the whole flow is.
enum OnboardingStatus {
  /// The user is going through the steps.
  inProgress,

  /// The choices are being saved; the controls are disabled meanwhile.
  saving,

  /// Done through the last step.
  completed,

  /// Done by skipping.
  skipped,
}

/// Where the location step is.
enum OnboardingLocationStatus { notSet, locating, set }

class OnboardingState extends Equatable {
  const new({
    this.step = OnboardingStep.welcome,
    this.interests = defaultInterests,
    this.reminderPreset = ReminderTimePreset.eveningBefore,
    this.customTiming = defaultCustomTiming,
    this.locationStatus = OnboardingLocationStatus.notSet,
    this.location,
    this.locationFailure,
    this.status = OnboardingStatus.inProgress,
    this.failure,
  });

  /// Every reminder starts out on, as it does without onboarding.
  static const Set<FastingInterest> defaultInterests = {
    FastingInterest.mondayThursday,
    FastingInterest.whiteDays,
    FastingInterest.ramadan,
    FastingInterest.shawwal,
    FastingInterest.specialDays,
  };

  /// What the custom option shows before the user changes it.
  static const ReminderTiming defaultCustomTiming = ReminderTiming(
    daysBefore: 1,
    time: WallClockTime(21, 0),
  );

  final OnboardingStep step;
  final Set<FastingInterest> interests;
  final ReminderTimePreset reminderPreset;

  /// Used when [reminderPreset] is [ReminderTimePreset.custom]; kept
  /// otherwise so switching back restores it.
  final ReminderTiming customTiming;

  final OnboardingLocationStatus locationStatus;

  /// The location set on the location step, once it is set.
  final GeoPoint? location;

  /// Why the device location could not be used; one emission only.
  final LocationFailure? locationFailure;

  final OnboardingStatus status;

  /// Why the choices could not be saved; one emission only.
  final StorageFailure? failure;

  /// Whether the flow has ended and the app should move on.
  bool get isDone =>
      status == OnboardingStatus.completed ||
      status == OnboardingStatus.skipped;

  /// What the reminders become when the flow ends.
  ReminderPlan get reminderPlan => ReminderPlan.fromChoices(
    interests: interests,
    preset: reminderPreset,
    customTiming: customTiming,
  );

  /// [locationFailure] and [failure] describe one emission only, so they
  /// reset unless passed again.
  OnboardingState copyWith({
    OnboardingStep? step,
    Set<FastingInterest>? interests,
    ReminderTimePreset? reminderPreset,
    ReminderTiming? customTiming,
    OnboardingLocationStatus? locationStatus,
    GeoPoint? location,
    LocationFailure? locationFailure,
    OnboardingStatus? status,
    StorageFailure? failure,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      interests: interests ?? this.interests,
      reminderPreset: reminderPreset ?? this.reminderPreset,
      customTiming: customTiming ?? this.customTiming,
      locationStatus: locationStatus ?? this.locationStatus,
      location: location ?? this.location,
      locationFailure: locationFailure,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    step,
    interests,
    reminderPreset,
    customTiming,
    locationStatus,
    location,
    locationFailure,
    status,
    failure,
  ];
}
