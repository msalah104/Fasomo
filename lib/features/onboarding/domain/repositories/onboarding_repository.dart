import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// Whether the first-run flow is done: the single place that is read and
/// saved.
abstract interface class OnboardingRepository {
  /// Whether onboarding is done (finished or skipped).
  ///
  /// An install that never recorded the flag counts as done when an earlier
  /// version of the app left data on the device, so an update does not
  /// show onboarding to people already using the app.
  Result<bool, StorageFailure> isCompleted();

  /// Records that onboarding is under way, before any step saves a choice,
  /// so a flow cut short is shown again on the next launch.
  Future<Result<void, StorageFailure>> markStarted();

  /// Records that onboarding is done, so it is not shown again.
  Future<Result<void, StorageFailure>> markCompleted();
}
