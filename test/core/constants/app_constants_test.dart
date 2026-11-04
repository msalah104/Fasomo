import 'dart:io';

import 'package:fasomo/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('appVersion matches the version name in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version: (\d+\.\d+\.\d+)\+\d+$',
      multiLine: true,
    ).firstMatch(pubspec)?.group(1);

    expect(AppConstants.appVersion, version);
  });
}
