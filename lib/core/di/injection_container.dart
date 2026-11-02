import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/adjusted_hijri_converter.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/notification_reconciler.dart';
import 'package:fasomo/core/notifications/sync_notifications.dart';
import 'package:fasomo/core/push/push_messaging.dart';
import 'package:fasomo/core/push/sync_announcement_topic.dart';
import 'package:fasomo/core/services/notifications/fln_notification_gateway.dart';
import 'package:fasomo/core/services/push/fcm_push_messaging.dart';
import 'package:fasomo/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:fasomo/features/calendar/data/repositories/calendar_preferences_repository_impl.dart';
import 'package:fasomo/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_preferences_repository.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_current_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_year.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_show_gregorian_days.dart';
import 'package:fasomo/features/calendar/domain/usecases/save_show_gregorian_days.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/home/data/repositories/fasting_repository_impl.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';
import 'package:fasomo/features/home/domain/usecases/get_current_hijri_date.dart';
import 'package:fasomo/features/home/domain/usecases/get_upcoming_fasting_days.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
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
import 'package:fasomo/features/settings/domain/usecases/get_hijri_offset.dart';
import 'package:fasomo/features/settings/domain/usecases/get_language.dart';
import 'package:fasomo/features/settings/domain/usecases/get_theme_mode.dart';
import 'package:fasomo/features/settings/domain/usecases/get_today_hijri_date.dart';
import 'package:fasomo/features/settings/domain/usecases/save_hijri_offset.dart';
import 'package:fasomo/features/settings/domain/usecases/save_language.dart';
import 'package:fasomo/features/settings/domain/usecases/save_theme_mode.dart';
import 'package:fasomo/features/settings/presentation/bloc/hijri_adjustment_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/theme_bloc.dart';
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

/// The services that need a real device: OS notifications and push.
///
/// [init] builds the real ones by default; a harness that runs the app
/// without a device (e.g. the screenshot tool) passes fakes instead.
final class PlatformServices {
  const new({
    required this.notifications,
    required this.notificationPermission,
    required this.push,
  });

  final NotificationGateway notifications;
  final NotificationPermission notificationPermission;
  final PushMessaging push;
}

/// The composition root: the only place concrete implementations are chosen.
Future<void> init({PlatformServices? platform}) async {
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
      () => CalendarBloc(
        getCurrentHijriMonth: sl(),
        getHijriMonth: sl(),
        getHijriYear: sl(),
        getShowGregorianDays: sl(),
        saveShowGregorianDays: sl(),
      ),
    )
    ..registerLazySingleton(() => GetCurrentHijriMonth(sl()))
    ..registerLazySingleton(() => GetHijriMonth(sl()))
    ..registerLazySingleton(() => GetHijriYear(sl()))
    ..registerLazySingleton(() => GetShowGregorianDays(sl()))
    ..registerLazySingleton(() => SaveShowGregorianDays(sl()))
    ..registerLazySingleton<CalendarRepository>(
      () => CalendarRepositoryImpl(calendar: sl(), clock: sl()),
    )
    ..registerLazySingleton<CalendarPreferencesRepository>(
      () => CalendarPreferencesRepositoryImpl(localDataSource: sl()),
    )
    ..registerLazySingleton<CalendarLocalDataSource>(
      () => CalendarLocalDataSourceImpl(sharedPreferences: sl()),
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
    ..registerFactory(
      () => ThemeBloc(getThemeMode: sl(), saveThemeMode: sl()),
    )
    ..registerLazySingleton(() => GetThemeMode(sl()))
    ..registerLazySingleton(() => SaveThemeMode(sl()))
    ..registerFactory(
      () => HijriAdjustmentBloc(
        getHijriOffset: sl(),
        saveHijriOffset: sl(),
        getTodayHijriDate: sl(),
      ),
    )
    ..registerLazySingleton(() => GetHijriOffset(sl()))
    ..registerLazySingleton(() => SaveHijriOffset(sl()))
    ..registerLazySingleton(
      () => GetTodayHijriDate(converter: sl(), clock: sl()),
    )
    // One instance is both the settings store and the offset the Hijri
    // converter reads, so a saved adjustment applies straight away.
    ..registerLazySingleton(
      () => SettingsRepositoryImpl(sharedPreferences: sl()),
    )
    ..registerLazySingleton<SettingsRepository>(sl.get<SettingsRepositoryImpl>)
    ..registerLazySingleton<HijriOffsetSource>(sl.get<SettingsRepositoryImpl>)
    // ============ Core ============
    ..registerLazySingleton<Clock>(() => const Clock())
    // Every Hijri date in the app goes through the user's adjustment.
    ..registerLazySingleton<HijriConverter>(
      () => AdjustedHijriConverter(const UmmAlQuraHijriConverter(), sl()),
    )
    ..registerLazySingleton(() => FastingCalendar(sl()));

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final services = platform ?? await _devicePlatformServices();
  sl
    ..registerLazySingleton<NotificationGateway>(() => services.notifications)
    ..registerLazySingleton<NotificationPermission>(
      () => services.notificationPermission,
    )
    ..registerLazySingleton(() => NotificationReconciler(sl()))
    // Every feature that schedules notifications is a source of the one sync,
    // because the reconciler owns the whole OS pending set.
    ..registerLazySingleton(
      () => SyncNotifications(
        sources: [sl<FastingReminderSource>(), sl<QadaReminderSource>()],
        reconciler: sl(),
        clock: sl(),
      ),
    )
    ..registerLazySingleton<PushMessaging>(() => services.push)
    ..registerLazySingleton(() => SyncAnnouncementTopic(sl()));
}

Future<PlatformServices> _devicePlatformServices() async {
  final notifications = FlnNotificationGateway();
  await notifications.initialize();
  // Requires Firebase.initializeApp to have run (see main.dart).
  final push = FcmPushMessaging(presenter: notifications);
  await push.initialize();
  return PlatformServices(
    notifications: notifications,
    notificationPermission: notifications,
    push: push,
  );
}
