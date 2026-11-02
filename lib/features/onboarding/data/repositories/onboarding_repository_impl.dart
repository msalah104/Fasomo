import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:fasomo/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:flutter/services.dart';

/// [OnboardingRepository] on a local flag.
///
/// The flag is written as `false` when the flow starts, before any step
/// saves a choice. So a missing flag means the flow never started on this
/// install, and then data from an earlier version is what tells an update
/// apart from a fresh install.
class OnboardingRepositoryImpl implements OnboardingRepository {
  const new({required this.localDataSource});

  static const String _key = OnboardingLocalDataSourceImpl.completedKey;

  final OnboardingLocalDataSource localDataSource;

  @override
  Result<bool, StorageFailure> isCompleted() {
    try {
      return Ok(
        localDataSource.getCompleted() ??
            localDataSource.hasDataFromEarlierVersion(),
      );
    } on FormatException catch (e, st) {
      AppLog.error('onboarding.read', e, st);
      return const Err(StorageReadFailed(_key));
    }
  }

  @override
  Future<Result<void, StorageFailure>> markStarted() =>
      _write(completed: false);

  @override
  Future<Result<void, StorageFailure>> markCompleted() =>
      _write(completed: true);

  Future<Result<void, StorageFailure>> _write({required bool completed}) async {
    try {
      await localDataSource.setCompleted(completed: completed);
      return const Ok(null);
    } on StorageWriteException catch (e, st) {
      AppLog.error('onboarding.write', e, st);
      return const Err(StorageWriteFailed(_key));
    } on PlatformException catch (e, st) {
      AppLog.error('onboarding.write', e, st);
      return const Err(StorageWriteFailed(_key));
    }
  }
}
