import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';

class SetMakeUpFast
    implements UseCase<Future<Result<void, Failure>>, SetMakeUpFastParams> {
  const new(this.repository);

  final FastLogRepository repository;

  @override
  Future<Result<void, Failure>> call(SetMakeUpFastParams params) =>
      repository.setMakeUp(params.date, makeUp: params.makeUp);
}

class SetMakeUpFastParams extends Equatable {
  const new({required this.date, required this.makeUp});

  final DateTime date;
  final bool makeUp;

  @override
  List<Object> get props => [date, makeUp];
}
