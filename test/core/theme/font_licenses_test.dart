import 'dart:convert';

import 'package:fasomo/core/theme/app_fonts.dart';
import 'package:fasomo/core/theme/font_licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(LicenseRegistry.reset);

  test('each bundled font licence reaches the licence page', () async {
    LicenseRegistry.reset();
    registerFontLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    final packages = entries.expand((e) => e.packages).toSet();

    expect(packages, containsAll(AppFonts.licenseAssets.keys));
    for (final entry in entries) {
      final text = entry.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('SIL Open Font License'));
    }
  });

  test('pubspec declares both families with four weights each', () async {
    final manifest = jsonDecode(
      await rootBundle.loadString('FontManifest.json'),
    ) as List<dynamic>;
    final families = {
      for (final family in manifest.cast<Map<String, dynamic>>())
        family['family'] as String: (family['fonts'] as List<dynamic>).length,
    };

    expect(families[AppFonts.heading], 4);
    expect(families[AppFonts.body], 4);
  });
}
