part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

final class LoadHomeData extends HomeEvent {
  const new();
}

final class RefreshHomeData extends HomeEvent {
  const new();
}

/// The user picked [date] in the week strip; the list starts from it.
final class DaySelected extends HomeEvent {
  const new(this.date);

  final DateTime date;

  @override
  List<Object> get props => [date];
}
