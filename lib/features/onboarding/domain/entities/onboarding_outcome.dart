/// How the first-run flow ended.
enum OnboardingOutcome {
  /// The user went through every step, including the notification one.
  completed,

  /// The user skipped the rest of the flow, so nothing has asked for
  /// notification permission yet.
  skipped,
}
