import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/notification_reconciler.dart';
import 'package:fasomo/core/services/notifications/fln_notification_gateway.dart';
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
import 'package:fasomo/features/reminders/domain/usecases/sync_reminder_notifications.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';
import 'package:fasomo/features/settings/domain/usecases/get_language.dart';
import 'package:fasomo/features/settings/domain/usecases/save_language.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/features/tracker/data/datasources/fast_log_local_data_source.dart';
import 'package:fasomo/features/tracker/data/repositories/fast_log_repository_impl.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';
import 'package:fasomo/features/tracker/domain/usecases/get_fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_day_fasted.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_extra_qada_owed.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_make_up_fast.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_ramadan_day_missed.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
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
        syncNotifications: sl(),
        notificationPermission: sl(),
      ),
    )
    ..registerLazySingleton(
      () => SyncReminderNotifications(
        repository: sl(),
        calendar: sl(),
        reconciler: sl(),
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
    // --- Tracker ---
    ..registerFactory(
      () => TrackerBloc(
        getSummary: sl(),
        setDayFasted: sl(),
        setRamadanDayMissed: sl(),
        setMakeUpFast: sl(),
        setExtraQadaOwed: sl(),
      ),
    )
    ..registerLazySingleton(() => GetFastLogSummary(sl()))
    ..registerLazySingleton(() => SetDayFasted(sl()))
    ..registerLazySingleton(() => SetRamadanDayMissed(sl()))
    ..registerLazySingleton(() => SetMakeUpFast(sl()))
    ..registerLazySingleton(() => SetExtraQadaOwed(sl()))
    ..registerLazySingleton<FastLogRepository>(
      () => FastLogRepositoryImpl(
        localDataSource: sl(),
        calendar: sl(),
        clock: sl(),
      ),
    )
    ..registerLazySingleton<FastLogLocalDataSource>(
      () => FastLogLocalDataSourceImpl(sharedPreferences: sl()),
    )
    // --- Settings ---
    ..registerFactory(() => LanguageBloc(getLanguage: sl(), saveLanguage: sl()))
    ..registerLazySingleton(() => GetLanguage(sl()))
    ..registerLazySingleton(() => SaveLanguage(sl()))
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sharedPreferences: sl()),
    )
    // ============ Core ============
    ..registerLazySingleton<Clock>(() => const Clock())
    ..registerLazySingleton<HijriConverter>(
      () => const UmmAlQuraHijriConverter(),
    )
    ..registerLazySingleton(() => FastingCalendar(sl()));

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final notifications = FlnNotificationGateway();
  await notifications.initialize();
  sl
    ..registerLazySingleton<NotificationGateway>(() => notifications)
    ..registerLazySingleton<NotificationPermission>(() => notifications)
    ..registerLazySingleton(() => NotificationReconciler(sl()));
}
