import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/sync_notifications.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/usecases/get_reminders.dart';
import 'package:fasomo/features/reminders/domain/usecases/prompt_notification_permission_once.dart';
import 'package:fasomo/features/reminders/domain/usecases/save_reminder.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_copy.dart';

class MockGetReminders extends Mock implements GetReminders;

class MockSaveReminder extends Mock implements SaveReminder;

class MockSyncNotifications extends Mock implements SyncNotifications;

class MockPromptPermissionOnce extends Mock
    implements PromptNotificationPermissionOnce;

class MockNotificationPermission extends Mock implements NotificationPermission;

void main() {
  late MockGetReminders getReminders;
  late MockSaveReminder saveReminder;
  late MockSyncNotifications sync;
  late MockNotificationPermission permission;
  late MockPromptPermissionOnce promptOnce;

  /// What storage holds; saveReminder mutates it.
  late List<Reminder> stored;

  const whiteDays = Reminder(
    fastingType: FastingType.whiteDays,
    isEnabled: true,
  );
  const writeFailed = StorageWriteFailed('reminders');

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(whiteDays);
    registerFallbackValue(const TestCopy());
  });

  setUp(() {
    stored = [];
    getReminders = MockGetReminders();
    saveReminder = MockSaveReminder();
    sync = MockSyncNotifications();
    permission = MockNotificationPermission();
    promptOnce = MockPromptPermissionOnce();

    when(() => getReminders(any())).thenAnswer((_) => Ok(List.of(stored)));
    when(() => saveReminder(any())).thenAnswer((invocation) async {
      final reminder = invocation.positionalArguments.first as Reminder;
      stored = [
        for (final r in stored)
          if (r.id != reminder.id) r,
        reminder,
      ];
      return const Ok(null);
    });
    when(() => promptOnce(any())).thenAnswer((_) async => true);
    when(() => sync(any())).thenAnswer((_) async => const Ok(null));
    when(() => permission.request()).thenAnswer((_) async => true);
  });

  ReminderBloc build() => ReminderBloc(
    getReminders: getReminders,
    saveReminder: saveReminder,
    syncNotifications: sync,
    notificationPermission: permission,
    promptPermissionOnce: promptOnce,
  );

  ReminderState loaded(List<Reminder> reminders) =>
      ReminderState(status: ReminderStatus.success, reminders: reminders);

  blocTest<ReminderBloc, ReminderState>(
    'LoadReminders emits the stored reminders; no sync before the copy is known',
    setUp: () => stored = [whiteDays],
    build: build,
    act: (bloc) => bloc.add(const LoadReminders()),
    expect: () => [
      const ReminderState(status: ReminderStatus.loading),
      loaded(const [whiteDays]),
    ],
    verify: (_) => verifyNever(() => sync(any())),
  );

  blocTest<ReminderBloc, ReminderState>(
    'ReminderCopyChanged syncs once per distinct copy',
    build: build,
    act: (bloc) => bloc
      ..add(const ReminderCopyChanged(TestCopy()))
      ..add(const ReminderCopyChanged(TestCopy())),
    verify: (_) => verify(() => sync(const TestCopy())).called(1),
  );

  blocTest<ReminderBloc, ReminderState>(
    'SyncRequested re-runs the sync with the current copy',
    build: build,
    act: (bloc) => bloc
      ..add(const ReminderCopyChanged(TestCopy()))
      ..add(const SyncRequested()),
    verify: (_) => verify(() => sync(any())).called(2),
  );

  blocTest<ReminderBloc, ReminderState>(
    'ToggleReminder creates an enabled reminder, asks permission, saves and syncs',
    build: build,
    act: (bloc) => bloc
      ..add(const ReminderCopyChanged(TestCopy()))
      ..add(const ToggleReminder(FastingType.whiteDays)),
    expect: () => [
      loaded(const [whiteDays]),
    ],
    verify: (_) {
      verify(() => permission.request()).called(1);
      verify(() => saveReminder(whiteDays)).called(1);
      verify(() => sync(any())).called(2);
    },
  );

  blocTest<ReminderBloc, ReminderState>(
    'ToggleReminder on an enabled reminder disables it without a permission prompt',
    setUp: () => stored = [whiteDays],
    build: build,
    seed: () => loaded(const [whiteDays]),
    act: (bloc) => bloc.add(const ToggleReminder(FastingType.whiteDays)),
    expect: () => [
      loaded([whiteDays.copyWith(isEnabled: false)]),
    ],
    verify: (_) => verifyNever(() => permission.request()),
  );

  blocTest<ReminderBloc, ReminderState>(
    'a denied permission still saves the reminder and flags it once',
    setUp: () =>
        when(() => permission.request()).thenAnswer((_) async => false),
    build: build,
    act: (bloc) => bloc.add(const AddFastingDayReminder(FastingType.whiteDays)),
    expect: () => [
      const ReminderState(permissionDenied: true),
      const ReminderState(
        status: ReminderStatus.success,
        reminders: [whiteDays],
        permissionDenied: true,
      ),
    ],
  );

  blocTest<ReminderBloc, ReminderState>(
    'UpdateReminderSettings saves the edited reminder',
    setUp: () => stored = [whiteDays],
    build: build,
    act: (bloc) => bloc.add(
      UpdateReminderSettings(
        whiteDays.copyWith(reminderTime: ReminderTime.morningOfDay),
      ),
    ),
    expect: () => [
      loaded([whiteDays.copyWith(reminderTime: ReminderTime.morningOfDay)]),
    ],
  );

  blocTest<ReminderBloc, ReminderState>(
    'a failed save reports the failure and keeps the list',
    setUp: () => when(
      () => saveReminder(any()),
    ).thenAnswer((_) async => const Err(writeFailed)),
    build: build,
    seed: () => loaded(const []),
    act: (bloc) => bloc.add(const AddFastingDayReminder(FastingType.whiteDays)),
    expect: () => [
      const ReminderState(status: ReminderStatus.success, failure: writeFailed),
    ],
  );

  blocTest<ReminderBloc, ReminderState>(
    'a failed sync reports a notification failure',
    setUp: () => when(() => sync(any())).thenAnswer(
      (_) async => const Err(NotificationPlatformFailed('schedule')),
    ),
    build: build,
    act: (bloc) => bloc.add(const ReminderCopyChanged(TestCopy())),
    expect: () => [
      const ReminderState(failure: NotificationPlatformFailed('schedule')),
    ],
  );

  blocTest<ReminderBloc, ReminderState>(
    'unreadable storage is an error state',
    setUp: () => when(
      () => getReminders(any()),
    ).thenReturn(const Err(StorageReadFailed('reminders'))),
    build: build,
    act: (bloc) => bloc.add(const LoadReminders()),
    expect: () => [
      const ReminderState(status: ReminderStatus.loading),
      const ReminderState(
        status: ReminderStatus.error,
        failure: StorageReadFailed('reminders'),
      ),
    ],
  );

  test('isEnabledFor reflects enabled reminders only', () {
    final state = loaded([
      whiteDays,
      const Reminder(fastingType: FastingType.shawwal, isEnabled: false),
    ]);
    expect(state.isEnabledFor(FastingType.whiteDays), isTrue);
    expect(state.isEnabledFor(FastingType.shawwal), isFalse);
    expect(state.isEnabledFor(FastingType.arafah), isFalse);
  });

  blocTest<ReminderBloc, ReminderState>(
    'the first-launch prompt reports a refusal',
    setUp: () => when(() => promptOnce(any())).thenAnswer((_) async => false),
    build: build,
    seed: () => loaded(const [whiteDays]),
    act: (bloc) => bloc.add(const PermissionPromptRequested()),
    expect: () => [
      const ReminderState(
        status: ReminderStatus.success,
        reminders: [whiteDays],
        permissionDenied: true,
      ),
    ],
  );

  blocTest<ReminderBloc, ReminderState>(
    'the prompt is silent on later launches',
    setUp: () => when(() => promptOnce(any())).thenAnswer((_) async => null),
    build: build,
    act: (bloc) => bloc.add(const PermissionPromptRequested()),
    expect: () => const <ReminderState>[],
  );
}
