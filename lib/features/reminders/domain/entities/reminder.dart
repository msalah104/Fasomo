import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';

enum ReminderTime { dayBefore, morningOfDay, custom }

/// A user's reminder for one kind of fasting day. There is at most one
/// reminder per [FastingType], so the type doubles as the id.
class Reminder extends Equatable {
  const new({
    required this.fastingType,
    required this.isEnabled,
    this.reminderTime = ReminderTime.dayBefore,
    this.customTiming = defaultCustomTiming,
    this.customMessage,
  });

  static const ReminderTiming defaultCustomTiming = ReminderTiming(
    daysBefore: 1,
    time: WallClockTime(21, 0),
  );

  final FastingType fastingType;
  final bool isEnabled;
  final ReminderTime reminderTime;

  /// Used when [reminderTime] is [ReminderTime.custom]; kept otherwise so a
  /// user switching back to custom gets their last choice.
  final ReminderTiming customTiming;
  final String? customMessage;

  String get id => fastingType.name;

  /// When this reminder fires relative to each fasting day.
  ReminderTiming get timing => switch (reminderTime) {
    ReminderTime.dayBefore => ReminderTiming.dayBefore,
    ReminderTime.morningOfDay => ReminderTiming.morningOf,
    ReminderTime.custom => customTiming,
  };

  Reminder copyWith({
    bool? isEnabled,
    ReminderTime? reminderTime,
    ReminderTiming? customTiming,
  }) {
    return Reminder(
      fastingType: fastingType,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      customTiming: customTiming ?? this.customTiming,
      customMessage: customMessage,
    );
  }

  /// Returns a copy whose custom message is [message] (`null` clears it).
  Reminder withCustomMessage(String? message) => Reminder(
    fastingType: fastingType,
    isEnabled: isEnabled,
    reminderTime: reminderTime,
    customTiming: customTiming,
    customMessage: message,
  );

  Map<String, Object?> toJson() => {
    'fastingType': fastingType.name,
    'isEnabled': isEnabled,
    'reminderTime': reminderTime.name,
    'customDaysBefore': customTiming.daysBefore,
    'customHour': customTiming.time.hour,
    'customMinute': customTiming.time.minute,
    'customMessage': customMessage,
  };

  /// Decodes [json], or returns `null` when it is not a valid reminder.
  ///
  /// Also accepts the pre-1.0 format (`fastingDay: "FastingType.x"`,
  /// `reminderTime: "ReminderTime.x"`, `customTime` as an ISO string).
  static Reminder? tryFromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final type = _byName(
      FastingType.values,
      json['fastingType'] ?? json['fastingDay'],
    );
    final isEnabled = json['isEnabled'];
    if (type == null || isEnabled is! bool) return null;

    final customMessage = json['customMessage'];
    return Reminder(
      fastingType: type,
      isEnabled: isEnabled,
      reminderTime:
          _byName(ReminderTime.values, json['reminderTime']) ??
          ReminderTime.dayBefore,
      customTiming: _customTimingFrom(json) ?? defaultCustomTiming,
      customMessage: customMessage is String ? customMessage : null,
    );
  }

  static ReminderTiming? _customTimingFrom(Map<String, Object?> json) {
    final (days, hour, minute) = (
      json['customDaysBefore'],
      json['customHour'],
      json['customMinute'],
    );
    if (days is int && hour is int && minute is int) {
      if (days < 0 || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }
      return ReminderTiming(
        daysBefore: days,
        time: WallClockTime(hour, minute),
      );
    }
    final legacy = json['customTime'];
    final parsed = legacy is String ? DateTime.tryParse(legacy) : null;
    if (parsed == null) return null;
    return ReminderTiming(
      daysBefore: 1,
      time: WallClockTime(parsed.hour, parsed.minute),
    );
  }

  static T? _byName<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String) return null;
    final name = raw.split('.').last;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    fastingType,
    isEnabled,
    reminderTime,
    customTiming,
    customMessage,
  ];
}
