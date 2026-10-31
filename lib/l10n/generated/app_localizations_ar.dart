// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'فاصومو';

  @override
  String get home => 'الرئيسية';

  @override
  String get calendar => 'التقويم';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get about => 'حول';

  @override
  String get currentHijriDate => 'التاريخ الهجري الحالي';

  @override
  String get upcomingFastingDays => 'أيام الصيام القادمة';

  @override
  String get activateReminder => 'تفعيل التذكير';

  @override
  String get deactivateReminder => 'إلغاء التذكير';

  @override
  String get whiteDays => 'الأيام البيض';

  @override
  String get mondayThursday => 'الاثنين والخميس';

  @override
  String get dayOfArafah => 'يوم عرفة';

  @override
  String get dayOfAshura => 'يوم عاشوراء';

  @override
  String get dayOfTasua => 'يوم تاسوعاء';

  @override
  String get ramadan => 'رمضان';

  @override
  String get shawwalSixDays => 'الست من شوال';

  @override
  String get whiteDaysDesc =>
      'الأيام 13 و14 و15 من كل شهر هجري. صيام هذه الأيام مستحب بشدة.';

  @override
  String get mondayThursdayDesc =>
      'كان النبي صلى الله عليه وسلم يصوم الاثنين والخميس.';

  @override
  String get arafahDesc =>
      'التاسع من ذي الحجة. صيام هذا اليوم يكفر ذنوب سنتين.';

  @override
  String get ashuraDesc => 'العاشر من محرم. صيام هذا اليوم يكفر ذنوب سنة.';

  @override
  String get tasuaDesc => 'التاسع من محرم. يستحب صيامه مع عاشوراء.';

  @override
  String get ramadanDesc => 'شهر رمضان - الصيام واجب.';

  @override
  String get shawwalDesc => 'ستة أيام من شوال بعد عيد الفطر تعدل صيام الدهر.';

  @override
  String get reminderSettings => 'إعدادات التذكير';

  @override
  String get reminderTime => 'وقت التذكير';

  @override
  String get dayBefore => 'قبل يوم';

  @override
  String get morningOfDay => 'صباح اليوم';

  @override
  String get customTime => 'وقت مخصص';

  @override
  String get sameDay => 'في نفس اليوم';

  @override
  String atTime(String time) {
    return 'الساعة $time';
  }

  @override
  String get notificationMessage => 'رسالة الإشعار';

  @override
  String get customMessageHint => 'اكتب رسالة إشعار مخصصة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get editReminder => 'تعديل التذكير';

  @override
  String get manageReminders => 'إدارة تذكيرات أيام الصيام';

  @override
  String get activeReminders => 'تذكيرات أيام الصيام';

  @override
  String get notificationsDenied =>
      'الإشعارات معطلة لتطبيق فاصومو. فعّلها من إعدادات النظام لتصلك التذكيرات.';

  @override
  String get reminderSyncFailed => 'تعذر تحديث التذكيرات المجدولة';

  @override
  String get reminderSaveFailed => 'تعذر حفظ التذكير';

  @override
  String reminderTitle(int daysBefore, String type) {
    String _temp0 = intl.Intl.pluralLogic(
      daysBefore,
      locale: localeName,
      other: 'بعد $daysBefore يوماً: $type',
      few: 'بعد $daysBefore أيام: $type',
      two: 'بعد يومين: $type',
      one: 'غداً: $type',
      zero: 'اليوم: $type',
    );
    return '$_temp0';
  }

  @override
  String daysUntil(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بعد $count يوماً',
      few: 'بعد $count أيام',
      two: 'بعد يومين',
      one: 'غداً',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String get fastingDay => 'يوم صيام';

  @override
  String get noUpcomingFasting => 'لا توجد أيام صيام قادمة';

  @override
  String get noSpecificFastingDay => 'لا توجد أيام صيام محددة';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get monthUnavailable => 'هذا الشهر خارج نطاق التقويم المدعوم';

  @override
  String get specialDays => 'أيام مميزة';

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String hijriYear(String year) {
    return '$year هـ';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get hijriMonth1 => 'محرم';

  @override
  String get hijriMonth2 => 'صفر';

  @override
  String get hijriMonth3 => 'ربيع الأول';

  @override
  String get hijriMonth4 => 'ربيع الآخر';

  @override
  String get hijriMonth5 => 'جمادى الأولى';

  @override
  String get hijriMonth6 => 'جمادى الآخرة';

  @override
  String get hijriMonth7 => 'رجب';

  @override
  String get hijriMonth8 => 'شعبان';

  @override
  String get hijriMonth9 => 'رمضان';

  @override
  String get hijriMonth10 => 'شوال';

  @override
  String get hijriMonth11 => 'ذو القعدة';

  @override
  String get hijriMonth12 => 'ذو الحجة';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get aboutApp => 'عن فاصومو';

  @override
  String get aboutDesc =>
      'فاصومو هو تطبيق لتتبع الصيام الإسلامي يساعد المسلمين على متابعة أيام الصيام المستحبة وفقاً لسنة النبي محمد صلى الله عليه وسلم.';

  @override
  String version(String version) {
    return 'الإصدار $version';
  }

  @override
  String get islamicReferences => 'المراجع الإسلامية';

  @override
  String get hadithWhiteDays =>
      '\"من صام ثلاثة أيام من كل شهر فكأنما صام الدهر كله\" (البخاري ومسلم)';

  @override
  String get hadithMondayThursday =>
      '\"كان النبي يصوم الاثنين والخميس\" (الترمذي)';

  @override
  String get hadithArafah =>
      '\"صيام يوم عرفة يكفر السنة الماضية والباقية\" (مسلم)';

  @override
  String get hadithAshura => '\"صيام يوم عاشوراء يكفر السنة الماضية\" (مسلم)';

  @override
  String get features => 'المميزات';

  @override
  String get featureCalendarTitle => 'التقويم الهجري';

  @override
  String get featureCalendarDesc =>
      'تقويم هجري كامل مع عرض أيام الصيام المستحبة';

  @override
  String get featureRemindersDesc => 'تنبيهات ذكية لأيام الصيام القادمة';

  @override
  String get featureLanguagesTitle => 'دعم اللغات';

  @override
  String get featureLanguagesDesc => 'دعم كامل للغتين العربية والإنجليزية';

  @override
  String get contactSupport => 'التواصل والدعم';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get website => 'الموقع';

  @override
  String get sourceCode => 'الشيفرة المصدرية';

  @override
  String get credits => 'شكر وتقدير';

  @override
  String get creditsText =>
      'تم تطوير هذا التطبيق لمساعدة المسلمين على متابعة أيام الصيام المستحبة وفقاً للسنة النبوية الشريفة.';

  @override
  String get copyright => '© فاصومو. جميع الحقوق محفوظة.';

  @override
  String monthProgress(int day, int total) {
    return 'اليوم $day من $total';
  }

  @override
  String get weekStripTitle => 'هذا الأسبوع';

  @override
  String fastingDaysFrom(String date) {
    return 'أيام الصيام من $date';
  }

  @override
  String get yourFasting => 'صيامك';

  @override
  String get fastingProgress => 'تقدّم الصيام';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String get longestStreak => 'أطول سلسلة';

  @override
  String get markFastedToday => 'صمتُ اليوم';

  @override
  String get markAsFasted => 'تسجيل كيوم صيام';

  @override
  String get fasted => 'تم الصيام';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get thisYear => 'هذا العام';

  @override
  String fastedOfDue(int fasted, int due) {
    return '$fasted من $due';
  }

  @override
  String monthFastedSummary(int fasted, int due) {
    return 'هذا الشهر: $fasted من $due من أيام الصيام';
  }

  @override
  String get trackerEmpty => 'سجّل الأيام التي تصومها لتبدأ سلسلتك.';

  @override
  String get noFastingDaysYet => 'لا توجد أيام صيام حتى الآن.';

  @override
  String get fastLogSaveFailed => 'تعذّر حفظ سجل الصيام';

  @override
  String get fastLogLoadFailed => 'تعذّر تحميل سجل الصيام';

  @override
  String get qadaTitle => 'صيام القضاء';

  @override
  String get qadaDaysLeft => 'أيام متبقية للقضاء';

  @override
  String qadaMadeUpOfOwed(int madeUp, int owed) {
    return 'قُضي $madeUp من $owed';
  }

  @override
  String qadaHomeSummary(int count) {
    return 'أيام القضاء المتبقية: $count';
  }

  @override
  String ramadanOfYear(String year) {
    return 'رمضان $year هـ';
  }

  @override
  String daysUntilRamadan(int count) {
    return 'الأيام المتبقية حتى رمضان: $count';
  }

  @override
  String get qadaNoneOwed => 'لا يوجد صيام قضاء مستحق.';

  @override
  String get qadaAddOwed => 'إضافة أيام مستحقة';

  @override
  String get qadaOwedDialogTitle => 'أيام مستحقة من رمضان';

  @override
  String get qadaOwedDialogHint =>
      'الأيام التي أفطرتها ولم تُسجَّل في التقويم.';

  @override
  String get qadaOwedYear => 'رمضان عام';

  @override
  String get qadaOwedDays => 'الأيام المستحقة';

  @override
  String get addOneDay => 'إضافة يوم';

  @override
  String get removeOneDay => 'إزالة يوم';

  @override
  String get missed => 'أفطرت';

  @override
  String get madeUp => 'قضاء';

  @override
  String get makeUpFast => 'صيام قضاء';

  @override
  String get makeUpFastHint => 'يُحتسب من الأيام المستحقة عليك';

  @override
  String get qadaExplanation =>
      'سجّل أيام رمضان التي أفطرتها في التقويم، أو أضف أيامًا مستحقة من أعوام سابقة. كل يوم قضاء يسدّ أقدم رمضان أولًا، ويُحتسب أيضًا في سلسلتك ومجاميعك.';

  @override
  String get qadaSaveFailed =>
      'تعذّر الحفظ. لا يكون صيام القضاء في رمضان ولا في العيد ولا في يوم لم يأتِ بعد.';

  @override
  String get logMakeUpFast => 'تسجيل يوم قضاء';

  @override
  String get pickMakeUpDay => 'يوم صيام القضاء';

  @override
  String get recentMakeUps => 'آخر أيام القضاء';

  @override
  String get removeMakeUp => 'حذف يوم القضاء هذا';

  @override
  String get noMakeUpDayAvailable =>
      'لا يوجد يوم يمكن تسجيله بعد: لا يكون القضاء في رمضان ولا في العيد.';

  @override
  String qadaReminderTitle(int daysBefore) {
    String _temp0 = intl.Intl.pluralLogic(
      daysBefore,
      locale: localeName,
      other: 'بعد $daysBefore يوماً: يوم مناسب للقضاء',
      few: 'بعد $daysBefore أيام: يوم مناسب للقضاء',
      two: 'بعد يومين: يوم مناسب للقضاء',
      one: 'غداً: يوم مناسب للقضاء',
      zero: 'اليوم: يوم مناسب للقضاء',
    );
    return '$_temp0';
  }

  @override
  String qadaReminderBody(int remaining) {
    return 'أيام القضاء المتبقية: $remaining';
  }

  @override
  String mergedReminderTitle(int daysBefore, String type) {
    String _temp0 = intl.Intl.pluralLogic(
      daysBefore,
      locale: localeName,
      other: 'بعد $daysBefore يوماً: $type + قضاء',
      few: 'بعد $daysBefore أيام: $type + قضاء',
      two: 'بعد يومين: $type + قضاء',
      one: 'غداً: $type + قضاء',
      zero: 'اليوم: $type + قضاء',
    );
    return '$_temp0';
  }

  @override
  String mergedReminderBody(String type, int remaining) {
    return 'صُمه بنية القضاء فيُحتسب لـ$type أيضًا. أيام القضاء المتبقية: $remaining';
  }

  @override
  String ramadanCountdownTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'رمضان بعد $count يوماً',
      few: 'رمضان بعد $count أيام',
      two: 'رمضان بعد يومين',
      one: 'رمضان غداً',
    );
    return '$_temp0';
  }

  @override
  String ramadanCountdownBody(int remaining) {
    return 'أيام القضاء المتبقية قبل رمضان: $remaining';
  }

  @override
  String get qadaReminders => 'تذكيرات القضاء';

  @override
  String get qadaRemindersOff => 'متوقفة';

  @override
  String get qadaRemindersIdle => 'مفعّلة. تبدأ عندما تكون عليك أيام قضاء.';

  @override
  String get weeklyReminder => 'أسبوعيًا';

  @override
  String get monthlyReminder => 'شهريًا';

  @override
  String get beforeRamadanReminder => 'قبل رمضان';

  @override
  String hijriDayOption(String day) {
    return 'اليوم $day من الشهر الهجري';
  }

  @override
  String get whiteDaysOption => 'الأيام البيض (13)';

  @override
  String daysBeforeOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get addDaysBefore => 'إضافة';

  @override
  String get daysBeforeDialogTitle => 'عدد الأيام قبل رمضان';

  @override
  String daysBeforeInvalid(int max) {
    return 'أدخل رقمًا من 1 إلى $max';
  }

  @override
  String get reminderTimeLabel => 'الوقت';

  @override
  String weeklySummary(String days) {
    return 'أسبوعيًا: $days';
  }

  @override
  String monthlySummary(String day) {
    return 'شهريًا: اليوم $day';
  }

  @override
  String beforeRamadanSummary(String days) {
    return 'قبل رمضان: $days';
  }

  @override
  String get qadaRemindersFootnote =>
      'تتجاوز تذكيرات القضاء رمضان والعيدين والأيام التي صمتها، وتتوقف عندما لا يبقى عليك قضاء. وفي أيام صيام السنة تُدمج مع تذكير ذلك اليوم.';

  @override
  String sunriseAt(String time) {
    return 'الشروق $time';
  }

  @override
  String sunsetAt(String time) {
    return 'الغروب $time';
  }

  @override
  String get skyDaytime => 'نهار';

  @override
  String get skyNight => 'ليل';

  @override
  String moonLit(String phase, int percent) {
    return 'القمر: $phase، مضاء بنسبة $percent٪';
  }

  @override
  String get moonNew => 'محاق';

  @override
  String get moonWaxingCrescent => 'هلال متزايد';

  @override
  String get moonFirstQuarter => 'تربيع أول';

  @override
  String get moonWaxingGibbous => 'أحدب متزايد';

  @override
  String get moonFull => 'بدر';

  @override
  String get moonWaningGibbous => 'أحدب متناقص';

  @override
  String get moonLastQuarter => 'تربيع ثانٍ';

  @override
  String get moonWaningCrescent => 'هلال متناقص';

  @override
  String get useMyLocation => 'استخدم موقعي';

  @override
  String get updateMyLocation => 'حدّث موقعي';

  @override
  String get skyOverMakkah => 'معروضة لمكة المكرمة';

  @override
  String get locationDenied =>
      'لم يُسمح بالوصول إلى الموقع، لذلك ما زالت السماء لمكة المكرمة.';

  @override
  String get locationDeniedForever =>
      'الموقع متوقف لتطبيق فاسومو، لذلك تظهر سماء مكة المكرمة. يمكنك السماح به من الإعدادات.';

  @override
  String get locationServiceOff => 'خدمات الموقع متوقفة. شغّلها لترى سماءك.';

  @override
  String get locationUnavailable =>
      'تعذّر تحديد موقعك. حاول مرة أخرى بعد قليل.';

  @override
  String get openSettings => 'الإعدادات';
}
