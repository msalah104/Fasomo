/// Base of every recoverable failure. A failure carries a stable [code] and
/// typed parameters only; the presentation layer turns the code into a
/// localized message.
sealed class Failure {
  const new();

  String get code;
}

/// Failures from Hijri calendar computation.
sealed class CalendarFailure extends Failure {
  const new();
}

/// The requested date is outside the Umm al-Qura table the app ships with.
final class CalendarOutOfRange extends CalendarFailure {
  const new({required this.minHijriYear, required this.maxHijriYear});

  final int minHijriYear;
  final int maxHijriYear;

  @override
  String get code => 'calendar.out_of_range';
}

/// Failures from on-device key/value storage.
sealed class StorageFailure extends Failure {
  const new();
}

/// Stored data could not be read or decoded.
final class StorageReadFailed extends StorageFailure {
  const new(this.key);

  final String key;

  @override
  String get code => 'storage.read_failed';
}

/// Data could not be written to storage.
final class StorageWriteFailed extends StorageFailure {
  const new(this.key);

  final String key;

  @override
  String get code => 'storage.write_failed';
}

/// A day that the fasting log does not accept.
sealed class TrackerFailure extends Failure {
  const new();
}

/// The day has not happened yet.
final class FutureDayNotLoggable extends TrackerFailure {
  const new();

  @override
  String get code => 'tracker.future_day';
}

/// Fasting is forbidden on the day (an Eid or a day of Tashreeq).
final class ForbiddenDayNotLoggable extends TrackerFailure {
  const new();

  @override
  String get code => 'tracker.forbidden_day';
}

/// A make-up fast cannot fall in Ramadan, whose own fast is obligatory.
final class RamadanDayNotMakeUp extends TrackerFailure {
  const new();

  @override
  String get code => 'tracker.ramadan_make_up';
}

/// Only a Ramadan day can be marked as missed and owed.
final class NotARamadanDay extends TrackerFailure {
  const new();

  @override
  String get code => 'tracker.not_ramadan';
}

/// Failures from the OS notification scheduler.
sealed class NotificationFailure extends Failure {
  const new();
}

/// The platform rejected a schedule, cancel or query call.
final class NotificationPlatformFailed extends NotificationFailure {
  const new(this.operation);

  /// `schedule`, `cancel`, `cancelAll`, `getPending` or `preview`.
  final String operation;

  @override
  String get code => 'notification.platform_failed';
}

/// Failures from the remote push service.
sealed class PushFailure extends Failure {
  const new();
}

/// The push service rejected or could not complete a topic change, e.g.
/// while offline or before iOS has issued an APNs token.
final class PushTopicFailed extends PushFailure {
  const new(this.topic);

  final String topic;

  @override
  String get code => 'push.topic_failed';
}

/// Failures while sharing an image through the OS share sheet.
sealed class ShareFailure extends Failure {
  const new();
}

/// The image to share could not be drawn or encoded.
final class ShareRenderFailed extends ShareFailure {
  const new();

  @override
  String get code => 'share.render_failed';
}

/// The OS share sheet could not be opened, or rejected the file.
final class SharePlatformFailed extends ShareFailure {
  const new();

  @override
  String get code => 'share.platform_failed';
}

/// Failures getting a fix from the device's location service.
sealed class LocationFailure extends Failure {
  const new();
}

/// The user refused location permission. When [permanently], the system no
/// longer asks, so only the app's system settings can grant it.
final class LocationPermissionDenied extends LocationFailure {
  const new({required this.permanently});

  final bool permanently;

  @override
  String get code => permanently
      ? 'location.permission_denied_forever'
      : 'location.permission_denied';
}

/// Location services are switched off for the whole device.
final class LocationServiceDisabled extends LocationFailure {
  const new();

  @override
  String get code => 'location.service_disabled';
}

/// No fix arrived in time and the device has no recent one.
final class LocationUnavailable extends LocationFailure {
  const new();

  @override
  String get code => 'location.unavailable';
}

/// Failures from the home-screen widget bridge.
sealed class HomeWidgetFailure extends Failure {
  const new();
}

/// The platform rejected saving the widget's data or redrawing it.
final class HomeWidgetPlatformFailed extends HomeWidgetFailure {
  const new(this.operation);

  /// `setAppGroupId`, `save`, `update` or `schedule`.
  final String operation;

  @override
  String get code => 'home_widget.platform_failed';
}
