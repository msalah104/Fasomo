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
