part of 'reminder_bloc.dart';

enum ReminderStatus { initial, loading, success, error }

class ReminderState extends Equatable {
  const new({
    this.status = ReminderStatus.initial,
    this.reminders = const [],
    this.failure,
    this.permissionDenied = false,
  });

  final ReminderStatus status;
  final List<Reminder> reminders;

  /// The failure from the latest operation, if any. With
  /// [ReminderStatus.error] the reminders could not be loaded at all;
  /// otherwise it is a one-off problem shown as a message.
  final Failure? failure;

  /// The user declined notification permission for an enabled reminder.
  final bool permissionDenied;

  bool isEnabledFor(FastingType type) =>
      reminders.any((r) => r.fastingType == type && r.isEnabled);

  /// [failure] and [permissionDenied] describe one emission only, so they
  /// reset unless passed again.
  ReminderState copyWith({
    ReminderStatus? status,
    List<Reminder>? reminders,
    Failure? failure,
    bool permissionDenied = false,
  }) {
    return ReminderState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      failure: failure,
      permissionDenied: permissionDenied,
    );
  }

  @override
  List<Object?> get props => [status, reminders, failure, permissionDenied];
}
