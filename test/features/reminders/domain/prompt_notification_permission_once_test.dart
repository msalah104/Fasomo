import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/usecases/prompt_notification_permission_once.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/in_memory_reminder_repository.dart';

class MockNotificationPermission extends Mock implements NotificationPermission;

void main() {
  test('asks on the first launch only', () async {
    final repository = InMemoryReminderRepository(const []);
    final permission = MockNotificationPermission();
    when(permission.request).thenAnswer((_) async => true);
    final prompt = PromptNotificationPermissionOnce(
      repository: repository,
      permission: permission,
    );

    expect(await prompt(const NoParams()), isTrue);
    expect(await prompt(const NoParams()), isNull);
    verify(permission.request).called(1);
  });
}
