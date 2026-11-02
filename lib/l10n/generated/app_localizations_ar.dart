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
  String get goToToday => 'اليوم';

  @override
  String get goToTodayTooltip => 'الانتقال إلى الشهر الحالي';

  @override
  String get gregorianDays => 'ميلادي';

  @override
  String get gregorianDaysTooltip => 'إظهار أرقام الأيام الميلادية';

  @override
  String get calendarSettingSaveFailed => 'تعذّر حفظ إعداد التقويم';

  @override
  String get monthView => 'شهر';

  @override
  String get yearView => 'سنة';

  @override
  String get previousYear => 'السنة السابقة';

  @override
  String get nextYear => 'السنة التالية';

  @override
  String get yearUnavailable => 'هذه السنة خارج نطاق التقويم المدعوم';

  @override
  String get currentMonth => 'الشهر الحالي';

  @override
  String yearViewMonthLabel(String month, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم صيام',
      many: '$count يوم صيام',
      few: '$count أيام صيام',
      two: 'يوما صيام',
      one: 'يوم صيام واحد',
      zero: 'لا أيام صيام',
    );
    return '$month، $_temp0';
  }

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
  String get suggestedPace => 'الوتيرة المقترحة';

  @override
  String get suggestedPaceHint =>
      'يختار لك أيام القضاء، مقدّمًا الاثنين والخميس، ويتكيّف كلما تغيّر ما عليك.';

  @override
  String qadaPaceWeekly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لتُتمّ القضاء قبل رمضان، صُم $count يوم قضاء كل أسبوع.',
      many: 'لتُتمّ القضاء قبل رمضان، صُم $count يومًا من القضاء كل أسبوع.',
      few: 'لتُتمّ القضاء قبل رمضان، صُم $count أيام قضاء كل أسبوع.',
      two: 'لتُتمّ القضاء قبل رمضان، صُم يومَي قضاء كل أسبوع.',
      one: 'لتُتمّ القضاء قبل رمضان، صُم يوم قضاء واحدًا كل أسبوع.',
      zero: 'لا يلزمك صيام قضاء هذا الأسبوع لتُتمّه قبل رمضان.',
    );
    return '$_temp0';
  }

  @override
  String get qadaPaceEveryDay =>
      'لتُتمّ القضاء قبل رمضان، صُم كل يوم يجوز فيه القضاء.';

  @override
  String qadaPaceNotEnough(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'لم يبقَ قبل رمضان إلا $count يوم، وهي أقل مما عليك. صُم ما استطعت منها، ويبقى الباقي عليك بعد رمضان.',
      many:
          'لم يبقَ قبل رمضان إلا $count يومًا، وهي أقل مما عليك. صُم ما استطعت منها، ويبقى الباقي عليك بعد رمضان.',
      few:
          'لم يبقَ قبل رمضان إلا $count أيام، وهي أقل مما عليك. صُم ما استطعت منها، ويبقى الباقي عليك بعد رمضان.',
      two: 'لم يبقَ قبل رمضان إلا يومان، وهما أقل مما عليك. صُمهما، ويبقى الباقي عليك بعد رمضان.',
      one: 'لم يبقَ قبل رمضان إلا يوم واحد، وهو أقل مما عليك. صُمه، ويبقى الباقي عليك بعد رمضان.',
      zero: 'لم يبقَ قبل رمضان يوم تقضي فيه ما عليك، ويبقى القضاء عليك بعده.',
    );
    return '$_temp0';
  }

  @override
  String qadaPaceNext(String date) {
    return 'التالي: $date';
  }

  @override
  String qadaPaceLineWeekly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الوتيرة المقترحة: $count يوم في الأسبوع',
      many: 'الوتيرة المقترحة: $count يومًا في الأسبوع',
      few: 'الوتيرة المقترحة: $count أيام في الأسبوع',
      two: 'الوتيرة المقترحة: يومان في الأسبوع',
      one: 'الوتيرة المقترحة: يوم واحد في الأسبوع',
      zero: 'الوتيرة المقترحة: لا أيام هذا الأسبوع',
    );
    return '$_temp0';
  }

  @override
  String get qadaPaceLineEveryDay => 'الوتيرة المقترحة: كل يوم تستطيعه';

  @override
  String qadaPaceLineNotEnough(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لم يبقَ للقضاء قبل رمضان إلا $count يوم',
      many: 'لم يبقَ للقضاء قبل رمضان إلا $count يومًا',
      few: 'لم يبقَ للقضاء قبل رمضان إلا $count أيام',
      two: 'لم يبقَ للقضاء قبل رمضان إلا يومان',
      one: 'لم يبقَ للقضاء قبل رمضان إلا يوم واحد',
      zero: 'لم يبقَ يوم للقضاء قبل رمضان',
    );
    return '$_temp0';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingSaveFailed =>
      'تعذّر حفظ هذا الإعداد. سيبقى مطبّقًا حتى إغلاق التطبيق.';

  @override
  String get theme => 'السمة';

  @override
  String get themeSystem => 'حسب إعداد النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsCalendar => 'التقويم';

  @override
  String get hijriAdjustment => 'تعديل التاريخ الهجري';

  @override
  String get hijriAdjustmentExplanation =>
      'قد تبدأ الشهور في بلدك قبل تقويم أم القرى أو بعده بيوم بحسب رؤية الهلال. إن اختلف التاريخ الهجري المحلي فعدّله هنا، وسيتبعه التقويم وأيام الصيام والتذكيرات.';

  @override
  String hijriAdjustmentToday(String date) {
    return 'اليوم: $date';
  }

  @override
  String get hijriOffsetNone => 'دون تعديل';

  @override
  String hijriOffsetAdd(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'إضافة $days يومًا',
      few: 'إضافة $days أيام',
      two: 'إضافة يومين',
      one: 'إضافة يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String hijriOffsetSubtract(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'طرح $days يومًا',
      few: 'طرح $days أيام',
      two: 'طرح يومين',
      one: 'طرح يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get notificationTone => 'صوت التذكير';

  @override
  String get notificationToneSystem => 'صوت النظام الافتراضي';

  @override
  String get notificationToneSoftChime => 'رنين هادئ';

  @override
  String get notificationToneBell => 'جرس';

  @override
  String get notificationToneGentle => 'نغمة لطيفة';

  @override
  String get notificationToneVibrateOnly => 'اهتزاز فقط';

  @override
  String get notificationToneSilent => 'صامت';

  @override
  String notificationTonePlay(String tone) {
    return 'تجربة $tone';
  }

  @override
  String get notificationTonePreviewTitle => 'هكذا ستبدو تذكيراتك';

  @override
  String notificationTonePreviewBody(String tone) {
    return 'صوت التذكير: $tone';
  }

  @override
  String get notificationTonePreviewFailed => 'تعذّر تشغيل الصوت.';

  @override
  String get duasTitle => 'الأدعية والنية';

  @override
  String get duasAboutDesc =>
      'النية، ودعاء الإفطار وليلة القدر، والحديث الوارد في كل يوم صيام، مع مصادرها. متاحة دون اتصال.';

  @override
  String get duasOpen => 'الأدعية';

  @override
  String get duasFilterAll => 'الكل';

  @override
  String get duaSectionIntention => 'النية';

  @override
  String get duaSectionBreakingTheFast => 'الإفطار';

  @override
  String get duaSectionLaylatAlQadr => 'ليلة القدر';

  @override
  String get duaSectionVirtue => 'فضل كل صيام';

  @override
  String get duaIntentionTitle => 'النية';

  @override
  String get duaIntentionNote => 'النية محلها القلب، ولا يلزم التلفظ بها.';

  @override
  String get duaIftarTitle => 'عند الإفطار';

  @override
  String get duaIftarAsGuestTitle => 'إذا أفطرت عند أحد';

  @override
  String get duaLaylatAlQadrTitle => 'في ليلة القدر';

  @override
  String duaSources(String sources) {
    return 'المصدر: $sources';
  }

  @override
  String get duaSourceSeparator => '؛ ';

  @override
  String hadithSourceBukhari(String number) {
    return 'صحيح البخاري $number';
  }

  @override
  String hadithSourceMuslim(String number) {
    return 'صحيح مسلم $number';
  }

  @override
  String hadithSourceAbuDawud(String number) {
    return 'سنن أبي داود $number';
  }

  @override
  String hadithSourceTirmidhi(String number) {
    return 'جامع الترمذي $number';
  }

  @override
  String hadithSourceNasai(String number) {
    return 'سنن النسائي $number';
  }

  @override
  String hadithSourceIbnMajah(String number) {
    return 'سنن ابن ماجه $number';
  }

  @override
  String duaCopy(String title) {
    return 'نسخ $title';
  }

  @override
  String get duaCopied => 'تم النسخ';

  @override
  String get shareDay => 'مشاركة';

  @override
  String shareDayTooltip(String type) {
    return 'مشاركة $type صورةً';
  }

  @override
  String shareDayHeadline(int days, String type) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'صيام بعد $days يومًا: $type',
      few: 'صيام بعد $days أيام: $type',
      two: 'صيام بعد يومين: $type',
      one: 'صيام الغد: $type',
      zero: 'صيام اليوم: $type',
    );
    return '$_temp0';
  }

  @override
  String shareDayText(
    String headline,
    String hijriDate,
    String gregorianDate,
    String appName,
  ) {
    return '$headline، $hijriDate ($gregorianDate). مشاركة من تطبيق $appName.';
  }

  @override
  String get shareDayFailed => 'تعذّرت مشاركة هذا اليوم. حاول مرة أخرى.';

  @override
  String get cityPickerTitle => 'اختر مدينة';

  @override
  String get cityPickerSearchHint => 'ابحث باسم المدينة أو الدولة';

  @override
  String get cityPickerClearSearch => 'مسح البحث';

  @override
  String cityPickerNoResults(String query) {
    return 'لا توجد مدينة تطابق «$query». جرّب مدينة كبيرة قريبة.';
  }
}
