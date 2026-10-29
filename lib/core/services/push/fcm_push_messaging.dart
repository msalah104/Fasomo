import 'dart:async';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/core/notifications/deterministic_id.dart';
import 'package:fasomo/core/push/push_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// The only file that imports `firebase_messaging`.
///
/// Only notification messages are sent (from the Firebase console, to an
/// announcements topic), so the OS displays them while the app is in the
/// background and no background Dart handler is needed.
class FcmPushMessaging implements PushMessaging {
  /// [messaging] is injectable for tests; production uses the default.
  new({required this.presenter, FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final AnnouncementPresenter presenter;
  final FirebaseMessaging _messaging;

  StreamSubscription<RemoteMessage>? _foreground;

  /// Starts showing announcements that arrive in the foreground: iOS shows
  /// them itself once asked to, Android needs a local notification.
  Future<void> initialize() async {
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } on FirebaseException catch (e, st) {
      AppLog.error('push.foregroundOptions', e, st);
    }
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _foreground?.cancel();
    _foreground = FirebaseMessaging.onMessage.listen(_showInForeground);
  }

  Future<void> dispose() async {
    await _foreground?.cancel();
    _foreground = null;
  }

  @override
  Future<Result<void, PushFailure>> subscribe(String topic) =>
      _guard(topic, 'subscribe', () => _messaging.subscribeToTopic(topic));

  @override
  Future<Result<void, PushFailure>> unsubscribe(String topic) => _guard(
    topic,
    'unsubscribe',
    () => _messaging.unsubscribeFromTopic(topic),
  );

  Future<void> _showInForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    try {
      await presenter.showAnnouncement(
        id: DeterministicId.of([
          'announcement',
          message.messageId ?? message.sentTime?.toIso8601String() ?? '',
        ]),
        title: notification.title ?? '',
        body: notification.body ?? '',
      );
    } on Exception catch (e, st) {
      AppLog.error('push.showForeground', e, st);
    }
  }

  Future<Result<void, PushFailure>> _guard(
    String topic,
    String operation,
    Future<void> Function() call,
  ) async {
    try {
      await call();
      return const Ok(null);
    } on FirebaseException catch (e, st) {
      AppLog.error('push.$operation', e, st);
      return Err(PushTopicFailed(topic));
    }
  }
}
