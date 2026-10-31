import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fasomo'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @currentHijriDate.
  ///
  /// In en, this message translates to:
  /// **'Current Hijri Date'**
  String get currentHijriDate;

  /// No description provided for @upcomingFastingDays.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Fasting Days'**
  String get upcomingFastingDays;

  /// No description provided for @activateReminder.
  ///
  /// In en, this message translates to:
  /// **'Activate Reminder'**
  String get activateReminder;

  /// No description provided for @deactivateReminder.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Reminder'**
  String get deactivateReminder;

  /// No description provided for @whiteDays.
  ///
  /// In en, this message translates to:
  /// **'White Days'**
  String get whiteDays;

  /// No description provided for @mondayThursday.
  ///
  /// In en, this message translates to:
  /// **'Monday & Thursday'**
  String get mondayThursday;

  /// No description provided for @dayOfArafah.
  ///
  /// In en, this message translates to:
  /// **'Day of Arafah'**
  String get dayOfArafah;

  /// No description provided for @dayOfAshura.
  ///
  /// In en, this message translates to:
  /// **'Day of Ashura'**
  String get dayOfAshura;

  /// No description provided for @dayOfTasua.
  ///
  /// In en, this message translates to:
  /// **'Day of Tasua'**
  String get dayOfTasua;

  /// No description provided for @ramadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get ramadan;

  /// No description provided for @shawwalSixDays.
  ///
  /// In en, this message translates to:
  /// **'Six Days of Shawwal'**
  String get shawwalSixDays;

  /// No description provided for @whiteDaysDesc.
  ///
  /// In en, this message translates to:
  /// **'The 13th, 14th, and 15th of every Hijri month. Fasting these days is highly recommended.'**
  String get whiteDaysDesc;

  /// No description provided for @mondayThursdayDesc.
  ///
  /// In en, this message translates to:
  /// **'The Prophet (PBUH) used to fast on Mondays and Thursdays.'**
  String get mondayThursdayDesc;

  /// No description provided for @arafahDesc.
  ///
  /// In en, this message translates to:
  /// **'The 9th of Dhul Hijjah. Fasting this day expiates sins of two years.'**
  String get arafahDesc;

  /// No description provided for @ashuraDesc.
  ///
  /// In en, this message translates to:
  /// **'The 10th of Muharram. Fasting this day expiates sins of one year.'**
  String get ashuraDesc;

  /// No description provided for @tasuaDesc.
  ///
  /// In en, this message translates to:
  /// **'The 9th of Muharram. It is recommended to fast along with Ashura.'**
  String get tasuaDesc;

  /// No description provided for @ramadanDesc.
  ///
  /// In en, this message translates to:
  /// **'The month of Ramadan - obligatory fasting.'**
  String get ramadanDesc;

  /// No description provided for @shawwalDesc.
  ///
  /// In en, this message translates to:
  /// **'Six days of fasting in Shawwal after Eid al-Fitr equals fasting the whole year.'**
  String get shawwalDesc;

  /// No description provided for @reminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderSettings;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @dayBefore.
  ///
  /// In en, this message translates to:
  /// **'Day Before'**
  String get dayBefore;

  /// No description provided for @morningOfDay.
  ///
  /// In en, this message translates to:
  /// **'Morning of the Day'**
  String get morningOfDay;

  /// No description provided for @customTime.
  ///
  /// In en, this message translates to:
  /// **'Custom Time'**
  String get customTime;

  /// No description provided for @sameDay.
  ///
  /// In en, this message translates to:
  /// **'Same day'**
  String get sameDay;

  /// Time-of-day suffix, e.g. "at 8:00 PM".
  ///
  /// In en, this message translates to:
  /// **'at {time}'**
  String atTime(String time);

  /// No description provided for @notificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification Message'**
  String get notificationMessage;

  /// No description provided for @customMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom notification message'**
  String get customMessageHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @manageReminders.
  ///
  /// In en, this message translates to:
  /// **'Manage your fasting day reminders'**
  String get manageReminders;

  /// No description provided for @activeReminders.
  ///
  /// In en, this message translates to:
  /// **'Fasting reminders'**
  String get activeReminders;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Fasomo. Enable them in system settings to get reminders.'**
  String get notificationsDenied;

  /// No description provided for @reminderSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update scheduled reminders'**
  String get reminderSyncFailed;

  /// No description provided for @reminderSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the reminder'**
  String get reminderSaveFailed;

  /// Notification title announcing a fasting day.
  ///
  /// In en, this message translates to:
  /// **'{daysBefore, plural, =0{Today: {type}} =1{Tomorrow: {type}} other{In {daysBefore} days: {type}}}'**
  String reminderTitle(int daysBefore, String type);

  /// How far away a fasting day is.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today} =1{Tomorrow} other{In {count} days}}'**
  String daysUntil(int count);

  /// No description provided for @fastingDay.
  ///
  /// In en, this message translates to:
  /// **'Fasting Day'**
  String get fastingDay;

  /// No description provided for @noUpcomingFasting.
  ///
  /// In en, this message translates to:
  /// **'No upcoming fasting days'**
  String get noUpcomingFasting;

  /// No description provided for @noSpecificFastingDay.
  ///
  /// In en, this message translates to:
  /// **'No specific fasting day'**
  String get noSpecificFastingDay;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @monthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This month is outside the supported calendar range'**
  String get monthUnavailable;

  /// No description provided for @specialDays.
  ///
  /// In en, this message translates to:
  /// **'Special Days'**
  String get specialDays;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// A Hijri year.
  ///
  /// In en, this message translates to:
  /// **'{year} AH'**
  String hijriYear(String year);

  /// A full Hijri date; numbers are pre-formatted for the locale.
  ///
  /// In en, this message translates to:
  /// **'{day} {month} {year}'**
  String hijriDate(String day, String month, String year);

  /// No description provided for @hijriMonth1.
  ///
  /// In en, this message translates to:
  /// **'Muharram'**
  String get hijriMonth1;

  /// No description provided for @hijriMonth2.
  ///
  /// In en, this message translates to:
  /// **'Safar'**
  String get hijriMonth2;

  /// No description provided for @hijriMonth3.
  ///
  /// In en, this message translates to:
  /// **'Rabi\' al-Awwal'**
  String get hijriMonth3;

  /// No description provided for @hijriMonth4.
  ///
  /// In en, this message translates to:
  /// **'Rabi\' al-Thani'**
  String get hijriMonth4;

  /// No description provided for @hijriMonth5.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Ula'**
  String get hijriMonth5;

  /// No description provided for @hijriMonth6.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Akhirah'**
  String get hijriMonth6;

  /// No description provided for @hijriMonth7.
  ///
  /// In en, this message translates to:
  /// **'Rajab'**
  String get hijriMonth7;

  /// No description provided for @hijriMonth8.
  ///
  /// In en, this message translates to:
  /// **'Sha\'ban'**
  String get hijriMonth8;

  /// No description provided for @hijriMonth9.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get hijriMonth9;

  /// No description provided for @hijriMonth10.
  ///
  /// In en, this message translates to:
  /// **'Shawwal'**
  String get hijriMonth10;

  /// No description provided for @hijriMonth11.
  ///
  /// In en, this message translates to:
  /// **'Dhul Qa\'dah'**
  String get hijriMonth11;

  /// No description provided for @hijriMonth12.
  ///
  /// In en, this message translates to:
  /// **'Dhul Hijjah'**
  String get hijriMonth12;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// Always shown in English.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Always shown in Arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Fasomo'**
  String get aboutApp;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Fasomo is an Islamic fasting tracker app that helps Muslims keep track of recommended fasting days according to the Sunnah of Prophet Muhammad (PBUH).'**
  String get aboutDesc;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @islamicReferences.
  ///
  /// In en, this message translates to:
  /// **'Islamic References'**
  String get islamicReferences;

  /// No description provided for @hadithWhiteDays.
  ///
  /// In en, this message translates to:
  /// **'\"Whoever fasts three days of each month, it is like fasting the entire year.\" (Bukhari & Muslim)'**
  String get hadithWhiteDays;

  /// No description provided for @hadithMondayThursday.
  ///
  /// In en, this message translates to:
  /// **'\"The Prophet used to fast on Mondays and Thursdays.\" (Tirmidhi)'**
  String get hadithMondayThursday;

  /// No description provided for @hadithArafah.
  ///
  /// In en, this message translates to:
  /// **'\"Fasting the day of Arafah expiates the sins of the past year and the coming year.\" (Muslim)'**
  String get hadithArafah;

  /// No description provided for @hadithAshura.
  ///
  /// In en, this message translates to:
  /// **'\"Fasting the day of Ashura expiates the sins of the previous year.\" (Muslim)'**
  String get hadithAshura;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @featureCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri Calendar'**
  String get featureCalendarTitle;

  /// No description provided for @featureCalendarDesc.
  ///
  /// In en, this message translates to:
  /// **'Full Hijri calendar with recommended fasting days marked'**
  String get featureCalendarDesc;

  /// No description provided for @featureRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Smart notifications for upcoming fasting days'**
  String get featureRemindersDesc;

  /// No description provided for @featureLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Support'**
  String get featureLanguagesTitle;

  /// No description provided for @featureLanguagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Full support for Arabic and English languages'**
  String get featureLanguagesDesc;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact & Support'**
  String get contactSupport;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @creditsText.
  ///
  /// In en, this message translates to:
  /// **'This app was developed to help Muslims track recommended fasting days according to the Sunnah of Prophet Muhammad (PBUH).'**
  String get creditsText;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© Fasomo. All rights reserved.'**
  String get copyright;

  /// Where today falls in the Hijri month, e.g. Day 17 of 30.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String monthProgress(int day, int total);

  /// Screen-reader label for the seven-day strip on Home.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weekStripTitle;

  /// Heading of the Home list when a day other than today is picked in the week strip.
  ///
  /// In en, this message translates to:
  /// **'Fasting days from {date}'**
  String fastingDaysFrom(String date);

  /// No description provided for @yourFasting.
  ///
  /// In en, this message translates to:
  /// **'Your fasting'**
  String get yourFasting;

  /// No description provided for @fastingProgress.
  ///
  /// In en, this message translates to:
  /// **'Fasting progress'**
  String get fastingProgress;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get longestStreak;

  /// No description provided for @markFastedToday.
  ///
  /// In en, this message translates to:
  /// **'I fasted today'**
  String get markFastedToday;

  /// No description provided for @markAsFasted.
  ///
  /// In en, this message translates to:
  /// **'Mark as fasted'**
  String get markAsFasted;

  /// No description provided for @fasted.
  ///
  /// In en, this message translates to:
  /// **'Fasted'**
  String get fasted;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// Fasting days kept out of those due so far, e.g. "9 of 12".
  ///
  /// In en, this message translates to:
  /// **'{fasted} of {due}'**
  String fastedOfDue(int fasted, int due);

  /// One-line summary on the Home progress card.
  ///
  /// In en, this message translates to:
  /// **'This month: {fasted} of {due} fasting days'**
  String monthFastedSummary(int fasted, int due);

  /// No description provided for @trackerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Mark the days you fast to start a streak.'**
  String get trackerEmpty;

  /// No description provided for @noFastingDaysYet.
  ///
  /// In en, this message translates to:
  /// **'No fasting days so far.'**
  String get noFastingDaysYet;

  /// No description provided for @fastLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your fasting log'**
  String get fastLogSaveFailed;

  /// No description provided for @fastLogLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your fasting log'**
  String get fastLogLoadFailed;

  /// No description provided for @qadaTitle.
  ///
  /// In en, this message translates to:
  /// **'Make-up fasts (Qada)'**
  String get qadaTitle;

  /// No description provided for @qadaDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'days left to make up'**
  String get qadaDaysLeft;

  /// Make-up fasts done out of those owed.
  ///
  /// In en, this message translates to:
  /// **'{madeUp} of {owed} made up'**
  String qadaMadeUpOfOwed(int madeUp, int owed);

  /// Qada balance line on the Home progress card.
  ///
  /// In en, this message translates to:
  /// **'Make-up days left: {count}'**
  String qadaHomeSummary(int count);

  /// The Ramadan of a Hijri year, e.g. "Ramadan 1446 AH".
  ///
  /// In en, this message translates to:
  /// **'Ramadan {year} AH'**
  String ramadanOfYear(String year);

  /// Countdown shown while make-up days are still owed.
  ///
  /// In en, this message translates to:
  /// **'Days until Ramadan: {count}'**
  String daysUntilRamadan(int count);

  /// No description provided for @qadaNoneOwed.
  ///
  /// In en, this message translates to:
  /// **'No make-up fasts owed.'**
  String get qadaNoneOwed;

  /// No description provided for @qadaAddOwed.
  ///
  /// In en, this message translates to:
  /// **'Add days owed'**
  String get qadaAddOwed;

  /// No description provided for @qadaOwedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Days owed from a Ramadan'**
  String get qadaOwedDialogTitle;

  /// No description provided for @qadaOwedDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Days you missed that aren\'t marked in the calendar.'**
  String get qadaOwedDialogHint;

  /// No description provided for @qadaOwedYear.
  ///
  /// In en, this message translates to:
  /// **'Ramadan of'**
  String get qadaOwedYear;

  /// No description provided for @qadaOwedDays.
  ///
  /// In en, this message translates to:
  /// **'Days owed'**
  String get qadaOwedDays;

  /// No description provided for @addOneDay.
  ///
  /// In en, this message translates to:
  /// **'Add a day'**
  String get addOneDay;

  /// No description provided for @removeOneDay.
  ///
  /// In en, this message translates to:
  /// **'Remove a day'**
  String get removeOneDay;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @madeUp.
  ///
  /// In en, this message translates to:
  /// **'Made up'**
  String get madeUp;

  /// No description provided for @makeUpFast.
  ///
  /// In en, this message translates to:
  /// **'Make-up fast'**
  String get makeUpFast;

  /// No description provided for @makeUpFastHint.
  ///
  /// In en, this message translates to:
  /// **'Counts toward the days you owe'**
  String get makeUpFastHint;

  /// No description provided for @qadaExplanation.
  ///
  /// In en, this message translates to:
  /// **'Mark the Ramadan days you missed in the calendar, or add days owed from earlier years. Each make-up fast pays off the oldest Ramadan first, and still counts toward your streak and totals.'**
  String get qadaExplanation;

  /// No description provided for @qadaSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. A make-up fast can\'t be in Ramadan, on an Eid or in the future.'**
  String get qadaSaveFailed;

  /// No description provided for @logMakeUpFast.
  ///
  /// In en, this message translates to:
  /// **'Log a make-up fast'**
  String get logMakeUpFast;

  /// No description provided for @pickMakeUpDay.
  ///
  /// In en, this message translates to:
  /// **'Day of the make-up fast'**
  String get pickMakeUpDay;

  /// No description provided for @recentMakeUps.
  ///
  /// In en, this message translates to:
  /// **'Recent make-up fasts'**
  String get recentMakeUps;

  /// No description provided for @removeMakeUp.
  ///
  /// In en, this message translates to:
  /// **'Remove this make-up fast'**
  String get removeMakeUp;

  /// No description provided for @noMakeUpDayAvailable.
  ///
  /// In en, this message translates to:
  /// **'There\'s no day to log yet: make-up fasts can\'t be in Ramadan or on an Eid.'**
  String get noMakeUpDayAvailable;

  /// Notification title suggesting a make-up (Qada) fast.
  ///
  /// In en, this message translates to:
  /// **'{daysBefore, plural, =0{Today: a day for a make-up fast} =1{Tomorrow: a day for a make-up fast} other{In {daysBefore} days: a day for a make-up fast}}'**
  String qadaReminderTitle(int daysBefore);

  /// Notification body with the Qada balance.
  ///
  /// In en, this message translates to:
  /// **'Make-up days left: {remaining}'**
  String qadaReminderBody(int remaining);

  /// Notification title for a fasting day that is also a suggested make-up day.
  ///
  /// In en, this message translates to:
  /// **'{daysBefore, plural, =0{Today: {type} + make-up} =1{Tomorrow: {type} + make-up} other{In {daysBefore} days: {type} + make-up}}'**
  String mergedReminderTitle(int daysBefore, String type);

  /// Body for a merged fasting and make-up reminder.
  ///
  /// In en, this message translates to:
  /// **'Fast it as a make-up and it counts for {type} too. Make-up days left: {remaining}'**
  String mergedReminderBody(String type, int remaining);

  /// Countdown notification title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Ramadan is tomorrow} other{Ramadan in {count} days}}'**
  String ramadanCountdownTitle(int count);

  /// Countdown notification body.
  ///
  /// In en, this message translates to:
  /// **'Make-up days still owed before Ramadan: {remaining}'**
  String ramadanCountdownBody(int remaining);

  /// No description provided for @qadaReminders.
  ///
  /// In en, this message translates to:
  /// **'Make-up reminders'**
  String get qadaReminders;

  /// No description provided for @qadaRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get qadaRemindersOff;

  /// No description provided for @qadaRemindersIdle.
  ///
  /// In en, this message translates to:
  /// **'On. They start when you owe make-up days.'**
  String get qadaRemindersIdle;

  /// No description provided for @weeklyReminder.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyReminder;

  /// No description provided for @monthlyReminder.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyReminder;

  /// No description provided for @beforeRamadanReminder.
  ///
  /// In en, this message translates to:
  /// **'Before Ramadan'**
  String get beforeRamadanReminder;

  /// A Hijri day-of-month choice.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of the Hijri month'**
  String hijriDayOption(String day);

  /// No description provided for @whiteDaysOption.
  ///
  /// In en, this message translates to:
  /// **'White Days (13th)'**
  String get whiteDaysOption;

  /// A countdown offset before Ramadan.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysBeforeOption(int count);

  /// No description provided for @addDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addDaysBefore;

  /// No description provided for @daysBeforeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Days before Ramadan'**
  String get daysBeforeDialogTitle;

  /// Validation for the countdown offset.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 1 to {max}'**
  String daysBeforeInvalid(int max);

  /// No description provided for @reminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTimeLabel;

  /// Weekly part of the make-up reminder summary.
  ///
  /// In en, this message translates to:
  /// **'Weekly: {days}'**
  String weeklySummary(String days);

  /// Monthly part of the make-up reminder summary.
  ///
  /// In en, this message translates to:
  /// **'Monthly: day {day}'**
  String monthlySummary(String day);

  /// Countdown part of the make-up reminder summary.
  ///
  /// In en, this message translates to:
  /// **'Before Ramadan: {days}'**
  String beforeRamadanSummary(String days);

  /// No description provided for @qadaRemindersFootnote.
  ///
  /// In en, this message translates to:
  /// **'Make-up reminders skip Ramadan, the Eids and days you\'ve already fasted, and stop once nothing is owed. On a Sunnah fasting day they\'re merged into that day\'s reminder.'**
  String get qadaRemindersFootnote;

  /// Today's sunrise on the sky header.
  ///
  /// In en, this message translates to:
  /// **'Sunrise {time}'**
  String sunriseAt(String time);

  /// Today's sunset on the sky header.
  ///
  /// In en, this message translates to:
  /// **'Sunset {time}'**
  String sunsetAt(String time);

  /// No description provided for @skyDaytime.
  ///
  /// In en, this message translates to:
  /// **'Daytime'**
  String get skyDaytime;

  /// No description provided for @skyNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get skyNight;

  /// The moon for screen readers, e.g. "Waxing crescent moon, 23% lit".
  ///
  /// In en, this message translates to:
  /// **'{phase} moon, {percent}% lit'**
  String moonLit(String phase, int percent);

  /// No description provided for @moonNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get moonNew;

  /// No description provided for @moonWaxingCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waxing crescent'**
  String get moonWaxingCrescent;

  /// No description provided for @moonFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'First quarter'**
  String get moonFirstQuarter;

  /// No description provided for @moonWaxingGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waxing gibbous'**
  String get moonWaxingGibbous;

  /// No description provided for @moonFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get moonFull;

  /// No description provided for @moonWaningGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waning gibbous'**
  String get moonWaningGibbous;

  /// No description provided for @moonLastQuarter.
  ///
  /// In en, this message translates to:
  /// **'Last quarter'**
  String get moonLastQuarter;

  /// No description provided for @moonWaningCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waning crescent'**
  String get moonWaningCrescent;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @updateMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Update my location'**
  String get updateMyLocation;

  /// No description provided for @skyOverMakkah.
  ///
  /// In en, this message translates to:
  /// **'Shown for Makkah'**
  String get skyOverMakkah;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location wasn\'t allowed, so the sky still shows Makkah.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location is off for Fasomo, so the sky shows Makkah. You can allow it in Settings.'**
  String get locationDeniedForever;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Turn them on to see your own sky.'**
  String get locationServiceOff;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location. Try again in a moment.'**
  String get locationUnavailable;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
