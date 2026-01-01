part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {}

class ToggleLanguage extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}
