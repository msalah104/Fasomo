import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';

class SetExtraQadaOwed
    implements UseCase<Future<Result<void, Failure>>, SetExtraQadaOwedParams> {
  const new(this.repository);

  final FastLogRepository repository;

  @override
  Future<Result<void, Failure>> call(SetExtraQadaOwedParams params) =>
      repository.setExtraOwed(params.hijriYear, days: params.days);
}

class SetExtraQadaOwedParams extends Equatable {
  const new({required this.hijriYear, required this.days})
    : assert(days >= 0, 'days owed cannot be negative');

  final int hijriYear;
  final int days;

  @override
  List<Object> get props => [hijriYear, days];
}
