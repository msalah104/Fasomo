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
  String get deleteReminderTitle => 'حذف التذكير';

  @override
  String get deleteReminderConfirm => 'هل أنت متأكد من حذف هذا التذكير؟';

  @override
  String get manageReminders => 'إدارة تذكيرات أيام الصيام';

  @override
  String get activeReminders => 'التذكيرات الحالية';

  @override
  String get noRemindersYet => 'لا توجد تذكيرات بعد';

  @override
  String get addRemindersFromHome => 'أضف التذكيرات من الصفحة الرئيسية';

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
}
