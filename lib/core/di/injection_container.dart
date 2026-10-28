import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/utils/notification_helper.dart';
import 'package:fasomo/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_current_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_month.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/home/data/repositories/fasting_repository_impl.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';
import 'package:fasomo/features/home/domain/usecases/get_current_hijri_date.dart';
import 'package:fasomo/features/home/domain/usecases/get_upcoming_fasting_days.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fasomo/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:fasomo/features/reminders/domain/usecases/delete_reminder.dart';
import 'package:fasomo/features/reminders/domain/usecases/get_reminders.dart';
import 'package:fasomo/features/reminders/domain/usecases/save_reminder.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

/// The composition root: the only place concrete implementations are chosen.
Future<void> init() async {
  // ============ Features ============

  // --- Home ---
  sl
    ..registerFactory(
      () => HomeBloc(getCurrentHijriDate: sl(), getUpcomingFastingDays: sl()),
    )
    ..registerLazySingleton(() => GetUpcomingFastingDays(sl()))
    ..registerLazySingleton(() => GetCurrentHijriDate(sl()))
    ..registerLazySingleton<FastingRepository>(
      () => FastingRepositoryImpl(calendar: sl(), clock: sl()),
    )
    // --- Calendar ---
    ..registerFactory(
      () => CalendarBloc(getCurrentHijriMonth: sl(), getHijriMonth: sl()),
    )
    ..registerLazySingleton(() => GetCurrentHijriMonth(sl()))
    ..registerLazySingleton(() => GetHijriMonth(sl()))
    ..registerLazySingleton<CalendarRepository>(
      () => CalendarRepositoryImpl(calendar: sl(), clock: sl()),
    )
    // --- Reminders ---
    ..registerFactory(
      () => ReminderBloc(
        getReminders: sl(),
        saveReminder: sl(),
        deleteReminder: sl(),
        notificationPlugin: sl(),
        clock: sl(),
      ),
    )
    ..registerLazySingleton(() => GetReminders(sl()))
    ..registerLazySingleton(() => SaveReminder(sl()))
    ..registerLazySingleton(() => DeleteReminder(sl()))
    ..registerLazySingleton<ReminderRepository>(
      () => ReminderRepositoryImpl(localDataSource: sl()),
    )
    ..registerLazySingleton<ReminderLocalDataSource>(
      () => ReminderLocalDataSourceImpl(sharedPreferences: sl()),
    )
    // ============ Core ============
    ..registerLazySingleton<Clock>(() => const Clock())
    ..registerLazySingleton<HijriConverter>(
      () => const UmmAlQuraHijriConverter(),
    )
    ..registerLazySingleton(() => FastingCalendar(sl()));

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
  sl.registerLazySingleton(() => flutterLocalNotificationsPlugin);
}
