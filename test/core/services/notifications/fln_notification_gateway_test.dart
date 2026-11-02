// Tests the adapter itself, so this is the one test that sees the plugin.
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/services/notifications/fln_notification_gateway.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPlugin extends Mock implements FlutterLocalNotificationsPlugin;

void main() {
  late MockPlugin plugin;
  late FlnNotificationGateway gateway;

  setUp(() {
    plugin = MockPlugin();
    gateway = FlnNotificationGateway(plugin);
    when(
      () => plugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
      ),
    ).thenAnswer((_) async {});
  });

  /// Previews [tone] and returns the details the plugin was given.
  Future<NotificationDetails> detailsFor(NotificationTone tone) async {
    await gateway.preview(tone, title: 'title', body: 'body');
    return verify(
          () => plugin.show(
            id: AppConstants.tonePreviewNotificationId,
            title: 'title',
            body: 'body',
            notificationDetails: captureAny(named: 'notificationDetails'),
          ),
        ).captured.single
        as NotificationDetails;
  }

  test('the system default plays the default sound on the original '
      'channel', () async {
    final details = await detailsFor(NotificationTone.systemDefault);
    expect(details.android!.channelId, AppConstants.notificationChannelId);
    expect(details.android!.playSound, isTrue);
    expect(details.android!.sound, isNull);
    expect(details.iOS!.presentSound, isTrue);
    expect(details.iOS!.sound, isNull);
  });

  test('a bundled tone plays its raw resource on its own channel', () async {
    final details = await detailsFor(NotificationTone.softChime);
    expect(
      details.android!.channelId,
      isNot(AppConstants.notificationChannelId),
    );
    expect(details.android!.playSound, isTrue);
    expect(
      details.android!.sound,
      isA<RawResourceAndroidNotificationSound>().having(
        (s) => s.sound,
        'sound',
        'tone_chime',
      ),
    );
    expect(details.iOS!.presentSound, isTrue);
    expect(details.iOS!.sound, 'tone_chime.wav');
  });

  test('vibrate only is silent, and vibrates on Android', () async {
    final details = await detailsFor(NotificationTone.vibrateOnly);
    expect(details.android!.playSound, isFalse);
    expect(details.android!.sound, isNull);
    expect(details.android!.enableVibration, isTrue);
    expect(details.iOS!.presentSound, isFalse);
    expect(details.iOS!.sound, isNull);
  });

  test('every tone goes to a different Android channel', () async {
    final ids = <String>{};
    for (final tone in NotificationTone.values) {
      ids.add((await detailsFor(tone)).android!.channelId);
    }
    expect(ids, hasLength(NotificationTone.values.length));
  });

  test('a platform error is a typed failure', () async {
    when(
      () => plugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
      ),
    ).thenThrow(PlatformException(code: 'invalid_sound'));

    final result = await gateway.preview(
      NotificationTone.bell,
      title: 'title',
      body: 'body',
    );

    expect(
      result,
      isA<Err<void, NotificationFailure>>().having(
        (e) => e.failure,
        'failure',
        isA<NotificationPlatformFailed>().having(
          (f) => f.operation,
          'operation',
          'preview',
        ),
      ),
    );
  });
}
