import 'dart:convert';

import 'package:fasomo/core/backup/backup_envelope.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final envelope = BackupEnvelope(
    formatVersion: BackupEnvelope.currentFormatVersion,
    appVersion: '1.0.0',
    exportedAtUtc: DateTime.utc(2026, 11, 2, 10, 15),
    sections: const {
      'zeta': {'b': 2, 'a': 'سحور 🌙'},
      'alpha': {
        'list': [
          {'y': true, 'x': null},
        ],
      },
    },
  );

  Map<String, Object?> fileJson() =>
      jsonDecode(envelope.encode()) as Map<String, Object?>;

  BackupFailure failureOf(String contents) =>
      switch (BackupEnvelope.decode(contents)) {
        Ok() => fail('expected a failure'),
        Err(:final failure) => failure,
      };

  test('writes the header first, then sorted sections', () {
    final json = fileJson();
    expect(json.keys, [
      'format',
      'formatVersion',
      'appVersion',
      'exportedAtUtc',
      'sectionsSha256',
      'sections',
    ]);
    expect(json['format'], 'fasomo.backup');
    expect(json['exportedAtUtc'], '2026-11-02T10:15:00.000Z');
    expect((json['sections']! as Map<String, Object?>).keys, [
      'alpha',
      'zeta',
    ]);
  });

  test('the same data always encodes to the same bytes', () {
    final reordered = BackupEnvelope(
      formatVersion: envelope.formatVersion,
      appVersion: envelope.appVersion,
      exportedAtUtc: envelope.exportedAtUtc,
      sections: const {
        'alpha': {
          'list': [
            {'x': null, 'y': true},
          ],
        },
        'zeta': {'a': 'سحور 🌙', 'b': 2},
      },
    );
    expect(reordered.encode(), envelope.encode());
  });

  test('decodes what it encodes', () {
    final decoded = switch (BackupEnvelope.decode(envelope.encode())) {
      Ok(:final value) => value,
      Err(:final failure) => fail(failure.code),
    };
    expect(decoded.formatVersion, 1);
    expect(decoded.appVersion, '1.0.0');
    expect(decoded.exportedAtUtc, DateTime.utc(2026, 11, 2, 10, 15));
    expect(decoded.sections, envelope.sections);
  });

  test('the checksum ignores indentation', () {
    final compact = jsonEncode(fileJson());
    expect(
      BackupEnvelope.decode(compact),
      isA<Ok<BackupEnvelope, BackupFailure>>(),
    );
  });

  test('refuses a newer format before reading anything else', () {
    final json = fileJson()
      ..['formatVersion'] = 2
      ..['sectionsSha256'] = 'not checked';
    expect(
      failureOf(jsonEncode(json)),
      isA<BackupFormatTooNew>()
          .having((f) => f.found, 'found', 2)
          .having((f) => f.supported, 'supported', 1),
    );
  });

  test('refuses edited contents', () {
    final edited = envelope.encode().replaceFirst('سحور', 'سحوز');
    expect(failureOf(edited), isA<BackupChecksumMismatch>());
  });

  test('refuses a changed checksum', () {
    final json = fileJson()..['sectionsSha256'] = '0' * 64;
    expect(failureOf(jsonEncode(json)), isA<BackupChecksumMismatch>());
  });

  group('refuses what is not a backup', () {
    final cases = <String, String Function()>{
      'empty': () => '',
      'not JSON': () => 'hello',
      'truncated': () {
        final text = envelope.encode();
        return text.substring(0, text.length ~/ 2);
      },
      'a JSON list': () => '[]',
      'another format': () => jsonEncode(fileJson()..['format'] = 'other'),
      'no format': () => jsonEncode(fileJson()..remove('format')),
      'version zero': () => jsonEncode(fileJson()..['formatVersion'] = 0),
      'version as text': () => jsonEncode(fileJson()..['formatVersion'] = '1'),
      'no sections': () => jsonEncode(fileJson()..remove('sections')),
      'sections as a list': () => jsonEncode(fileJson()..['sections'] = []),
      'a local export time': () =>
          jsonEncode(fileJson()..['exportedAtUtc'] = '2026-11-02T10:15:00'),
      'an unreadable export time': () =>
          jsonEncode(fileJson()..['exportedAtUtc'] = 'yesterday'),
      'no checksum': () => jsonEncode(fileJson()..remove('sectionsSha256')),
    };
    for (final MapEntry(key: name, value: contents) in cases.entries) {
      test(name, () {
        expect(
          failureOf(contents()),
          isA<BackupMalformed>().having((f) => f.sectionId, 'section', null),
        );
      });
    }
  });
}
