part of 'notification_tone_bloc.dart';

sealed class NotificationToneEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The user chose another reminder sound.
final class NotificationToneChanged extends NotificationToneEvent {
  const new(this.tone);

  final NotificationTone tone;

  @override
  List<Object> get props => [tone];
}

/// The user wants to hear [tone]: it is shown as a notification now, with
/// the localized [title] and [body].
final class NotificationTonePreviewRequested extends NotificationToneEvent {
  const new(this.tone, {required this.title, required this.body});

  final NotificationTone tone;
  final String title;
  final String body;

  @override
  List<Object> get props => [tone, title, body];
}
