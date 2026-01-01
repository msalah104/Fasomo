part of 'reminder_bloc.dart';

enum ReminderStatus { initial, loading, success, error }

class ReminderState extends Equatable {
  final ReminderStatus status;
  final List<Reminder> reminders;
  final String? errorMessage;

  const ReminderState({
    this.status = ReminderStatus.initial,
    this.reminders = const [],
    this.errorMessage,
  });

  ReminderState copyWith({
    ReminderStatus? status,
    List<Reminder>? reminders,
    String? errorMessage,
  }) {
    return ReminderState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reminders, errorMessage];
}
