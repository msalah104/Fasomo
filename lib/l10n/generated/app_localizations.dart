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

  /// Calendar button that jumps back to the month containing today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get goToToday;

  /// No description provided for @goToTodayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Go to the current month'**
  String get goToTodayTooltip;

  /// Calendar toggle that shows the Gregorian day number in each day cell.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get gregorianDays;

  /// No description provided for @gregorianDaysTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show Gregorian day numbers'**
  String get gregorianDaysTooltip;

  /// No description provided for @calendarSettingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the calendar setting'**
  String get calendarSettingSaveFailed;

  /// Calendar view switch: one month at a time.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthView;

  /// Calendar view switch: the twelve months of a Hijri year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearView;

  /// No description provided for @previousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get previousYear;

  /// No description provided for @nextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get nextYear;

  /// No description provided for @yearUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This year is outside the supported calendar range'**
  String get yearUnavailable;

  /// Screen-reader note on the month containing today in the year view.
  ///
  /// In en, this message translates to:
  /// **'Current month'**
  String get currentMonth;

  /// Screen-reader label of a month in the year view; tapping it opens the month.
  ///
  /// In en, this message translates to:
  /// **'{month}, {count, plural, =0{no fasting days} =1{1 fasting day} other{{count} fasting days}}'**
  String yearViewMonthLabel(String month, int count);

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

  /// Make-up reminder kind that spreads the days owed over the weeks left before Ramadan.
  ///
  /// In en, this message translates to:
  /// **'Suggested pace'**
  String get suggestedPace;

  /// No description provided for @suggestedPaceHint.
  ///
  /// In en, this message translates to:
  /// **'Picks the make-up days for you, Mondays and Thursdays first, and adjusts as your balance changes.'**
  String get suggestedPaceHint;

  /// The suggested make-up pace when it is fewer than every day.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{To finish before Ramadan, fast 1 make-up day a week.} other{To finish before Ramadan, fast {count} make-up days a week.}}'**
  String qadaPaceWeekly(int count);

  /// No description provided for @qadaPaceEveryDay.
  ///
  /// In en, this message translates to:
  /// **'To finish before Ramadan, fast a make-up day on every day you can.'**
  String get qadaPaceEveryDay;

  /// Said honestly when more make-up days are owed than there are days left before Ramadan.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No days are left before Ramadan to make up what you owe. The rest stays owed after it.} =1{Only 1 day is left before Ramadan, fewer than you owe. Fast it, and the rest stays owed after Ramadan.} other{Only {count} days are left before Ramadan, fewer than you owe. Fast every one you can, and the rest stays owed after Ramadan.}}'**
  String qadaPaceNotEnough(int count);

  /// The next day the suggested pace plans a make-up fast on.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String qadaPaceNext(String date);

  /// Short pace line in the Qada section.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Suggested pace: 1 day a week} other{Suggested pace: {count} days a week}}'**
  String qadaPaceLineWeekly(int count);

  /// No description provided for @qadaPaceLineEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Suggested pace: every day you can'**
  String get qadaPaceLineEveryDay;

  /// Short pace line when more days are owed than are left before Ramadan.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No days left to make up before Ramadan} =1{Only 1 day left to make up before Ramadan} other{Only {count} days left to make up before Ramadan}}'**
  String qadaPaceLineNotEnough(int count);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Settings section header for language and theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this setting. It applies until the app is closed.'**
  String get settingSaveFailed;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Theme choice that follows the device's light or dark setting.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Settings section header for Hijri calendar options.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get settingsCalendar;

  /// No description provided for @hijriAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Hijri date adjustment'**
  String get hijriAdjustment;

  /// No description provided for @hijriAdjustmentExplanation.
  ///
  /// In en, this message translates to:
  /// **'Moon sighting in your country may start months a day earlier or later than the Umm al-Qura calendar. If your local Hijri date differs, adjust it here: the calendar, fasting days and reminders all follow.'**
  String get hijriAdjustmentExplanation;

  /// Preview of today's Hijri date with the adjustment applied.
  ///
  /// In en, this message translates to:
  /// **'Today: {date}'**
  String hijriAdjustmentToday(String date);

  /// No description provided for @hijriOffsetNone.
  ///
  /// In en, this message translates to:
  /// **'No adjustment'**
  String get hijriOffsetNone;

  /// Screen-reader label for a positive Hijri adjustment.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Add 1 day} other{Add {days} days}}'**
  String hijriOffsetAdd(int days);

  /// Screen-reader label for a negative Hijri adjustment.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Subtract 1 day} other{Subtract {days} days}}'**
  String hijriOffsetSubtract(int days);

  /// Settings section header for notification options.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Settings tile and dialog title for the sound reminders play.
  ///
  /// In en, this message translates to:
  /// **'Reminder sound'**
  String get notificationTone;

  /// Reminder sound choice: the device's own notification sound.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get notificationToneSystem;

  /// Reminder sound choice: two soft notes, like a doorbell chime.
  ///
  /// In en, this message translates to:
  /// **'Soft chime'**
  String get notificationToneSoftChime;

  /// Reminder sound choice: a small struck bell.
  ///
  /// In en, this message translates to:
  /// **'Bell'**
  String get notificationToneBell;

  /// Reminder sound choice: a quiet rising three-note tune.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get notificationToneGentle;

  /// Reminder sound choice: no sound, vibration only.
  ///
  /// In en, this message translates to:
  /// **'Vibrate only'**
  String get notificationToneVibrateOnly;

  /// The vibrate-only reminder sound choice as named on iPhone and iPad, where an app's notification can't vibrate without a sound.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get notificationToneSilent;

  /// Tooltip and screen-reader label of the button that previews a reminder sound (or, for vibrate only, the vibration).
  ///
  /// In en, this message translates to:
  /// **'Try {tone}'**
  String notificationTonePlay(String tone);

  /// Title of the test notification shown when previewing a reminder sound.
  ///
  /// In en, this message translates to:
  /// **'This is how reminders will sound'**
  String get notificationTonePreviewTitle;

  /// Body of the test notification shown when previewing a reminder sound.
  ///
  /// In en, this message translates to:
  /// **'Reminder sound: {tone}'**
  String notificationTonePreviewBody(String tone);

  /// No description provided for @notificationTonePreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play the sound.'**
  String get notificationTonePreviewFailed;

  /// Title of the Duas page and its entry on the About tab.
  ///
  /// In en, this message translates to:
  /// **'Duas and intentions'**
  String get duasTitle;

  /// What the Duas page holds, on its About tab entry.
  ///
  /// In en, this message translates to:
  /// **'The intention, the duas for breaking the fast and for Laylat al-Qadr, and the hadith behind each fasting day, with their sources. Available offline.'**
  String get duasAboutDesc;

  /// Button on a fasting day that opens the Duas page for that kind of fast.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get duasOpen;

  /// Filter chip on the Duas page that shows the texts for every fast.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get duasFilterAll;

  /// Section heading on the Duas page.
  ///
  /// In en, this message translates to:
  /// **'Intention'**
  String get duaSectionIntention;

  /// Section heading on the Duas page.
  ///
  /// In en, this message translates to:
  /// **'Breaking the fast'**
  String get duaSectionBreakingTheFast;

  /// Section heading on the Duas page.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Qadr'**
  String get duaSectionLaylatAlQadr;

  /// Section heading on the Duas page for the hadith on each kind of fast.
  ///
  /// In en, this message translates to:
  /// **'The virtue of each fast'**
  String get duaSectionVirtue;

  /// Title of the hadith on intention.
  ///
  /// In en, this message translates to:
  /// **'The intention (niyyah)'**
  String get duaIntentionTitle;

  /// Note under the hadith on intention.
  ///
  /// In en, this message translates to:
  /// **'The intention to fast is made in the heart; it does not need to be said aloud.'**
  String get duaIntentionNote;

  /// Title of the dua said when breaking the fast.
  ///
  /// In en, this message translates to:
  /// **'When breaking the fast'**
  String get duaIftarTitle;

  /// Title of the dua for the hosts when breaking the fast at their home.
  ///
  /// In en, this message translates to:
  /// **'When breaking the fast at someone\'s home'**
  String get duaIftarAsGuestTitle;

  /// Title of the dua for Laylat al-Qadr.
  ///
  /// In en, this message translates to:
  /// **'On Laylat al-Qadr'**
  String get duaLaylatAlQadrTitle;

  /// The hadith references under a text.
  ///
  /// In en, this message translates to:
  /// **'Source: {sources}'**
  String duaSources(String sources);

  /// Separator between two hadith references, including its spacing.
  ///
  /// In en, this message translates to:
  /// **'; '**
  String get duaSourceSeparator;

  /// A hadith reference.
  ///
  /// In en, this message translates to:
  /// **'Sahih al-Bukhari {number}'**
  String hadithSourceBukhari(String number);

  /// A hadith reference.
  ///
  /// In en, this message translates to:
  /// **'Sahih Muslim {number}'**
  String hadithSourceMuslim(String number);

  /// A hadith reference.
  ///
  /// In en, this message translates to:
  /// **'Sunan Abi Dawud {number}'**
  String hadithSourceAbuDawud(String number);

  /// A hadith reference.
  ///
  /// In en, this message translates to:
  /// **'Jami` at-Tirmidhi {number}'**
  String hadithSourceTirmidhi(String number);

  /// A hadith reference.
  ///
  /// In en, this message translates to:
  /// **'Sunan an-Nasa\'i {number}'**
  String hadithSourceNasai(String number);

  /// A hadith reference.
  ///
  /// In en, this message translates to:
  /// **'Sunan Ibn Majah {number}'**
  String hadithSourceIbnMajah(String number);

  /// Tooltip and screen-reader label of the button that copies a dua.
  ///
  /// In en, this message translates to:
  /// **'Copy {title}'**
  String duaCopy(String title);

  /// Shown after a dua is copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get duaCopied;

  /// Button on a fasting day that shares it as an image.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareDay;

  /// Tooltip and screen-reader hint of the share button.
  ///
  /// In en, this message translates to:
  /// **'Share {type} as an image'**
  String shareDayTooltip(String type);

  /// Headline of a shared fasting day that is today or ahead.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Fasting today: {type}} =1{Fasting tomorrow: {type}} other{Fasting in {days} days: {type}}}'**
  String shareDayHeadline(int days, String type);

  /// Text sent with the shared image of a fasting day.
  ///
  /// In en, this message translates to:
  /// **'{headline}, {hijriDate} ({gregorianDate}). Shared from {appName}.'**
  String shareDayText(
    String headline,
    String hijriDate,
    String gregorianDate,
    String appName,
  );

  /// Shown when a fasting day could not be shared.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share this day. Please try again.'**
  String get shareDayFailed;

  /// No description provided for @cityPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get cityPickerTitle;

  /// Hint in the search field of the city picker.
  ///
  /// In en, this message translates to:
  /// **'Search by city or country'**
  String get cityPickerSearchHint;

  /// No description provided for @cityPickerClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get cityPickerClearSearch;

  /// Shown when the city search finds nothing.
  ///
  /// In en, this message translates to:
  /// **'No city matches “{query}”. Try a nearby big city.'**
  String cityPickerNoResults(String query);

  /// Under the Home sky: today's sunrise time.
  ///
  /// In en, this message translates to:
  /// **'Sunrise {time}'**
  String skySunrise(String time);

  /// Under the Home sky: today's sunset time.
  ///
  /// In en, this message translates to:
  /// **'Sunset {time}'**
  String skySunset(String time);

  /// Under the Home sky at night: when the moon rose or will rise.
  ///
  /// In en, this message translates to:
  /// **'Moonrise {time}'**
  String skyMoonrise(String time);

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

  /// No description provided for @skyDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get skyDawn;

  /// No description provided for @skyDusk.
  ///
  /// In en, this message translates to:
  /// **'Dusk'**
  String get skyDusk;

  /// Screen-reader description of the Home sky: the place it is drawn for.
  ///
  /// In en, this message translates to:
  /// **'Sky over {place}'**
  String skyOver(String place);

  /// Like skyOver, when the user has not set a location yet.
  ///
  /// In en, this message translates to:
  /// **'Sky over {place}, an approximate location'**
  String skyOverApproximate(String place);

  /// No description provided for @skySunUp.
  ///
  /// In en, this message translates to:
  /// **'The sun is up'**
  String get skySunUp;

  /// Screen-reader description of the moon in the Home sky.
  ///
  /// In en, this message translates to:
  /// **'The moon is up: {phase}, {percent} lit'**
  String skyMoonUp(String phase, String percent);

  /// Screen-reader description of the moon when it has set.
  ///
  /// In en, this message translates to:
  /// **'The moon is below the horizon: {phase}, {percent} lit'**
  String skyMoonDown(String phase, String percent);

  /// Moon phase name, used mid-sentence (lower case).
  ///
  /// In en, this message translates to:
  /// **'new moon'**
  String get moonNew;

  /// No description provided for @moonWaxingCrescent.
  ///
  /// In en, this message translates to:
  /// **'waxing crescent'**
  String get moonWaxingCrescent;

  /// No description provided for @moonFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'first quarter'**
  String get moonFirstQuarter;

  /// No description provided for @moonWaxingGibbous.
  ///
  /// In en, this message translates to:
  /// **'waxing gibbous'**
  String get moonWaxingGibbous;

  /// No description provided for @moonFull.
  ///
  /// In en, this message translates to:
  /// **'full moon'**
  String get moonFull;

  /// No description provided for @moonWaningGibbous.
  ///
  /// In en, this message translates to:
  /// **'waning gibbous'**
  String get moonWaningGibbous;

  /// No description provided for @moonLastQuarter.
  ///
  /// In en, this message translates to:
  /// **'last quarter'**
  String get moonLastQuarter;

  /// No description provided for @moonWaningCrescent.
  ///
  /// In en, this message translates to:
  /// **'waning crescent'**
  String get moonWaningCrescent;

  /// Location chip on the Home sky before the user sets a location.
  ///
  /// In en, this message translates to:
  /// **'Approximate · Set location'**
  String get locationApproximate;

  /// Location chip for a device location with no listed city nearby.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get locationMyLocation;

  /// No description provided for @locationLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get locationLocating;

  /// Screen-reader hint for the location chip.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get locationChipHint;

  /// No description provided for @locationSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your location'**
  String get locationSheetTitle;

  /// No description provided for @locationSheetBody.
  ///
  /// In en, this message translates to:
  /// **'The sky is drawn for your approximate location. It stays on this device.'**
  String get locationSheetBody;

  /// No description provided for @locationUseDevice.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get locationUseDevice;

  /// No description provided for @locationUseDeviceDetail.
  ///
  /// In en, this message translates to:
  /// **'Approximate, to about a kilometre. Asks for permission.'**
  String get locationUseDeviceDetail;

  /// No description provided for @locationChooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get locationChooseCity;

  /// No description provided for @locationChooseCityDetail.
  ///
  /// In en, this message translates to:
  /// **'Works offline, with no permission needed'**
  String get locationChooseCityDetail;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission wasn\'t given. You can choose a city instead.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked for Fasomo. Allow it in Settings, or choose a city.'**
  String get locationDeniedForever;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Turn them on, or choose a city.'**
  String get locationServiceOff;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find your location. Try again, or choose a city.'**
  String get locationUnavailable;

  /// Snackbar action that opens the system settings for this app.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// Settings section title for how prayer times are calculated.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get settingsPrayerTimes;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @prayerMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get prayerMethod;

  /// No description provided for @prayerMethodAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic (by country)'**
  String get prayerMethodAutomatic;

  /// Subtitle of the method setting when it follows the country; method is the method it resolved to.
  ///
  /// In en, this message translates to:
  /// **'Automatic: {method}'**
  String prayerMethodAutomaticResolved(String method);

  /// No description provided for @prayerMethodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura, Makkah'**
  String get prayerMethodUmmAlQura;

  /// No description provided for @prayerMethodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority of Survey'**
  String get prayerMethodEgyptian;

  /// No description provided for @prayerMethodMuslimWorldLeague.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get prayerMethodMuslimWorldLeague;

  /// No description provided for @prayerMethodIsna.
  ///
  /// In en, this message translates to:
  /// **'Islamic Society of North America'**
  String get prayerMethodIsna;

  /// No description provided for @prayerMethodKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get prayerMethodKarachi;

  /// No description provided for @prayerMethodDubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get prayerMethodDubai;

  /// No description provided for @prayerMethodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get prayerMethodKuwait;

  /// No description provided for @prayerMethodQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get prayerMethodQatar;

  /// No description provided for @prayerMethodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore (MUIS)'**
  String get prayerMethodSingapore;

  /// No description provided for @prayerMethodTurkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey (Diyanet)'**
  String get prayerMethodTurkey;

  /// No description provided for @prayerMethodTehran.
  ///
  /// In en, this message translates to:
  /// **'Institute of Geophysics, Tehran'**
  String get prayerMethodTehran;

  /// Settings tile title: how Asr is reckoned.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asrMethod;

  /// No description provided for @asrMethodStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard (Shafi\'i, Maliki, Hanbali)'**
  String get asrMethodStandard;

  /// No description provided for @asrMethodHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get asrMethodHanafi;

  /// No description provided for @highLatitudeRule.
  ///
  /// In en, this message translates to:
  /// **'High latitudes'**
  String get highLatitudeRule;

  /// No description provided for @highLatitudeMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle of the night'**
  String get highLatitudeMiddle;

  /// No description provided for @highLatitudeSeventh.
  ///
  /// In en, this message translates to:
  /// **'One-seventh of the night'**
  String get highLatitudeSeventh;

  /// No description provided for @highLatitudeAngle.
  ///
  /// In en, this message translates to:
  /// **'Twilight angle'**
  String get highLatitudeAngle;

  /// No description provided for @highLatitudeHint.
  ///
  /// In en, this message translates to:
  /// **'For places where the sky never gets dark enough for Fajr or Isha'**
  String get highLatitudeHint;

  /// No description provided for @prayerAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Adjust times'**
  String get prayerAdjustments;

  /// No description provided for @prayerAdjustmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Minutes added to or taken from each time, to match your mosque'**
  String get prayerAdjustmentsHint;

  /// No description provided for @prayerAdjustmentsNone.
  ///
  /// In en, this message translates to:
  /// **'No adjustments'**
  String get prayerAdjustmentsNone;

  /// An adjustment in minutes with its sign, e.g. +3 min.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String prayerAdjustmentMinutes(String minutes);

  /// One adjusted prayer in the summary, e.g. Maghrib +3 min.
  ///
  /// In en, this message translates to:
  /// **'{prayer} {minutes}'**
  String prayerAdjustmentItem(String prayer, String minutes);

  /// Screen-reader label of the minus button for one prayer's adjustment.
  ///
  /// In en, this message translates to:
  /// **'{prayer} one minute earlier'**
  String prayerAdjustEarlier(String prayer);

  /// Screen-reader label of the plus button for one prayer's adjustment.
  ///
  /// In en, this message translates to:
  /// **'{prayer} one minute later'**
  String prayerAdjustLater(String prayer);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Countdown card on Home: the first day of Ramadan by the adjusted calendar.
  ///
  /// In en, this message translates to:
  /// **'Expected to start on {date}'**
  String ramadanStartsOn(String date);

  /// No description provided for @ramadanFirstSuhoor.
  ///
  /// In en, this message translates to:
  /// **'The first suhoor ends at {time} (Fajr)'**
  String ramadanFirstSuhoor(String time);

  /// On the Ramadan card: today's day of the month and the month's length.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {days}'**
  String ramadanDayOf(int day, int days);

  /// No description provided for @ramadanIftarIn.
  ///
  /// In en, this message translates to:
  /// **'Iftar in {duration}'**
  String ramadanIftarIn(String duration);

  /// No description provided for @ramadanSuhoorEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends in {duration}'**
  String ramadanSuhoorEndsIn(String duration);

  /// A short countdown, e.g. 2 h 15 min.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, String minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// The countdown as a screen reader says it.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =0{} =1{1 hour } other{{hours} hours }}{minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String durationSpoken(int hours, int minutes);

  /// No description provided for @ramadanSuhoorEnds.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends'**
  String get ramadanSuhoorEnds;

  /// No description provided for @ramadanIftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get ramadanIftar;

  /// Under the Ramadan times: where they are for and the calculation method.
  ///
  /// In en, this message translates to:
  /// **'{place} · {method}'**
  String ramadanTimesFor(String place, String method);

  /// No description provided for @ramadanTimesApproximate.
  ///
  /// In en, this message translates to:
  /// **'Times for {place} until you set your location'**
  String ramadanTimesApproximate(String place);

  /// No description provided for @ramadanComplete.
  ///
  /// In en, this message translates to:
  /// **'Ramadan is complete. Eid Mubarak!'**
  String get ramadanComplete;

  /// Title of the daily Ramadan checklist.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ramadanChecklistTitle;

  /// No description provided for @ramadanTaraweeh.
  ///
  /// In en, this message translates to:
  /// **'Taraweeh'**
  String get ramadanTaraweeh;

  /// No description provided for @ramadanQuranPages.
  ///
  /// In en, this message translates to:
  /// **'Quran pages'**
  String get ramadanQuranPages;

  /// The Quran pages read today, as a screen reader says it.
  ///
  /// In en, this message translates to:
  /// **'{pages, plural, =0{No pages} =1{1 page} other{{pages} pages}}'**
  String ramadanQuranPagesValue(int pages);

  /// No description provided for @ramadanQuranPageAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a page'**
  String get ramadanQuranPageAdd;

  /// No description provided for @ramadanQuranPageRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove a page'**
  String get ramadanQuranPageRemove;

  /// No description provided for @ramadanPrayerTimesToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayer times'**
  String get ramadanPrayerTimesToday;

  /// No description provided for @ramadanChecklistLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load today\'s checklist.'**
  String get ramadanChecklistLoadFailed;

  /// No description provided for @ramadanChecklistSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save today\'s checklist.'**
  String get ramadanChecklistSaveFailed;

  /// Title of the suhoor reminder, sent the chosen minutes before Fajr.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =0{Suhoor ends now} =1{Suhoor ends in 1 minute} other{Suhoor ends in {minutes} minutes}}'**
  String suhoorNotificationTitle(int minutes);

  /// No description provided for @suhoorNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Fajr is at {time}. Finish your suhoor and make your intention to fast.'**
  String suhoorNotificationBody(String time);

  /// Title of the iftar reminder, sent at Maghrib or the chosen minutes before.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =0{It\'s time for iftar} =1{Iftar in 1 minute} other{Iftar in {minutes} minutes}}'**
  String iftarNotificationTitle(int minutes);

  /// No description provided for @iftarNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Maghrib is at {time}. May Allah accept your fast.'**
  String iftarNotificationBody(String time);

  /// Reminders tab card and sheet title for the prayer-timed reminders.
  ///
  /// In en, this message translates to:
  /// **'Suhoor and iftar'**
  String get suhoorIftarReminders;

  /// No description provided for @suhoorIftarHint.
  ///
  /// In en, this message translates to:
  /// **'In Ramadan, timed from each day\'s Fajr and Maghrib where you are.'**
  String get suhoorIftarHint;

  /// No description provided for @suhoorReminder.
  ///
  /// In en, this message translates to:
  /// **'Suhoor'**
  String get suhoorReminder;

  /// No description provided for @iftarReminder.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get iftarReminder;

  /// No description provided for @suhoorMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before Fajr'**
  String suhoorMinutesBefore(int minutes);

  /// No description provided for @iftarMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =0{At Maghrib} other{{minutes} min before Maghrib}}'**
  String iftarMinutesBefore(int minutes);

  /// No description provided for @suhoorIftarOtherDays.
  ///
  /// In en, this message translates to:
  /// **'Also on other fasting days'**
  String get suhoorIftarOtherDays;

  /// No description provided for @suhoorIftarOtherDaysDetail.
  ///
  /// In en, this message translates to:
  /// **'Mondays and Thursdays, the White Days, Arafah and more'**
  String get suhoorIftarOtherDaysDetail;

  /// No description provided for @suhoorIftarOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get suhoorIftarOff;

  /// One part of the Suhoor and iftar summary, e.g. Suhoor: 45 min before Fajr.
  ///
  /// In en, this message translates to:
  /// **'{meal}: {when}'**
  String suhoorIftarSummaryItem(String meal, String when);

  /// Home-screen widget line naming the next fasting day and how far away it is.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Today: {type}} =1{Tomorrow: {type}} other{{type} in {days} days}}'**
  String homeWidgetNextFast(int days, String type);

  /// Home-screen widget text shown when its dates are out of date because the app has not been opened for over a week.
  ///
  /// In en, this message translates to:
  /// **'Open Fasomo to update'**
  String get homeWidgetOpenApp;

  /// Title of the settings section for exporting and restoring a backup file.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// Settings action that saves reminders, settings and the fasting log to a file and opens the share sheet.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get backupExport;

  /// Explains what the export contains, and that the file is plain text.
  ///
  /// In en, this message translates to:
  /// **'Save your reminders, settings and fasting log to a file. The file is not encrypted.'**
  String get backupExportSubtitle;

  /// Settings action that replaces this phone's data with a backup file the user picks.
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get backupRestore;

  /// Explains when to restore a backup.
  ///
  /// In en, this message translates to:
  /// **'Bring back a backup, for example on a new phone'**
  String get backupRestoreSubtitle;

  /// Screen-reader label of the progress indicator while a backup is exported or restored.
  ///
  /// In en, this message translates to:
  /// **'Working on the backup…'**
  String get backupInProgress;

  /// Title of the dialog that confirms a restore before the file is picked.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup?'**
  String get backupRestoreConfirmTitle;

  /// Body of the restore confirmation dialog: names the replace policy.
  ///
  /// In en, this message translates to:
  /// **'Your reminders, settings and fasting log will be replaced by the ones in the backup you choose. Anything the backup does not include stays as it is. This cannot be undone.'**
  String get backupRestoreConfirmBody;

  /// Button in the restore confirmation dialog that opens the file picker.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get backupRestoreConfirmAction;

  /// Shown after the backup file was handed to the share sheet.
  ///
  /// In en, this message translates to:
  /// **'Backup ready'**
  String get backupExported;

  /// Shown after a backup was restored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// Shown after a restore that ignored parts of the file this version does not know.
  ///
  /// In en, this message translates to:
  /// **'Backup restored. Some parts from a newer version of Fasomo were skipped.'**
  String get backupRestoredWithSkipped;

  /// Restore refused: the file's format is newer than this app.
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of Fasomo. Update the app, then try again.'**
  String get backupErrorNewerVersion;

  /// Restore refused: the file could not be read as a backup.
  ///
  /// In en, this message translates to:
  /// **'This file is not a Fasomo backup, or it is damaged. Nothing was changed.'**
  String get backupErrorCorrupt;

  /// Restore refused: the file's checksum does not match its contents.
  ///
  /// In en, this message translates to:
  /// **'This backup was changed or damaged after it was made. Nothing was changed.'**
  String get backupErrorChecksum;

  /// Restore failed while writing and was rolled back.
  ///
  /// In en, this message translates to:
  /// **'Could not save the restored data, so nothing was changed.'**
  String get backupErrorRestoreStorage;

  /// Restore failed: the picked file could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not read that file. Nothing was changed.'**
  String get backupErrorFile;

  /// Export failed: the data could not be read or the file could not be written or shared.
  ///
  /// In en, this message translates to:
  /// **'Could not create the backup. Please try again.'**
  String get backupErrorExport;

  /// First-run flow: ends the flow now and keeps the defaults for the rest.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// First-run flow: moves on from the location step without setting a location.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get onboardingLater;

  /// First-run flow progress, under the step dots.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepOf(int current, int total);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Fasomo'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Fasomo shows the recommended and obligatory fasts of the Hijri year and reminds you before each one.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingFastsTitle.
  ///
  /// In en, this message translates to:
  /// **'Which fasts interest you?'**
  String get onboardingFastsTitle;

  /// No description provided for @onboardingFastsBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get a reminder before each one you choose. You can change this any time in Reminders.'**
  String get onboardingFastsBody;

  /// No description provided for @onboardingFastsNone.
  ///
  /// In en, this message translates to:
  /// **'No reminders will be set. You can turn them on later in Reminders.'**
  String get onboardingFastsNone;

  /// First-run flow: one choice that covers the three special fasting days.
  ///
  /// In en, this message translates to:
  /// **'Arafah, Ashura and Tasua'**
  String get onboardingSpecialDays;

  /// No description provided for @onboardingTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'When should we remind you?'**
  String get onboardingTimeTitle;

  /// No description provided for @onboardingTimeBody.
  ///
  /// In en, this message translates to:
  /// **'This applies to every reminder you chose. You can change each one later.'**
  String get onboardingTimeBody;

  /// No description provided for @onboardingEveningBefore.
  ///
  /// In en, this message translates to:
  /// **'Evening before'**
  String get onboardingEveningBefore;

  /// No description provided for @onboardingMorningOf.
  ///
  /// In en, this message translates to:
  /// **'Morning of the fast'**
  String get onboardingMorningOf;

  /// Screen-reader hint on the button that opens the time picker for the custom reminder time.
  ///
  /// In en, this message translates to:
  /// **'Change the reminder time'**
  String get onboardingPickTime;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Your location draws the real sky on Home, and later sets prayer times. It stays on this device.'**
  String get onboardingLocationBody;

  /// First-run flow: confirms the location, e.g. 'Location set: Cairo'.
  ///
  /// In en, this message translates to:
  /// **'Location set: {place}'**
  String onboardingLocationSet(String place);

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a fast'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Fasomo needs permission to show notifications, so your reminders can reach you before each fast.'**
  String get onboardingNotificationsBody;

  /// No description provided for @onboardingAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboardingAllowNotifications;

  /// No description provided for @onboardingNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get onboardingNotNow;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your choices. Try again, or skip.'**
  String get onboardingSaveFailed;
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
