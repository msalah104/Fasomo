import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/usecases/get_suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/usecases/save_suhoor_iftar_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The suhoor and iftar reminder settings. A change shows at once and is
/// then saved; the app shell resyncs the notifications on every change.
/// The notifications follow what is saved, so a change that can't be saved
/// is undone.
class SuhoorIftarBloc extends Bloc<SuhoorIftarEvent, SuhoorIftarState> {
  /// Starts from the saved settings, read synchronously; unreadable ones
  /// show the defaults.
  new({
    required this.getSettings,
    required this.saveSettings,
  }) : super(SuhoorIftarState(settings: _saved(getSettings))) {
    on<SuhoorIftarSettingsChanged>(_onChanged, transformer: sequential());
    on<SuhoorIftarReloaded>(
      (event, emit) => emit(SuhoorIftarState(settings: _saved(getSettings))),
    );
  }

  final GetSuhoorIftarSettings getSettings;
  final SaveSuhoorIftarSettings saveSettings;

  static SuhoorIftarSettings _saved(GetSuhoorIftarSettings getSettings) =>
      switch (getSettings(const NoParams())) {
        Ok(:final value) => value,
        Err() => SuhoorIftarSettings.defaults,
      };

  Future<void> _onChanged(
    SuhoorIftarSettingsChanged event,
    Emitter<SuhoorIftarState> emit,
  ) async {
    final before = state.settings;
    if (event.settings == before) return;
    emit(SuhoorIftarState(settings: event.settings));
    if (await saveSettings(event.settings) case Err(:final failure)) {
      emit(SuhoorIftarState(settings: before, failure: failure));
    }
  }
}

sealed class SuhoorIftarEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// Replaces the settings.
final class SuhoorIftarSettingsChanged extends SuhoorIftarEvent {
  const new(this.settings);

  final SuhoorIftarSettings settings;

  @override
  List<Object> get props => [settings];
}

/// Reads the saved settings again, e.g. after a restore.
final class SuhoorIftarReloaded extends SuhoorIftarEvent {
  const new();
}

class SuhoorIftarState extends Equatable {
  const new({required this.settings, this.failure});

  final SuhoorIftarSettings settings;

  /// Set when the last change could not be saved (and was undone).
  final StorageFailure? failure;

  @override
  List<Object?> get props => [settings, failure];
}
