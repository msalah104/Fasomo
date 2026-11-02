import 'dart:convert';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/ramadan/data/repositories/ramadan_checklist_repository_impl.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSharedPreferences extends Mock implements SharedPreferences;

const String _key = RamadanChecklistRepositoryImpl.storageKey;

void main() {
  final day = DateTime(2027, 2, 19);

  Future<RamadanChecklistRepositoryImpl> repository([
    Map<String, Object> stored = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(stored);
    return RamadanChecklistRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
  }

  RamadanChecklist read(RamadanChecklistRepositoryImpl repo, DateTime date) =>
      switch (repo.checklistFor(date)) {
        Ok(:final value) => value,
        Err(:final failure) => fail('unexpected $failure'),
      };

  test('an empty checklist for a day with nothing saved', () async {
    final repo = await repository();
    expect(read(repo, day), RamadanChecklist(date: day));
  });

  test('saves per day, read back for that day only', () async {
    final repo = await repository();
    final checklist = RamadanChecklist(
      date: day,
      prayedTaraweeh: true,
      quranPages: 12,
    );

    expect(await repo.save(checklist), isA<Ok<void, StorageFailure>>());

    expect(read(repo, DateTime(2027, 2, 19, 21, 30)), checklist);
    expect(
      read(repo, DateTime(2027, 2, 20)),
      RamadanChecklist(date: DateTime(2027, 2, 20)),
    );
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString(_key)!), {
      '2027-02-19': {'taraweeh': true, 'quranPages': 12},
    });
  });

  test('clearing a day removes it from storage', () async {
    final repo = await repository({
      _key: jsonEncode({
        '2027-02-18': {'taraweeh': true, 'quranPages': 3},
        '2027-02-19': {'taraweeh': true, 'quranPages': 0},
      }),
    });

    await repo.save(RamadanChecklist(date: day));

    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString(_key)!), {
      '2027-02-18': {'taraweeh': true, 'quranPages': 3},
    });
  });

  group('unreadable data is a read failure', () {
    for (final raw in [
      'not json',
      '[]',
      jsonEncode({
        '2027-02-19': {'taraweeh': 'yes', 'quranPages': 1},
      }),
      jsonEncode({
        '2027-02-19': {'taraweeh': true, 'quranPages': 700},
      }),
    ]) {
      test(raw, () async {
        final repo = await repository({_key: raw});
        expect(
          repo.checklistFor(day),
          isA<Err<RamadanChecklist, StorageFailure>>().having(
            (e) => e.failure,
            'failure',
            isA<StorageReadFailed>(),
          ),
        );
      });
    }
  });

  test('a write over unreadable data starts afresh', () async {
    final repo = await repository({_key: 'not json'});
    final checklist = RamadanChecklist(date: day, quranPages: 2);

    expect(await repo.save(checklist), isA<Ok<void, StorageFailure>>());
    expect(read(repo, day), checklist);
  });

  group('a failed write is a write failure', () {
    late _MockSharedPreferences prefs;

    setUp(() {
      prefs = _MockSharedPreferences();
      when(() => prefs.get(any())).thenReturn(null);
    });

    test('refused', () async {
      when(() => prefs.setString(any(), any())).thenAnswer((_) async => false);
      final repo = RamadanChecklistRepositoryImpl(sharedPreferences: prefs);
      expect(
        await repo.save(RamadanChecklist(date: day, quranPages: 1)),
        isA<Err<void, StorageFailure>>().having(
          (e) => e.failure,
          'failure',
          isA<StorageWriteFailed>(),
        ),
      );
    });

    test('thrown by the platform', () async {
      when(
        () => prefs.setString(any(), any()),
      ).thenThrow(PlatformException(code: 'io'));
      final repo = RamadanChecklistRepositoryImpl(sharedPreferences: prefs);
      expect(
        await repo.save(RamadanChecklist(date: day, quranPages: 1)),
        isA<Err<void, StorageFailure>>(),
      );
    });
  });

  test('the checklist clamps pages and knows when it is empty', () {
    final checklist = RamadanChecklist(date: day);
    expect(checklist.isEmpty, isTrue);
    expect(checklist.copyWith(quranPages: 900).quranPages, 604);
    expect(checklist.copyWith(quranPages: -3).quranPages, 0);
    expect(checklist.copyWith(prayedTaraweeh: true).isEmpty, isFalse);
  });
}
