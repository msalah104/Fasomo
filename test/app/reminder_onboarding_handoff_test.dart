import 'package:fasomo/app/reminder_onboarding_handoff.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/onboarding/domain/entities/reminder_plan.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/usecases/get_reminders.dart';
import 'package:fasomo/features/reminders/domain/usecases/prompt_notification_permission_once.dart';
import 'package:fasomo/features/reminders/domain/usecases/save_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_reminder_repository.dart';

class _CountingPermission implements NotificationPermission {
  int requests = 0;

  @override
  Future<bool> request() async {
    requests++;
    return true;
  }
}

void main() {
  late InMemoryReminderRepository repository;
  late _CountingPermission permission;
  late ReminderOnboardingHandoff handoff;

  setUp(() {
    // What a fresh install reads: every type on, the evening before.
    repository = InMemoryReminderRepository([
      for (final type in FastingType.values)
        Reminder(fastingType: type, isEnabled: true),
    ]);
    permission = _CountingPermission();
    handoff = ReminderOnboardingHandoff(
      getReminders: GetReminders(repository),
      saveReminder: SaveReminder(repository),
      promptPermissionOnce: PromptNotificationPermissionOnce(
        repository: repository,
        permission: permission,
      ),
    );
  });

  Reminder reminderFor(FastingType type) =>
      repository.reminders.singleWhere((r) => r.fastingType == type);

  test('the default plan changes nothing', () async {
    final before = repository.reminders;
    expect(
      await handoff.applyReminderPlan(ReminderPlan.defaults),
      isA<Ok<void, StorageFailure>>(),
    );
    expect(repository.reminders, before);
  });

  test('turns on only the chosen types, all in the morning', () async {
    await handoff.applyReminderPlan(
      const ReminderPlan(
        enabledTypes: {FastingType.ramadan, FastingType.whiteDays},
        timing: ReminderTiming.morningOf,
      ),
    );

    for (final type in FastingType.values) {
      final reminder = reminderFor(type);
      expect(
        reminder.isEnabled,
        type == FastingType.ramadan || type == FastingType.whiteDays,
        reason: type.name,
      );
      expect(reminder.reminderTime, ReminderTime.morningOfDay);
      expect(reminder.timing, ReminderTiming.morningOf);
    }
  });

  test("a custom timing becomes each reminder's custom time", () async {
    const custom = ReminderTiming(daysBefore: 0, time: WallClockTime(4, 15));
    repository.reminders = [
      const Reminder(
        fastingType: FastingType.mondayThursday,
        isEnabled: true,
        customMessage: 'Suhoor!',
      ),
    ];

    await handoff.applyReminderPlan(
      const ReminderPlan(
        enabledTypes: {FastingType.mondayThursday},
        timing: custom,
      ),
    );

    final reminder = reminderFor(FastingType.mondayThursday);
    expect(reminder.reminderTime, ReminderTime.custom);
    expect(reminder.timing, custom);
    expect(reminder.customMessage, 'Suhoor!');
  });

  test('a storage failure is returned, not thrown', () async {
    repository.failure = const StorageReadFailed('reminders');
    expect(
      await handoff.applyReminderPlan(ReminderPlan.defaults),
      isA<Err<void, StorageFailure>>(),
    );
  });

  test('asks for notification permission once per install', () async {
    expect(await handoff.requestNotificationPermission(), isTrue);
    expect(await handoff.requestNotificationPermission(), isNull);
    expect(permission.requests, 1);
    // The app's own first-launch prompt then has nothing left to ask.
    expect(
      await PromptNotificationPermissionOnce(
        repository: repository,
        permission: permission,
      )(const NoParams()),
      isNull,
    );
  });
}
