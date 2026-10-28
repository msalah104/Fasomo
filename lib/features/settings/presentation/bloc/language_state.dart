part of 'language_bloc.dart';

class LanguageState extends Equatable {
  const new({required this.language, this.failure});

  final AppLanguage language;

  /// Set when the choice could not be saved.
  final StorageFailure? failure;

  /// The locale to force on the app, or `null` to follow the device.
  Locale? get locale => switch (language.languageCode) {
    final code? => Locale(code),
    null => null,
  };

  @override
  List<Object?> get props => [language, failure];
}
