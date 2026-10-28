part of 'reminder_bloc.dart';

enum ReminderStatus { initial, loading, success, error }

class ReminderState extends Equatable {
  const new({
    this.status = ReminderStatus.initial,
    this.reminders = const [],
    this.failure,
  });

  final ReminderStatus status;
  final List<Reminder> reminders;
  final StorageFailure? failure;

  bool isEnabledFor(FastingType type) =>
      reminders.any((r) => r.fastingType == type && r.isEnabled);

  ReminderState copyWith({
    ReminderStatus? status,
    List<Reminder>? reminders,
    StorageFailure? failure,
  }) {
    return ReminderState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      failure: status == ReminderStatus.error ? failure ?? this.failure : null,
    );
  }

  @override
  List<Object?> get props => [status, reminders, failure];
}
