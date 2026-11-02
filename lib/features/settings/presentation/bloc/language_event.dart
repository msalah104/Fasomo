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

/// The saved language may have changed outside this bloc, e.g. by a
/// restore: read it again.
final class LanguageReloaded extends LanguageEvent {
  const new();
}
