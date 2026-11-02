part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

final class ThemeModeChanged extends ThemeEvent {
  const new(this.mode);

  final AppThemeMode mode;

  @override
  List<Object> get props => [mode];
}
