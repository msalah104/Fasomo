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

  test('starts empty', () async {
    expect(stored(await repositoryWith({})), isEmpty);
  });

  test('save inserts, then replaces the reminder with the same type', () async {
    final repository = await repositoryWith({});
    const reminder = Reminder(
      fastingType: FastingType.whiteDays,
      isEnabled: true,
    );

    await repository.saveReminder(reminder);
    await repository.saveReminder(reminder.copyWith(isEnabled: false));

    expect(stored(repository), [reminder.copyWith(isEnabled: false)]);
  });

  test('delete removes only that reminder', () async {
    final repository = await repositoryWith({});
    await repository.saveReminder(
      const Reminder(fastingType: FastingType.whiteDays, isEnabled: true),
    );
    await repository.saveReminder(
      const Reminder(fastingType: FastingType.shawwal, isEnabled: true),
    );

    await repository.deleteReminder('whiteDays');

    expect(stored(repository).map((r) => r.fastingType), [FastingType.shawwal]);
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
