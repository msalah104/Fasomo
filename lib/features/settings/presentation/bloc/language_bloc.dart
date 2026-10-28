import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/usecases/get_language.dart';
import 'package:fasomo/features/settings/domain/usecases/save_language.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  /// Starts from the saved language, read synchronously so the first frame
  /// already renders in the right language and direction.
  new({required GetLanguage getLanguage, required this.saveLanguage})
    : super(
        LanguageState(
          language: switch (getLanguage(const NoParams())) {
            Ok(:final value) => value,
            Err() => AppLanguage.system,
          },
        ),
      ) {
    on<LanguageChanged>(_onLanguageChanged);
  }

  final SaveLanguage saveLanguage;

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<LanguageState> emit,
  ) async {
    // Switch immediately; a failed save only means it is not remembered.
    emit(LanguageState(language: event.language));
    if (await saveLanguage(event.language) case Err(:final failure)) {
      emit(LanguageState(language: event.language, failure: failure));
    }
  }
}
