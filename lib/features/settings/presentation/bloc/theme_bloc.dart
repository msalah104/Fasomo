import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/domain/usecases/get_theme_mode.dart';
import 'package:fasomo/features/settings/domain/usecases/save_theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  /// Starts from the saved theme mode, read synchronously so the first frame
  /// already paints light or dark as chosen, with no flash of the other.
  new({required GetThemeMode getThemeMode, required this.saveThemeMode})
    : super(
        ThemeState(
          mode: switch (getThemeMode(const NoParams())) {
            Ok(:final value) => value,
            Err() => AppThemeMode.system,
          },
        ),
      ) {
    on<ThemeModeChanged>(_onThemeModeChanged);
  }

  final SaveThemeMode saveThemeMode;

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    // Switch immediately; a failed save only means it is not remembered.
    emit(ThemeState(mode: event.mode));
    if (await saveThemeMode(event.mode) case Err(:final failure)) {
      emit(ThemeState(mode: event.mode, failure: failure));
    }
  }
}
