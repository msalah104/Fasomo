import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/settings/data/backup/settings_backup_section.dart';
import 'package:fasomo/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSettingsRepository extends Mock implements SettingsRepository;

void main() {
  late SettingsRepositoryImpl repository;
  late SettingsBackupSection section;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = SettingsRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
    section = SettingsBackupSection(repository);
  });

  Map<String, Object?> exported() => switch (section.export()) {
    Ok(:final value) => value,
    Err(:final failure) => fail(failure.code),
  };

  test('exports the defaults of a fresh install', () {
    expect(exported(), {
      'language': 'system',
      'themeMode': 'system',
      'hijriOffsetDays': 0,
    });
  });

  test('exports enum names and the offset in days', () async {
    await repository.saveLanguage(AppLanguage.arabic);
    await repository.saveThemeMode(AppThemeMode.dark);
    await repository.saveHijriOffset(HijriOffset.minusOne);
    expect(exported(), {
      'language': 'arabic',
      'themeMode': 'dark',
      'hijriOffsetDays': -1,
    });
  });

  test('cannot export an unreadable stored value', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'sepia'});
    section = SettingsBackupSection(
      SettingsRepositoryImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
    );
    expect(section.export(), isA<Err<Object?, BackupFailure>>());
  });

  test('restores what it exported', () async {
    final json = {
      'language': 'english',
      'themeMode': 'light',
      'hijriOffsetDays': 2,
    };
    expect(section.validate(json), isA<Ok<void, BackupFailure>>());
    expect(await section.restore(json), isA<Ok<void, BackupFailure>>());
    expect(exported(), json);
  });

  group('validate refuses', () {
    const valid = {
      'language': 'arabic',
      'themeMode': 'dark',
      'hijriOffsetDays': 1,
    };
    final cases = <String, Map<String, Object?>>{
      'an unknown language': {...valid, 'language': 'french'},
      'a localized language': {...valid, 'language': 'العربية'},
      'an unknown theme': {...valid, 'themeMode': 'sepia'},
      'an offset out of range': {...valid, 'hijriOffsetDays': 3},
      'an offset as text': {...valid, 'hijriOffsetDays': '1'},
      'Arabic-Indic digits': {...valid, 'hijriOffsetDays': '١'},
      'a missing language': {...valid}..remove('language'),
    };
    for (final MapEntry(key: name, value: json) in cases.entries) {
      test(name, () {
        expect(
          section.validate(json),
          isA<Err<void, BackupFailure>>().having(
            (err) => err.failure,
            'failure',
            isA<BackupMalformed>().having((f) => f.sectionId, 'id', 'settings'),
          ),
        );
      });
    }
  });

  test('a failed save is a storage failure', () async {
    final failing = MockSettingsRepository();
    when(
      () => failing.saveLanguage(AppLanguage.arabic),
    ).thenAnswer((_) async => const Ok(null));
    when(
      () => failing.saveThemeMode(AppThemeMode.dark),
    ).thenAnswer((_) async => const Err(StorageWriteFailed('theme_mode')));
    final result = await SettingsBackupSection(failing).restore({
      'language': 'arabic',
      'themeMode': 'dark',
      'hijriOffsetDays': 0,
    });
    expect(
      result,
      isA<Err<void, BackupFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<BackupStorageFailed>(),
      ),
    );
  });
}
