import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:fasomo/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A data source whose writes the platform refuses.
class _RefusingDataSource implements OnboardingLocalDataSource {
  @override
  bool? getCompleted() => null;

  @override
  bool hasDataFromEarlierVersion() => false;

  @override
  Future<void> setCompleted({required bool completed}) async =>
      throw const StorageWriteException(
        OnboardingLocalDataSourceImpl.completedKey,
      );
}

void main() {
  const key = OnboardingLocalDataSourceImpl.completedKey;

  Future<(OnboardingRepositoryImpl, SharedPreferences)> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = await SharedPreferences.getInstance();
    return (
      OnboardingRepositoryImpl(
        localDataSource: OnboardingLocalDataSourceImpl(
          sharedPreferences: preferences,
        ),
      ),
      preferences,
    );
  }

  bool completed(OnboardingRepositoryImpl repository) =>
      (repository.isCompleted() as Ok<bool, StorageFailure>).value;

  group('a fresh install', () {
    test('has not done onboarding', () async {
      final (repository, _) = await repositoryWith({});
      expect(completed(repository), isFalse);
    });

    test('has done it once it is marked completed', () async {
      final (repository, preferences) = await repositoryWith({});

      expect(await repository.markStarted(), isA<Ok<void, StorageFailure>>());
      expect(preferences.getBool(key), isFalse);
      expect(completed(repository), isFalse);

      expect(
        await repository.markCompleted(),
        isA<Ok<void, StorageFailure>>(),
      );
      expect(preferences.getBool(key), isTrue);
      expect(completed(repository), isTrue);
    });
  });

  group('an update from a version without onboarding', () {
    test('counts as done when permission was already asked', () async {
      final (repository, _) = await repositoryWith({
        AppConstants.permissionAskedKey: true,
      });
      expect(completed(repository), isTrue);
    });

    test('counts as done with saved reminders or a saved language', () async {
      for (final values in <Map<String, Object>>[
        {AppConstants.remindersKey: <String>[]},
        {AppConstants.languageKey: 'arabic'},
        {
          AppConstants.fastLogKey: <String>['2026-10-22'],
        },
      ]) {
        final (repository, _) = await repositoryWith(values);
        expect(completed(repository), isTrue, reason: '$values');
      }
    });

    test(
      'ignores data saved during an onboarding that was cut short',
      () async {
        // The flag is written as false before any step saves a choice.
        final (repository, _) = await repositoryWith({
          key: false,
          AppConstants.languageKey: 'arabic',
          AppConstants.permissionAskedKey: true,
        });
        expect(completed(repository), isFalse);
      },
    );
  });

  test('a flag of the wrong type is a read failure', () async {
    final (repository, _) = await repositoryWith({key: 'yes'});
    expect(
      repository.isCompleted(),
      isA<Err<bool, StorageFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<StorageReadFailed>(),
      ),
    );
  });

  test('a refused write is a write failure', () async {
    final repository = OnboardingRepositoryImpl(
      localDataSource: _RefusingDataSource(),
    );
    for (final write in [repository.markStarted, repository.markCompleted]) {
      expect(
        await write(),
        isA<Err<void, StorageFailure>>().having(
          (err) => err.failure,
          'failure',
          isA<StorageWriteFailed>(),
        ),
      );
    }
  });
}
