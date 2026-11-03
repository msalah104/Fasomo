import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:fasomo/core/backup/backup_envelope.dart';
import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/backup/preferences_snapshot_store.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A section that keeps one string under [key], with switchable failures.
class FakeSection implements BackupSection {
  new(this.id, this.preferences, {String? key}) : key = key ?? id;

  @override
  final String id;
  final String key;
  final SharedPreferences preferences;

  bool failExport = false;
  bool failRestore = false;
  bool throwOnRestore = false;
  final List<String> calls = [];

  @override
  Set<String> get storageKeys => {key};

  @override
  Result<Map<String, Object?>, BackupFailure> export() => failExport
      ? Err(BackupStorageFailed(id))
      : Ok({'value': preferences.getString(key)});

  @override
  Result<void, BackupFailure> validate(Map<String, Object?> json) {
    calls.add('validate');
    return json['value'] is String
        ? const Ok(null)
        : Err(BackupMalformed(sectionId: id));
  }

  @override
  Future<Result<void, BackupFailure>> restore(Map<String, Object?> json) async {
    calls.add('restore');
    // Writes before failing, like a section that fails on its second key.
    await preferences.setString(key, json['value']! as String);
    if (throwOnRestore) throw StateError('bug');
    return failRestore ? Err(BackupStorageFailed(id)) : const Ok(null);
  }
}

