import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:fasomo/core/backup/backup_envelope.dart';
import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/backup/preferences_snapshot_store.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/calendar/data/backup/calendar_backup_section.dart';
import 'package:fasomo/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:fasomo/features/reminders/data/backup/reminders_backup_section.dart';
import 'package:fasomo/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/settings/data/backup/settings_backup_section.dart';
import 'package:fasomo/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/tracker/data/backup/tracker_backup_section.dart';
import 'package:fasomo/features/tracker/data/datasources/fast_log_local_data_source.dart';
import 'package:fasomo/features/tracker/data/datasources/qada_reminder_local_data_source.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fails every restore, to force a rollback after the real sections wrote.
class _FailingSection implements BackupSection {
  @override
  String get id => 'zz_failing';

  @override
  Set<String> get storageKeys => const {};

  @override
  Result<Map<String, Object?>, BackupFailure> export() => const Ok({});

  @override
  Result<void, BackupFailure> validate(Map<String, Object?> json) =>
      const Ok(null);

  @override
  Future<Result<void, BackupFailure>> restore(
    Map<String, Object?> json,
  ) async => Err(BackupStorageFailed(id));
}

/// A device: the real sections over its own shared preferences. Building
/// one resets the mock store, so finish with one device before the next.
class _Device {
  new _(this.preferences, {List<BackupSection> extra = const []})
    : service = BackupService(
        sections: [
          SettingsBackupSection(
            SettingsRepositoryImpl(sharedPreferences: preferences),
          ),
          RemindersBackupSection(
            ReminderLocalDataSourceImpl(sharedPreferences: preferences),
          ),
          TrackerBackupSection(
            fastLog: FastLogLocalDataSourceImpl(sharedPreferences: preferences),
            qadaReminders: QadaReminderLocalDataSourceImpl(
              sharedPreferences: preferences,
            ),
          ),
          CalendarBackupSection(
            CalendarLocalDataSourceImpl(sharedPreferences: preferences),
          ),
          ...extra,
        ],
        snapshots: PreferencesSnapshotStore(preferences),
        clock: Clock.fixed(DateTime.utc(2026, 11, 2, 10, 15)),
        appVersion: '1.0.0',
      );

  static Future<_Device> fresh({
    Map<String, Object> values = const {},
    List<BackupSection> extra = const [],
  }) async {
    SharedPreferences.setMockInitialValues(values);
    return _Device._(await SharedPreferences.getInstance(), extra: extra);
  }

  final SharedPreferences preferences;
  final BackupService service;

  String export() => switch (service.export()) {
    Ok(:final value) => value.contents,
    Err(:final failure) => fail('export failed: ${failure.code}'),
  };

  Map<String, Object?> stored() => {
    for (final key in preferences.getKeys()) key: preferences.get(key),
  };
}

/// Messages that break naive encoders: quotes, newlines, emoji, bidi marks,
/// Arabic, whitespace only and empty, next to one that is absent.
const List<String?> _hostileMessages = [
  'Suhoor "now", it\'s time\n\tline two',
  'سحور 🌙 ‏١٢٫٥‏ ok',
  '   ',
  '',
  r'\u0000 not an escape, =cmd() not a formula',
  null,
];

Future<void> _writeHostileFixture(SharedPreferences preferences) async {
  final settings = SettingsRepositoryImpl(sharedPreferences: preferences);
  await settings.saveLanguage(AppLanguage.arabic);
  await settings.saveThemeMode(AppThemeMode.dark);
  await settings.saveHijriOffset(HijriOffset.minusTwo);

  final reminders = ReminderLocalDataSourceImpl(sharedPreferences: preferences);
  // Stored out of order, to prove the export sorts them.
  final types = FastingType.values.reversed.toList();
  await reminders.saveReminders([
    for (var i = 0; i < _hostileMessages.length && i < types.length; i++)
      Reminder(
        fastingType: types[i],
        isEnabled: i.isEven,
        reminderTime: ReminderTime.values[i % ReminderTime.values.length],
        customTiming: ReminderTiming(
          daysBefore: i % 2,
          time: WallClockTime(23 - i, 59 - i),
        ),
        customMessage: _hostileMessages[i],
      ),
  ]);
  await reminders.saveNotificationTone(NotificationTone.vibrateOnly);

  // Years of daily entries, across a DST change and leap days.
  final fasted = {
    for (var i = 0; i < 3000; i += 2) DateTime(2018, 1, 1 + i),
  };
  final makeUp = {
    for (final day in fasted)
      if (day.day == 13) day,
  };
  await FastLogLocalDataSourceImpl(sharedPreferences: preferences).saveLog(
    FastLog(
      fastedDays: fasted,
      makeUpDays: makeUp,
      missedRamadanDays: {DateTime(2026, 2, 20), DateTime(2026, 3, 2)},
      extraOwed: const {1441: 999, 1446: 3},
    ),
  );
  await QadaReminderLocalDataSourceImpl(sharedPreferences: preferences)
      .saveSettings(
        const QadaReminderSettings(
          weeklyEnabled: false,
          weekdays: {DateTime.monday, DateTime.thursday},
          monthlyHijriDay: 30,
          daysBeforeRamadan: {354, 1},
          time: QadaReminderTime.morningOf,
          paceEnabled: true,
        ),
      );

  await CalendarLocalDataSourceImpl(
    sharedPreferences: preferences,
  ).saveShowGregorianDays(show: true);
}

