import 'package:fasomo/core/error/failures.dart';

/// The outcome of an operation that can fail for an expected, recoverable
/// reason. Callers `switch` on [Ok] / [Err] exhaustively.
sealed class Result<T, F extends Failure> {
  const new();
}

final class Ok<T, F extends Failure> extends Result<T, F> {
  const new(this.value);
  final T value;
}

final class Err<T, F extends Failure> extends Result<T, F> {
  const new(this.failure);
  final F failure;
}

extension ResultX<T, F extends Failure> on Result<T, F> {
  R fold<R>(R Function(T value) onOk, R Function(F failure) onErr) =>
      switch (this) {
        Ok(:final value) => onOk(value),
        Err(:final failure) => onErr(failure),
      };

  Result<R, F> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Ok(transform(value)),
    Err(:final failure) => Err(failure),
  };
}
