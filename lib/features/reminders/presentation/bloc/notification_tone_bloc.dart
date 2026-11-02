import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/usecases/get_notification_tone.dart';
import 'package:fasomo/features/reminders/domain/usecases/save_notification_tone.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notification_tone_event.dart';
part 'notification_tone_state.dart';

/// The reminder sound setting.
///
/// A saved change shows up as a new [NotificationToneState.tone]; the app
/// shell then resyncs the notifications, which reschedules every pending
/// reminder with the new sound.
class NotificationToneBloc
    extends Bloc<NotificationToneEvent, NotificationToneState> {
  /// Starts from the saved tone, read synchronously.
  new({
    required GetNotificationTone getNotificationTone,
    required this.saveNotificationTone,
    required this.permission,
    required this.tonePreview,
  }) : super(
         NotificationToneState(
           tone: switch (getNotificationTone(const NoParams())) {
             Ok(:final value) => value,
             Err() => NotificationTone.systemDefault,
           },
         ),
       ) {
    // In order, so a save and a preview never interleave.
    on<NotificationToneEvent>(_onEvent, transformer: sequential());
  }

  final SaveNotificationTone saveNotificationTone;
  final NotificationPermission permission;
  final NotificationTonePreview tonePreview;

  Future<void> _onEvent(
    NotificationToneEvent event,
    Emitter<NotificationToneState> emit,
  ) async {
    // Clear the last message, so the same one can be shown again.
    if (state.failure != null || state.permissionDenied) {
      emit(NotificationToneState(tone: state.tone));
    }
    switch (event) {
      case NotificationToneChanged(:final tone):
        await _save(tone, emit);
      case NotificationTonePreviewRequested(
        :final tone,
        :final title,
        :final body,
      ):
        await _preview(tone, title: title, body: body, emit: emit);
    }
  }

  /// Saves first and switches only once saved, because the sync reads the
  /// saved tone: an unsaved choice would never reach the notifications.
  Future<void> _save(
    NotificationTone tone,
    Emitter<NotificationToneState> emit,
  ) async {
    if (tone == state.tone) return;
    switch (await saveNotificationTone(tone)) {
      case Ok():
        emit(NotificationToneState(tone: tone));
      case Err(:final failure):
        emit(NotificationToneState(tone: state.tone, failure: failure));
    }
  }

  Future<void> _preview(
    NotificationTone tone, {
    required String title,
    required String body,
    required Emitter<NotificationToneState> emit,
  }) async {
    if (!await permission.request()) {
      emit(NotificationToneState(tone: state.tone, permissionDenied: true));
      return;
    }
    final result = await tonePreview.preview(tone, title: title, body: body);
    if (result case Err(:final failure)) {
      emit(NotificationToneState(tone: state.tone, failure: failure));
    }
  }
}
