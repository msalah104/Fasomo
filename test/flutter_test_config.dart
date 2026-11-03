import 'dart:async';

import 'package:fasomo/core/presentation/numerals.dart';

/// Runs before every test file, so tests format numbers like the app does.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  pinWesternDigits();
  await testMain();
}
