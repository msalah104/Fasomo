import 'dart:convert';

import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/features/reminders/data/backup/reminders_backup_section.dart';
import 'package:fasomo/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockReminderLocalDataSource extends Mock
    implements ReminderLocalDataSource;

void main() {
  late ReminderLocalDataSourceImpl dataSource;
  late RemindersBackupSection section;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'notification_permission_asked': true,
    });
    dataSource = ReminderLocalDataSourceImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
    section = RemindersBackupSection(dataSource);
  });

  Map<String, Object?> exported() => switch (section.export()) {
    Ok(:final value) => value,
    Err(:final failure) => fail(failure.code),
  };

  final monday = const Reminder(
    fastingType: FastingType.mondayThursday,
    isEnabled: false,
  ).withCustomMessage('سحور 🌙');

  Map<String, Object?> reminderJson(Map<String, Object?> changes) => {
    ...const Reminder(
      fastingType: FastingType.mondayThursday,
      isEnabled: true,
    ).toJson(),
    ...changes,
  };

  test('a fresh install exports the default tone and no changes', () {
    expect(exported(), {
      'notificationTone': 'systemDefault',
      'reminders': <Object>[],
    });
  });

  test('exports the changed reminders in fasting-type order', () async {
    const arafah = Reminder(
      fastingType: FastingType.arafah,
      isEnabled: true,
      reminderTime: ReminderTime.morningOfDay,
    );
    // Stored in the opposite order.
    await dataSource.saveReminders([monday, arafah]);
    await dataSource.saveNotificationTone(NotificationTone.bell);
    final json = exported();
    expect(json['notificationTone'], 'bell');
    final types = [
      for (final reminder in json['reminders']! as List<Object?>)
        (reminder! as Map<String, Object?>)['fastingType'],
    ];
    expect(types, ['arafah', 'mondayThursday']);
  });

  test('cannot export unreadable reminders', () async {
    SharedPreferences.setMockInitialValues({
      'reminders': ['{"fastingType": "nope"}'],
    });
    section = RemindersBackupSection(
      ReminderLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
    );
    expect(section.export(), isA<Err<Object?, BackupFailure>>());
  });

  test('restores reminders and tone, but not the permission flag', () async {
    final json = {
      'notificationTone': 'gentle',
      'reminders': [monday.toJson()],
    };
    expect(section.validate(json), isA<Ok<void, BackupFailure>>());
    expect(await section.restore(json), isA<Ok<void, BackupFailure>>());
    expect(dataSource.getReminders(), [monday]);
    expect(dataSource.getNotificationTone(), NotificationTone.gentle);
    expect(dataSource.getPermissionAsked(), isTrue);
    expect(jsonEncode(exported()), jsonEncode(json));
  });

  group('validate refuses', () {
    final cases = <String, Map<String, Object?>>{
      'an unknown tone': {'notificationTone': 'trumpet', 'reminders': []},
      'a missing tone': {'reminders': []},
      'reminders that are not a list': {
        'notificationTone': 'bell',
        'reminders': {'monday': true},
      },
      'an unknown fasting type': {
        'notificationTone': 'bell',
        'reminders': [
          reminderJson({'fastingType': 'friday'}),
        ],
      },
      'the pre-1.0 type format': {
        'notificationTone': 'bell',
        'reminders': [
          reminderJson({'fastingType': 'FastingType.mondayThursday'}),
        ],
      },
      'an unknown reminder time': {
        'notificationTone': 'bell',
        'reminders': [
          reminderJson({'reminderTime': 'noon'}),
        ],
      },
      'an hour out of range': {
        'notificationTone': 'bell',
        'reminders': [
          reminderJson({'customHour': 24}),
        ],
      },
      'negative days before': {
        'notificationTone': 'bell',
        'reminders': [
          reminderJson({'customDaysBefore': -1}),
        ],
      },
      'a message that is not text': {
        'notificationTone': 'bell',
        'reminders': [
          reminderJson({'customMessage': 7}),
        ],
      },
      'a missing field': {
        'notificationTone': 'bell',
        'reminders': [reminderJson({})..remove('isEnabled')],
      },
      'two reminders for one fasting type': {
        'notificationTone': 'bell',
        'reminders': [
          reminderJson({}),
          reminderJson({'isEnabled': false}),
        ],
      },
    };
    for (final MapEntry(key: name, value: json) in cases.entries) {
      test(name, () {
        expect(
          section.validate(json),
          isA<Err<void, BackupFailure>>().having(
            (err) => err.failure,
            'failure',
            isA<BackupMalformed>().having(
              (f) => f.sectionId,
              'id',
              'reminders',
            ),
          ),
        );
      });
    }
  });

  test('a refused write is a storage failure', () async {
    registerFallbackValue(<Reminder>[]);
    final failing = MockReminderLocalDataSource();
    when(
      () => failing.saveReminders(any()),
    ).thenThrow(const StorageWriteException('reminders'));
    expect(
      await RemindersBackupSection(
        failing,
      ).restore({'notificationTone': 'bell', 'reminders': []}),
      isA<Err<void, BackupFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<BackupStorageFailed>(),
      ),
    );
  });
}
