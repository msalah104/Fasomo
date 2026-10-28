import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';

class SetRamadanDayMissed
    implements
        UseCase<Future<Result<void, Failure>>, SetRamadanDayMissedParams> {
  const new(this.repository);

  final FastLogRepository repository;

  @override
  Future<Result<void, Failure>> call(SetRamadanDayMissedParams params) =>
      repository.setMissedRamadan(params.date, missed: params.missed);
}

class SetRamadanDayMissedParams extends Equatable {
  const new({required this.date, required this.missed});

  final DateTime date;
  final bool missed;

  @override
  List<Object> get props => [date, missed];
}
