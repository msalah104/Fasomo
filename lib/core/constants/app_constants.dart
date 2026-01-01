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
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhul Qa\'dah',
    'Dhul Hijjah',
  ];

  // Fasting Days
  static const List<int> whiteDays = [13, 14, 15];
  static const List<int> mondayThursdayWeekdays = [1, 4]; // Monday and Thursday
  static const int dayOfArafah = 9; // 9th of Dhul Hijjah
  static const int dayOfAshura = 10; // 10th of Muharram
  static const int dayOfTasua = 9; // 9th of Muharram

  // Special Months
  static const int muharram = 1;
  static const int rajab = 7;
  static const int shaban = 8;
  static const int ramadan = 9;
  static const int shawwal = 10;
  static const int dhulHijjah = 12;
}
