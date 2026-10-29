import 'package:equatable/equatable.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';

/// When a make-up reminder fires relative to its day.
enum QadaReminderTime {
  /// 20:00 the evening before, in time to plan suhoor.
  eveningBefore(ReminderTiming.dayBefore),

  /// 07:00 on the day.
  morningOf(ReminderTiming.morningOf);

  new(this.timing);

  final ReminderTiming timing;
}

/// Which make-up (Qada) reminders are on. Everything starts on; reminders
/// only fire while make-up days are owed.
class QadaReminderSettings extends Equatable {
  const new({
    this.weeklyEnabled = true,
    this.weekdays = const {DateTime.saturday},
    this.monthlyEnabled = true,
    this.monthlyHijriDay = whiteDaysStart,
    this.beforeRamadanEnabled = true,
    this.daysBeforeRamadan = const {30, 7},
    this.time = QadaReminderTime.eveningBefore,
  });

  static const defaults = QadaReminderSettings();

  /// The 13th, first of the White Days, so the fast counts for both.
  static const int whiteDaysStart = 13;

  /// The most days before Ramadan a countdown can be set to: a Hijri year
  /// is at least 354 days.
  static const int maxDaysBeforeRamadan = 354;

  final bool weeklyEnabled;

  /// [DateTime.monday] … [DateTime.sunday].
  final Set<int> weekdays;

  final bool monthlyEnabled;

  /// 1–30; a month without that day is skipped.
  final int monthlyHijriDay;

  final bool beforeRamadanEnabled;

  /// Each value schedules a countdown that many days before Ramadan.
  final Set<int> daysBeforeRamadan;

  final QadaReminderTime time;

  bool get anyEnabled =>
      (weeklyEnabled && weekdays.isNotEmpty) ||
      monthlyEnabled ||
      (beforeRamadanEnabled && daysBeforeRamadan.isNotEmpty);

  QadaReminderSettings copyWith({
    bool? weeklyEnabled,
    Set<int>? weekdays,
    bool? monthlyEnabled,
    int? monthlyHijriDay,
    bool? beforeRamadanEnabled,
    Set<int>? daysBeforeRamadan,
    QadaReminderTime? time,
  }) {
    return QadaReminderSettings(
      weeklyEnabled: weeklyEnabled ?? this.weeklyEnabled,
      weekdays: weekdays ?? this.weekdays,
      monthlyEnabled: monthlyEnabled ?? this.monthlyEnabled,
      monthlyHijriDay: monthlyHijriDay ?? this.monthlyHijriDay,
      beforeRamadanEnabled: beforeRamadanEnabled ?? this.beforeRamadanEnabled,
      daysBeforeRamadan: daysBeforeRamadan ?? this.daysBeforeRamadan,
      time: time ?? this.time,
    );
  }

  Map<String, Object> toJson() => {
    'weeklyEnabled': weeklyEnabled,
    'weekdays': weekdays.toList()..sort(),
    'monthlyEnabled': monthlyEnabled,
    'monthlyHijriDay': monthlyHijriDay,
    'beforeRamadanEnabled': beforeRamadanEnabled,
    'daysBeforeRamadan': daysBeforeRamadan.toList()..sort(),
    'time': time.name,
  };

  /// Decodes [json], or returns `null` when it is not valid settings.
  static QadaReminderSettings? tryFromJson(Object? json) {
    if (json
        case {
          'weeklyEnabled': final bool weeklyEnabled,
          'weekdays': final List<Object?> weekdays,
          'monthlyEnabled': final bool monthlyEnabled,
          'monthlyHijriDay': final int monthlyHijriDay,
          'beforeRamadanEnabled': final bool beforeRamadanEnabled,
          'daysBeforeRamadan': final List<Object?> daysBeforeRamadan,
          'time': final String time,
        }
        when weekdays.every((d) => d is int && d >= 1 && d <= 7) &&
            monthlyHijriDay >= 1 &&
            monthlyHijriDay <= 30 &&
            daysBeforeRamadan.every(
              (d) => d is int && d >= 1 && d <= maxDaysBeforeRamadan,
            )) {
      final parsedTime = QadaReminderTime.values
          .where((t) => t.name == time)
          .firstOrNull;
      if (parsedTime == null) return null;
      return QadaReminderSettings(
        weeklyEnabled: weeklyEnabled,
        weekdays: weekdays.cast<int>().toSet(),
        monthlyEnabled: monthlyEnabled,
        monthlyHijriDay: monthlyHijriDay,
        beforeRamadanEnabled: beforeRamadanEnabled,
        daysBeforeRamadan: daysBeforeRamadan.cast<int>().toSet(),
        time: parsedTime,
      );
    }
    return null;
  }

  @override
  List<Object> get props => [
    weeklyEnabled,
    weekdays,
    monthlyEnabled,
    monthlyHijriDay,
    beforeRamadanEnabled,
    daysBeforeRamadan,
    time,
  ];
}
