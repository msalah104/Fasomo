import 'dart:developer' as developer;

/// Local-only diagnostics. Boundaries log the original error and stack here
/// before converting it into a typed failure.
abstract final class AppLog {
  static void error(String event, Object error, StackTrace stackTrace) {
    developer.log(
      event,
      name: 'fasomo',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
