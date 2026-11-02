import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Whether the first-run flow is done. Synchronous, so the launch can
/// decide what follows the splash without waiting.
class IsOnboardingCompleted
    implements UseCase<Result<bool, StorageFailure>, NoParams> {
  const new(this.repository);

  final OnboardingRepository repository;

  @override
  Result<bool, StorageFailure> call(NoParams params) =>
      repository.isCompleted();
}
