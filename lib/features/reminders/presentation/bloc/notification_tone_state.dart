part of 'notification_tone_bloc.dart';

class NotificationToneState extends Equatable {
  const new({
    required this.tone,
    this.failure,
    this.permissionDenied = false,
  });

  /// The saved reminder sound.
  final NotificationTone tone;

  /// Set for one emission when a choice could not be saved
  /// ([StorageFailure]) or a preview could not be shown
  /// ([NotificationFailure]).
  final Failure? failure;

  /// Set for one emission when a preview needed notification permission
  /// and the user declined it.
  final bool permissionDenied;

  @override
  List<Object?> get props => [tone, failure, permissionDenied];
}
