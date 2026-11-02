/// The sound every reminder plays when it fires.
///
/// The bundled tones ship with the app (`res/raw` on Android, the Runner
/// bundle on iOS); see `tool/tones/generate_tones.py`.
enum NotificationTone {
  /// The device's own notification sound.
  systemDefault,

  /// Two soft notes, like a doorbell chime.
  softChime,

  /// A small struck bell.
  bell,

  /// A quiet rising arpeggio.
  gentle,

  /// No sound: vibration only on Android, a silent banner on iOS.
  vibrateOnly,
}

/// Where the notification sync reads the chosen [NotificationTone] from.
///
/// Read on every sync, so a saved change applies to the next one. An
/// unreadable value counts as [NotificationTone.systemDefault].
abstract interface class NotificationToneSource {
  NotificationTone get notificationTone;
}

/// A [NotificationToneSource] that never changes, for tests and previews.
final class FixedNotificationTone implements NotificationToneSource {
  const new(this.notificationTone);

  @override
  final NotificationTone notificationTone;
}
