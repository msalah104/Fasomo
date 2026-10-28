import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';

enum ReminderTime { dayBefore, morningOfDay, custom }

/// A user's reminder for one kind of fasting day. There is at most one
/// reminder per [FastingType], so the type doubles as the id.
class Reminder extends Equatable {
  const new({
    required this.fastingType,
    required this.isEnabled,
    this.reminderTime = ReminderTime.dayBefore,
    this.customTime,
    this.customMessage,
  });

  final FastingType fastingType;
  final bool isEnabled;
  final ReminderTime reminderTime;
  final DateTime? customTime;
  final String? customMessage;

  String get id => fastingType.name;

  Reminder copyWith({
    bool? isEnabled,
    ReminderTime? reminderTime,
    DateTime? customTime,
    String? customMessage,
  }) {
    return Reminder(
      fastingType: fastingType,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      customTime: customTime ?? this.customTime,
      customMessage: customMessage ?? this.customMessage,
    );
  }

  /// Returns a copy whose custom message is [message] (`null` clears it).
  Reminder withCustomMessage(String? message) => Reminder(
    fastingType: fastingType,
    isEnabled: isEnabled,
    reminderTime: reminderTime,
    customTime: customTime,
    customMessage: message,
  );

  Map<String, Object?> toJson() => {
    'fastingType': fastingType.name,
    'isEnabled': isEnabled,
    'reminderTime': reminderTime.name,
    'customTime': customTime?.toIso8601String(),
    'customMessage': customMessage,
  };

  /// Decodes [json], or returns `null` when it is not a valid reminder.
  ///
  /// Also accepts the pre-1.0 format (`fastingDay: "FastingType.x"`,
  /// `reminderTime: "ReminderTime.x"`).
  static Reminder? tryFromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final type = _byName(
      FastingType.values,
      json['fastingType'] ?? json['fastingDay'],
    );
    final isEnabled = json['isEnabled'];
    if (type == null || isEnabled is! bool) return null;

    final customTime = json['customTime'];
    final customMessage = json['customMessage'];
    return Reminder(
      fastingType: type,
      isEnabled: isEnabled,
      reminderTime:
          _byName(ReminderTime.values, json['reminderTime']) ??
          ReminderTime.dayBefore,
      customTime: customTime is String ? DateTime.tryParse(customTime) : null,
      customMessage: customMessage is String ? customMessage : null,
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
    customTime,
    customMessage,
  ];
}
