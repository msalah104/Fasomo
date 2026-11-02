import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/onboarding/domain/entities/reminder_plan.dart';

/// What onboarding hands to the rest of the app. The app composes it from
/// the reminders feature's use cases, so onboarding never imports another
/// feature.
abstract interface class OnboardingHandoff {
  /// Turns reminders on for exactly [plan]'s types, all firing at its
  /// timing, keeping each reminder's custom message.
  Future<Result<void, StorageFailure>> applyReminderPlan(ReminderPlan plan);

  /// Asks the OS for notification permission, once per install. Returns
  /// whether notifications may be shown, or `null` when the user was asked
  /// before.
  Future<bool?> requestNotificationPermission();
}
