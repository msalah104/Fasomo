class AppConstants {
  // App Info
  static const String appName = 'Fasomo';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String languageKey = 'language';
  static const String remindersKey = 'reminders';
  static const String notificationEnabledKey = 'notification_enabled';

  // Notification
  static const String notificationChannelId = 'fasomo_fasting_reminders';
  static const String notificationChannelName = 'Fasting Reminders';
  static const String notificationChannelDescription =
      'Notifications for upcoming fasting days';

  // Islamic Calendar
  static const List<String> arabicMonthNames = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static const List<String> englishMonthNames = [
    'Muharram',
    'Safar',
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhul Qa'dah",
    'Dhul Hijjah',
  ];
}
