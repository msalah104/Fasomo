import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';

class NotificationHelper {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInitialize = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request permissions for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleNotification({
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iOSDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    int id,
  ) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> showInstantNotification({
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iOSDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
