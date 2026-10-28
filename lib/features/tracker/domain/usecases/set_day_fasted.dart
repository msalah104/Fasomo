import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';

class SetDayFasted
    implements UseCase<Future<Result<void, Failure>>, SetDayFastedParams> {
  const new(this.repository);

  final FastLogRepository repository;

  @override
  Future<Result<void, Failure>> call(SetDayFastedParams params) =>
      repository.setFasted(params.date, fasted: params.fasted);
}

class SetDayFastedParams extends Equatable {
  const new({required this.date, required this.fasted});

  final DateTime date;
  final bool fasted;

  @override
  List<Object> get props => [date, fasted];
}
