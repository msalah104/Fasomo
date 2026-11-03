import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/ramadan/data/backup/ramadan_backup_section.dart';
import 'package:fasomo/features/ramadan/data/repositories/ramadan_checklist_repository_impl.dart';
import 'package:fasomo/features/ramadan/data/repositories/suhoor_iftar_settings_repository_impl.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The value of [result]; `Ok` itself has no value equality.
T _read<T>(Result<T, StorageFailure> result) => switch (result) {
  Ok(:final value) => value,
  Err() => fail('read failed'),
};

void main() {
  const reminders = SuhoorIftarSettings(
    suhoorEnabled: false,
    suhoorMinutesBeforeFajr: 30,
    iftarMinutesBeforeMaghrib: 5,
    onOtherFastingDays: true,
  );
  final firstDay = RamadanChecklist(
    date: DateTime(2027, 2, 8),
    prayedTaraweeh: true,
  );
  final laterDay = RamadanChecklist(
    date: DateTime(2027, 2, 19),
    quranPages: 12,
  );

  Future<RamadanChecklistRepositoryImpl> checklists() async =>
      RamadanChecklistRepositoryImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

  Future<SuhoorIftarSettingsRepositoryImpl> settings() async =>
      SuhoorIftarSettingsRepositoryImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

  Future<RamadanBackupSection> section() async => RamadanBackupSection(
    checklist: await checklists(),
    reminders: await settings(),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a fresh install exports the defaults and no checklists', () async {
    final exported = switch ((await section()).export()) {
      Ok(:final value) => value,
      Err() => fail('export failed'),
    };

    expect(exported['checklist'], isEmpty);
    expect(
      exported['reminders'],
      SuhoorIftarSettingsRepositoryImpl.encode(SuhoorIftarSettings.defaults),
    );
  });

  test('days are exported sorted, with canonical dates', () async {
    final repo = await checklists();
    await repo.save(laterDay);
    await repo.save(firstDay);

    final exported = switch ((await section()).export()) {
      Ok(:final value) => value,
      Err() => fail('export failed'),
    };

    expect(exported['checklist'], [
      {'date': '2027-02-08', 'taraweeh': true, 'quranPages': 0},
      {'date': '2027-02-19', 'taraweeh': false, 'quranPages': 12},
    ]);
  });

  test('everything survives export and restore on another phone', () async {
    final phone = await checklists();
    await phone.save(firstDay);
    await phone.save(laterDay);
    await (await settings()).saveSettings(reminders);
    final exported = switch ((await section()).export()) {
      Ok(:final value) => value,
      Err() => fail('export failed'),
    };

    SharedPreferences.setMockInitialValues({});
    final newPhone = await section();
    expect(newPhone.validate(exported), const Ok<void, BackupFailure>(null));
    expect(
      await newPhone.restore(exported),
      const Ok<void, BackupFailure>(null),
    );

    expect(_read((await settings()).getSettings()), reminders);
    final restored = await checklists();
    expect(_read(restored.checklistFor(firstDay.date)), firstDay);
    expect(_read(restored.checklistFor(laterDay.date)), laterDay);
  });

  test('a restore replaces the checklists whole', () async {
    final repo = await checklists();
    await repo.save(firstDay);

    final result = await (await section()).restore({
      'reminders': SuhoorIftarSettingsRepositoryImpl.encode(reminders),
      'checklist': [
        {'date': '2027-02-19', 'taraweeh': false, 'quranPages': 12},
      ],
    });

    expect(result, isA<Ok<void, BackupFailure>>());
    expect(
      _read(repo.checklistFor(firstDay.date)),
      RamadanChecklist(date: firstDay.date),
    );
    expect(_read(repo.checklistFor(laterDay.date)), laterDay);
  });

  test('a stored day it cannot read fails the export', () async {
    SharedPreferences.setMockInitialValues({
      RamadanChecklistRepositoryImpl.storageKey:
          '{"2027-02-19": {"taraweeh": "yes", "quranPages": 12}}',
    });

    expect(
      (await section()).export(),
      isA<Err<Map<String, Object?>, BackupFailure>>(),
    );
  });

  test('rejects malformed sections without writing', () async {
    final repo = await checklists();
    await repo.save(firstDay);
    final validReminders = SuhoorIftarSettingsRepositoryImpl.encode(reminders);
    final section_ = await section();

    for (final bad in <Map<String, Object?>>[
      {},
      {'reminders': validReminders},
      {'checklist': <Object>[]},
      {
        'reminders': {'suhoor': true},
        'checklist': <Object>[],
      },
      {'reminders': validReminders, 'checklist': 'none'},
      for (final entry in <Object>[
        'a day',
        {'date': '2027-02-31', 'taraweeh': true, 'quranPages': 1},
        {'date': '19/02/2027', 'taraweeh': true, 'quranPages': 1},
        {'date': '2027-02-19', 'taraweeh': 1, 'quranPages': 1},
        {'date': '2027-02-19', 'taraweeh': true, 'quranPages': 605},
        {'date': '2027-02-19', 'taraweeh': true, 'quranPages': -1},
      ])
        {
          'reminders': validReminders,
          'checklist': [entry],
        },
      {
        'reminders': validReminders,
        'checklist': [
          {'date': '2027-02-19', 'taraweeh': true, 'quranPages': 1},
          {'date': '2027-02-19', 'taraweeh': false, 'quranPages': 2},
        ],
      },
    ]) {
      expect(section_.validate(bad), isA<Err<void, BackupFailure>>());
      expect(await section_.restore(bad), isA<Err<void, BackupFailure>>());
    }
    expect(_read(repo.checklistFor(firstDay.date)), firstDay);
  });
}
