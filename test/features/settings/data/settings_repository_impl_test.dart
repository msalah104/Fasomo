import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SettingsRepositoryImpl> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return SettingsRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
  }

  T valueOf<T>(Result<T, StorageFailure> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => fail('expected a value, got ${failure.code}'),
  };

  group('language', () {
    test('follows the system until one is saved', () async {
      final repository = await repositoryWith({});
      expect(valueOf(repository.getLanguage()), AppLanguage.system);
    });

    test('a saved language reads back, also after a restart', () async {
      final repository = await repositoryWith({});
      expect(
        await repository.saveLanguage(AppLanguage.arabic),
        isA<Ok<void, StorageFailure>>(),
      );
      expect(valueOf(repository.getLanguage()), AppLanguage.arabic);

      final stored = (await SharedPreferences.getInstance()).getString(
        AppConstants.languageKey,
      );
      expect(stored, 'arabic');
    });

    test('an unknown stored value is a read failure', () async {
      final repository = await repositoryWith({
        AppConstants.languageKey: 'klingon',
      });
      expect(repository.getLanguage(), isA<Err<AppLanguage, StorageFailure>>());
    });
  });

  group('theme mode', () {
    test('follows the system until one is saved', () async {
      final repository = await repositoryWith({});
      expect(valueOf(repository.getThemeMode()), AppThemeMode.system);
    });

    test('reads a stored mode synchronously', () async {
      final repository = await repositoryWith({
        AppConstants.themeModeKey: 'dark',
      });
      expect(valueOf(repository.getThemeMode()), AppThemeMode.dark);
    });

    test('a saved mode reads back', () async {
      final repository = await repositoryWith({});
      for (final mode in AppThemeMode.values) {
        expect(
          await repository.saveThemeMode(mode),
          isA<Ok<void, StorageFailure>>(),
        );
        expect(valueOf(repository.getThemeMode()), mode);
      }
    });

    test('an unknown or mistyped stored value is a read failure', () async {
      for (final stored in <Object>['sepia', 1]) {
        final repository = await repositoryWith({
          AppConstants.themeModeKey: stored,
        });
        expect(
          repository.getThemeMode(),
          isA<Err<AppThemeMode, StorageFailure>>().having(
            (err) => err.failure,
            'failure',
            const TypeMatcher<StorageReadFailed>().having(
              (failure) => failure.key,
              'key',
              AppConstants.themeModeKey,
            ),
          ),
        );
      }
    });

    test('is stored apart from the language', () async {
      final repository = await repositoryWith({});
      await repository.saveThemeMode(AppThemeMode.light);
      expect(valueOf(repository.getLanguage()), AppLanguage.system);
    });
  });

  group('Hijri offset', () {
    test('is none until one is saved', () async {
      final repository = await repositoryWith({});
      expect(valueOf(repository.getHijriOffset()), HijriOffset.none);
      expect(repository.hijriOffset, HijriOffset.none);
    });

    test('every offset saves as its days and reads back', () async {
      final repository = await repositoryWith({});
      for (final offset in HijriOffset.values) {
        expect(
          await repository.saveHijriOffset(offset),
          isA<Ok<void, StorageFailure>>(),
        );
        expect(valueOf(repository.getHijriOffset()), offset);
        expect(repository.hijriOffset, offset);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(AppConstants.hijriOffsetKey), offset.days);
      }
    });

    test('reads a stored offset synchronously', () async {
      final repository = await repositoryWith({
        AppConstants.hijriOffsetKey: -2,
      });
      expect(repository.hijriOffset, HijriOffset.minusTwo);
    });

    test('an out-of-range or mistyped value is a read failure, and the '
        'converter then applies none', () async {
      for (final stored in <Object>[3, -5, 'plusOne']) {
        final repository = await repositoryWith({
          AppConstants.hijriOffsetKey: stored,
        });
        expect(
          repository.getHijriOffset(),
          isA<Err<HijriOffset, StorageFailure>>(),
        );
        expect(repository.hijriOffset, HijriOffset.none);
      }
    });
  });
}
