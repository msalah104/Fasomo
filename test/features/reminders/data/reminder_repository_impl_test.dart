import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fasomo/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ReminderRepositoryImpl> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    return ReminderRepositoryImpl(
      localDataSource: ReminderLocalDataSourceImpl(sharedPreferences: prefs),
    );
  }

  List<Reminder> stored(ReminderRepositoryImpl repository) =>
      switch (repository.getReminders()) {
        Ok(:final value) => value,
        Err() => fail('expected stored reminders'),
      };

  test('every type starts on, in priority order', () async {
    final reminders = stored(await repositoryWith({}));

    expect(reminders.map((r) => r.fastingType), FastingType.values);
    expect(reminders.every((r) => r.isEnabled), isTrue);
    expect(
      reminders.every((r) => r.reminderTime == ReminderTime.dayBefore),
      isTrue,
    );
  });

  test('a saved change replaces that type and keeps the others', () async {
    final repository = await repositoryWith({});
    const reminder = Reminder(
      fastingType: FastingType.whiteDays,
      isEnabled: true,
    );

    await repository.saveReminder(reminder);
    await repository.saveReminder(reminder.copyWith(isEnabled: false));

    final reminders = stored(repository);
    expect(reminders, hasLength(FastingType.values.length));
    expect(
      reminders.firstWhere((r) => r.fastingType == FastingType.whiteDays),
      reminder.copyWith(isEnabled: false),
    );
    expect(
      reminders.where((r) => r.fastingType != FastingType.whiteDays),
      everyElement(isA<Reminder>().having((r) => r.isEnabled, 'on', isTrue)),
    );
  });

  test('remembers that permission was asked for', () async {
    final repository = await repositoryWith({});
    expect(repository.wasPermissionAsked(), isFalse);

    await repository.markPermissionAsked();

    expect(repository.wasPermissionAsked(), isTrue);
    expect(
      (await repositoryWith({
        AppConstants.permissionAskedKey: true,
      })).wasPermissionAsked(),
      isTrue,
    );
  });

  test('corrupt storage is a typed read failure, not an exception', () async {
    final repository = await repositoryWith({
      AppConstants.remindersKey: ['{not json'],
    });
    expect(
      repository.getReminders(),
      isA<Err<List<Reminder>, StorageFailure>>().having(
        (e) => e.failure,
        'failure',
        isA<StorageReadFailed>(),
      ),
    );
  });
}
