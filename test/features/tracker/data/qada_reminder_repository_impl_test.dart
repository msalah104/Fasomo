import 'dart:convert';

import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/tracker/data/datasources/qada_reminder_local_data_source.dart';
import 'package:fasomo/features/tracker/data/repositories/qada_reminder_repository_impl.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<QadaReminderRepositoryImpl> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return QadaReminderRepositoryImpl(
      localDataSource: QadaReminderLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
    );
  }

  test(
    'everything is on by default: Saturday, the 13th, 30 and 7 days',
    () async {
      final settings = (await repositoryWith({})).getSettings();

      final value =
          (settings as Ok<QadaReminderSettings, StorageFailure>).value;
      expect(value, QadaReminderSettings.defaults);
      expect(value.weeklyEnabled, isTrue);
      expect(value.monthlyEnabled, isTrue);
      expect(value.beforeRamadanEnabled, isTrue);
      expect(value.weekdays, {DateTime.saturday});
      expect(value.monthlyHijriDay, 13);
      expect(value.daysBeforeRamadan, {30, 7});
      expect(value.time, QadaReminderTime.eveningBefore);
      expect(QadaReminderSettings.defaults.anyEnabled, isTrue);
    },
  );

  test('round-trips every setting', () async {
    final repository = await repositoryWith({});
    const settings = QadaReminderSettings(
      weeklyEnabled: false,
      weekdays: {DateTime.monday, DateTime.thursday},
      monthlyHijriDay: 20,
      daysBeforeRamadan: {100, 3},
      time: QadaReminderTime.morningOf,
    );

    await repository.saveSettings(settings);

    expect((repository.getSettings() as Ok).value, settings);
  });

  test('malformed settings are a read failure', () async {
    final valid = QadaReminderSettings.defaults.toJson();
    for (final bad in [
      jsonEncode({'weeklyEnabled': true}),
      jsonEncode({
        ...valid,
        'weekdays': [9],
      }),
      jsonEncode({...valid, 'time': 'noon'}),
      jsonEncode({
        ...valid,
        'daysBeforeRamadan': [0],
      }),
    ]) {
      final repository = await repositoryWith({
        AppConstants.qadaRemindersKey: bad,
      });
      expect(
        repository.getSettings(),
        isA<Err<QadaReminderSettings, StorageFailure>>(),
        reason: bad,
      );
    }
  });
}
