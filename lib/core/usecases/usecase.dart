import 'package:equatable/equatable.dart';

abstract interface class UseCase<T, Params> {
  T call(Params params);
}

class NoParams extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}
