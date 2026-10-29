import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_copy.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/sync_notifications.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/usecases/get_reminders.dart';
import 'package:fasomo/features/reminders/domain/usecases/prompt_notification_permission_once.dart';
import 'package:fasomo/features/reminders/domain/usecases/save_reminder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  new({
    required this.getReminders,
    required this.saveReminder,
    required this.syncNotifications,
    required this.notificationPermission,
    required this.promptPermissionOnce,
  }) : super(const ReminderState()) {
    // One handler, processed in order, so mutations never interleave.
    on<ReminderEvent>(_onEvent, transformer: sequential());
  }

  final GetReminders getReminders;
  final SaveReminder saveReminder;

  /// The app-wide sync; it also schedules the make-up (Qada) reminders.
  final SyncNotifications syncNotifications;
  final NotificationPermission notificationPermission;
  final PromptNotificationPermissionOnce promptPermissionOnce;

  /// Text for the current language; set by [ReminderCopyChanged]. No sync
  /// runs until it is known.
  NotificationCopy? _copy;

  Future<void> _onEvent(
    ReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    switch (event) {
      case LoadReminders():
        emit(state.copyWith(status: ReminderStatus.loading));
        _emitStored(emit);
        await _sync(emit);
      case ReminderCopyChanged(:final copy):
        if (copy == _copy) return;
        _copy = copy;
        await _sync(emit);
      case SyncRequested():
        await _sync(emit);
      case PermissionPromptRequested():
        if (await promptPermissionOnce(const NoParams()) == false) {
          emit(state.copyWith(permissionDenied: true));
        }
      case AddFastingDayReminder(:final fastingType):
        await _save(Reminder(fastingType: fastingType, isEnabled: true), emit);
      case ToggleReminder(:final fastingType):
        await _save(_toggled(fastingType), emit);
      case UpdateReminderSettings(:final reminder):
        await _save(reminder, emit);
    }
  }

  Reminder _toggled(FastingType type) {
    final existing = state.reminders
        .where((r) => r.fastingType == type)
        .firstOrNull;
    return existing == null
        ? Reminder(fastingType: type, isEnabled: true)
        : existing.copyWith(isEnabled: !existing.isEnabled);
  }

  Future<void> _save(Reminder reminder, Emitter<ReminderState> emit) async {
    if (reminder.isEnabled && !await notificationPermission.request()) {
      // Keep the reminder so it starts working once permission is granted.
      emit(state.copyWith(permissionDenied: true));
    }
    await _apply(saveReminder(reminder), emit);
  }

  Future<void> _apply(
    Future<Result<void, StorageFailure>> mutation,
    Emitter<ReminderState> emit,
  ) async {
    switch (await mutation) {
      case Ok():
        _emitStored(emit);
        await _sync(emit);
      case Err(:final failure):
        emit(state.copyWith(failure: failure));
    }
  }

  void _emitStored(Emitter<ReminderState> emit) {
    switch (getReminders(const NoParams())) {
      case Ok(value: final reminders):
        emit(
          state.copyWith(
            status: ReminderStatus.success,
            reminders: reminders,
            permissionDenied: state.permissionDenied,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(status: ReminderStatus.error, failure: failure));
    }
  }

  Future<void> _sync(Emitter<ReminderState> emit) async {
    final copy = _copy;
    if (copy == null) return;
    if (await syncNotifications(copy) case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
    }
  }
}
