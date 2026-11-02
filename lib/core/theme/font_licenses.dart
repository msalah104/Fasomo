import 'package:fasomo/core/theme/app_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the bundled fonts' OFL licences to the app's licence page.
///
/// Only a collector is registered here; the licence files are read from
/// [bundle] (the root bundle by default) when the licence page asks for them,
/// so this never delays the first frame.
void registerFontLicenses({AssetBundle? bundle}) {
  final assets = bundle ?? rootBundle;
  LicenseRegistry.addLicense(() => _fontLicenses(assets));
}

Stream<LicenseEntry> _fontLicenses(AssetBundle bundle) async* {
  for (final MapEntry(key: family, value: path)
      in AppFonts.licenseAssets.entries) {
    final text = await bundle.loadString(path);
    yield LicenseEntryWithLineBreaks([family], text);
  }
}
