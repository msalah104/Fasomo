import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/notification_helper.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/get_reminders.dart';
import '../../domain/usecases/save_reminder.dart';
import '../../domain/usecases/delete_reminder.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final GetReminders getReminders;
  final SaveReminder saveReminder;
  final DeleteReminder deleteReminder;
  final FlutterLocalNotificationsPlugin notificationPlugin;

  ReminderBloc({
    required this.getReminders,
    required this.saveReminder,
    required this.deleteReminder,
    required this.notificationPlugin,
  }) : super(const ReminderState()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddFastingDayReminder>(_onAddFastingDayReminder);
    on<ToggleReminder>(_onToggleReminder);
    on<UpdateReminderSettings>(_onUpdateReminderSettings);
    on<DeleteReminderEvent>(_onDeleteReminder);

    // Initialize notifications
    NotificationHelper.initialize(notificationPlugin);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    try {
      final reminders = getReminders(NoParams());

      emit(state.copyWith(
        status: ReminderStatus.success,
        reminders: reminders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddFastingDayReminder(
    AddFastingDayReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final reminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fastingDay: event.fastingDay,
        title: event.title,
        isEnabled: true,
        reminderTime: ReminderTime.dayBefore,
      );

      await saveReminder(reminder);

      // Schedule notification
      await _scheduleNotification(reminder);

      final updatedReminders = getReminders(NoParams());
      emit(state.copyWith(
        status: ReminderStatus.success,
        reminders: updatedReminders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleReminder(
    ToggleReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final reminder = state.reminders.firstWhere(
        (r) => r.fastingDay == event.fastingDay,
      );

      final updatedReminder = reminder.copyWith(isEnabled: !reminder.isEnabled);

      // Update in repository
      await deleteReminder(reminder.id);
      await saveReminder(updatedReminder);

      // Update notification
      if (updatedReminder.isEnabled) {
        await _scheduleNotification(updatedReminder);
      } else {
        await NotificationHelper.cancelNotification(
          notificationPlugin,
          int.parse(updatedReminder.id),
        );
      }

      final updatedReminders = getReminders(NoParams());
      emit(state.copyWith(
        status: ReminderStatus.success,
        reminders: updatedReminders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateReminderSettings(
    UpdateReminderSettings event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await deleteReminder(event.reminder.id);
      await saveReminder(event.reminder);

      // Reschedule notification
      if (event.reminder.isEnabled) {
        await NotificationHelper.cancelNotification(
          notificationPlugin,
          int.parse(event.reminder.id),
        );
        await _scheduleNotification(event.reminder);
      }

      final updatedReminders = getReminders(NoParams());
      emit(state.copyWith(
        status: ReminderStatus.success,
        reminders: updatedReminders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await deleteReminder(event.id);

      await NotificationHelper.cancelNotification(
        notificationPlugin,
        int.parse(event.id),
      );

      final updatedReminders = getReminders(NoParams());
      emit(state.copyWith(
        status: ReminderStatus.success,
        reminders: updatedReminders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    // For demo purposes, schedule a notification
    // In a real app, you'd calculate the actual fasting day date
    final scheduledDate = DateTime.now().add(const Duration(hours: 1));

    final message = reminder.customMessage ??
        'Reminder: ${reminder.title} is coming up!';

    await NotificationHelper.scheduleNotification(
      flutterLocalNotificationsPlugin: notificationPlugin,
      id: int.parse(reminder.id),
      title: 'Fasting Reminder',
      body: message,
      scheduledDate: scheduledDate,
    );
  }
}
