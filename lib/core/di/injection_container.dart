import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/home/data/datasources/fasting_local_data_source.dart';
import '../../features/home/data/repositories/fasting_repository_impl.dart';
import '../../features/home/domain/repositories/fasting_repository.dart';
import '../../features/home/domain/usecases/get_upcoming_fasting_days.dart';
import '../../features/home/domain/usecases/get_current_hijri_date.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

import '../../features/calendar/data/datasources/calendar_local_data_source.dart';
import '../../features/calendar/data/repositories/calendar_repository_impl.dart';
import '../../features/calendar/domain/repositories/calendar_repository.dart';
import '../../features/calendar/domain/usecases/get_hijri_month.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';

import '../../features/reminders/data/datasources/reminder_local_data_source.dart';
import '../../features/reminders/data/repositories/reminder_repository_impl.dart';
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import '../../features/reminders/domain/usecases/get_reminders.dart';
import '../../features/reminders/domain/usecases/save_reminder.dart';
import '../../features/reminders/domain/usecases/delete_reminder.dart';
import '../../features/reminders/presentation/bloc/reminder_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============ Features ============

  // --- Home Feature ---
  // Bloc
  sl.registerFactory(() => HomeBloc(
        getUpcomingFastingDays: sl(),
        getCurrentHijriDate: sl(),
      ));

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
    () => CalendarLocalDataSourceImpl(),
  );

  // --- Reminders Feature ---
  // Bloc
  sl.registerFactory(() => ReminderBloc(
        getReminders: sl(),
        saveReminder: sl(),
        deleteReminder: sl(),
        notificationPlugin: sl(),
      ));

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
  sl.registerLazySingleton(() => flutterLocalNotificationsPlugin);
}
