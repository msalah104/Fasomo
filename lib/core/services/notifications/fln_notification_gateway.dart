import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/scheduled_notification.dart';
import 'package:fasomo/core/push/push_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// The only file that imports `flutter_local_notifications`.
class FlnNotificationGateway
    implements
        NotificationGateway,
        NotificationPermission,
        AnnouncementPresenter {
  /// [plugin] is injectable for tests; production uses the default.
  new([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const AndroidNotificationChannel _announcementChannel =
      AndroidNotificationChannel(
        AppConstants.announcementChannelId,
        AppConstants.announcementChannelName,
        description: AppConstants.announcementChannelDescription,
        importance: Importance.high,
      );

  static const NotificationDetails _announcementDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      AppConstants.announcementChannelId,
      AppConstants.announcementChannelName,
      channelDescription: AppConstants.announcementChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(),
  );

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Initializes the plugin without prompting; permission is requested when
  /// the user first enables a reminder.
  Future<void> initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    // Created up front: push messages that arrive in the background are
    // posted by the OS to this channel before any Dart code runs.
    await _android?.createNotificationChannel(_announcementChannel);
  }

  @override
  Future<void> showAnnouncement({
    required int id,
    required String title,
    required String body,
  }) => _plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: _announcementDetails,
  );

  @override
  Future<bool> request() async {
    try {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted =
          await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          await _android?.requestNotificationsPermission();
      return granted ?? true;
    } on PlatformException catch (e, st) {
      AppLog.error('notifications.permission', e, st);
      return false;
    }
  }

  @override
  Future<Result<void, NotificationFailure>> schedule(
    ScheduledNotification notification,
  ) => _guard('schedule', () async {
    final fireAt = notification.fireAt;
    await _plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      payload: notification.payload,
      // Resolve the wall-clock time in the device zone at schedule time.
      scheduledDate: tz.TZDateTime(
        tz.local,
        fireAt.year,
        fireAt.month,
        fireAt.day,
        fireAt.hour,
        fireAt.minute,
      ),
      notificationDetails: _details,
      androidScheduleMode: await _scheduleMode(),
    );
  });

  @override
  Future<Result<void, NotificationFailure>> cancel(int id) =>
      _guard('cancel', () => _plugin.cancel(id: id));

  @override
  Future<Result<void, NotificationFailure>> cancelAll() =>
      _guard('cancelAll', _plugin.cancelAll);

  @override
  Future<Result<Set<int>, NotificationFailure>> getPending() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return Ok({for (final request in pending) request.id});
    } on PlatformException catch (e, st) {
      AppLog.error('notifications.getPending', e, st);
      return const Err(NotificationPlatformFailed('getPending'));
    }
  }

  /// Exact alarms only when the user has granted SCHEDULE_EXACT_ALARM;
  /// otherwise the permission-free inexact mode, which still pierces Doze.
  Future<AndroidScheduleMode> _scheduleMode() async {
    final canExact = await _android?.canScheduleExactNotifications() ?? false;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<Result<void, NotificationFailure>> _guard(
    String operation,
    Future<void> Function() call,
  ) async {
    try {
      await call();
      return const Ok(null);
    } on PlatformException catch (e, st) {
      AppLog.error('notifications.$operation', e, st);
      return Err(NotificationPlatformFailed(operation));
    }
  }
}
