import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/location/device_location_gateway.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/location/location_repository_impl.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/notification_reconciler.dart';
import 'package:fasomo/core/notifications/sync_notifications.dart';
import 'package:fasomo/core/push/push_messaging.dart';
import 'package:fasomo/core/push/sync_announcement_topic.dart';
import 'package:fasomo/core/services/location/geolocator_location_gateway.dart';
import 'package:fasomo/core/services/notifications/fln_notification_gateway.dart';
import 'package:fasomo/core/services/push/fcm_push_messaging.dart';
import 'package:fasomo/core/time/minute_ticker.dart';
import 'package:fasomo/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_current_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_month.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/home/data/repositories/fasting_repository_impl.dart';
import 'package:fasomo/features/home/data/services/suncalc_sky_calculator.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';
import 'package:fasomo/features/home/domain/services/sky_calculator.dart';
import 'package:fasomo/features/home/domain/usecases/get_current_hijri_date.dart';
import 'package:fasomo/features/home/domain/usecases/get_sky_scene.dart';
import 'package:fasomo/features/home/domain/usecases/get_upcoming_fasting_days.dart';
import 'package:fasomo/features/home/domain/usecases/open_location_settings.dart';
import 'package:fasomo/features/home/domain/usecases/refresh_saved_location.dart';
import 'package:fasomo/features/home/domain/usecases/use_device_location.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/home/presentation/bloc/sky_bloc.dart';
import 'package:fasomo/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fasomo/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:fasomo/features/reminders/domain/fasting_reminder_source.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:fasomo/features/reminders/domain/usecases/get_reminders.dart';
import 'package:fasomo/features/reminders/domain/usecases/prompt_notification_permission_once.dart';
import 'package:fasomo/features/reminders/domain/usecases/save_reminder.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';
import 'package:fasomo/features/settings/domain/usecases/get_language.dart';
import 'package:fasomo/features/settings/domain/usecases/save_language.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/features/tracker/data/datasources/fast_log_local_data_source.dart';
import 'package:fasomo/features/tracker/data/datasources/qada_reminder_local_data_source.dart';
import 'package:fasomo/features/tracker/data/repositories/fast_log_repository_impl.dart';
import 'package:fasomo/features/tracker/data/repositories/qada_reminder_repository_impl.dart';
import 'package:fasomo/features/tracker/domain/qada_reminder_planner.dart';
import 'package:fasomo/features/tracker/domain/qada_reminder_source.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';
import 'package:fasomo/features/tracker/domain/repositories/qada_reminder_repository.dart';
import 'package:fasomo/features/tracker/domain/usecases/can_make_up_on.dart';
import 'package:fasomo/features/tracker/domain/usecases/get_fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/usecases/get_qada_reminder_settings.dart';
import 'package:fasomo/features/tracker/domain/usecases/save_qada_reminder_settings.dart';
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
    ..registerFactory(
      () => SkyBloc(
        getSkyScene: sl(),
        ticker: sl(),
        useDeviceLocation: sl(),
        refreshSavedLocation: sl(),
        openLocationSettings: sl(),
      ),
    )
    ..registerLazySingleton(() => UseDeviceLocation(sl()))
    ..registerLazySingleton(() => RefreshSavedLocation(sl()))
    ..registerLazySingleton(() => OpenLocationSettings(sl()))
    ..registerLazySingleton(
      () => GetSkyScene(location: sl(), calculator: sl(), clock: sl()),
    )
    ..registerLazySingleton<SkyCalculator>(() => const SuncalcSkyCalculator())
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
        syncNotifications: sl(),
        notificationPermission: sl(),
        promptPermissionOnce: sl(),
      ),
    )
    ..registerLazySingleton(
      () => FastingReminderSource(repository: sl(), calendar: sl()),
    )
    ..registerLazySingleton(() => GetReminders(sl()))
    ..registerLazySingleton(() => SaveReminder(sl()))
    ..registerLazySingleton(
      () =>
          PromptNotificationPermissionOnce(repository: sl(), permission: sl()),
    )
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
        canMakeUpOnDay: sl(),
        getQadaReminders: sl(),
        saveQadaReminders: sl(),
      ),
    )
    ..registerLazySingleton(
      () => QadaReminderSource(settings: sl(), fastLog: sl(), planner: sl()),
    )
    ..registerLazySingleton(() => QadaReminderPlanner(sl()))
    ..registerLazySingleton(() => GetQadaReminderSettings(sl()))
    ..registerLazySingleton(() => SaveQadaReminderSettings(sl()))
    ..registerLazySingleton<QadaReminderRepository>(
      () => QadaReminderRepositoryImpl(localDataSource: sl()),
    )
    ..registerLazySingleton<QadaReminderLocalDataSource>(
      () => QadaReminderLocalDataSourceImpl(sharedPreferences: sl()),
    )
    ..registerLazySingleton(() => CanMakeUpOn(sl()))
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
    ..registerLazySingleton(() => FastingCalendar(sl()))
    ..registerLazySingleton<MinuteTicker>(() => PeriodicMinuteTicker(sl()))
    ..registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(
        sharedPreferences: sl(),
        gateway: sl(),
        clock: sl(),
      ),
    )
    ..registerLazySingleton<DeviceLocationGateway>(
      () => const GeolocatorLocationGateway(),
    );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final notifications = FlnNotificationGateway();
  await notifications.initialize();
  sl
    ..registerLazySingleton<NotificationGateway>(() => notifications)
    ..registerLazySingleton<NotificationPermission>(() => notifications)
    ..registerLazySingleton(() => NotificationReconciler(sl()))
    // Every feature that schedules notifications is a source of the one sync,
    // because the reconciler owns the whole OS pending set.
    ..registerLazySingleton(
      () => SyncNotifications(
        sources: [sl<FastingReminderSource>(), sl<QadaReminderSource>()],
        reconciler: sl(),
        clock: sl(),
      ),
    );

  // Requires Firebase.initializeApp to have run (see main.dart).
  final push = FcmPushMessaging(presenter: notifications);
  await push.initialize();
  sl
    ..registerLazySingleton<PushMessaging>(() => push)
    ..registerLazySingleton(() => SyncAnnouncementTopic(sl()));
}
