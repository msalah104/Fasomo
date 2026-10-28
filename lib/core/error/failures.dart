import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const new(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const new(super.message);
}

class ServerFailure extends Failure {
  const new(super.message);
}

class ValidationFailure extends Failure {
  const new(super.message);
}
