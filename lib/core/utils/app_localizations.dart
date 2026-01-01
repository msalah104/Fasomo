import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Fasomo',
      'home': 'Home',
      'calendar': 'Calendar',
      'reminders': 'Reminders',
      'about': 'About',
      'current_hijri_date': 'Current Hijri Date',
      'upcoming_fasting_days': 'Upcoming Fasting Days',
      'activate_reminder': 'Activate Reminder',
      'deactivate_reminder': 'Deactivate Reminder',
      'white_days': 'White Days',
      'monday_thursday': 'Monday & Thursday',
      'day_of_arafah': 'Day of Arafah',
      'day_of_ashura': 'Day of Ashura',
      'day_of_tasua': 'Day of Tasua',
      'ramadan': 'Ramadan',
      'shawwal_six_days': 'Six Days of Shawwal',
      'white_days_desc':
          'The 13th, 14th, and 15th of every Hijri month. Fasting these days is highly recommended.',
      'monday_thursday_desc':
          'The Prophet (PBUH) used to fast on Mondays and Thursdays.',
      'arafah_desc':
          'The 9th of Dhul Hijjah. Fasting this day expiates sins of two years.',
      'ashura_desc':
          'The 10th of Muharram. Fasting this day expiates sins of one year.',
      'tasua_desc':
          'The 9th of Muharram. It is recommended to fast along with Ashura.',
      'ramadan_desc': 'The month of Ramadan - obligatory fasting.',
      'shawwal_desc':
          'Six days of fasting in Shawwal after Eid al-Fitr equals fasting the whole year.',
      'reminder_settings': 'Reminder Settings',
      'enable_reminders': 'Enable Reminders',
      'reminder_time': 'Reminder Time',
      'day_before': 'Day Before',
      'morning_of_day': 'Morning of the Day',
      'custom_time': 'Custom Time',
      'notification_message': 'Notification Message',
      'save': 'Save',
      'cancel': 'Cancel',
      'about_app': 'About Fasomo',
      'about_desc':
          'Fasomo is an Islamic fasting tracker app that helps Muslims keep track of recommended fasting days according to the Sunnah of Prophet Muhammad (PBUH).',
      'islamic_references': 'Islamic References',
      'hadith_white_days':
          '"Whoever fasts three days of each month, it is like fasting the entire year." (Bukhari & Muslim)',
      'hadith_monday_thursday':
          '"The Prophet used to fast on Mondays and Thursdays." (Tirmidhi)',
      'hadith_arafah':
          '"Fasting the day of Arafah expiates the sins of the past year and the coming year." (Muslim)',
      'hadith_ashura':
          '"Fasting the day of Ashura expiates the sins of the previous year." (Muslim)',
      'contact_support': 'Contact & Support',
      'version': 'Version',
      'no_upcoming_fasting': 'No upcoming fasting days this month',
      'loading': 'Loading...',
      'error_occurred': 'An error occurred',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'days_left': 'days left',
      'fasting_day': 'Fasting Day',
      'optional_fasting': 'Optional Fasting',
      'mandatory_fasting': 'Mandatory Fasting',
    },
    'ar': {
      'app_name': 'فاصومو',
      'home': 'الرئيسية',
      'calendar': 'التقويم',
      'reminders': 'التذكيرات',
      'about': 'حول',
      'current_hijri_date': 'التاريخ الهجري الحالي',
      'upcoming_fasting_days': 'أيام الصيام القادمة',
      'activate_reminder': 'تفعيل التذكير',
      'deactivate_reminder': 'إلغاء التذكير',
      'white_days': 'الأيام البيض',
      'monday_thursday': 'الاثنين والخميس',
      'day_of_arafah': 'يوم عرفة',
      'day_of_ashura': 'يوم عاشوراء',
      'day_of_tasua': 'يوم تاسوعاء',
      'ramadan': 'رمضان',
      'shawwal_six_days': 'الست من شوال',
      'white_days_desc':
          'الأيام 13 و14 و15 من كل شهر هجري. صيام هذه الأيام مستحب بشدة.',
      'monday_thursday_desc': 'كان النبي صلى الله عليه وسلم يصوم الاثنين والخميس.',
      'arafah_desc':
          'التاسع من ذي الحجة. صيام هذا اليوم يكفر ذنوب سنتين.',
      'ashura_desc': 'العاشر من محرم. صيام هذا اليوم يكفر ذنوب سنة.',
      'tasua_desc': 'التاسع من محرم. يستحب صيامه مع عاشوراء.',
      'ramadan_desc': 'شهر رمضان - الصيام واجب.',
      'shawwal_desc':
          'ستة أيام من شوال بعد عيد الفطر تعدل صيام الدهر.',
      'reminder_settings': 'إعدادات التذكير',
      'enable_reminders': 'تفعيل التذكيرات',
      'reminder_time': 'وقت التذكير',
      'day_before': 'قبل يوم',
      'morning_of_day': 'صباح اليوم',
      'custom_time': 'وقت مخصص',
      'notification_message': 'رسالة الإشعار',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'about_app': 'عن فاصومو',
      'about_desc':
          'فاصومو هو تطبيق لتتبع الصيام الإسلامي يساعد المسلمين على متابعة أيام الصيام المستحبة وفقاً لسنة النبي محمد صلى الله عليه وسلم.',
      'islamic_references': 'المراجع الإسلامية',
      'hadith_white_days':
          '"من صام ثلاثة أيام من كل شهر فكأنما صام الدهر كله" (البخاري ومسلم)',
      'hadith_monday_thursday':
          '"كان النبي يصوم الاثنين والخميس" (الترمذي)',
      'hadith_arafah':
          '"صيام يوم عرفة يكفر السنة الماضية والباقية" (مسلم)',
      'hadith_ashura':
          '"صيام يوم عاشوراء يكفر السنة الماضية" (مسلم)',
      'contact_support': 'التواصل والدعم',
      'version': 'الإصدار',
      'no_upcoming_fasting': 'لا توجد أيام صيام قادمة هذا الشهر',
      'loading': 'جاري التحميل...',
      'error_occurred': 'حدث خطأ',
      'today': 'اليوم',
      'tomorrow': 'غداً',
      'days_left': 'يوم متبقي',
      'fasting_day': 'يوم صيام',
      'optional_fasting': 'صيام مستحب',
      'mandatory_fasting': 'صيام واجب',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appName => translate('app_name');
  String get home => translate('home');
  String get calendar => translate('calendar');
  String get reminders => translate('reminders');
  String get about => translate('about');
  String get currentHijriDate => translate('current_hijri_date');
  String get upcomingFastingDays => translate('upcoming_fasting_days');
  String get activateReminder => translate('activate_reminder');
  String get deactivateReminder => translate('deactivate_reminder');
  String get whiteDays => translate('white_days');
  String get mondayThursday => translate('monday_thursday');
  String get dayOfArafah => translate('day_of_arafah');
  String get dayOfAshura => translate('day_of_ashura');
  String get dayOfTasua => translate('day_of_tasua');
  String get ramadan => translate('ramadan');
  String get shawwalSixDays => translate('shawwal_six_days');
  String get whiteDaysDesc => translate('white_days_desc');
  String get mondayThursdayDesc => translate('monday_thursday_desc');
  String get arafahDesc => translate('arafah_desc');
  String get ashuraDesc => translate('ashura_desc');
  String get tasuaDesc => translate('tasua_desc');
  String get ramadanDesc => translate('ramadan_desc');
  String get shawwalDesc => translate('shawwal_desc');
  String get reminderSettings => translate('reminder_settings');
  String get enableReminders => translate('enable_reminders');
  String get reminderTime => translate('reminder_time');
  String get dayBefore => translate('day_before');
  String get morningOfDay => translate('morning_of_day');
  String get customTime => translate('custom_time');
  String get notificationMessage => translate('notification_message');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get aboutApp => translate('about_app');
  String get aboutDesc => translate('about_desc');
  String get islamicReferences => translate('islamic_references');
  String get hadithWhiteDays => translate('hadith_white_days');
  String get hadithMondayThursday => translate('hadith_monday_thursday');
  String get hadithArafah => translate('hadith_arafah');
  String get hadithAshura => translate('hadith_ashura');
  String get contactSupport => translate('contact_support');
  String get version => translate('version');
  String get noUpcomingFasting => translate('no_upcoming_fasting');
  String get loading => translate('loading');
  String get errorOccurred => translate('error_occurred');
  String get today => translate('today');
  String get tomorrow => translate('tomorrow');
  String get daysLeft => translate('days_left');
  String get fastingDay => translate('fasting_day');
  String get optionalFasting => translate('optional_fasting');
  String get mandatoryFasting => translate('mandatory_fasting');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
