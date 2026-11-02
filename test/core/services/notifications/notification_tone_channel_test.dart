import 'dart:io';

import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/services/notifications/notification_tone_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final channels = {
    for (final tone in NotificationTone.values)
      tone: NotificationToneChannel.of(tone),
  };

  test('the system default keeps the original channel and sound', () {
    final channel = channels[NotificationTone.systemDefault]!;
    expect(channel.androidChannelId, AppConstants.notificationChannelId);
    expect(channel.playsSound, isTrue);
    expect(channel.androidSound, isNull);
    expect(channel.iosSound, isNull);
  });

  test('every tone has its own Android channel', () {
    final ids = {for (final c in channels.values) c.androidChannelId};
    expect(ids, hasLength(NotificationTone.values.length));
    final names = {for (final c in channels.values) c.androidChannelName};
    expect(names, hasLength(NotificationTone.values.length));
  });

  test('each bundled tone names its sound on both platforms', () {
    for (final (tone, file) in [
      (NotificationTone.softChime, 'tone_chime'),
      (NotificationTone.bell, 'tone_bell'),
      (NotificationTone.gentle, 'tone_gentle'),
    ]) {
      final channel = channels[tone]!;
      expect(channel.playsSound, isTrue, reason: tone.name);
      expect(channel.androidSound, file, reason: tone.name);
      expect(channel.iosSound, '$file.wav', reason: tone.name);
    }
  });

  test('vibrate only plays no sound on either platform', () {
    final channel = channels[NotificationTone.vibrateOnly]!;
    expect(channel.playsSound, isFalse);
    expect(channel.androidSound, isNull);
    expect(channel.iosSound, isNull);
  });

  group('bundled sound files', () {
    final soundChannels = channels.values.where((c) => c.iosSound != null);

    test('are in Android res/raw, with names Android accepts', () {
      const raw = 'android/app/src/main/res/raw';
      for (final channel in soundChannels) {
        final name = channel.androidSound!;
        expect(name, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
        expect(
          File('$raw/$name.ogg').existsSync() ||
              File('$raw/$name.wav').existsSync(),
          isTrue,
          reason: name,
        );
      }
      // Without it, resource shrinking strips sounds only Dart refers to.
      expect(File('$raw/keep.xml').readAsStringSync(), contains('@raw/*'));
    });

    test('are in the iOS Runner bundle', () {
      final project = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();
      for (final channel in soundChannels) {
        final file = channel.iosSound!;
        expect(File('ios/Runner/$file').existsSync(), isTrue, reason: file);
        // Referenced by the project and copied by the Resources phase.
        expect(project, contains('/* $file */ = {isa = PBXFileReference'));
        expect(project, contains('/* $file in Resources */,'));
      }
    });

    test('are short enough for iOS (under 30 seconds)', () {
      for (final channel in soundChannels) {
        final bytes = File('ios/Runner/${channel.iosSound}').readAsBytesSync();
        // 44-byte WAV header; 16-bit mono at 44.1 kHz.
        final seconds = (bytes.length - 44) / (44100 * 2);
        expect(seconds, lessThanOrEqualTo(2.5), reason: channel.iosSound);
      }
    });
  });
}