void main() {
  test(
    'export, restore on a new phone, export again: identical bytes',
    () async {
      final phone = await _Device.fresh();
      await _writeHostileFixture(phone.preferences);
      final original = phone.export();

      final newPhone = await _Device.fresh();
      final result = await newPhone.service.restore(original);
      expect(result, isA<Ok<RestoreReport, BackupFailure>>());
      expect(newPhone.export(), original);

      // The values survived as data, not just as bytes.
      final sections =
          (jsonDecode(original) as Map<String, Object?>)['sections']!
              as Map<String, Object?>;
      final restoredMessages = [
        for (final reminder
            in (sections['reminders']! as Map<String, Object?>)['reminders']!
                as List<Object?>)
          (reminder! as Map<String, Object?>)['customMessage'],
      ];
      expect(restoredMessages.toSet(), _hostileMessages.toSet());
      expect(
        (sections['tracker']! as Map<String, Object?>)['fastedDays'],
        hasLength(1500),
      );
      expect(
        SettingsRepositoryImpl(
          sharedPreferences: newPhone.preferences,
        ).getHijriOffset(),
        isA<Ok<HijriOffset, StorageFailure>>().having(
          (ok) => ok.value,
          'offset',
          HijriOffset.minusTwo,
        ),
      );
    },
  );

  test('a backup of a fresh install restores to the same defaults', () async {
    final original = (await _Device.fresh()).export();
    final newPhone = await _Device.fresh(values: {'language': 'english'});
    await newPhone.service.restore(original);
    expect(newPhone.export(), original);
  });

  test('restoring the same file twice gives the same data', () async {
    final phone = await _Device.fresh();
    await _writeHostileFixture(phone.preferences);
    final original = phone.export();

    final newPhone = await _Device.fresh();
    await newPhone.service.restore(original);
    final once = newPhone.stored();
    await newPhone.service.restore(original);
    expect(newPhone.stored(), once);
  });

  test('a failed write rolls back every section, byte for byte', () async {
    final phone = await _Device.fresh();
    await _writeHostileFixture(phone.preferences);
    final original = phone.export();

    // The new phone already has some data of its own, and lacks other keys.
    final newPhone = await _Device.fresh(
      values: {
        'language': 'english',
        'fast_log': ['2026-01-05'],
        'notification_permission_asked': true,
      },
      extra: [_FailingSection()],
    );
    final before = newPhone.stored();
    // The failing section must be in the file for its restore to run.
    final result = await newPhone.service.restore(
      _withFailingSection(original),
    );
    expect(
      result,
      isA<Err<RestoreReport, BackupFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<BackupStorageFailed>(),
      ),
    );
    expect(newPhone.stored(), before);
  });
}

/// [contents] with an empty `zz_failing` section added and the checksum
/// recomputed, as if written that way.
String _withFailingSection(String contents) {
  final json = jsonDecode(contents) as Map<String, Object?>;
  return BackupEnvelope(
    formatVersion: json['formatVersion']! as int,
    appVersion: json['appVersion']! as String,
    exportedAtUtc: DateTime.parse(json['exportedAtUtc']! as String),
    sections: {
      ...json['sections']! as Map<String, Object?>,
      'zz_failing': <String, Object?>{},
    },
  ).encode();
}