void main() {
  final exportedAt = DateTime.utc(2026, 11, 2, 10, 15);
  late SharedPreferences preferences;
  late FakeSection first;
  late FakeSection second;
  late BackupService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'first': 'old first',
      'untouched': 'kept',
    });
    preferences = await SharedPreferences.getInstance();
    first = FakeSection('first', preferences);
    second = FakeSection('second', preferences);
    service = BackupService(
      sections: [first, second],
      snapshots: PreferencesSnapshotStore(preferences),
      clock: Clock.fixed(exportedAt),
      appVersion: '1.0.0',
    );
  });

  String fileWith(Map<String, Object?> sections, {int? version}) =>
      BackupEnvelope(
        formatVersion: version ?? BackupEnvelope.currentFormatVersion,
        appVersion: '9.9.9',
        exportedAtUtc: exportedAt,
        sections: sections,
      ).encode();

  Map<String, Object?> stored() => {
    for (final key in preferences.getKeys()) key: preferences.get(key),
  };

  BackupFailure failureOf(Result<Object?, BackupFailure> result) =>
      switch (result) {
        Ok() => fail('expected a failure'),
        Err(:final failure) => failure,
      };

  group('export', () {
    test('writes every section, the app version and the UTC time', () {
      final file = switch (service.export()) {
        Ok(:final value) => value,
        Err(:final failure) => fail(failure.code),
      };
      expect(file.fileName, 'fasomo-backup-2026-11-02-1015.json');
      final json = jsonDecode(file.contents) as Map<String, Object?>;
      expect(json['appVersion'], '1.0.0');
      expect(json['exportedAtUtc'], '2026-11-02T10:15:00.000Z');
      expect(json['sections'], {
        'first': {'value': 'old first'},
        'second': {'value': null},
      });
    });

    test('fails whole when a section cannot be read', () {
      second.failExport = true;
      expect(
        failureOf(service.export()),
        isA<BackupStorageFailed>().having((f) => f.sectionId, 'id', 'second'),
      );
    });

    test('names the file by UTC time, whatever the local zone', () {
      expect(
        BackupService.fileNameFor(DateTime.utc(2027, 1, 9, 3, 7)),
        'fasomo-backup-2027-01-09-0307.json',
      );
    });
  });

  group('restore', () {
    test('replaces each section in the file and reports it', () async {
      final result = await service.restore(
        fileWith({
          'first': {'value': 'new first'},
          'second': {'value': 'new second'},
        }),
      );
      expect(
        result,
        isA<Ok<RestoreReport, BackupFailure>>().having(
          (ok) => ok.value,
          'report',
          RestoreReport(
            restoredSections: const ['first', 'second'],
            skippedSections: const [],
            exportedAtUtc: exportedAt,
          ),
        ),
      );
      expect(stored(), {
        'first': 'new first',
        'second': 'new second',
        'untouched': 'kept',
      });
    });

    test('leaves a section missing from the file untouched', () async {
      await service.restore(
        fileWith({
          'second': {'value': 'new second'},
        }),
      );
      expect(stored(), {
        'first': 'old first',
        'second': 'new second',
        'untouched': 'kept',
      });
      expect(first.calls, isEmpty);
    });

    test('skips and reports sections it does not know', () async {
      final result = await service.restore(
        fileWith({
          'first': {'value': 'new first'},
          'zodiac': {'anything': 1},
          'location': {'lat': 21.4},
        }),
      );
      expect(
        (result as Ok<RestoreReport, BackupFailure>).value.skippedSections,
        ['location', 'zodiac'],
      );
      expect(preferences.getString('first'), 'new first');
    });

    test('validates every section before writing any', () async {
      final before = stored();
      final result = await service.restore(
        fileWith({
          'first': {'value': 'new first'},
          'second': {'value': 42},
        }),
      );
      expect(
        failureOf(result),
        isA<BackupMalformed>().having((f) => f.sectionId, 'id', 'second'),
      );
      expect(first.calls, ['validate']);
      expect(stored(), before);
    });

    test('refuses a section that is not an object', () async {
      final result = await service.restore(
        fileWith({
          'first': ['new first'],
        }),
      );
      expect(
        failureOf(result),
        isA<BackupMalformed>().having((f) => f.sectionId, 'id', 'first'),
      );
    });

    test('refuses a file with nothing it can restore', () async {
      final before = stored();
      expect(
        failureOf(await service.restore(fileWith({}))),
        isA<BackupMalformed>(),
      );
      expect(
        failureOf(
          await service.restore(
            fileWith({
              'zodiac': {'anything': 1},
            }),
          ),
        ),
        isA<BackupMalformed>(),
      );
      expect(stored(), before);
    });

    test('refuses a newer format without writing anything', () async {
      final before = stored();
      final result = await service.restore(
        fileWith({
          'first': {'value': 'new first'},
        }, version: BackupEnvelope.currentFormatVersion + 1),
      );
      expect(failureOf(result), isA<BackupFormatTooNew>());
      expect(first.calls, isEmpty);
      expect(stored(), before);
    });

    test('refuses a checksum mismatch without writing anything', () async {
      final before = stored();
      final edited = fileWith({
        'first': {'value': 'new first'},
      }).replaceFirst('new first', 'evil first');
      expect(
        failureOf(await service.restore(edited)),
        isA<BackupChecksumMismatch>(),
      );
      expect(first.calls, isEmpty);
      expect(stored(), before);
    });

    test('rolls every section back when a later one fails to write', () async {
      second.failRestore = true;
      final before = stored();
      final result = await service.restore(
        fileWith({
          'first': {'value': 'new first'},
          'second': {'value': 'new second'},
        }),
      );
      expect(
        failureOf(result),
        isA<BackupStorageFailed>().having((f) => f.sectionId, 'id', 'second'),
      );
      expect(first.calls, ['validate', 'restore']);
      // "second" had no value before, so the rollback removes it again.
      expect(stored(), before);
    });

    test('rolls back on an unexpected throw too, then rethrows', () async {
      second.throwOnRestore = true;
      final before = stored();
      await expectLater(
        service.restore(
          fileWith({
            'first': {'value': 'new first'},
            'second': {'value': 'new second'},
          }),
        ),
        throwsStateError,
      );
      expect(stored(), before);
    });
  });

  group('PreferencesSnapshotStore', () {
    test('puts back every kind of value and removes new keys', () async {
      SharedPreferences.setMockInitialValues({
        'bool': true,
        'int': 7,
        'double': 1.5,
        'string': 'نص',
        'list': ['a', 'b'],
      });
      final prefs = await SharedPreferences.getInstance();
      final store = PreferencesSnapshotStore(prefs);
      final keys = {'bool', 'int', 'double', 'string', 'list', 'absent'};
      final snapshot = store.capture(keys);

      await prefs.setBool('bool', false);
      await prefs.setInt('int', 8);
      await prefs.setDouble('double', 2.5);
      await prefs.setString('string', 'other');
      await prefs.setStringList('list', ['c']);
      await prefs.setString('absent', 'now present');

      expect(await store.putBack(snapshot), isTrue);
      expect(
        {for (final key in keys) key: prefs.get(key)},
        {
          'bool': true,
          'int': 7,
          'double': 1.5,
          'string': 'نص',
          'list': ['a', 'b'],
          'absent': null,
        },
      );
    });
  });
}
