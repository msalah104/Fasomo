part of 'tracker_bloc.dart';

enum TrackerStatus { initial, loading, success, error }

class TrackerState extends Equatable {
  const new({
    this.status = TrackerStatus.initial,
    this.summary = FastLogSummary.empty,
    this.qadaReminders = QadaReminderSettings.defaults,
    this.qadaPace,
    this.failure,
  });

  final TrackerStatus status;
  final FastLogSummary summary;
  final QadaReminderSettings qadaReminders;

  /// The suggested make-up pace for [summary]; `null` when nothing is owed
  /// or the next Ramadan is outside the supported calendar.
  final QadaPace? qadaPace;

  /// The failure from the latest operation, if any. With
  /// [TrackerStatus.error] the log could not be read at all; otherwise it is
  /// a one-off problem shown as a message.
  final Failure? failure;

  bool isFasted(DateTime date) => summary.isFasted(date);

  /// [failure] describes one emission only, so it resets unless passed again.
  TrackerState copyWith({
    TrackerStatus? status,
    FastLogSummary? summary,
    QadaReminderSettings? qadaReminders,
    Failure? failure,
  }) {
    return TrackerState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      qadaReminders: qadaReminders ?? this.qadaReminders,
      qadaPace: qadaPace,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    summary,
    qadaReminders,
    qadaPace,
    failure,
  ];
}
