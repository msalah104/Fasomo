part of 'duas_bloc.dart';

sealed class DuasEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// Show the texts for [filter], or every text when it is `null`. Also the
/// event that first loads the page.
final class DuasFilterChanged extends DuasEvent {
  const new(this.filter);

  final FastingType? filter;

  @override
  List<Object?> get props => [filter];
}
