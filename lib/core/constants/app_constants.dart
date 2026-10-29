class AppConstants {
  // App Info
  static const String appName = 'Fasomo';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String languageKey = 'language';
  static const String remindersKey = 'reminders';
  static const String permissionAskedKey = 'notification_permission_asked';
  static const String fastLogKey = 'fast_log';
  static const String makeUpDaysKey = 'qada_made_up';
  static const String missedRamadanKey = 'qada_missed';
  static const String extraOwedKey = 'qada_extra_owed';
  static const String qadaRemindersKey = 'qada_reminders';

  // Notification
  static const String notificationChannelId = 'fasomo_fasting_reminders';
  static const String notificationChannelName = 'Fasting Reminders';
  static const String notificationChannelDescription =
      'Notifications for upcoming fasting days';

  // Must match default_notification_channel_id in AndroidManifest.xml, so
  // background push messages land on the same channel.
  static const String announcementChannelId = 'fasomo_announcements';
  static const String announcementChannelName = 'Announcements';
  static const String announcementChannelDescription =
      'News such as the confirmed start of Ramadan or Eid';

  // Contact
  static const String supportEmail = 'support@fasomo.app';
  static const String website = 'www.fasomo.app';
  static const String sourceCode = 'github.com/msalah104/Fasomo';
}
