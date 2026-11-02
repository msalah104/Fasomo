import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';

/// How a [NotificationTone] is delivered on each platform. Pure data, so the
/// mapping is testable without the notification plugin.
///
/// On Android the sound belongs to the notification channel and can't be
/// changed once the channel exists, so every tone has its own channel. The
/// ids carry a version: if a bundled sound ever changes, bump it, or phones
/// that already created the channel keep playing the old sound.
final class NotificationToneChannel {
  const new({
    required this.androidChannelId,
    required this.androidChannelName,
    required this.playsSound,
    this.androidSound,
    this.iosSound,
  });

  /// The mapping for [tone].
  factory of(NotificationTone tone) => switch (tone) {
    // The original channel, so existing installs keep their settings.
    NotificationTone.systemDefault => const NotificationToneChannel(
      androidChannelId: AppConstants.notificationChannelId,
      androidChannelName: AppConstants.notificationChannelName,
      playsSound: true,
    ),
    NotificationTone.softChime => const NotificationToneChannel(
      androidChannelId: '${AppConstants.notificationChannelId}_chime_v1',
      androidChannelName: '${AppConstants.notificationChannelName} (chime)',
      playsSound: true,
      androidSound: 'tone_chime',
      iosSound: 'tone_chime.wav',
    ),
    NotificationTone.bell => const NotificationToneChannel(
      androidChannelId: '${AppConstants.notificationChannelId}_bell_v1',
      androidChannelName: '${AppConstants.notificationChannelName} (bell)',
      playsSound: true,
      androidSound: 'tone_bell',
      iosSound: 'tone_bell.wav',
    ),
    NotificationTone.gentle => const NotificationToneChannel(
      androidChannelId: '${AppConstants.notificationChannelId}_gentle_v1',
      androidChannelName: '${AppConstants.notificationChannelName} (gentle)',
      playsSound: true,
      androidSound: 'tone_gentle',
      iosSound: 'tone_gentle.wav',
    ),
    NotificationTone.vibrateOnly => const NotificationToneChannel(
      androidChannelId: '${AppConstants.notificationChannelId}_vibrate_v1',
      androidChannelName:
          '${AppConstants.notificationChannelName} (vibrate only)',
      playsSound: false,
    ),
  };

  final String androidChannelId;

  /// Shown in the system's notification settings for the app.
  final String androidChannelName;

  /// Whether the notification makes any sound. When `false`, Android only
  /// vibrates and iOS shows a silent banner (iOS has no vibrate-only option
  /// for app notifications).
  final bool playsSound;

  /// The `res/raw` resource name, without extension; `null` for the
  /// system's default sound.
  final String? androidSound;

  /// The sound file in the iOS app bundle; `null` for the default sound.
  final String? iosSound;
}
