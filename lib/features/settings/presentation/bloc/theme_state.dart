part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  const new({required this.mode, this.failure});

  final AppThemeMode mode;

  /// Set when the choice could not be saved.
  final StorageFailure? failure;

  /// The mode for [MaterialApp.themeMode].
  ThemeMode get themeMode => switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  @override
  List<Object?> get props => [mode, failure];
}
