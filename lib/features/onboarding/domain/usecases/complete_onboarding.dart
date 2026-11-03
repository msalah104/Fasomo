import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Records that the first-run flow is done, so it is not shown again.
class CompleteOnboarding
    implements UseCase<Future<Result<void, StorageFailure>>, NoParams> {
  const new(this.repository);

  final OnboardingRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(NoParams params) =>
      repository.markCompleted();
}
