import 'package:equatable/equatable.dart';

enum ReminderTime {
  dayBefore,
  morningOfDay,
  custom,
}

class Reminder extends Equatable {
  final String id;
  final String fastingDay;
  final String title;
  final bool isEnabled;
  final ReminderTime reminderTime;
  final DateTime? customTime;
  final String? customMessage;

  const Reminder({
    required this.id,
    required this.fastingDay,
    required this.title,
    required this.isEnabled,
    this.reminderTime = ReminderTime.dayBefore,
    this.customTime,
    this.customMessage,
  });

  Reminder copyWith({
    String? id,
    String? fastingDay,
    String? title,
    bool? isEnabled,
    ReminderTime? reminderTime,
    DateTime? customTime,
    String? customMessage,
  }) {
    return Reminder(
      id: id ?? this.id,
      fastingDay: fastingDay ?? this.fastingDay,
      title: title ?? this.title,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      customTime: customTime ?? this.customTime,
      customMessage: customMessage ?? this.customMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fastingDay': fastingDay,
      'title': title,
      'isEnabled': isEnabled,
      'reminderTime': reminderTime.toString(),
      'customTime': customTime?.toIso8601String(),
      'customMessage': customMessage,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      fastingDay: json['fastingDay'] as String,
      title: json['title'] as String,
      isEnabled: json['isEnabled'] as bool,
      reminderTime: ReminderTime.values.firstWhere(
        (e) => e.toString() == json['reminderTime'],
        orElse: () => ReminderTime.dayBefore,
      ),
      customTime: json['customTime'] != null
          ? DateTime.parse(json['customTime'] as String)
          : null,
      customMessage: json['customMessage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fastingDay,
        title,
        isEnabled,
        reminderTime,
        customTime,
        customMessage,
      ];
}
