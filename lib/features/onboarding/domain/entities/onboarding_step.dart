/// The screens of the first-run flow, in the order they are shown.
enum OnboardingStep {
  /// Welcome, and the app language.
  welcome,

  /// Which kinds of fasting day to be reminded of.
  fastingTypes,

  /// When those reminders fire.
  reminderTime,

  /// Where the user is, for the sky (optional).
  location,

  /// Permission to show the reminders.
  notifications;

  /// Whether there is no step before this one.
  bool get isFirst => index == 0;

  /// Whether this is the step that finishes the flow.
  bool get isLast => index == values.length - 1;

  /// The step after this one, or this one when it is the last.
  OnboardingStep get next => isLast ? this : values[index + 1];

  /// The step before this one, or this one when it is the first.
  OnboardingStep get previous => isFirst ? this : values[index - 1];

  /// 1-based, for "Step 2 of 5".
  int get number => index + 1;
}
