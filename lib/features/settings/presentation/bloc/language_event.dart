part of 'language_bloc.dart';

sealed class LanguageEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

final class LanguageChanged extends LanguageEvent {
  const new(this.language);

  final AppLanguage language;

  @override
  List<Object> get props => [language];
}
