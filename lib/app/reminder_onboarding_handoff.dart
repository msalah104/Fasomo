import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/onboarding/domain/entities/reminder_plan.dart';
import 'package:fasomo/features/onboarding/domain/onboarding_handoff.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/usecases/get_reminders.dart';
import 'package:fasomo/features/reminders/domain/usecases/prompt_notification_permission_once.dart';
import 'package:fasomo/features/reminders/domain/usecases/save_reminder.dart';

/// Onboarding's answers, applied through the reminders feature's use cases.
/// It lives in the app layer so neither feature imports the other.
class ReminderOnboardingHandoff implements OnboardingHandoff {
  const new({
    required this.getReminders,
    required this.saveReminder,
    required this.promptPermissionOnce,
  });

  final GetReminders getReminders;
  final SaveReminder saveReminder;
  final PromptNotificationPermissionOnce promptPermissionOnce;

  @override
  Future<Result<void, StorageFailure>> applyReminderPlan(
    ReminderPlan plan,
  ) async {
    switch (getReminders(const NoParams())) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: final reminders):
        for (final reminder in reminders) {
          final updated = planned(reminder, plan);
          if (updated == reminder) continue;
          if (await saveReminder(updated) case Err(:final failure)) {
            return Err(failure);
          }
        }
        return const Ok(null);
    }
  }

  @override
  Future<bool?> requestNotificationPermission() =>
      promptPermissionOnce(const NoParams());

  /// [reminder] on or off as [plan] says, at its timing. The standard
  /// timings keep their own setting, so the reminder editor shows them by
  /// name; any other is the reminder's custom timing.
  static Reminder planned(Reminder reminder, ReminderPlan plan) {
    final isEnabled = plan.enabledTypes.contains(reminder.fastingType);
    final timing = plan.timing;
    if (timing == ReminderTiming.dayBefore) {
      return reminder.copyWith(
        isEnabled: isEnabled,
        reminderTime: ReminderTime.dayBefore,
      );
    }
    if (timing == ReminderTiming.morningOf) {
      return reminder.copyWith(
        isEnabled: isEnabled,
        reminderTime: ReminderTime.morningOfDay,
      );
    }
    return reminder.copyWith(
      isEnabled: isEnabled,
      reminderTime: ReminderTime.custom,
      customTiming: timing,
    );
  }
}
