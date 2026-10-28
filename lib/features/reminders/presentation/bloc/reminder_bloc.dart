import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/core/utils/notification_helper.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/usecases/delete_reminder.dart';
import 'package:fasomo/features/reminders/domain/usecases/get_reminders.dart';
import 'package:fasomo/features/reminders/domain/usecases/save_reminder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  new({
    required this.getReminders,
    required this.saveReminder,
    required this.deleteReminder,
    required this.notificationPlugin,
    required this.clock,
  }) : super(const ReminderState()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddFastingDayReminder>(_onAddFastingDayReminder);
    on<ToggleReminder>(_onToggleReminder);
    on<UpdateReminderSettings>(_onUpdateReminderSettings);
    on<DeleteReminderEvent>(_onDeleteReminder);
  }

  final GetReminders getReminders;
  final SaveReminder saveReminder;
  final DeleteReminder deleteReminder;
  final FlutterLocalNotificationsPlugin notificationPlugin;
  final Clock clock;

  void _onLoadReminders(LoadReminders event, Emitter<ReminderState> emit) {
    emit(state.copyWith(status: ReminderStatus.loading));
    _emitStored(emit);
  }

  Future<void> _onAddFastingDayReminder(
    AddFastingDayReminder event,
    Emitter<ReminderState> emit,
  ) => _save(Reminder(fastingType: event.fastingType, isEnabled: true), emit);

  Future<void> _onToggleReminder(
    ToggleReminder event,
    Emitter<ReminderState> emit,
  ) async {
    final existing = state.reminders
        .where((r) => r.fastingType == event.fastingType)
        .firstOrNull;
    final updated = existing == null
        ? Reminder(fastingType: event.fastingType, isEnabled: true)
        : existing.copyWith(isEnabled: !existing.isEnabled);
    await _save(updated, emit);
  }

  Future<void> _onUpdateReminderSettings(
    UpdateReminderSettings event,
    Emitter<ReminderState> emit,
  ) => _save(event.reminder, emit);

  Future<void> _onDeleteReminder(
    DeleteReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    switch (await deleteReminder(event.fastingType.name)) {
      case Ok():
        await NotificationHelper.cancelNotification(
          notificationPlugin,
          event.fastingType.index,
        );
        _emitStored(emit);
      case Err(:final failure):
        emit(state.copyWith(status: ReminderStatus.error, failure: failure));
    }
  }

  Future<void> _save(Reminder reminder, Emitter<ReminderState> emit) async {
    switch (await saveReminder(reminder)) {
      case Ok():
        await NotificationHelper.cancelNotification(
          notificationPlugin,
          reminder.fastingType.index,
        );
        if (reminder.isEnabled) await _scheduleNotification(reminder);
        _emitStored(emit);
      case Err(:final failure):
        emit(state.copyWith(status: ReminderStatus.error, failure: failure));
    }
  }

  void _emitStored(Emitter<ReminderState> emit) {
    switch (getReminders(const NoParams())) {
      case Ok(value: final reminders):
        emit(
          state.copyWith(status: ReminderStatus.success, reminders: reminders),
        );
      case Err(:final failure):
        emit(state.copyWith(status: ReminderStatus.error, failure: failure));
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    // Placeholder fire time; real fasting-day fire times replace this.
    final scheduledDate = clock.now().add(const Duration(hours: 1));

    await NotificationHelper.scheduleNotification(
      flutterLocalNotificationsPlugin: notificationPlugin,
      id: reminder.fastingType.index,
      title: 'Fasting Reminder',
      body: reminder.customMessage ?? 'Fasting day coming up',
      scheduledDate: scheduledDate,
    );
  }
}
