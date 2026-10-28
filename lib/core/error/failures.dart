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
