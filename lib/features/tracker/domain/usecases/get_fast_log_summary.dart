import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';

class GetFastLogSummary
    implements UseCase<Result<FastLogSummary, StorageFailure>, NoParams> {
  const new(this.repository);

  final FastLogRepository repository;

  @override
  Result<FastLogSummary, StorageFailure> call(NoParams params) =>
      repository.getSummary();
}
