import 'package:flutter/foundation.dart';

/// Local-only diagnostics. Boundaries log the original error and stack here
/// before converting it into a typed failure.
///
/// Each entry is printed once, so it shows in logcat (as
/// `I/flutter … [fasomo] event: …`), the Xcode console and the IDE's run
/// console alike. Nothing is sent anywhere.
abstract final class AppLog {
  /// A step worth seeing when diagnosing, e.g. each stage of a location
  /// request.
  static void info(String event, String message) =>
      debugPrint('[fasomo] $event: $message');

  static void error(String event, Object error, StackTrace stackTrace) {
    debugPrint('[fasomo] $event failed: $error');
    debugPrintStack(stackTrace: stackTrace, label: '[fasomo] $event');
  }
}
