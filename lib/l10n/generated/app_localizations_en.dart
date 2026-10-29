// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Fasomo';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get reminders => 'Reminders';

  @override
  String get about => 'About';

  @override
  String get currentHijriDate => 'Current Hijri Date';

  @override
  String get upcomingFastingDays => 'Upcoming Fasting Days';

  @override
  String get activateReminder => 'Activate Reminder';

  @override
  String get deactivateReminder => 'Deactivate Reminder';

  @override
  String get whiteDays => 'White Days';

  @override
  String get mondayThursday => 'Monday & Thursday';

  @override
  String get dayOfArafah => 'Day of Arafah';

  @override
  String get dayOfAshura => 'Day of Ashura';

  @override
  String get dayOfTasua => 'Day of Tasua';

  @override
  String get ramadan => 'Ramadan';

  @override
  String get shawwalSixDays => 'Six Days of Shawwal';

  @override
  String get whiteDaysDesc =>
      'The 13th, 14th, and 15th of every Hijri month. Fasting these days is highly recommended.';

  @override
  String get mondayThursdayDesc =>
      'The Prophet (PBUH) used to fast on Mondays and Thursdays.';

  @override
  String get arafahDesc =>
      'The 9th of Dhul Hijjah. Fasting this day expiates sins of two years.';

  @override
  String get ashuraDesc =>
      'The 10th of Muharram. Fasting this day expiates sins of one year.';

  @override
  String get tasuaDesc =>
      'The 9th of Muharram. It is recommended to fast along with Ashura.';

  @override
  String get ramadanDesc => 'The month of Ramadan - obligatory fasting.';

  @override
  String get shawwalDesc =>
      'Six days of fasting in Shawwal after Eid al-Fitr equals fasting the whole year.';

  @override
  String get reminderSettings => 'Reminder Settings';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get dayBefore => 'Day Before';

  @override
  String get morningOfDay => 'Morning of the Day';

  @override
  String get customTime => 'Custom Time';

  @override
  String get sameDay => 'Same day';

  @override
  String atTime(String time) {
    return 'at $time';
  }

  @override
  String get notificationMessage => 'Notification Message';

  @override
  String get customMessageHint => 'Enter a custom notification message';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get manageReminders => 'Manage your fasting day reminders';

  @override
  String get activeReminders => 'Fasting reminders';

  @override
  String get notificationsDenied =>
      'Notifications are turned off for Fasomo. Enable them in system settings to get reminders.';

  @override
  String get reminderSyncFailed => 'Could not update scheduled reminders';

  @override
  String get reminderSaveFailed => 'Could not save the reminder';

  @override
  String reminderTitle(int daysBefore, String type) {
    String _temp0 = intl.Intl.pluralLogic(
      daysBefore,
      locale: localeName,
      other: 'In $daysBefore days: $type',
      one: 'Tomorrow: $type',
      zero: 'Today: $type',
    );
    return '$_temp0';
  }

  @override
  String daysUntil(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'Tomorrow',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get fastingDay => 'Fasting Day';

  @override
  String get noUpcomingFasting => 'No upcoming fasting days';

  @override
  String get noSpecificFastingDay => 'No specific fasting day';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get monthUnavailable =>
      'This month is outside the supported calendar range';

  @override
  String get specialDays => 'Special Days';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String hijriYear(String year) {
    return '$year AH';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get hijriMonth1 => 'Muharram';

  @override
  String get hijriMonth2 => 'Safar';

  @override
  String get hijriMonth3 => 'Rabi\' al-Awwal';

  @override
  String get hijriMonth4 => 'Rabi\' al-Thani';

  @override
  String get hijriMonth5 => 'Jumada al-Ula';

  @override
  String get hijriMonth6 => 'Jumada al-Akhirah';

  @override
  String get hijriMonth7 => 'Rajab';

  @override
  String get hijriMonth8 => 'Sha\'ban';

  @override
  String get hijriMonth9 => 'Ramadan';

  @override
  String get hijriMonth10 => 'Shawwal';

  @override
  String get hijriMonth11 => 'Dhul Qa\'dah';

  @override
  String get hijriMonth12 => 'Dhul Hijjah';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get aboutApp => 'About Fasomo';

  @override
  String get aboutDesc =>
      'Fasomo is an Islamic fasting tracker app that helps Muslims keep track of recommended fasting days according to the Sunnah of Prophet Muhammad (PBUH).';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get islamicReferences => 'Islamic References';

  @override
  String get hadithWhiteDays =>
      '\"Whoever fasts three days of each month, it is like fasting the entire year.\" (Bukhari & Muslim)';

  @override
  String get hadithMondayThursday =>
      '\"The Prophet used to fast on Mondays and Thursdays.\" (Tirmidhi)';

  @override
  String get hadithArafah =>
      '\"Fasting the day of Arafah expiates the sins of the past year and the coming year.\" (Muslim)';

  @override
  String get hadithAshura =>
      '\"Fasting the day of Ashura expiates the sins of the previous year.\" (Muslim)';

  @override
  String get features => 'Features';

  @override
  String get featureCalendarTitle => 'Hijri Calendar';

  @override
  String get featureCalendarDesc =>
      'Full Hijri calendar with recommended fasting days marked';

  @override
  String get featureRemindersDesc =>
      'Smart notifications for upcoming fasting days';

  @override
  String get featureLanguagesTitle => 'Language Support';

  @override
  String get featureLanguagesDesc =>
      'Full support for Arabic and English languages';

  @override
  String get contactSupport => 'Contact & Support';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';

  @override
  String get sourceCode => 'Source code';

  @override
  String get credits => 'Credits';

  @override
  String get creditsText =>
      'This app was developed to help Muslims track recommended fasting days according to the Sunnah of Prophet Muhammad (PBUH).';

  @override
  String get copyright => '© Fasomo. All rights reserved.';

  @override
  String monthProgress(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get weekStripTitle => 'This week';

  @override
  String fastingDaysFrom(String date) {
    return 'Fasting days from $date';
  }

  @override
  String get yourFasting => 'Your fasting';

  @override
  String get fastingProgress => 'Fasting progress';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get longestStreak => 'Longest streak';

  @override
  String get markFastedToday => 'I fasted today';

  @override
  String get markAsFasted => 'Mark as fasted';

  @override
  String get fasted => 'Fasted';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String fastedOfDue(int fasted, int due) {
    return '$fasted of $due';
  }

  @override
  String monthFastedSummary(int fasted, int due) {
    return 'This month: $fasted of $due fasting days';
  }

  @override
  String get trackerEmpty => 'Mark the days you fast to start a streak.';

  @override
  String get noFastingDaysYet => 'No fasting days so far.';

  @override
  String get fastLogSaveFailed => 'Could not save your fasting log';

  @override
  String get fastLogLoadFailed => 'Could not load your fasting log';

  @override
  String get qadaTitle => 'Make-up fasts (Qada)';

  @override
  String get qadaDaysLeft => 'days left to make up';

  @override
  String qadaMadeUpOfOwed(int madeUp, int owed) {
    return '$madeUp of $owed made up';
  }

  @override
  String qadaHomeSummary(int count) {
    return 'Make-up days left: $count';
  }

  @override
  String ramadanOfYear(String year) {
    return 'Ramadan $year AH';
  }

  @override
  String daysUntilRamadan(int count) {
    return 'Days until Ramadan: $count';
  }

  @override
  String get qadaNoneOwed => 'No make-up fasts owed.';

  @override
  String get qadaAddOwed => 'Add days owed';

  @override
  String get qadaOwedDialogTitle => 'Days owed from a Ramadan';

  @override
  String get qadaOwedDialogHint =>
      'Days you missed that aren\'t marked in the calendar.';

  @override
  String get qadaOwedYear => 'Ramadan of';

  @override
  String get qadaOwedDays => 'Days owed';

  @override
  String get addOneDay => 'Add a day';

  @override
  String get removeOneDay => 'Remove a day';

  @override
  String get missed => 'Missed';

  @override
  String get madeUp => 'Made up';

  @override
  String get makeUpFast => 'Make-up fast';

  @override
  String get makeUpFastHint => 'Counts toward the days you owe';

  @override
  String get qadaExplanation =>
      'Mark the Ramadan days you missed in the calendar, or add days owed from earlier years. Each make-up fast pays off the oldest Ramadan first, and still counts toward your streak and totals.';

  @override
  String get qadaSaveFailed =>
      'Could not save. A make-up fast can\'t be in Ramadan, on an Eid or in the future.';

  @override
  String get logMakeUpFast => 'Log a make-up fast';

  @override
  String get pickMakeUpDay => 'Day of the make-up fast';

  @override
  String get recentMakeUps => 'Recent make-up fasts';

  @override
  String get removeMakeUp => 'Remove this make-up fast';

  @override
  String get noMakeUpDayAvailable =>
      'There\'s no day to log yet: make-up fasts can\'t be in Ramadan or on an Eid.';

  @override
  String qadaReminderTitle(int daysBefore) {
    String _temp0 = intl.Intl.pluralLogic(
      daysBefore,
      locale: localeName,
      other: 'In $daysBefore days: a day for a make-up fast',
      one: 'Tomorrow: a day for a make-up fast',
      zero: 'Today: a day for a make-up fast',
    );
    return '$_temp0';
  }

  @override
  String qadaReminderBody(int remaining) {
    return 'Make-up days left: $remaining';
  }

  @override
  String mergedReminderTitle(int daysBefore, String type) {
    String _temp0 = intl.Intl.pluralLogic(
      daysBefore,
      locale: localeName,
      other: 'In $daysBefore days: $type + make-up',
      one: 'Tomorrow: $type + make-up',
      zero: 'Today: $type + make-up',
    );
    return '$_temp0';
  }

  @override
  String mergedReminderBody(String type, int remaining) {
    return 'Fast it as a make-up and it counts for $type too. Make-up days left: $remaining';
  }

  @override
  String ramadanCountdownTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ramadan in $count days',
      one: 'Ramadan is tomorrow',
    );
    return '$_temp0';
  }

  @override
  String ramadanCountdownBody(int remaining) {
    return 'Make-up days still owed before Ramadan: $remaining';
  }

  @override
  String get qadaReminders => 'Make-up reminders';

  @override
  String get qadaRemindersOff => 'Off';

  @override
  String get qadaRemindersIdle => 'On. They start when you owe make-up days.';

  @override
  String get weeklyReminder => 'Weekly';

  @override
  String get monthlyReminder => 'Monthly';

  @override
  String get beforeRamadanReminder => 'Before Ramadan';

  @override
  String hijriDayOption(String day) {
    return 'Day $day of the Hijri month';
  }

  @override
  String get whiteDaysOption => 'White Days (13th)';

  @override
  String daysBeforeOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get addDaysBefore => 'Add';

  @override
  String get daysBeforeDialogTitle => 'Days before Ramadan';

  @override
  String daysBeforeInvalid(int max) {
    return 'Enter a number from 1 to $max';
  }

  @override
  String get reminderTimeLabel => 'Time';

  @override
  String weeklySummary(String days) {
    return 'Weekly: $days';
  }

  @override
  String monthlySummary(String day) {
    return 'Monthly: day $day';
  }

  @override
  String beforeRamadanSummary(String days) {
    return 'Before Ramadan: $days';
  }

  @override
  String get qadaRemindersFootnote =>
      'Make-up reminders skip Ramadan, the Eids and days you\'ve already fasted, and stop once nothing is owed. On a Sunnah fasting day they\'re merged into that day\'s reminder.';
}
