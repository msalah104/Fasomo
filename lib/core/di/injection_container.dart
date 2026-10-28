import 'package:fasomo/core/utils/notification_helper.dart';
import 'package:fasomo/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:fasomo/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_month.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/home/data/datasources/fasting_local_data_source.dart';
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

Future<void> init() async {
  // ============ Features ============

  // --- Home Feature ---
  // Bloc
  sl.registerFactory(
    () => HomeBloc(
      getUpcomingFastingDays: sl(),
      getCurrentHijriDate: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUpcomingFastingDays(sl()));
  sl.registerLazySingleton(() => GetCurrentHijriDate(sl()));

  // Repository
  sl.registerLazySingleton<FastingRepository>(
    () => FastingRepositoryImpl(localDataSource: sl()),
  );

  // Data source
  sl.registerLazySingleton<FastingLocalDataSource>(
    () => FastingLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // --- Calendar Feature ---
  // Bloc
  sl.registerFactory(() => CalendarBloc(getHijriMonth: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetHijriMonth(sl()));

  // Repository
  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(localDataSource: sl()),
  );

  // Data source
  sl.registerLazySingleton<CalendarLocalDataSource>(
    CalendarLocalDataSourceImpl.new,
  );

  // --- Reminders Feature ---
  // Bloc
  sl.registerFactory(
    () => ReminderBloc(
      getReminders: sl(),
      saveReminder: sl(),
      deleteReminder: sl(),
      notificationPlugin: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetReminders(sl()));
  sl.registerLazySingleton(() => SaveReminder(sl()));
  sl.registerLazySingleton(() => DeleteReminder(sl()));

  // Repository
  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(localDataSource: sl()),
  );

  // Data source
  sl.registerLazySingleton<ReminderLocalDataSource>(
    () => ReminderLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ============ Core ============
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
  sl.registerLazySingleton(() => flutterLocalNotificationsPlugin);
}
